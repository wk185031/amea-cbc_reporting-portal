package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class Finacle360 extends CsvReportProcessor {
	
	private final Logger logger = LoggerFactory.getLogger(Finacle360.class);
	
	private static final String CBC_BANK_NAME = "CBC01";
	private static final String CBS_BANK_NAME = "CBC02";

	@Override
	public void processCsvRecord(ReportGenerationMgr rgm) throws ReportGenerationException {
		logger.debug("In Finacle360.processCsvRecord()");
		File file = null;
		String fileLocation = rgm.getFileLocation();
		this.setEncryptionService(rgm.getEncryptionService());
		String fileName = "";

		try {
			String fileTxnDate = rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));

            fileName = "ATM_CBC01_CRDUPL_360" + "_" + fileTxnDate + "_" + "001" + ReportConstants.CSV_FORMAT;

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}

					file = new File(rgm.getFileLocation() + fileName);
					execute(rgm, file);
					logger.debug("Write file to : {}", file.getAbsolutePath());
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception("Errors when generating " + fileName);
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + fileName, e);
			throw new ReportGenerationException("Errors when generating " + fileName, e);
		}
	}
	
	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
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

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In Finacle360.preProcessing()");
		
		// replace {From_Date}/{To_Date}/{DCMS_Schema}/{Iss_Name}/{Iss_Id} to actual value
		rgm.setBodyQuery(rgm.getBodyQuery()
				.replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
	            .replace("{" + ReportConstants.PARAM_TO_DATE + "}", "'" + rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
				.replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA+ "}", rgm.getDcmsDbSchema())
				.replace("{" + ReportConstants.PARAM_DB_LINK_DCMS + "}", rgm.getDbLink())
				.replace("{" + ReportConstants.PARAM_ISSUER_NAME+ "}", rgm.getInstitution().equals("CBC") ? CBC_BANK_NAME : CBS_BANK_NAME)
				.replace("{" + ReportConstants.PARAM_ISSUER_ID+ "}", rgm.getInstitution().equals("CBC") ? ReportConstants.DCMS_CBC_INSTITUTION : ReportConstants.DCMS_CBS_INSTITUTION));
		
		addBatchPreProcessingFieldsToGlobalMap(rgm);
	}
	
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			line.append(getFieldValue(rgm, field, fieldsMap));
			line.append(field.getDelimiter());
			if (field.isEol()) {
				line.append(getEol());
			}
		}

		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CsvReportProcessor.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if(field.isEol()) {
				line.append(getFieldValue(rgm, field, null));
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				line.append(getFieldValue(rgm, field, null));
				line.append(field.getDelimiter());
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}
}
