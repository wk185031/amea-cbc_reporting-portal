package my.com.mandrill.base.reporting;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ReportGenerationFields {

	private final Logger logger = LoggerFactory.getLogger(ReportGenerationFields.class);
	public static final String TYPE_NEWLINE = "NEWLINE";
	public static final String TYPE_NUMBER = "NUMBER";
	public static final String TYPE_SPECIAL_NUMBER = "SPECIAL_NUMBER";
	public static final String TYPE_FORMAT_NUMBER = "FORMAT_NUMBER";
	public static final String TYPE_DECIMAL = "DECIMAL";
	public static final String TYPE_SPECIAL_DECIMAL = "SPECIAL_DECIMAL";
	public static final String TYPE_FORMAT_DECIMAL = "FORMAT_DECIMAL";
	public static final String TYPE_DECIMAL_WITHOUT_LEADING_ZEROS = "DECIMAL_WITHOUT_LEADING_ZEROS";
	public static final String TYPE_DATE = "DATE";
	public static final String TYPE_STRING = "STRING";
	public static final String TYPE_SPECIAL_STRING = "SPECIAL_STRING";
	public static final String TYPE_BIN = "BIN";
	public static final String TYPE_ENCRYPTED_STRING = "ENCRYPTED";
	public static final String DEFAULT_DATE_FORMAT = "yyy/MM/dd HH:mm:ss";

	// Report Definition
	private String reportCategory;
	private String fileName;
	private String fileNamePrefix;
	private String fileFormat;
	private String fileFormatTmp;
	private String fileLocation;
	private String processingClass;
	private String headerFields;
	private String bodyFields;
	private String trailerFields;
	private String bodyQuery;
	private String trailerQuery;
	// Report Definition Section
	private int sequence;
	private String sectionName;
	private String fieldName;
	private int csvTxtLength;
	private int pdfLength;
	private String fieldType;
	private String value;
	private String delimiter;
	private String fieldFormat;
	private String defaultValue;
	private boolean firstField;
	private boolean bodyHeader;
	private boolean eol;
	private boolean endOfSection;
	private String source;
	// Report Generation
	private Date fileDate;
	private Date txnStartDate;
	private Date txnEndDate;
	private boolean generate;

	public ReportGenerationFields() {
		super();
	}

	public ReportGenerationFields(String fieldName, String fieldType, String value) {
		this.fieldName = fieldName;
		this.fieldType = fieldType;
		this.value = value;
	}

	public String getReportCategory() {
		return reportCategory;
	}

	public void setReportCategory(String reportCategory) {
		this.reportCategory = reportCategory;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getFileNamePrefix() {
		return fileNamePrefix;
	}

	public void setFileNamePrefix(String fileNamePrefix) {
		this.fileNamePrefix = fileNamePrefix;
	}

	public String getFileFormat() {
		return fileFormat;
	}

	public void setFileFormat(String fileFormat) {
		this.fileFormat = fileFormat;
	}

	public String getFileFormatTmp() {
		return fileFormatTmp;
	}

	public void setFileFormatTmp(String fileFormatTmp) {
		this.fileFormatTmp = fileFormatTmp;
	}

	public String getFileLocation() {
		return fileLocation;
	}

	public void setFileLocation(String fileLocation) {
		this.fileLocation = fileLocation;
	}

	public String getProcessingClass() {
		return processingClass;
	}

	public void setProcessingClass(String processingClass) {
		this.processingClass = processingClass;
	}

	public String getHeaderFields() {
		return headerFields;
	}

	public void setHeaderFields(String headerFields) {
		this.headerFields = headerFields;
	}

	public String getBodyFields() {
		return bodyFields;
	}

	public void setBodyFields(String bodyFields) {
		this.bodyFields = bodyFields;
	}

	public String getTrailerFields() {
		return trailerFields;
	}

	public void setTrailerFields(String trailerFields) {
		this.trailerFields = trailerFields;
	}

	public String getBodyQuery() {
		return bodyQuery;
	}

	public void setBodyQuery(String bodyQuery) {
		this.bodyQuery = bodyQuery;
	}

	public String getTrailerQuery() {
		return trailerQuery;
	}

	public void setTrailerQuery(String trailerQuery) {
		this.trailerQuery = trailerQuery;
	}

	public int getSequence() {
		return sequence;
	}

	public void setSequence(int sequence) {
		this.sequence = sequence;
	}

	public String getSectionName() {
		return sectionName;
	}

	public void setSectionName(String sectionName) {
		this.sectionName = sectionName;
	}

	public String getFieldName() {
		return fieldName;
	}

	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}

	public int getCsvTxtLength() {
		return csvTxtLength;
	}

	public void setCsvTxtLength(int csvTxtLength) {
		this.csvTxtLength = csvTxtLength;
	}

	public int getPdfLength() {
		return pdfLength;
	}

	public void setPdfLength(int pdfLength) {
		this.pdfLength = pdfLength;
	}

	public String getFieldType() {
		return fieldType;
	}

	public void setFieldType(String fieldType) {
		this.fieldType = fieldType;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public String getDelimiter() {
		return delimiter;
	}

	public void setDelimiter(String delimiter) {
		this.delimiter = delimiter;
	}

	public String getFieldFormat() {
		return fieldFormat;
	}

	public void setFieldFormat(String fieldFormat) {
		this.fieldFormat = fieldFormat;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public boolean isFirstField() {
		return firstField;
	}

	public void setFirstField(boolean firstField) {
		this.firstField = firstField;
	}

	public boolean isBodyHeader() {
		return bodyHeader;
	}

	public void setBodyHeader(boolean bodyHeader) {
		this.bodyHeader = bodyHeader;
	}

	public boolean isEol() {
		return eol;
	}

	public void setEol(boolean eol) {
		this.eol = eol;
	}

	public boolean isEndOfSection() {
		return endOfSection;
	}

	public void setEndOfSection(boolean endOfSection) {
		this.endOfSection = endOfSection;
	}

	public Date getFileDate() {
		return fileDate;
	}

	public void setFileDate(Date fileDate) {
		this.fileDate = fileDate;
	}

	public Date getTxnStartDate() {
		return txnStartDate;
	}

	public void setTxnStartDate(Date txnStartDate) {
		this.txnStartDate = txnStartDate;
	}

	public Date getTxnEndDate() {
		return txnEndDate;
	}

	public void setTxnEndDate(Date txnEndDate) {
		this.txnEndDate = txnEndDate;
	}

	public boolean isGenerate() {
		return generate;
	}

	public void setGenerate(boolean generate) {
		this.generate = generate;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String format(String eol, boolean fixedLength, Integer eky_id) {
		String padChar = null;
		boolean fieldLeading = false;
		String tempValue = null;

		if (value == null || value.length() < 1) {
			padChar = " ";
			tempValue = "";
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_ENCRYPTED_STRING)) {
			if (value != null && !value.isEmpty()) {
				// tempValue = (SecureField.fromDatabase(value, eky_id)).getClear();
			}
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_DATE)) {
			if (fieldFormat == null) {
				fieldFormat = DEFAULT_DATE_FORMAT;
			}
			SimpleDateFormat df = new SimpleDateFormat(fieldFormat);
			Date date = new Date(Long.parseLong(value));
			tempValue = df.format(date);
			return tempValue;
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
			padChar = "0";
			fieldLeading = true;
			double doubleValue = Double.parseDouble(value);
			DecimalFormat formatter = new DecimalFormat(fieldFormat);
			tempValue = formatter.format(doubleValue);
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_SPECIAL_DECIMAL)) { // Format eg. 10.55 to
																								// 1055
			padChar = "0";
			fieldLeading = true;
			double doubleValue = Double.parseDouble(value);
			DecimalFormat formatter = new DecimalFormat(fieldFormat);
			tempValue = formatter.format(doubleValue).replace(".", "");
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_FORMAT_DECIMAL)) { // Format eg. 100055 to
																								// 1000.55
			padChar = "0";
			fieldLeading = true;
			int exponent = fieldFormat.length() - fieldFormat.indexOf(".") - 1;
			double doubleValue = Double.parseDouble(value) / (Math.pow(10, exponent));
			String newformat = null;

			if (doubleValue < 0) {
				// newformat = Padding.add(format, padChar, length - 1, fieldLeading);
			} else {
				// newformat = Padding.add(format, padChar, length, fieldLeading);
			}

			DecimalFormat formatter = new DecimalFormat(newformat);
			tempValue = formatter.format(doubleValue);
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL_WITHOUT_LEADING_ZEROS)) { // Format
																											// eg.
																											// 0001000.55
																											// to
			// 1000.55
			padChar = " ";
			fieldLeading = true;
			double doubleValue = Double.parseDouble(value);
			DecimalFormat formatter = new DecimalFormat(fieldFormat);
			tempValue = formatter.format(doubleValue);
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
			padChar = "0";
			fieldLeading = true;
			tempValue = value;
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_SPECIAL_NUMBER)) { // Format eg. 1000 to 10
			padChar = "0";
			fieldLeading = true;
			if (value.equals("0")) {
				tempValue = "0";
			} else {
				tempValue = value.substring(0, value.length() - 2);
			}
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_FORMAT_NUMBER)) { // Format eg. 10 to 1000
			padChar = "0";
			fieldLeading = true;
			if (value.equals("0")) {
				tempValue = "0";
			} else {
				tempValue = value.concat("00");
			}
		} else if (fieldType.equalsIgnoreCase(ReportGenerationFields.TYPE_SPECIAL_STRING)) {
			padChar = " ";
			fieldLeading = true;
			tempValue = value.replaceAll(eol, " ");
		} else {
			padChar = " ";
			tempValue = value.replaceAll(eol, " ");
		}
		return tempValue;
	}

	@Override
	public String toString() {
		return "ReportGenerationFields [logger=" + logger + ", reportCategory=" + reportCategory + ", fileName="
				+ fileName + ", fileNamePrefix=" + fileNamePrefix + ", fileFormat=" + fileFormat + ", fileFormatTmp="
				+ fileFormatTmp + ", fileLocation=" + fileLocation + ", processingClass=" + processingClass
				+ ", headerFields=" + headerFields + ", bodyFields=" + bodyFields + ", trailerFields=" + trailerFields
				+ ", bodyQuery=" + bodyQuery + ", trailerQuery=" + trailerQuery + ", sequence=" + sequence
				+ ", sectionName=" + sectionName + ", fieldName=" + fieldName + ", csvTxtLength=" + csvTxtLength
				+ ", pdfLength=" + pdfLength + ", fieldType=" + fieldType + ", value=" + value + ", delimiter="
				+ delimiter + ", fieldFormat=" + fieldFormat + ", defaultValue=" + defaultValue + ", firstField="
				+ firstField + ", bodyHeader=" + bodyHeader + ", eol=" + eol + ", endOfSection=" + endOfSection
				+ ", source=" + source + ", fileDate=" + fileDate + ", txnStartDate=" + txnStartDate + ", txnEndDate="
				+ txnEndDate + ", generate=" + generate + "]";
	}

	public ReportGenerationFields clone(ReportGenerationMgr rgm) {
		ReportGenerationFields field = new ReportGenerationFields();
		field.setSectionName(sectionName);
		field.setFieldName(fieldName);
		field.setCsvTxtLength(csvTxtLength);
		field.setPdfLength(pdfLength);
		field.setFieldType(fieldType);
		field.setValue(value);
		field.setDelimiter(delimiter);
		field.setFieldFormat(fieldFormat);
		field.setDefaultValue(defaultValue);
		field.setFirstField(firstField);
		field.setBodyHeader(bodyHeader);
		field.setEol(eol);
		field.setEndOfSection(endOfSection);
		field.setSource(source);
		return field;
	}
}
