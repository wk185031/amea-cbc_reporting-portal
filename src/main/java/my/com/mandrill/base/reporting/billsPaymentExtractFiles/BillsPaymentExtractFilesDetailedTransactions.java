package my.com.mandrill.base.reporting.billsPaymentExtractFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class BillsPaymentExtractFilesDetailedTransactions extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(BillsPaymentExtractFilesDetailedTransactions.class);
	private int success = 0;
	private double totalPayments = 0.00;

	@Override
	public void processTxtRecord(ReportGenerationMgr rgm) {
		logger.debug("In BillsPaymentExtractFilesDetailedTransactions.processTxtRecord()");
		if (getEncryptionService() == null) {
			setEncryptionService(rgm.getEncryptionService());
		}

		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();

		try {
			if (rgm.isGenerate() == true) {
				txnDate = rgm.getFileDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_03));
			} else {
				txnDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_03));
			}

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}

					separateQuery(rgm);

					// Generate Cash card report
					file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + txnDate + "-cashCard"
							+ ReportConstants.DPS_FORMAT);

					setQuery(rgm, getCashCardBodyQuery(), getCashCardTrailerQuery());

					execute(rgm, file);

					// Generate ATM card report
					file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + txnDate + "-atmCard"
							+ ReportConstants.DPS_FORMAT);

					setQuery(rgm, getAtmCardBodyQuery(), getAtmCardTrailerQuery());

					execute(rgm, file);

					rgm.fileOutputStream.flush();
					rgm.fileOutputStream.close();

				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception(
						"Errors when generating" + rgm.getFileNamePrefix() + txnDate + ReportConstants.DPS_FORMAT);
			}

		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + txnDate + ReportConstants.DPS_FORMAT, e);

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
	protected void execute(ReportGenerationMgr rgm, File file) {
		
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addBatchPreProcessingFieldsToGlobalMap(rgm);
			executeBodyQuery(rgm);
			addPostProcessingFieldsToGlobalMap(rgm);
			executeTrailerQuery(rgm);
			
		} catch (IOException e) {
			rgm.errors++;
			logger.error("Error in generating TXT file", e);
		} 
	}

	private void addPostProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In BillsPaymentExtractFilesDetailedTransactions.addPostProcessingFieldsToGlobalMap()");
		ReportGenerationFields noOfRecords = new ReportGenerationFields(ReportConstants.NO_OF_DATA_RECORDS,
				ReportGenerationFields.TYPE_NUMBER, Integer.toString(success));
		getGlobalFileFieldsMap().put(noOfRecords.getFieldName(), noOfRecords);
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

			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
					|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.TRAN_AMOUNT)) {
					totalPayments += Double.parseDouble(getFieldValue(field, fieldsMap));
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap))
							.replace(' ', '0').concat("00"));
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap).replace(' ', '0'));
				}
			} else {
				line.append(getFieldValue(rgm, field, fieldsMap));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In BillsPaymentExtractFilesDetailedTransactions.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
					|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_PAYMENTS)) {
					if (String.valueOf(totalPayments).indexOf(".") != -1) {
						line.append(String.format("%" + field.getCsvTxtLength() + "s", totalPayments).replace(' ', '0')
								.replace(".", "0"));
					} else {
						line.append(
								String.format("%" + field.getCsvTxtLength() + "s", totalPayments).replace(' ', '0'));
					}
				} else {
					line.append(getGlobalFieldValue(rgm, field).replace(' ', '0'));
				}
			} else {
				line.append(getGlobalFieldValue(rgm, field));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
	
	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In BillsPaymentExtractFilesDetailedTransactions.separateQuery()");
		
		if (rgm.getBodyQuery() != null) {
			setCashCardBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setAtmCardBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
		
		if (rgm.getTrailerQuery() != null) {
			setCashCardTrailerQuery(rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setAtmCardTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
		
	}
	
	private void setQuery(ReportGenerationMgr rgm, String bodyQuery, String trailerQuery) {
		
		rgm.setBodyQuery(bodyQuery);
		rgm.setTrailerQuery(trailerQuery);
		
	}
}
