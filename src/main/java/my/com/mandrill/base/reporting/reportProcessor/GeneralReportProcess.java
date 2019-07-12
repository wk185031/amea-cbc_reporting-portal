package my.com.mandrill.base.reporting.reportProcessor;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class GeneralReportProcess {

	private final Logger logger = LoggerFactory.getLogger(GeneralReportProcess.class);
	private HashMap<String, ReportGenerationFields> globalFileFieldsMap = new HashMap<String, ReportGenerationFields>();
	private String eol = System.lineSeparator();
	private boolean header = false;
	private boolean bodyHeader = false;
	private boolean body = false;
	private boolean trailer = false;
	private boolean fieldFormatException = false;

	public HashMap<String, ReportGenerationFields> getGlobalFileFieldsMap() {
		return globalFileFieldsMap;
	}

	public void setGlobalFileFieldsMap(HashMap<String, ReportGenerationFields> globalFileFieldsMap) {
		this.globalFileFieldsMap = globalFileFieldsMap;
	}

	public String getEol() {
		return eol;
	}

	public void setEol(String eol) {
		this.eol = eol;
	}

	public boolean isHeader() {
		return header;
	}

	public void setHeader(boolean header) {
		this.header = header;
	}

	public boolean isBodyHeader() {
		return bodyHeader;
	}

	public void setBodyHeader(boolean bodyHeader) {
		this.bodyHeader = bodyHeader;
	}

	public boolean isBody() {
		return body;
	}

	public void setBody(boolean body) {
		this.body = body;
	}

	public boolean isTrailer() {
		return trailer;
	}

	public void setTrailer(boolean trailer) {
		this.trailer = trailer;
	}

	public boolean isFieldFormatException() {
		return fieldFormatException;
	}

	public void setFieldFormatException(boolean fieldFormatException) {
		this.fieldFormatException = fieldFormatException;
	}

	public String getBodyQuery(ReportGenerationMgr rgm) {
		String query = rgm.getBodyQuery();
		StringBuffer sb = new StringBuffer();
		if (query != null) {
			Pattern p = Pattern.compile("[{]\\w+,*\\w*[}]");
			Matcher m = p.matcher(query);
			while (m.find()) {
				String paramName = m.group().substring(1, m.group().length() - 1);
				if (globalFileFieldsMap.containsKey(paramName)) {
					m.appendReplacement(sb, globalFileFieldsMap.get(paramName).format(null));
				} else {
					rgm.errors++;
					logger.error("No field defined for parameter ", paramName);
				}

			}
			m.appendTail(sb);
		} else {
			logger.debug("*** Body query is null or empty");
		}
		return sb.toString();
	}

	public String getTrailerQuery(ReportGenerationMgr rgm) {
		String query = rgm.getTrailerQuery();
		StringBuffer sb = new StringBuffer();
		if (query != null) {
			Pattern p = Pattern.compile("[{]\\w+,*\\w*[}]");
			Matcher m = p.matcher(query);
			while (m.find()) {
				String paramName = m.group().substring(1, m.group().length() - 1);
				if (globalFileFieldsMap.containsKey(paramName)) {
					m.appendReplacement(sb, globalFileFieldsMap.get(paramName).format(null));
				} else {
					rgm.errors++;
					logger.error("No field defined for parameter ", paramName);
				}

			}
			m.appendTail(sb);
		} else {
			logger.debug("*** Trailer query is null or empty");
		}
		return sb.toString();
	}

	protected List<ReportGenerationFields> extractHeaderFields(ReportGenerationMgr rgm)
			throws JSONException, JsonParseException, JsonMappingException, IOException {
		header = true;
		bodyHeader = false;
		body = false;
		trailer = false;
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> headerFields = null;
		if (rgm.getHeaderFields() != null) {
			headerFields = objectMapper.readValue(rgm.getHeaderFields().getBytes(),
					new TypeReference<List<ReportGenerationFields>>() {
					});
			if (headerFields.size() > 0) {
				headerFields.get(headerFields.size() - 1).setEndOfSection(true);
			}
		}
		return headerFields;
	}

	protected List<ReportGenerationFields> extractBodyHeaderFields(ReportGenerationMgr rgm)
			throws JSONException, JsonParseException, JsonMappingException, IOException {
		header = false;
		bodyHeader = true;
		body = false;
		trailer = false;
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> bodyHeaderFields = null;
		if (rgm.getBodyFields() != null) {
			bodyHeaderFields = objectMapper.readValue(rgm.getBodyFields().getBytes(),
					new TypeReference<List<ReportGenerationFields>>() {
					});
			bodyHeaderFields = bodyHeaderFields.stream()
					.filter((reportGenerationField) -> reportGenerationField.isBodyHeader() == true)
					.collect(Collectors.toList());
			if (bodyHeaderFields.size() > 0) {
				bodyHeaderFields.get(bodyHeaderFields.size() - 1).setEndOfSection(true);
			}
		}
		return bodyHeaderFields;
	}

	protected List<ReportGenerationFields> extractBodyFields(ReportGenerationMgr rgm)
			throws JSONException, JsonParseException, JsonMappingException, IOException {
		header = false;
		bodyHeader = false;
		body = true;
		trailer = false;
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> bodyFields = null;
		if (rgm.getBodyFields() != null) {
			bodyFields = objectMapper.readValue(rgm.getBodyFields().getBytes(),
					new TypeReference<List<ReportGenerationFields>>() {
					});
			bodyFields = bodyFields.stream()
					.filter((reportGenerationField) -> reportGenerationField.isBodyHeader() == false)
					.collect(Collectors.toList());
			if (bodyFields.size() > 0) {
				bodyFields.get(bodyFields.size() - 1).setEndOfSection(true);
			}
		}
		return bodyFields;
	}

	protected List<ReportGenerationFields> extractTrailerFields(ReportGenerationMgr rgm)
			throws JSONException, JsonParseException, JsonMappingException, IOException {
		header = false;
		bodyHeader = false;
		body = false;
		trailer = true;
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> trailerFields = null;
		if (rgm.getTrailerFields() != null) {
			trailerFields = objectMapper.readValue(rgm.getTrailerFields().getBytes(),
					new TypeReference<List<ReportGenerationFields>>() {
					});
			if (trailerFields.size() > 0) {
				trailerFields.get(trailerFields.size() - 1).setEndOfSection(true);
			}
		}
		return trailerFields;
	}

	protected String getGlobalFieldValue(ReportGenerationFields field) {
		String fieldValue = "";
		if (field.getDefaultValue() != null && field.getDefaultValue().trim().length() != 0) {
			fieldValue = field.getDefaultValue();
		} else if (globalFileFieldsMap.containsKey(field.getFieldName())) {
			fieldValue = globalFileFieldsMap.get(field.getFieldName()).getValue();
		} else {
			return "";
		}
		field.setValue(fieldValue);

		Integer eky_id = null;
		// if (fieldConfig.getFieldType().equalsIgnoreCase(Field.TYPE_ENCRYPTED_STRING))
		// {
		// eky_id = SecurityManager.getCurrentKeyIndex();
		// }
		return field.format(eky_id);
	}

	protected String getFieldValue(ReportGenerationFields field, HashMap<String, ReportGenerationFields> fieldsMap) {
		String fieldValue = "";
		if (field.getDefaultValue() != null && field.getDefaultValue().trim().length() != 0) {
			fieldValue = field.getDefaultValue();
		} else if (fieldsMap.containsKey(field.getFieldName())) {
			fieldValue = fieldsMap.get(field.getFieldName()).getValue();
		} else if (globalFileFieldsMap.containsKey(field.getFieldName())) {
			fieldValue = globalFileFieldsMap.get(field.getFieldName()).getValue();
		} else {
			return "";
		}
		field.setValue(fieldValue);

		Integer eky_id = null;
		// if (fieldConfig.getFieldType().equalsIgnoreCase(Field.TYPE_ENCRYPTED_STRING))
		// {
		// eky_id = SecurityManager.getCurrentKeyIndex();
		// }
		return field.format(eky_id);
	}

	protected String getGlobalFieldValue(ReportGenerationMgr rgm, ReportGenerationFields field) {
		String fieldValue = "";
		if (field.getDefaultValue() != null && field.getDefaultValue().trim().length() != 0) {
			fieldValue = field.getDefaultValue();
		} else if (globalFileFieldsMap.containsKey(field.getFieldName())) {
			fieldValue = globalFileFieldsMap.get(field.getFieldName()).getValue();
		} else {
			fieldValue = "";
		}
		field.setValue(fieldValue);

		Integer eky_id = null;
		// if (fieldConfig.getFieldType().equalsIgnoreCase(Field.TYPE_ENCRYPTED_STRING))
		// {
		// eky_id = SecurityManager.getCurrentKeyIndex();
		// }
		return field.format(rgm, header, bodyHeader, body, trailer, fieldFormatException, eky_id);
	}

	protected String getFieldValue(ReportGenerationMgr rgm, ReportGenerationFields field,
			HashMap<String, ReportGenerationFields> fieldsMap) {
		String fieldValue = "";
		if (field.getDefaultValue() != null && field.getDefaultValue().trim().length() != 0) {
			fieldValue = field.getDefaultValue();
		} else if (fieldsMap.containsKey(field.getFieldName())) {
			fieldValue = fieldsMap.get(field.getFieldName()).getValue();
		} else if (globalFileFieldsMap.containsKey(field.getFieldName())) {
			fieldValue = globalFileFieldsMap.get(field.getFieldName()).getValue();
		} else {
			fieldValue = "";
		}
		field.setValue(fieldValue);

		Integer eky_id = null;
		// if (fieldConfig.getFieldType().equalsIgnoreCase(Field.TYPE_ENCRYPTED_STRING))
		// {
		// eky_id = SecurityManager.getCurrentKeyIndex();
		// }
		return field.format(rgm, header, bodyHeader, body, trailer, fieldFormatException, eky_id);
	}

	protected void addReportPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GeneralReportProcess.addPreProcessingFieldsToGlobalMap()");
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
			String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnStartDate())
					.concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnEndDate()).concat(" ")
					.concat(ReportConstants.END_TIME);

			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getTxnEndDate().getTime()));
			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");

			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		} else {
			String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getYesterdayDate())
					.concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTodayDate()).concat(" ")
					.concat(ReportConstants.END_TIME);

			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getYesterdayDate().getTime()));
			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");

			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		}
	}

	protected void addBatchPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GeneralReportProcess.addBatchPreProcessingFieldsToGlobalMap()");
		if (rgm.isGenerate() == true) {
			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String fileTxnDate = df.format(rgm.getTxnEndDate());
			String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnStartDate()) + " "
					+ ReportConstants.START_TIME;
			String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnEndDate()) + " "
					+ ReportConstants.END_TIME;

			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");
			ReportGenerationFields fileUploadDate = new ReportGenerationFields(ReportConstants.FILE_UPLOAD_DATE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getTxnEndDate().getTime()));
			ReportGenerationFields fileName = new ReportGenerationFields(ReportConstants.FILE_NAME,
					ReportGenerationFields.TYPE_STRING,
					rgm.getFileNamePrefix() + "_" + fileTxnDate + "_" + "001" + ReportConstants.TXT_FORMAT);

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
			getGlobalFileFieldsMap().put(fileUploadDate.getFieldName(), fileUploadDate);
			getGlobalFileFieldsMap().put(fileName.getFieldName(), fileName);
		} else {
			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String fileTxnDate = df.format(rgm.getYesterdayDate());
			String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getYesterdayDate())
					.concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTodayDate()).concat(" ")
					.concat(ReportConstants.END_TIME);

			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");
			ReportGenerationFields fileUploadDate = new ReportGenerationFields(ReportConstants.FILE_UPLOAD_DATE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getYesterdayDate().getTime()));
			ReportGenerationFields fileName = new ReportGenerationFields(ReportConstants.FILE_NAME,
					ReportGenerationFields.TYPE_STRING,
					rgm.getFileNamePrefix() + "_" + fileTxnDate + "_" + "001" + ReportConstants.TXT_FORMAT);

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
			getGlobalFileFieldsMap().put(fileUploadDate.getFieldName(), fileUploadDate);
			getGlobalFileFieldsMap().put(fileName.getFieldName(), fileName);
		}
	}

	protected void performTransformations(HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		Map<String, Object> poolDBObjects = new HashMap<String, Object>();
		// TBD
	}
}
