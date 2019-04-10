package my.com.mandrill.base.reporting.glHandoffFiles;

import java.io.IOException;
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

	@Override
	public void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
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

	@Override
	protected void addPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
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

	@Override
	protected void addPostProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		ReportGenerationFields noOfRecords = new ReportGenerationFields(ReportConstants.NO_OF_DATA_RECORDS,
				ReportGenerationFields.TYPE_NUMBER, Integer.toString((rgm.getSuccess())));
		getGlobalFileFieldsMap().put(noOfRecords.getFieldName(), noOfRecords);
	}

	@Override
	public void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		addPreProcessingFieldsToGlobalMap(rgm);
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (getGlobalFieldValue(field, true) == null) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
			} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
				line.append(String.format("%-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true))
						.replace(' ', '0'));
			} else {
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	public void writeBodyLine(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
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

	@Override
	public void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException {
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
}
