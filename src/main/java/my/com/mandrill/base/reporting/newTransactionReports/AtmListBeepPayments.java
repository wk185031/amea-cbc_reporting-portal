package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class AtmListBeepPayments extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(AtmListBeepPayments.class);
	private int pagination = 0;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		
		try {
			
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination++;
			writeHeader(rgm, pagination);
			
			separateQuery(rgm);
			
			rgm.setBodyQuery(getOnusBodyQuery());
			rgm.setTrailerQuery(getOnusTrailerQuery());
			
			preProcessing(rgm);			
			processReport(rgm, "ON-US TRANSACTIONS");
			
			rgm.setBodyQuery(getInterEntityBodyQuery());
			rgm.setTrailerQuery(getInterEntityTrailerQuery());
			
			preProcessing(rgm);			
			processReport(rgm, "INTER-ENTITY TRANSACTIONS");
			
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in generating CSV file", e);
		} finally {
			try {
				if (rgm.fileOutputStream != null) {
					rgm.fileOutputStream.close();
					rgm.exit();
				}
			} catch (IOException e) {
				rgm.errors++;
				logger.error("Error in closing fileOutputStream", e);
			}
		}
	}
	private void processReport(ReportGenerationMgr rgm, String categoryHeader) {
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		StringBuilder line = new StringBuilder();

		line.append(categoryHeader);
		line.append(getEol());
		
		try {
			line.append(ReportConstants.CHANNEL + " : ").append(";").append(ReportConstants.ATM).append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());

			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					line = new StringBuilder();
					line.append(ReportConstants.BRANCH + " : ").append(";").append(branchCode).append(";")
							.append(branchName).append(";");
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						preProcessing(rgm, branchCode, terminal,branchName);
						line = new StringBuilder();
						line.append(ReportConstants.TERMINAL + " : ").append(";").append(terminal).append(";")
								.append(location).append(";");
						line.append(getEol());
						rgm.writeLine(line.toString().getBytes());
						writeBodyHeader(rgm);
						executeBodyQuery(rgm);
						line = new StringBuilder();
						line.append(getEol());
						rgm.writeLine(line.toString().getBytes());
					}
					executeTrailerQuery(rgm);
				}
			}
			
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in generating CSV file", e);
		} 
	}
	
	
	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In ListRfidPayments.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setOnusBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setInterEntityBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
		if (rgm.getTrailerQuery() != null) {
			setOnusTrailerQuery(rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setInterEntityTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}
	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmListBeepPayments.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_NAME + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal, String filterByBranchName)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmListBeepPayments.preProcessing()");
		if (filterByBranchCode != null && filterByTerminal != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(AST.AST_TERMINAL_ID, -4) = '" + filterByTerminal + "'");
			ReportGenerationFields branchName = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_NAME,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_NAME = '" + filterByBranchName + "'");

			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			getGlobalFileFieldsMap().put(branchName.getFieldName(), branchName);
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}
	@Override
	protected void writeHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In DailySummaryRfidChannelPayments.writeRetailHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 4:
			case 16:
				break;
			default:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
						line.append(String.valueOf(pagination));
					}else {
					line.append(getGlobalFieldValue(rgm, field));
					}
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}
