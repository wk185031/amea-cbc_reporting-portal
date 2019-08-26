package my.com.mandrill.base.reporting.eloadTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;
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
import my.com.mandrill.base.reporting.reportProcessor.IbftReportProcessor;

public class ApprovedEloadOnUsTransactions extends IbftReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ApprovedEloadOnUsTransactions.class);
	private int pagination = 0;
	private int totalCount = 0;
	private double grandTotal = 0.00;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			separateQuery(rgm);

			pagination++;
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm, pagination);
			processingDetails(rgm);

			pagination++;
			addReportPreProcessingFieldsToGlobalMap(rgm);
			processingSummaryDetails(rgm, pagination);

			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException e) {
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
		logger.debug("In ApprovedEloadOnUsTransactions.processingDetails()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		try {
			rgm.setBodyQuery(getCriteriaQuery());
			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						StringBuilder line = new StringBuilder();
						line.append("BRANCH: ").append(";").append(branchCode + " ").append(";")
								.append(branchName + " ").append(";");
						line.append(getEol());
						line.append("TERM: ").append(";").append(terminal + " ").append(";").append(location + " ")
								.append(";");
						line.append(getEol());
						rgm.writeLine(line.toString().getBytes());
						writeBodyHeader(rgm);
						rgm.setBodyQuery(getTxnBodyQuery());
						rgm.setTrailerQuery(getTxnTrailerQuery());
						preProcessing(rgm, branchCode, terminal);
						executeBodyQuery(rgm, false, location);
						executeTrailerQuery(rgm, false);
					}
				}
			}
			DecimalFormat formatter = new DecimalFormat("#,##0.00");
			StringBuilder line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append("GRAND TOTAL : ").append(";").append(totalCount)
					.append(";").append("AMOUNT : ").append(";").append(formatter.format(grandTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in processingDetails", e);
		}
	}

	private void processingSummaryDetails(ReportGenerationMgr rgm, int pagination) {
		logger.debug("In ApprovedEloadOnUsTransactions.processingSummaryDetails()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		try {
			writeSummaryHeader(rgm, pagination);
			writeSummaryBodyHeader(rgm);

			rgm.setBodyQuery(getCriteriaQuery());
			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					StringBuilder line = new StringBuilder();
					line.append(branchCode).append(";").append(";").append(branchName).append(";");
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						rgm.setBodyQuery(getSummaryBodyQuery());
						preProcessing(rgm, branchCode, terminal);
						executeBodyQuery(rgm, true, location);
					}
				}
			}
			rgm.setTrailerQuery(getSummaryTrailerQuery());
			executeTrailerQuery(rgm, true);
			StringBuilder line = new StringBuilder();
			line.append("*** END OF REPORT ***");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in processingSummaryDetails", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedEloadOnUsTransactions.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setTxnBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCriteriaQuery(getTxnBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
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
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ApprovedEloadOnUsTransactions.preProcessing()");
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
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In ApprovedEloadOnUsTransactions.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
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

	private void writeSummaryBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In ApprovedEloadOnUsTransactions.writeSummaryBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 28:
			case 29:
			case 30:
			case 31:
			case 32:
			case 33:
			case 34:
			case 35:
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
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			switch (field.getSequence()) {
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
			case 24:
			case 25:
			case 26:
			case 27:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeSummaryBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String location)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 36:
			case 37:
			case 38:
			case 39:
			case 40:
				if (!field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
						line.append(location);
					} else {
						line.append(getFieldValue(rgm, field, fieldsMap));
					}
				} else {
					line.append("");
				}
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In ApprovedEloadOnUsTransactions.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
				break;
			default:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL)) {
						if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
							grandTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
						} else {
							grandTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
						}
					}
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_TRAN)) {
						if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
							totalCount += Integer.parseInt(getFieldValue(field, fieldsMap).replace(",", ""));
						} else {
							totalCount += Integer.parseInt(getFieldValue(field, fieldsMap));
						}
					}
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeSummaryTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In ApprovedEloadOnUsTransactions.writeSummaryTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
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
}
