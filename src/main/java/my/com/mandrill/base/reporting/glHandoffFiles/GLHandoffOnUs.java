package my.com.mandrill.base.reporting.glHandoffFiles;

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

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.GeneralReportProcess;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class GLHandoffOnUs extends GeneralReportProcess {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffOnUs.class);
	private int success = 0;
	private int errors = 0;
	private int pagination = 0;

	public int getSuccess() {
		return success;
	}

	public void setSuccess(int success) {
		this.success = success;
	}

	public int getErrors() {
		return errors;
	}

	public void setErrors(int errors) {
		this.errors = errors;
	}

	public int getPagination() {
		return pagination;
	}

	public void setPagination(int pagination) {
		this.pagination = pagination;
	}

	@Override
	public void processCsvTxtRecord(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffOnUs.processCsvTxtRecord()");
		File file = null;
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
		String txnDate = df.format(rgm.getTxnEndDate());

		if (rgm.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_CSV)) {
			file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + "_" + "001"
					+ ReportConstants.CSV_FORMAT);
			execute(file, rgm);

		}
		if (rgm.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_TXT)) {
			file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + "_" + "001"
					+ ReportConstants.TXT_FORMAT);
			execute(file, rgm);

		}
	}

	private void execute(File file, ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffOnUs.execute()");
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			writeHeader(rgm);
			executeBodyQuery(rgm);
			postProcessing(rgm);
			writeTrailer(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			logger.error("Error in generating GL file", e);
		} finally {
			try {
				if (rgm.fileOutputStream != null) {
					rgm.fileOutputStream.close();
					rgm.exit();
				}
			} catch (IOException e) {
				logger.error("Error in closing fileOutputStream", e);
			}
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffOnUs.writePdfBody()");
		if (rgm.isGenerate() == true) {
			if (rgm.getTxnStartDate() != null && rgm.getTxnEndDate() != null) {
				String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnStartDate())
						+ " " + ReportConstants.START_TIME;
				String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnEndDate()) + " "
						+ ReportConstants.END_TIME;

				ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
						ReportGenerationFields.TYPE_STRING,
						"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
								+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
								+ ReportConstants.FORMAT_TXN_DATE + "')");

				getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
			} else {
				logger.debug("\t\t txnStartDate or txnEndDate is empty or null");
			}
		} else {
			// String ytdDate = new
			// SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(epm.getYesterdayDate()).concat("
			// ").concat(kftcStartTimePropertyValue);
			// String todayDate = new
			// SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(epm.getTodayDate()).concat("
			// ").concat(mepsEndTimePropertyValue);

			// Field dateField = new Field(ReportConstants.PARAM_TXN_DATE,
			// Field.TYPE_STRING, "TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + ytdDate + "', '"
			// + ReportConstants.FORMAT_TXN_DATE + "') AND TXN.TRL_SYSTEM_TIMESTAMP <
			// TO_DATE('" + todayDate + "','" + ReportConstants.FORMAT_TXN_DATE + "')");
			// getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		}
		addPreProcessingFieldsToGlobalMap(rgm);
		performPreProcessingTransformations(getGlobalFileFieldsMap());
	}

	private void addPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffOnUs.addPreProcessingFieldsToGlobalMap()");
		if (rgm.isGenerate() == true) {
			if (rgm.getTxnStartDate() != null && rgm.getTxnEndDate() != null) {
				SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
				String txnDate = df.format(rgm.getTxnEndDate());
				ReportGenerationFields fileUploadDate = new ReportGenerationFields(ReportConstants.FILE_UPLOAD_DATE,
						ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getTxnEndDate().getTime()));
				ReportGenerationFields fileName = new ReportGenerationFields(ReportConstants.FILE_NAME,
						ReportGenerationFields.TYPE_STRING,
						rgm.getFileNamePrefix() + "_" + txnDate + "_" + "001" + ReportConstants.TXT_FORMAT);
				getGlobalFileFieldsMap().put(fileUploadDate.getFieldName(), fileUploadDate);
				getGlobalFileFieldsMap().put(fileName.getFieldName(), fileName);
			} else {
				logger.debug("\t\t txnStartDate or txnEndDate is empty or null");
			}
		} else {
			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String txnDate = df.format(new Date());
			ReportGenerationFields fileUploadDate = new ReportGenerationFields(ReportConstants.FILE_UPLOAD_DATE,
					ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
			ReportGenerationFields fileName = new ReportGenerationFields(ReportConstants.FILE_NAME,
					ReportGenerationFields.TYPE_STRING,
					rgm.getFileNamePrefix() + "_" + txnDate + "_" + "001" + ReportConstants.TXT_FORMAT);
			getGlobalFileFieldsMap().put(fileUploadDate.getFieldName(), fileUploadDate);
			getGlobalFileFieldsMap().put(fileName.getFieldName(), fileName);
		}
	}

	private void postProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffOnUs.postProcessing()");
		addPostProcessingFieldsToGlobalMap(rgm);
		performPostProcessingTransformations(getGlobalFileFieldsMap());
	}

	private void addPostProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffOnUs.addPostProcessingFieldsToGlobalMap()");
		ReportGenerationFields noOfRecords = new ReportGenerationFields(ReportConstants.NO_OF_DATA_RECORDS,
				ReportGenerationFields.TYPE_NUMBER, Integer.toString((getSuccess())));
		getGlobalFileFieldsMap().put(noOfRecords.getFieldName(), noOfRecords);
	}

	private void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In GLHandoffOnUs.writeHeader()");
		addPreProcessingFieldsToGlobalMap(rgm);
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
				line.append(String.format("%-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true))
						.replace(' ', '0'));
			} else if (getGlobalFieldValue(field, true) == null) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
			} else {
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
					|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
				line.append(String.format("%" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap, true))
						.replace(' ', '0').replaceAll("null", "0000"));
			} else if (getFieldValue(field, fieldsMap, true) == null) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
			} else {
				line.append(
						String.format("%1$-" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap, true)));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In GLHandoffOnUs.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
					|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
				line.append(String.format("%" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true))
						.replace(' ', '0').replaceAll("null", "0000"));
			} else if (getGlobalFieldValue(field, true) == null) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
			} else {
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffOnUs.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
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
							errors++;
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
							} else {
								Class clazz = result.getClass();
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap);
					success++;
				}
			} catch (Exception e) {
				logger.error("Error trying to execute the body query", e);
			} finally {
				try {
					ps.close();
					rs.close();
				} catch (SQLException e) {
					logger.error("Error closing DB resources", e);
				}
			}
		}
	}
}
