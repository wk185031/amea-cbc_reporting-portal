package my.com.mandrill.base.reporting.atmWithdrawalTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.SortedMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class AtmWithdrawalIssuerBank extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(AtmWithdrawalIssuerBank.class);

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String bankCode = null;
		String bankName = null;
		boolean isRecordsExist = false;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			writeHeader(rgm);
			for (SortedMap.Entry<String, String> bankCodeMap : filterCriteriaByBank(rgm).entrySet()) {
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
				line = new StringBuilder();
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
				isRecordsExist = true;
			}
			
			if (!isRecordsExist) {
				writeEmptyBody(rgm);
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
		logger.debug("In AtmWithdrawalIssuerBank.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_ISSUER_NAME + "}", "AND TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"));
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBankCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmWithdrawalIssuerBank.preProcessing()");
		if (filterByBankCode != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING,
					"LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = LPAD('" + filterByBankCode + "', 10, '0')");
			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
		}
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String txnQualifier, String voidCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			switch (field.getFieldName()) {
			case ReportConstants.DR_AMOUNT:
			case ReportConstants.CR_AMOUNT:
				if (!voidCode.equals("0")) {
					line.append("");
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
				}
				line.append(field.getDelimiter());
				break;
			case ReportConstants.COMMENT:
				if (!getFieldValue(rgm, field, fieldsMap).equalsIgnoreCase(ReportConstants.APPROVED)) {
					line.append(getFieldValue(rgm, field, fieldsMap));
				} else if (txnQualifier.equals("R")
						&& getFieldValue(rgm, field, fieldsMap).equalsIgnoreCase(ReportConstants.APPROVED)) {
					line.append(ReportConstants.FULL_REVERSAL);
				} else {
					line.append("");
				}
				line.append(field.getDelimiter());
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
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
