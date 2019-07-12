package my.com.mandrill.base.reporting;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ReportGenerationFields {

	public static final String TYPE_NUMBER = "Number";
	public static final String TYPE_DECIMAL = "Decimal";
	public static final String TYPE_DATE = "Date";
	public static final String TYPE_STRING = "String";
	public static final String TYPE_ENCRYPTED_STRING = "Encrypted";
	public static final String DEFAULT_DATE_FORMAT = "yyyy/MM/dd HH:mm:ss";

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
	private String tmpBodyQuery;
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
	private Date todayDate;
	private Date yesterdayDate;
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

	public String getTmpBodyQuery() {
		return tmpBodyQuery;
	}

	public void setTmpBodyQuery(String tmpBodyQuery) {
		this.tmpBodyQuery = tmpBodyQuery;
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

	public Date getTodayDate() {
		return todayDate;
	}

	public void setTodayDate(Date todayDate) {
		this.todayDate = todayDate;
	}

	public Date getYesterdayDate() {
		return yesterdayDate;
	}

	public void setYesterdayDate(Date yesterdayDate) {
		this.yesterdayDate = yesterdayDate;
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

	public String format(Integer eky_id) {
		String tempValue = null;
		switch (fieldType) {
		case ReportGenerationFields.TYPE_DATE:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = DEFAULT_DATE_FORMAT;
			}
			SimpleDateFormat df = new SimpleDateFormat(fieldFormat);
			Date date = new Date(Long.parseLong(value));
			tempValue = df.format(date);
			break;
		case ReportGenerationFields.TYPE_DECIMAL:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = "#,##0.00";
			}
			double doubleValue = Double.parseDouble(value);
			DecimalFormat formatter = new DecimalFormat(fieldFormat);
			tempValue = formatter.format(doubleValue);
			break;
		case ReportGenerationFields.TYPE_NUMBER:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				tempValue = value;
			} else {
				tempValue = String.format("%,d", Integer.parseInt(value));
			}
			break;
		case ReportGenerationFields.TYPE_STRING:
			tempValue = value;
			break;
		case ReportGenerationFields.TYPE_ENCRYPTED_STRING:
			if (value != null && !value.isEmpty()) {
				// tempValue = (SecureField.fromDatabase(value, eky_id)).getClear();
			}
			break;
		default:
			tempValue = "";
			break;
		}
		return tempValue;
	}

	public String format(ReportGenerationMgr rgm, boolean header, boolean bodyHeader, boolean body, boolean trailer,
			boolean fieldFormatException, Integer eky_id) {
		String tempValue = null;
		switch (fieldType) {
		case ReportGenerationFields.TYPE_DATE:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = DEFAULT_DATE_FORMAT;
			}
			SimpleDateFormat df = new SimpleDateFormat(fieldFormat);
			Date date = new Date(Long.parseLong(value));
			tempValue = df.format(date);
			break;
		case ReportGenerationFields.TYPE_DECIMAL:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = "#,##0.00";
			}
			double doubleValue = Double.parseDouble(value);
			DecimalFormat formatter = new DecimalFormat(fieldFormat);
			tempValue = formatter.format(doubleValue);
			break;
		case ReportGenerationFields.TYPE_NUMBER:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				tempValue = value;
			} else {
				tempValue = String.format("%,d", Integer.parseInt(value));
			}
			break;
		case ReportGenerationFields.TYPE_STRING:
			tempValue = value;
			break;
		case ReportGenerationFields.TYPE_ENCRYPTED_STRING:
			if (value != null && !value.isEmpty()) {
				// tempValue = (SecureField.fromDatabase(value, eky_id)).getClear();
			}
			break;
		default:
			tempValue = "";
			break;
		}

		if (rgm.getFileFormat().equals(ReportConstants.FILE_PDF)) {
			return formatPdfValue(rgm, tempValue, header, bodyHeader, body, trailer, fieldFormatException, eky_id);
		}

		if (rgm.getFileFormat().equals(ReportConstants.FILE_TXT)) {
			return formatTxtValue(rgm, tempValue, header, bodyHeader, body, trailer, fieldFormatException, eky_id);
		}

		if (rgm.getFileFormat().equals(ReportConstants.FILE_CSV)) {
			return formatFixCsvValue(tempValue, body);
		}
		return tempValue;
	}

	public String formatPdfValue(ReportGenerationMgr rgm, String tempValue, boolean header, boolean bodyHeader,
			boolean body, boolean trailer, boolean fieldFormatException, Integer eky_id) {
		if (header) {
			return formatPdfHeaderValue(tempValue, fieldFormatException);
		} else if (bodyHeader) {
			return formatPdfBodyHeaderValue(tempValue, fieldFormatException);
		} else if (body) {
			return formatPdfBodyValue(tempValue, fieldFormatException);
		} else {
			return formatPdfTrailerValue(tempValue, fieldFormatException);
		}
	}

	public String formatPdfHeaderValue(String tempValue, boolean fieldFormatException) {
		if (tempValue.trim().length() == 0) {
			tempValue = String.format("%1$" + pdfLength + "s", "");
		} else {
			if (fieldFormatException) {
				tempValue = String.format("%1$" + pdfLength + "s", tempValue);
			} else {
				tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
			}
		}
		return tempValue;
	}

	public String formatPdfBodyHeaderValue(String tempValue, boolean fieldFormatException) {
		if (fieldName != null) {
			if (fieldFormatException) {
				tempValue = String.format("%1$" + pdfLength + "s", fieldName);
			} else {
				if (fieldName.contains(ReportConstants.LINE)) {
					tempValue = String.format("%" + pdfLength + "s", " ").replace(' ', tempValue.charAt(0));
				} else {
					tempValue = String.format("%1$-" + pdfLength + "s", fieldName);
				}
			}
		} else {
			tempValue = String.format("%1$-" + pdfLength + "s", "");
		}
		return tempValue;
	}

	public String formatPdfBodyValue(String tempValue, boolean fieldFormatException) {
		if (fieldFormatException) {
			return formatFixLeftJustifiedPdfValue(tempValue);
		} else {
			return formatFixPdfValue(tempValue);
		}
	}

	public String formatPdfTrailerValue(String tempValue, boolean fieldFormatException) {
		if (tempValue.trim().length() == 0) {
			tempValue = String.format("%1$" + pdfLength + "s", "");
		} else {
			if (fieldFormatException) {
				tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
			} else {
				if (fieldName.contains(ReportConstants.LINE)) {
					tempValue = String.format("%" + pdfLength + "s", " ").replace(' ', tempValue.charAt(0));
				} else {
					tempValue = String.format("%1$" + pdfLength + "s", tempValue);
				}
			}
		}
		return tempValue;
	}

	public String formatFixPdfValue(String tempValue) {
		switch (fieldName) {
		case ReportConstants.ATM_CARD_NUMBER:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 19) {
				tempValue = String.format("%1$" + pdfLength + "s",
						String.format("%1$" + 19 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$" + pdfLength + "s", tempValue);
			}
			break;
		case ReportConstants.CODE:
		case ReportConstants.SEQ_NUMBER:
		case ReportConstants.TRACE_NUMBER:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 6) {
				tempValue = String.format("%1$" + pdfLength + "s",
						String.format("%1$" + 6 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$" + pdfLength + "s", tempValue);
			}
			break;
		case ReportConstants.FROM_ACCOUNT_NO:
		case ReportConstants.TO_ACCOUNT_NO:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 16) {
				tempValue = String.format("%1$" + pdfLength + "s",
						String.format("%1$" + 16 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$" + pdfLength + "s", tempValue);
			}
			break;
		case ReportConstants.VOID_CODE:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 3) {
				tempValue = String.format("%1$" + pdfLength + "s",
						String.format("%1$" + 3 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$" + pdfLength + "s", tempValue);
			}
			break;
		default:
			tempValue = String.format("%1$" + pdfLength + "s", tempValue);
			break;
		}
		return tempValue;
	}

	public String formatFixLeftJustifiedPdfValue(String tempValue) {
		switch (fieldName) {
		case ReportConstants.ATM_CARD_NUMBER:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 19) {
				tempValue = String.format("%1$-" + pdfLength + "s",
						String.format("%1$" + 19 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
			}
			break;
		case ReportConstants.CODE:
		case ReportConstants.SEQ_NUMBER:
		case ReportConstants.TRACE_NUMBER:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 6) {
				tempValue = String.format("%1$-" + pdfLength + "s",
						String.format("%1$" + 6 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
			}
			break;
		case ReportConstants.FROM_ACCOUNT_NO:
		case ReportConstants.TO_ACCOUNT_NO:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 16) {
				tempValue = String.format("%1$-" + pdfLength + "s",
						String.format("%1$" + 16 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
			}
			break;
		case ReportConstants.VOID_CODE:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 3) {
				tempValue = String.format("%1$-" + pdfLength + "s",
						String.format("%1$" + 3 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
			}
			break;
		default:
			tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
			break;
		}
		return tempValue;
	}

	public String formatTxtValue(ReportGenerationMgr rgm, String tempValue, boolean header, boolean bodyHeader,
			boolean body, boolean trailer, boolean fieldFormatException, Integer eky_id) {
		if (header) {
			return formatTxtHeaderValue(tempValue, fieldFormatException);
		} else if (bodyHeader) {
			return formatTxtBodyHeaderValue(tempValue, fieldFormatException);
		} else if (body) {
			return formatTxtBodyValue(tempValue, fieldFormatException);
		} else {
			return formatTxtTrailerValue(tempValue, fieldFormatException);
		}
	}

	public String formatTxtHeaderValue(String tempValue, boolean fieldFormatException) {
		if (tempValue.trim().length() == 0) {
			tempValue = String.format("%1$" + csvTxtLength + "s", "");
		} else {
			if (fieldFormatException) {
				tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
			} else {
				tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
			}
		}
		return tempValue;
	}

	public String formatTxtBodyHeaderValue(String tempValue, boolean fieldFormatException) {
		if (fieldName != null) {
			if (fieldFormatException) {
				tempValue = String.format("%1$" + csvTxtLength + "s", fieldName);
			} else {
				if (fieldName.contains(ReportConstants.LINE)) {
					tempValue = String.format("%" + csvTxtLength + "s", " ").replace(' ', tempValue.charAt(0));
				} else {
					tempValue = String.format("%1$-" + csvTxtLength + "s", fieldName);
				}
			}
		} else {
			tempValue = String.format("%1$-" + csvTxtLength + "s", "");
		}
		return tempValue;
	}

	public String formatTxtBodyValue(String tempValue, boolean fieldFormatException) {
		if (fieldFormatException) {
			return formatFixLeftJustifiedTxtValue(tempValue);
		} else {
			return formatFixTxtValue(tempValue);
		}
	}

	public String formatTxtTrailerValue(String tempValue, boolean fieldFormatException) {
		if (tempValue.trim().length() == 0) {
			tempValue = String.format("%1$" + csvTxtLength + "s", "");
		} else {
			if (fieldFormatException) {
				tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
			} else {
				if (fieldName.contains(ReportConstants.LINE)) {
					tempValue = String.format("%" + csvTxtLength + "s", " ").replace(' ', tempValue.charAt(0));
				} else {
					tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
				}
			}
		}
		return tempValue;
	}

	public String formatFixTxtValue(String tempValue) {
		switch (fieldName) {
		case ReportConstants.ATM_CARD_NUMBER:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 19) {
				tempValue = String.format("%1$" + csvTxtLength + "s",
						String.format("%1$" + 19 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
			}
			break;
		case ReportConstants.CODE:
		case ReportConstants.SEQ_NUMBER:
		case ReportConstants.TRACE_NUMBER:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 6) {
				tempValue = String.format("%1$" + csvTxtLength + "s",
						String.format("%1$" + 6 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
			}
			break;
		case ReportConstants.FROM_ACCOUNT_NO:
		case ReportConstants.TO_ACCOUNT_NO:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 16) {
				tempValue = String.format("%1$" + csvTxtLength + "s",
						String.format("%1$" + 16 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
			}
			break;
		case ReportConstants.VOID_CODE:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 3) {
				tempValue = String.format("%1$" + csvTxtLength + "s",
						String.format("%1$" + 3 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
			}
			break;
		default:
			tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
			break;
		}
		return tempValue;
	}

	public String formatFixLeftJustifiedTxtValue(String tempValue) {
		switch (fieldName) {
		case ReportConstants.ATM_CARD_NUMBER:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 19) {
				tempValue = String.format("%1$-" + csvTxtLength + "s",
						String.format("%1$" + 19 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
			}
			break;
		case ReportConstants.CODE:
		case ReportConstants.SEQ_NUMBER:
		case ReportConstants.TRACE_NUMBER:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 6) {
				tempValue = String.format("%1$-" + csvTxtLength + "s",
						String.format("%1$" + 6 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
			}
			break;
		case ReportConstants.FROM_ACCOUNT_NO:
		case ReportConstants.TO_ACCOUNT_NO:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 16) {
				tempValue = String.format("%1$-" + csvTxtLength + "s",
						String.format("%1$" + 16 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
			}
			break;
		case ReportConstants.VOID_CODE:
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}
			if (tempValue.length() <= 3) {
				tempValue = String.format("%1$-" + csvTxtLength + "s",
						String.format("%1$" + 3 + "s", tempValue).replace(' ', '0'));
			} else {
				tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
			}
			break;
		default:
			tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
			break;
		}
		return tempValue;
	}

	public String formatFixCsvValue(String tempValue, boolean body) {
		if (fieldName != null) {
			if (body) {
				switch (fieldName) {
				case ReportConstants.ATM_CARD_NUMBER:
					if (tempValue.trim().length() == 0) {
						tempValue = " ";
					}
					if (tempValue.length() <= 19) {
						tempValue = String.format("%1$" + 19 + "s", tempValue).replace(' ', '0');
					} else {
						return tempValue;
					}
					break;
				case ReportConstants.CODE:
				case ReportConstants.SEQ_NUMBER:
				case ReportConstants.TRACE_NUMBER:
					if (tempValue.trim().length() == 0) {
						tempValue = " ";
					}
					if (tempValue.length() <= 6) {
						tempValue = String.format("%1$" + 6 + "s", tempValue).replace(' ', '0');
					} else {
						return tempValue;
					}
					break;
				case ReportConstants.FROM_ACCOUNT_NO:
				case ReportConstants.TO_ACCOUNT_NO:
					if (tempValue.trim().length() == 0) {
						tempValue = " ";
					}
					if (tempValue.length() <= 16) {
						tempValue = String.format("%1$" + 16 + "s", tempValue).replace(' ', '0');
					} else {
						return tempValue;
					}
					break;
				case ReportConstants.VOID_CODE:
					if (tempValue.trim().length() == 0) {
						tempValue = " ";
					}
					if (tempValue.length() <= 3) {
						tempValue = String.format("%1$" + 3 + "s", tempValue).replace(' ', '0');
					} else {
						return tempValue;
					}
					break;
				default:
					return tempValue;
				}
			} else {
				return tempValue;
			}
		}
		return tempValue;
	}

	@Override
	public String toString() {
		return "ReportGenerationFields [" + "reportCategory=" + reportCategory + ", fileName=" + fileName
				+ ", fileNamePrefix=" + fileNamePrefix + ", fileFormat=" + fileFormat + ", fileFormatTmp="
				+ fileFormatTmp + ", fileLocation=" + fileLocation + ", processingClass=" + processingClass
				+ ", headerFields=" + headerFields + ", bodyFields=" + bodyFields + ", trailerFields=" + trailerFields
				+ ", bodyQuery=" + bodyQuery + ", trailerQuery=" + trailerQuery + ", tmpBodyQuery=" + tmpBodyQuery
				+ ", sequence=" + sequence + ", sectionName=" + sectionName + ", fieldName=" + fieldName
				+ ", csvTxtLength=" + csvTxtLength + ", pdfLength=" + pdfLength + ", fieldType=" + fieldType
				+ ", value=" + value + ", delimiter=" + delimiter + ", fieldFormat=" + fieldFormat + ", defaultValue="
				+ defaultValue + ", firstField=" + firstField + ", bodyHeader=" + bodyHeader + ", eol=" + eol
				+ ", endOfSection=" + endOfSection + ", source=" + source + ", fileDate=" + fileDate + ", txnStartDate="
				+ txnStartDate + ", txnEndDate=" + txnEndDate + ", generate=" + generate + "]";
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
