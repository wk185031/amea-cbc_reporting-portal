package my.com.mandrill.base.reporting.bartsFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class TransactionCountReport extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(TransactionCountReport.class);

	@Override
	public void processTxtRecord(ReportGenerationMgr rgm) {
		logger.debug("In TransactionCountReport.processTxtRecord()");
		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();

		try {
			if (rgm.isGenerate() == true) {
				txnDate = rgm.getFileDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_04));
			} else {
				txnDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_04));
			}

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}
					file = new File(
							rgm.getFileLocation() + rgm.getFileNamePrefix() + txnDate + ReportConstants.TXT_FORMAT);
					execute(rgm, file);
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception(
						"Errors when generating " + rgm.getFileNamePrefix() + txnDate + ReportConstants.TXT_FORMAT);
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + txnDate + ReportConstants.TXT_FORMAT, e);
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addBatchPreProcessingFieldsToGlobalMap(rgm);
			executeBodyQuery(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException e) {
			rgm.errors++;
			logger.error("Error in generating TXT file", e);
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
	
	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In ATMTransactionListOnUsAcquirer.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String txnQualifier = null;
		boolean hasCashDispensedAmount = false;
		boolean hasDepositAmount = false;
		boolean hasBillPaymentAmount = false;
		boolean hasTransferAmount = false;
		
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);

				while (rs.next()) {
					new StringBuffer();
					hasCashDispensedAmount = false;
					hasDepositAmount = false;
					hasBillPaymentAmount = false;
					hasTransferAmount = false;
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
							} else if (key.equalsIgnoreCase(ReportConstants.CASH_DISPENSED_AMOUNT)) {
								if(!result.toString().equals("0") && txnQualifier.equals("R")) {
									hasCashDispensedAmount = true;
								}
								field.setValue(result.toString());
							} else if (key.equalsIgnoreCase(ReportConstants.DEPOSITS_AMOUNT)) {
								if(!result.toString().equals("0")) {
									hasDepositAmount = true;
								}
								field.setValue(result.toString());
							} else if (key.equalsIgnoreCase(ReportConstants.BILL_PAYMENTS_AMOUNT)) {
								if(!result.toString().equals("0")) {
									hasBillPaymentAmount = true;
								}
								field.setValue(result.toString());
							} else if (key.equalsIgnoreCase(ReportConstants.TRANSFERS_AMOUNT)) {
								if(!result.toString().equals("0")) {
									hasTransferAmount = true;
								}
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					
					if(!hasCashDispensedAmount || txnQualifier.equals("F")) {
						lineFieldsMap.get(ReportConstants.REVERSAL_SIGN_CD).setValue("");
					} 
					if (!hasDepositAmount || txnQualifier.equals("F")) {
						lineFieldsMap.get(ReportConstants.REVERSAL_SIGN_DP).setValue("");
					} 
					if (!hasBillPaymentAmount || txnQualifier.equals("F")) {
						lineFieldsMap.get(ReportConstants.REVERSAL_SIGN_BP).setValue("");
					}
					if (!hasTransferAmount || txnQualifier.equals("F")) {
						lineFieldsMap.get(ReportConstants.REVERSAL_SIGN_TRFR).setValue("");
					} 
					
					writeBody(rgm, lineFieldsMap);
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
	
	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.isEol()) {
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(getEol());
			} else {
				line.append(getFieldValue(rgm, field, fieldsMap));
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}
}
