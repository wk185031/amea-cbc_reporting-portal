package my.com.mandrill.base.reporting.atmTransactionListsACD;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class ATMTransactionListOnUsAcquirer extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ATMTransactionListOnUsAcquirer.class);

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		StringBuilder breakLine = new StringBuilder();
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			writeHeader(rgm);
			for (SortedMap.Entry<String, Map<String, Map<String, Set<String>>>> branchCodeMap : filterByCriteria(rgm)
					.entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, Map<String, Set<String>>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, terminal);
					for (SortedMap.Entry<String, Set<String>> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						for (String locationList : terminalMap.getValue()) {
							StringBuilder line = new StringBuilder();
							location = locationList;
							line.append(branchName).append(";");
							line.append(getEol());
							line.append(ReportConstants.TERMINAL + " " + terminal + " AT " + location).append(";");
							line.append(getEol());
							rgm.writeLine(line.toString().getBytes());
							writeBodyHeader(rgm);
							preProcessing(rgm, branchCode, terminal);
							executeBodyQuery(rgm);
						}
					}
				}
				breakLine.append(getEol());
				rgm.writeLine(breakLine.toString().getBytes());
			}
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
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

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ATMTransactionListOnUsAcquirer.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ATMTransactionListOnUsAcquirer.preProcessing()");
		if (filterByBranchCode != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "TRIM(AST.AST_TERMINAL_ID) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}

	@Override
	protected void addReportPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In ATMTransactionListOnUsAcquirer.addPreProcessingFieldsToGlobalMap()");
		ReportGenerationFields runDateValue = new ReportGenerationFields(ReportConstants.RUNDATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields timeValue = new ReportGenerationFields(ReportConstants.TIME_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));

		getGlobalFileFieldsMap().put(runDateValue.getFieldName(), runDateValue);
		getGlobalFileFieldsMap().put(timeValue.getFieldName(), timeValue);

		if (rgm.isGenerate() == true) {
			String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnStartDate())
					.concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnEndDate()).concat(" ")
					.concat(ReportConstants.END_TIME);

			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");
			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getTxnEndDate().getTime()));

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
		} else {
			String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getYesterdayDate())
					.concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTodayDate()).concat(" ")
					.concat(ReportConstants.END_TIME);

			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");
			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getYesterdayDate().getTime()));

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
		}
	}

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In ATMTransactionListOnUsAcquirer.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String txnQualifier = null;
		String voidCode = null;
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);

				while (rs.next()) {
					new StringBuffer();
					lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when trying to write a line", e);
							continue;
						}
						if (result != null) {
							if (result instanceof Date) {
								field.setValue(Long.toString(((Date) result).getTime()));
							} else if (result instanceof oracle.sql.TIMESTAMP) {
								field.setValue(
										Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
							} else if (result instanceof oracle.sql.DATE) {
								field.setValue(Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
							} else if (key.equalsIgnoreCase(ReportConstants.TXN_QUALIFIER)) {
								txnQualifier = result.toString();
								field.setValue(result.toString());
							} else if (key.equalsIgnoreCase(ReportConstants.VOID_CODE)) {
								voidCode = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap, txnQualifier, voidCode);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				try {
					ps.close();
					rs.close();
				} catch (SQLException e) {
					rgm.errors++;
					logger.error("Error closing DB resources", e);
				}
			}
		}
	}
}
