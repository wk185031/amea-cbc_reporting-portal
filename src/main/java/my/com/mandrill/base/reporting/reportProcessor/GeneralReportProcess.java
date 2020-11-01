package my.com.mandrill.base.reporting.reportProcessor;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.apache.commons.lang.StringEscapeUtils;
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
import my.com.mandrill.base.reporting.security.SecurePANField;
import my.com.mandrill.base.reporting.security.SecureString;

public class GeneralReportProcess {

	private final Logger logger = LoggerFactory.getLogger(GeneralReportProcess.class);
	private HashMap<String, ReportGenerationFields> globalFileFieldsMap = new HashMap<String, ReportGenerationFields>();
	private String eol = System.lineSeparator();
	private boolean header = false;
	private boolean bodyHeader = false;
	private boolean body = false;
	private boolean trailer = false;

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

	public String getBodyQuery(ReportGenerationMgr rgm) {
		String query = rgm.getBodyQuery();
		StringBuffer sb = new StringBuffer();
		if (query != null) {
			Pattern p = Pattern.compile("[{]\\w+,*\\w*[}]");
			Matcher m = p.matcher(query);
			while (m.find()) {
				String paramName = m.group().substring(1, m.group().length() - 1);
				if (globalFileFieldsMap.containsKey(paramName)) {
					String value = globalFileFieldsMap.get(paramName).format();
					logger.debug("Replace parameter[{}] with value[{}]", paramName, value);
					m.appendReplacement(sb, value);
				} else {
					rgm.errors++;
					logger.error("No field defined for parameter: {}", paramName);
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
					m.appendReplacement(sb, globalFileFieldsMap.get(paramName).format());
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

		return field.format();
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

		return field.format();
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
		return field.format(rgm, header, bodyHeader, body, trailer);
	}

	protected String getFieldValue(ReportGenerationMgr rgm, ReportGenerationFields field,
			HashMap<String, ReportGenerationFields> fieldsMap) {
		String fieldValue = "";
		if (field.getDefaultValue() != null && field.getDefaultValue().trim().length() != 0) {
			fieldValue = field.getDefaultValue();
		} else if (globalFileFieldsMap.containsKey(field.getFieldName())) {
			fieldValue = globalFileFieldsMap.get(field.getFieldName()).getValue();
		} else if (null != fieldsMap && fieldsMap.containsKey(field.getFieldName())) {
			fieldValue = fieldsMap.get(field.getFieldName()).getValue();
		} else {
			fieldValue = "";
		}
		field.setValue(fieldValue);
		return field.format(rgm, header, bodyHeader, body, trailer);
	}

	protected void addReportPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GeneralReportProcess.addReportPreProcessingFieldsToGlobalMap()");
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01);
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
			String txnStart = rgm.getTxnStartDate().format(formatter).concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = rgm.getTxnEndDate().format(formatter).concat(" ").concat(ReportConstants.END_TIME);

			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toString());
			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");

			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		} else {
			String txnStart = rgm.getYesterdayDate().format(formatter).concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = rgm.getTodayDate().format(formatter).concat(" ").concat(ReportConstants.END_TIME);

//			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
//					ReportGenerationFields.TYPE_DATE, rgm.getYesterdayDate().toString());
            ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
                ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toString());
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
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01);
		if (rgm.isGenerate() == true) {
			String fileTxnDate = rgm.getTxnEndDate().format(formatter);
			String txnStart = rgm.getTxnStartDate().format(formatter) + " " + ReportConstants.START_TIME;
			String txnEnd = rgm.getTxnEndDate().format(formatter) + " " + ReportConstants.END_TIME;

			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");
			ReportGenerationFields fileUploadDate = new ReportGenerationFields(ReportConstants.FILE_UPLOAD_DATE,
					ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toString());
			ReportGenerationFields fileName = new ReportGenerationFields(ReportConstants.FILE_NAME,
					ReportGenerationFields.TYPE_STRING,
					rgm.getFileNamePrefix() + "_" + fileTxnDate + "_" + "001" + ReportConstants.TXT_FORMAT);

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
			getGlobalFileFieldsMap().put(fileUploadDate.getFieldName(), fileUploadDate);
			getGlobalFileFieldsMap().put(fileName.getFieldName(), fileName);
		} else {
			String fileTxnDate = rgm.getYesterdayDate().format(formatter);
			String txnStart = rgm.getYesterdayDate().format(formatter).concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = rgm.getTodayDate().format(formatter).concat(" ").concat(ReportConstants.END_TIME);

			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");
			ReportGenerationFields fileUploadDate = new ReportGenerationFields(ReportConstants.FILE_UPLOAD_DATE,
					ReportGenerationFields.TYPE_DATE, rgm.getYesterdayDate().toString());
			ReportGenerationFields fileName = new ReportGenerationFields(ReportConstants.FILE_NAME,
					ReportGenerationFields.TYPE_STRING,
					rgm.getFileNamePrefix() + "_" + fileTxnDate + "_" + "001" + ReportConstants.TXT_FORMAT);

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
			getGlobalFileFieldsMap().put(fileUploadDate.getFieldName(), fileUploadDate);
			getGlobalFileFieldsMap().put(fileName.getFieldName(), fileName);
		}
	}

	public String getBranchCode(String toAccountNumber, String toAccountNoEkyId) {
		int ekyId = Integer.parseInt(toAccountNoEkyId);
		int threeDigits = 0;
		String toAccountNo = "";
		String branchCode = "";
		try {
			toAccountNo = SecurePANField.fromDatabase(toAccountNumber, ekyId).getClear();
			switch (toAccountNo.length()) {
			case 10:
				branchCode = toAccountNo.substring(0, 3);
				switch (branchCode) {
				case "101":
				case "201":
					branchCode = "1001";
					break;
				case "103":
				case "203":
				case "303":
					branchCode = "1003";
					break;
				default:
					threeDigits = Integer.parseInt(branchCode) - 100 + 1000;
					branchCode = String.valueOf(threeDigits);
					break;
				}
				break;
			case 12:
				branchCode = toAccountNo.substring(0, 4);
				break;
			default:
				break;
			}
		} catch (Throwable e) {
			logger.error("Failed to decrypt to account number.", e);
		}
		return branchCode;
	}

	public void decryptValues(ReportGenerationFields field, HashMap<String, ReportGenerationFields> fieldsMap,
			HashMap<String, ReportGenerationFields> globalFieldsMap) {
		ReportGenerationFields decryptedField = null;
		int ekyId = 0;
		try {
			if (fieldsMap.get(field.getFieldName()).getValue() != null
					&& fieldsMap.get(field.getFieldName()).getValue().trim().length() > 0
					&& field.getDecryptionKey() != null && field.getDecryptionKey().trim().length() > 0) {
				ekyId = Integer.parseInt(fieldsMap.get(field.getDecryptionKey()).getValue());

				if (field.getTagValue() != null && field.getTagValue().trim().length() > 0) {
					String customDataSecure = SecureString
							.fromDatabase(fieldsMap.get(field.getFieldName()).getValue(), ekyId).getClear();
					decryptedField = new ReportGenerationFields(field.getFieldName(),
							ReportGenerationFields.TYPE_STRING, getTaggedData(customDataSecure, field.getTagValue()));
				} else {
					decryptedField = new ReportGenerationFields(field.getFieldName(),
							ReportGenerationFields.TYPE_STRING, SecurePANField
									.fromDatabase(fieldsMap.get(field.getFieldName()).getValue(), ekyId).getClear());
				}
			} else {
				decryptedField = new ReportGenerationFields(field.getFieldName(), ReportGenerationFields.TYPE_STRING,
						"");
			}

			if (decryptedField != null) {
				globalFieldsMap.put(decryptedField.getFieldName(), decryptedField);
			}
		} catch (Throwable e) {
			logger.error("Failed to decrypt value.", e);
		}
	}

	public String getTaggedData(String customData, String tag) {
		if (customData == null || tag == null) {
			return null;
		}

		String xmlTag = "<" + tag + ">";
		int beginIndex = customData.indexOf(xmlTag) + xmlTag.length();

		if (beginIndex < xmlTag.length()) {
			return null;
		}

		int endIndex = customData.indexOf("<", beginIndex);

		if (beginIndex >= endIndex) {
			return null;
		} else {
			String beforeValue = customData.substring(beginIndex, endIndex);
			return StringEscapeUtils.unescapeXml(beforeValue);
		}
	}
}
