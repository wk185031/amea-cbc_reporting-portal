package my.com.mandrill.base.reporting.atmWithdrawalTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.GeneralReportProcess;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class AtmWithdrawalIssuerBank extends GeneralReportProcess {

	private final Logger logger = LoggerFactory.getLogger(AtmWithdrawalIssuerBank.class);
	private int pagination = 0;

	@Override
	public void processCsvTxtRecord(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalIssuerBank.processCsvTxtRecord()");
		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);

		try {
			if (rgm.isGenerate() == true) {
				txnDate = df.format(rgm.getFileDate());
			} else {
				txnDate = df.format(rgm.getYesterdayDate());
			}

			if (rgm.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_CSV)) {
				if (rgm.errors == 0) {
					if (fileLocation != null) {
						File directory = new File(fileLocation);
						if (!directory.exists()) {
							directory.mkdirs();
						}
						file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate
								+ ReportConstants.CSV_FORMAT);
						pagination = 1;
						execute(rgm, file);
					} else {
						throw new Exception("Path: " + fileLocation + " not configured.");
					}
				} else {
					throw new Exception("Errors when generating" + rgm.getFileNamePrefix() + "_" + txnDate
							+ ReportConstants.CSV_FORMAT);
				}
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.CSV_FORMAT,
					e);
		}
	}

	private void execute(ReportGenerationMgr rgm, File file) {
		StringBuilder breakLine = new StringBuilder();
		String bankCode = null;
		String bankName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			writeHeader(rgm);
			for (SortedMap.Entry<String, String> bankCodeMap : filterByCriteria(rgm).entrySet()) {
				bankCode = bankCodeMap.getKey();
				bankName = bankCodeMap.getValue();
				StringBuilder line = new StringBuilder();
				line.append(ReportConstants.ACQUIRER_BANK + ": ").append(";").append(bankCode + " ").append(";")
						.append(bankName).append(";");
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
				preProcessing(rgm, bankCode);
				writeBodyHeader(rgm);
				executeBodyQuery(rgm);
				breakLine.append(getEol());
				rgm.writeLine(breakLine.toString().getBytes());
			}
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in generating CSV/TXT file", e);
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

	private SortedMap<String, String> filterByCriteria(ReportGenerationMgr rgm) {
		logger.debug("In ATMTransactionListIssuer.filterByCriteria()");
		String bankCode = null;
		String bankName = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter criteria: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when getting result", e);
							continue;
						}
						if (result != null) {
							if (key.equalsIgnoreCase(ReportConstants.BANK_CODE)) {
								bankCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BANK_NAME)) {
								bankName = result.toString();
							}
						}
					}
					criteriaMap.put(bankCode, bankName);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the criteria", e);
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
		return criteriaMap;
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmWithdrawalIssuerBank.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", ""));
		}

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

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
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

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		}
		addPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBankCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmWithdrawalIssuerBank.preProcessing()");
		if (filterByBankCode != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING, "NVL(CBA.CBA_CODE, '0000') = '" + filterByBankCode + "'");
			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
		}
	}

	private void addPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalIssuerBank.addPreProcessingFieldsToGlobalMap()");
		ReportGenerationFields todaysDateValue = new ReportGenerationFields(ReportConstants.TODAYS_DATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields runDateValue = new ReportGenerationFields(ReportConstants.RUNDATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields timeValue = new ReportGenerationFields(ReportConstants.TIME_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));

		getGlobalFileFieldsMap().put(todaysDateValue.getFieldName(), todaysDateValue);
		getGlobalFileFieldsMap().put(runDateValue.getFieldName(), runDateValue);
		getGlobalFileFieldsMap().put(timeValue.getFieldName(), timeValue);

		if (rgm.isGenerate() == true) {
			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getTxnEndDate().getTime()));
			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
		} else {
			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getYesterdayDate().getTime()));
			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
		}
	}

	private void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmWithdrawalIssuerBank.writeHeader()");
		addPreProcessingFieldsToGlobalMap(rgm);
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					line.append(pagination);
					line.append(field.getDelimiter());
					line.append(getEol());
				} else if (getGlobalFieldValue(field, true) == null) {
					line.append("");
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(field, true));
					line.append(field.getDelimiter());
					line.append(getEol());
				}
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					line.append("");
					line.append(field.getDelimiter());
				} else {
					line.append(getGlobalFieldValue(field, true));
					line.append(field.getDelimiter());
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmWithdrawalIssuerBank.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			line.append(field.getFieldName());
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String txnQualifier, String voidCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.SEQ_NUMBER)
					|| field.getFieldName().equalsIgnoreCase(ReportConstants.TRACE_NUMBER)) {
				if (getFieldValue(field, fieldsMap, true).length() <= 6) {
					line.append(
							String.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0'));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.ACCOUNT)) {
				if (getFieldValue(field, fieldsMap, true).length() <= 16) {
					line.append(
							String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0'));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.DR_AMOUNT)
					|| field.getFieldName().equalsIgnoreCase(ReportConstants.CR_AMOUNT)) {
				if (!voidCode.equals("0")) {
					line.append("");
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.VOID_CODE)) {
				if (getFieldValue(field, fieldsMap, true).length() <= 3) {
					line.append(
							String.format("%1$" + 3 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0'));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.COMMENT)) {
				if (!getFieldValue(field, fieldsMap, true).equalsIgnoreCase(ReportConstants.APPROVED)) {
					line.append(getFieldValue(field, fieldsMap, true));
				} else if (txnQualifier.equals("R")
						&& getFieldValue(field, fieldsMap, true).equalsIgnoreCase(ReportConstants.APPROVED)) {
					line.append(ReportConstants.FULL_REVERSAL);
				} else {
					line.append("");
				}
				line.append(field.getDelimiter());
			} else if (getFieldValue(field, fieldsMap, true) == null) {
				line.append("");
				line.append(field.getDelimiter());
			} else {
				line.append(getFieldValue(field, fieldsMap, true));
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalIssuerBank.executeBodyQuery()");
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
