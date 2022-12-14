package my.com.mandrill.base.reporting.reportProcessor;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import javax.persistence.Query;
import javax.persistence.EntityManager;

import org.apache.commons.lang.StringEscapeUtils;
import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.SpringContext;
import my.com.mandrill.base.reporting.security.SecurePANField;
import my.com.mandrill.base.repository.SystemConfigurationRepository;
import my.com.mandrill.base.service.EncryptionService;

@Service
public class GeneralReportProcess {

	private final Logger logger = LoggerFactory.getLogger(GeneralReportProcess.class);

	protected static String DCMS_ENCRYPTION_KEY = "DCMS_ENCRYPTION_KEY";
	protected static String DCMS_ROTATION_NUMBER_KEY = "ROTATION_NUMBER";
	protected static String DCMS_INSTITUTION_ID_KEY = "INSTITUTION_ID";


	private EncryptionService encryptionService;

	private HashMap<String, ReportGenerationFields> globalFileFieldsMap = new HashMap<String, ReportGenerationFields>();
	private String eol = "\r\n"; 
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
					//rgm.errors++;
					logger.warn("No field defined for parameter: {}", paramName);
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
					logger.warn("No field defined for parameter ", paramName);
				}

			}
			m.appendTail(sb);
		} else {
			logger.debug("*** Trailer query is null or empty");
		}
		return sb.toString();
	}
	
	public String getCriteriaQuery(ReportGenerationMgr rgm, String query) {
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
					logger.warn("No field defined for parameter: {}", paramName);
				}

			}
			m.appendTail(sb);
		} else {
			logger.debug("*** Body query is null or empty");
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
	
	protected List<ReportGenerationFields> extractInstitutionTrailerFields(ReportGenerationMgr rgm)
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

		ReportGenerationFields todaysDateValue = new ReportGenerationFields(ReportConstants.TODAYS_DATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields runDateValue = new ReportGenerationFields(ReportConstants.RUNDATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields timeValue = new ReportGenerationFields(ReportConstants.TIME_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));

		getGlobalFileFieldsMap().put(todaysDateValue.getFieldName(), todaysDateValue);
		getGlobalFileFieldsMap().put(runDateValue.getFieldName(), runDateValue);
		getGlobalFileFieldsMap().put(timeValue.getFieldName(), timeValue);

		ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnStartDate().toLocalDate().toString());
		getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);

		buildTransactionDateRangeCriteria(rgm);

	}
	
	protected void addAtmDownTimeReportPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GeneralReportProcess.addAtmDownTimeReportPreProcessingFieldsToGlobalMap()");

		ReportGenerationFields todaysDateValue = new ReportGenerationFields(ReportConstants.TODAYS_DATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields runDateValue = new ReportGenerationFields(ReportConstants.RUNDATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields timeValue = new ReportGenerationFields(ReportConstants.TIME_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));

		getGlobalFileFieldsMap().put(todaysDateValue.getFieldName(), todaysDateValue);
		getGlobalFileFieldsMap().put(runDateValue.getFieldName(), runDateValue);
		getGlobalFileFieldsMap().put(timeValue.getFieldName(), timeValue);

		ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnStartDate().toLocalDate().toString());
		getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);

		buildAtmDownTimeTransactionDateRangeCriteria(rgm);

	}

	protected void addBatchPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GeneralReportProcess.addBatchPreProcessingFieldsToGlobalMap()");

		String fileTxnDate = rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));

		ReportGenerationFields fileUploadDate = new ReportGenerationFields(ReportConstants.FILE_UPLOAD_DATE,
				ReportGenerationFields.TYPE_DATE, LocalDateTime.now().toString());
		if(rgm.getReportCategory().equals(ReportConstants.GL_HANDOFF_FILES)){
			fileTxnDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
		}
		ReportGenerationFields fileName = new ReportGenerationFields(ReportConstants.FILE_NAME,
				ReportGenerationFields.TYPE_STRING,
				rgm.getFileNamePrefix() + "_" + fileTxnDate + "_" + "001" + ReportConstants.TXT_FORMAT);
		ReportGenerationFields fromDateValue = new ReportGenerationFields(ReportConstants.FROM_DATE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnStartDate().toLocalDate().toString());
		ReportGenerationFields toDateValue = new ReportGenerationFields(ReportConstants.TO_DATE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toLocalDate().toString());
		if (rgm.getReportTxnEndDate() != null) {
			ReportGenerationFields reportToDateValue = new ReportGenerationFields(ReportConstants.REPORT_TO_DATE,
					ReportGenerationFields.TYPE_DATE, rgm.getReportTxnEndDate().toLocalDate().toString());
			getGlobalFileFieldsMap().put(reportToDateValue.getFieldName(), reportToDateValue);
		}

		buildTransactionDateRangeCriteria(rgm);
		getGlobalFileFieldsMap().put(fileUploadDate.getFieldName(), fileUploadDate);
		getGlobalFileFieldsMap().put(fileName.getFieldName(), fileName);
		getGlobalFileFieldsMap().put(fromDateValue.getFieldName(), fromDateValue);
		getGlobalFileFieldsMap().put(toDateValue.getFieldName(), toDateValue);
		
	}

	protected void buildTransactionDateRangeCriteria(ReportGenerationMgr rgm) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);

		String criteria = getTransactionDateRangeFieldName() + " >= TO_DATE('" + txnStart + "', '"
				+ ReportConstants.FORMAT_TXN_DATE + "') AND " + getTransactionDateRangeFieldName() + " < TO_DATE('"
				+ txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE + "')";
		ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
				ReportGenerationFields.TYPE_STRING, criteria);
		ReportGenerationFields fromDateValue = new ReportGenerationFields(ReportConstants.FROM_DATE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnStartDate().toLocalDate().toString());
		ReportGenerationFields toDateValue = new ReportGenerationFields(ReportConstants.TO_DATE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toLocalDate().toString());
		if (rgm.getReportTxnEndDate() != null) {
			ReportGenerationFields reportToDateValue = new ReportGenerationFields(ReportConstants.REPORT_TO_DATE,
					ReportGenerationFields.TYPE_DATE, rgm.getReportTxnEndDate().toLocalDate().toString());
			getGlobalFileFieldsMap().put(reportToDateValue.getFieldName(), reportToDateValue);
		}

		getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		getGlobalFileFieldsMap().put(fromDateValue.getFieldName(), fromDateValue);
		getGlobalFileFieldsMap().put(toDateValue.getFieldName(), toDateValue);
		
	}

	protected String getTransactionDateRangeFieldName() {
		return "TXN.TRL_SYSTEM_TIMESTAMP";
	}
	
	protected void buildAtmDownTimeTransactionDateRangeCriteria(ReportGenerationMgr rgm) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);

		String criteria = getAtmDownTimeStartDateRangeFieldName() + " >= TO_DATE('" + txnStart + "', '"
				+ ReportConstants.FORMAT_TXN_DATE + "') AND " + getAtmDownTimeEndDateRangeFieldName() + " < TO_DATE('"
				+ txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE + "')";
		ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
				ReportGenerationFields.TYPE_STRING, criteria);
		ReportGenerationFields fromDateValue = new ReportGenerationFields(ReportConstants.FROM_DATE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnStartDate().toLocalDate().toString());
		ReportGenerationFields toDateValue = new ReportGenerationFields(ReportConstants.TO_DATE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toLocalDate().toString());
		ReportGenerationFields reportToDateValue = new ReportGenerationFields(ReportConstants.REPORT_TO_DATE,
				ReportGenerationFields.TYPE_DATE, rgm.getReportTxnEndDate().toLocalDate().toString());

		getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		getGlobalFileFieldsMap().put(fromDateValue.getFieldName(), fromDateValue);
		getGlobalFileFieldsMap().put(toDateValue.getFieldName(), toDateValue);
		getGlobalFileFieldsMap().put(reportToDateValue.getFieldName(), reportToDateValue);
	}
	
	protected String getAtmDownTimeStartDateRangeFieldName() {
		return "ATD.ATD_START_TIMESTAMP";
	}
	
	protected String getAtmDownTimeEndDateRangeFieldName() {
		return "ATD.ATD_END_TIMESTAMP";
	}
	
	

	public String getBranchCode(String toAccountNumber, String toAccountNoEkyId) {
		
		String branchCode = "";
		
		if(toAccountNumber != null && toAccountNoEkyId != null) {
			
			int ekyId = Integer.parseInt(toAccountNoEkyId);
			int threeDigits = 0;
			String toAccountNo = "";
			
			try {
				toAccountNo = SecurePANField.fromDatabase(toAccountNumber, ekyId).getClear();
			} catch (Throwable e) {
				logger.warn("Failed to decrypt to account number.", e);
			}
				
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
			case 13:
				branchCode = toAccountNo.substring(2, 6);
				break;
			default:
				break;
			}
		}
		
		return branchCode;
	}

	public void decryptValues(ReportGenerationFields field, HashMap<String, ReportGenerationFields> fieldsMap,
			HashMap<String, ReportGenerationFields> globalFieldsMap) {
		ReportGenerationFields decryptedField = null;
		int ekyId = 0;
		try {
			if (fieldsMap.containsKey(field.getFieldName()) && fieldsMap.get(field.getFieldName()).getValue() != null
					&& fieldsMap.get(field.getFieldName()).getValue().trim().length() > 0
					&& field.getDecryptionKey() != null && field.getDecryptionKey().trim().length() > 0) {

				if (DCMS_ENCRYPTION_KEY.equals(field.getDecryptionKey())) {
					int keyRotationNumber = 0;
					try {
						keyRotationNumber = Integer.parseInt(fieldsMap.get(DCMS_ROTATION_NUMBER_KEY).getValue());
					} catch (NumberFormatException e) {
						logger.warn("Failed to parse value for DCMS_ROTATION_NUMBER_KEY");
					}
					String institutionCode = fieldsMap.get(DCMS_INSTITUTION_ID_KEY).getValue();
					String encryptedValue = fieldsMap.get(field.getFieldName()).getValue();

					decryptedField = new ReportGenerationFields(field.getFieldName(),
							ReportGenerationFields.TYPE_STRING,
							encryptionService.decryptDcms(encryptedValue, institutionCode, keyRotationNumber));
				} else {
					ekyId = Integer.parseInt(fieldsMap.get(field.getDecryptionKey()).getValue());

					if (field.getTagValue() != null && field.getTagValue().trim().length() > 0) {
						logger.trace("original custom data: {}", fieldsMap.get(field.getFieldName()).getValue());
						String decryptedCustomData = encryptionService
								.decryptAuthenticTag(fieldsMap.get(field.getFieldName()).getValue(), ekyId);
						logger.trace("decrypted custom data: {}", decryptedCustomData);
						
						decryptedField = new ReportGenerationFields(field.getFieldName(),
								ReportGenerationFields.TYPE_STRING,
								getTaggedData(decryptedCustomData, field.getTagValue()));
					} else {
						decryptedField = new ReportGenerationFields(field.getFieldName(),
								ReportGenerationFields.TYPE_STRING, encryptionService
										.decryptAuthenticField(fieldsMap.get(field.getFieldName()).getValue(), ekyId));
					}
				}
			} else {
				decryptedField = new ReportGenerationFields(field.getFieldName(), ReportGenerationFields.TYPE_STRING,
						"");
			}

			if (decryptedField != null) {
				globalFieldsMap.put(decryptedField.getFieldName(), decryptedField);
			}
		} catch (Throwable e) {
			logger.warn("Failed to decrypt value.", e);
		}
	}
	
	public void decryptValuesApprovedReject(ReportGenerationFields field, HashMap<String, ReportGenerationFields> fieldsMap,
			HashMap<String, ReportGenerationFields> globalFieldsMap) {
		ReportGenerationFields decryptedField = null;
		int ekyId = 0;
		try {
			if (fieldsMap.containsKey(field.getFieldName()) && fieldsMap.get(field.getFieldName()).getValue() != null
					&& fieldsMap.get(field.getFieldName()).getValue().trim().length() > 0
					&& field.getDecryptionKey() != null && field.getDecryptionKey().trim().length() > 0) {

				if (DCMS_ENCRYPTION_KEY.equals(field.getDecryptionKey())) {
					int keyRotationNumber = 0;
					String keyRotationStr = fieldsMap.get(DCMS_ROTATION_NUMBER_KEY).getValue();
					String encryptedValue = fieldsMap.get(field.getFieldName()).getValue();
					try {
						if(keyRotationStr!=null && !keyRotationStr.isEmpty()){
							keyRotationNumber = Integer.parseInt(keyRotationStr);
							String institutionCode = fieldsMap.get(DCMS_INSTITUTION_ID_KEY).getValue();
							

							decryptedField = new ReportGenerationFields(field.getFieldName(),
									ReportGenerationFields.TYPE_STRING,
									encryptionService.decryptDcms(encryptedValue, institutionCode, keyRotationNumber));
						}	
						else{
							decryptedField = new ReportGenerationFields(field.getFieldName(),
									ReportGenerationFields.TYPE_STRING, encryptedValue);
						}
					} catch (NumberFormatException e) {
						logger.warn("Failed to parse value for DCMS_ROTATION_NUMBER_KEY");
					}
					
				} else {
					ekyId = Integer.parseInt(fieldsMap.get(field.getDecryptionKey()).getValue());

					if (field.getTagValue() != null && field.getTagValue().trim().length() > 0) {
						logger.trace("original custom data: {}", fieldsMap.get(field.getFieldName()).getValue());
						String decryptedCustomData = encryptionService
								.decryptAuthenticTag(fieldsMap.get(field.getFieldName()).getValue(), ekyId);
						logger.trace("decrypted custom data: {}", decryptedCustomData);
						
						decryptedField = new ReportGenerationFields(field.getFieldName(),
								ReportGenerationFields.TYPE_STRING,
								getTaggedData(decryptedCustomData, field.getTagValue()));
					} else {
						decryptedField = new ReportGenerationFields(field.getFieldName(),
								ReportGenerationFields.TYPE_STRING, encryptionService
										.decryptAuthenticField(fieldsMap.get(field.getFieldName()).getValue(), ekyId));
					}
				}
			} else {
				decryptedField = new ReportGenerationFields(field.getFieldName(), ReportGenerationFields.TYPE_STRING,
						"");
			}

			if (decryptedField != null) {
				globalFieldsMap.put(decryptedField.getFieldName(), decryptedField);
			}
		} catch (Throwable e) {
			logger.warn("Failed to decrypt value.", e);
		}
	}
	
	public String getTaggedData(String customData, String tag) {
		if (customData == null || tag == null) {
			return null;
		}

		if (customData.contains(ReportConstants.SECUREFIELD)) {
			customData = customData.replace(" " + ReportConstants.SECUREFIELD + "=\"Y\"", "");
		}

		String xmlTag = "<" + tag + ">";
		int beginIndex = customData.indexOf(xmlTag) + xmlTag.length();

		if (beginIndex < xmlTag.length()) {
			return null;
		}

		int endIndex = customData.indexOf("<", beginIndex);

		if (beginIndex >= endIndex) {
			return "";
		} else {
			String beforeValue = customData.substring(beginIndex, endIndex);
			return StringEscapeUtils.unescapeXml(beforeValue);
		}
	}

	public EncryptionService getEncryptionService() {
		return encryptionService;
	}

	public void setEncryptionService(EncryptionService encryptionService) {
		this.encryptionService = encryptionService;
	}
	
	public List<Branch> getAllBranchByInstitution(String institutionCode) {
		SystemConfigurationRepository configRepo = SpringContext.getBean(SystemConfigurationRepository.class);
		String configName = institutionCode.toLowerCase().concat(".branch.prefix");
		SystemConfiguration config = configRepo.findByName(configName);
		
		if (config != null) {
			StringBuilder stmtBuilder = new StringBuilder();
			for (String prefix : config.getConfig().split(",")) {
				if (stmtBuilder.length() > 0) {
					stmtBuilder.append(" OR");
				}
				stmtBuilder.append(" id like '").append(prefix).append("%'");
			}
			
			EntityManager em = SpringContext.getBean(EntityManager.class);
			Query q = em.createQuery("select b from Branch b where" + stmtBuilder.toString() + " order by id");
			return q.getResultList();		
		}
		return new ArrayList<>();
	}

	public String getBranchQueryStatement(String institutionCode, String fieldName) {
		SystemConfigurationRepository configRepo = SpringContext.getBean(SystemConfigurationRepository.class);
		String configName = institutionCode.toLowerCase().concat(".branch.prefix");
		SystemConfiguration config = configRepo.findByName(configName);
		logger.debug("Find branch prefix: institutionCode={}, fieldName={}, configName={}, config={}", institutionCode,
				fieldName, configName, config == null ? "" : config.getConfig());
		String statement = "";
		if (config != null) {
			StringBuilder stmtBuilder = new StringBuilder();
			for (String prefix : config.getConfig().split(",")) {
				if (stmtBuilder.length() > 0) {
					stmtBuilder.append(" OR");
				}
				stmtBuilder.append(fieldName).append(" like '").append(prefix).append("%' ");
			}
			statement = stmtBuilder.toString();
		}
		return statement;
	}

}
