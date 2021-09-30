package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
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
import my.com.mandrill.base.reporting.reportProcessor.MovingCashReportProcessor;

public class ListMovingCashTransactions extends MovingCashReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ListMovingCashTransactions.class);
	private int pagination = 0;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			separateQuery(rgm);
			processingDetails(rgm);
			processingPendingDetails(rgm);
			processingSummaryDetails(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException e) {
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

	private void processingDetails(ReportGenerationMgr rgm) {
		logger.debug("In ListMovingCashTransactions.processingDetails()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		pagination++;
		try {
			preProcessing(rgm);
			writeHeader(rgm, pagination);

			StringBuilder line = new StringBuilder();
			line.append("PAY TO MOBILE TRANSACTIONS").append(";");
			line.append(getEol());
			line.append("MODE : ").append(";").append(ReportConstants.ATM).append(";").append("WITHDRAWAL").append(";");
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
						rgm.setBodyQuery(getTxnBodyQuery());
						rgm.setTrailerQuery(getTxnTrailerQuery());
						preProcessing(rgm, branchCode, terminal);
						line = new StringBuilder();
						line.append(ReportConstants.TERMINAL + " : ").append(";").append(terminal).append(";")
								.append(location).append(";");
						line.append(getEol());
						rgm.writeLine(line.toString().getBytes());
						writeBodyHeader(rgm);
						executeBodyQuery(rgm, false);
						line = new StringBuilder();
						line.append(getEol());
						rgm.writeLine(line.toString().getBytes());
					}
					executeTrailerQuery(rgm, false);
				}
			}
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in processingDetails", e);
		}
	}

	private void processingPendingDetails(ReportGenerationMgr rgm) {
		logger.debug("In ListMovingCashTransactions.processingPendingDetails()");

		try {
			
			pagination++;
			writePendingSectionHeader(rgm, pagination);

			StringBuilder line = new StringBuilder();
			line.append("PAY TO MOBILE TRANSACTIONS").append(";");
			line.append(getEol());
			line.append("MODE : ").append(";").append(ReportConstants.ATM).append(";").append("WITHDRAWAL").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());

			writeBodyHeader(rgm);

			rgm.setBodyQuery(getPendingTxnQuery());
			executeBodyQuery(rgm, false);
			
			rgm.setTrailerQuery(getPendingTrailerQuery());
			executeTrailerQuery(rgm, false);

		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in processingPendingDetails", e);
		}
	}

	private void processingSummaryDetails(ReportGenerationMgr rgm) {
		logger.debug("In ListMovingCashTransactions.processingSummaryDetails()");
		pagination++;
		try {
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeSummaryHeader(rgm, pagination);
			writeSummaryBodyHeader(rgm);
			rgm.setBodyQuery(getSummaryBodyQuery());
			rgm.setTrailerQuery(getSummaryTrailerQuery());
			executeBodyQuery(rgm, true);
			executeTrailerQuery(rgm, true);
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in processingSummaryDetails", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In ListMovingCashTransactions.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setTxnBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setPendingTxnQuery(getTxnBodyQuery()
					.replace("(TXN.TRL_TQU_ID IN ('F') OR (TXN.TRL_TQU_ID = 'R' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))",
					" TXN.TRL_TQU_ID = 'A'")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}

		if (rgm.getTrailerQuery() != null) {
			setTxnTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setPendingTrailerQuery(getTxnTrailerQuery().replace("AND TXN.TRL_TQU_ID = 'F'", " AND TXN.TRL_TQU_ID = 'A' ")
					.replace("AND NVL(TXN.TRL_POST_COMPLETION_CODE, 'O') != 'R'", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ListMovingCashTransactions.preProcessing()");
		rgm.setBodyQuery(getTxnBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
				.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ListMovingCashTransactions.preProcessing()");
		if (filterByBranchCode != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null) {
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(AST.AST_TERMINAL_ID, -4) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}

	@Override
	protected void writeSummaryBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In ListMovingCashTransactions.writeSummaryBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 27:
			case 28:
			case 29:
			case 30:
			case 31:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			default:
				break;
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeSummaryBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 32:
			case 33:
			case 34:
			case 35:
			case 36:
			case 37:
			case 38:
			case 39:
			case 40:
			case 41:
				if (field.isEol()) {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
				}
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
	
	private void writePendingSectionHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In MovingCashReportProcessor.writePendingSectionHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 3:
			case 4:
				break;
			default:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
						line.append(String.valueOf(pagination));
					} else {
						line.append(getGlobalFieldValue(rgm, field));
					}
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}
