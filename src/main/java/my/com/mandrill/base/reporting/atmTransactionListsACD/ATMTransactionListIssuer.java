package my.com.mandrill.base.reporting.atmTransactionListsACD;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class ATMTransactionListIssuer extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ATMTransactionListIssuer.class);

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String bankCode = null;
		String bankName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			writeHeader(rgm);
			for (SortedMap.Entry<String, String> bankCodeMap : filterCriteriaByBank(rgm).entrySet()) {
				bankCode = bankCodeMap.getKey();
				bankName = bankCodeMap.getValue();
				StringBuilder line = new StringBuilder();
				line.append(ReportConstants.ACQUIRER_BANK + ": ").append(";").append(bankName).append(";");
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
				preProcessing(rgm, bankCode);
				writeBodyHeader(rgm);
				executeBodyQuery(rgm);
				line = new StringBuilder();
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
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
		logger.debug("In ATMTransactionListIssuer.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_ISSUER_NAME + "}", "AND TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"));
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_MNEM + "}", "AND CBA.CBA_MNEM != '" + rgm.getInstitution() + "'"));
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", ""));
			
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBankCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ATMTransactionListIssuer.preProcessing()");
		if (filterByBankCode != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING,
					"LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = LPAD('" + filterByBankCode + "', 10, '0')");
			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
		}
	}

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In ATMTransactionListIssuer.executeBodyQuery()");
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
	
	protected SortedMap<String, String> filterCriteriaByBank(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterCriteriaByBank()");
		String bankCode = null;
		String bankName = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter bank code: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.BANK_CODE_ACQ)) {
								bankCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BANK_NAME_ACQ)) {
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
}
