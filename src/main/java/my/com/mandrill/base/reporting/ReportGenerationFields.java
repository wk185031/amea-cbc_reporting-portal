package my.com.mandrill.base.reporting;

import java.text.DecimalFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

public class ReportGenerationFields {

	public static final String TYPE_NUMBER = "Number";
	public static final String TYPE_DECIMAL = "Decimal";
	public static final String TYPE_DATE = "Date";
	public static final String TYPE_DATE_TIME = "Date Time";
	public static final String TYPE_STRING = "String";
	public static final String DEFAULT_DATE_FORMAT = "yyyy/MM/dd HH:mm:ss";
	public static final String DEFAULT_DECIMAL_FORMAT = "#,##0.00";
	public static final String PAD_TYPE_LEADING = "Leading";
	public static final String PAD_TYPE_TRAILING = "Trailing";
	public static final String PAD_VALUE_ZEROS = "Zeros";
	public static final String PAD_VALUE_SPACES = "Spaces";

	// Report Definition
	private String reportCategory;
	private String fileName;
	private String fileNamePrefix;
	private String fileFormat;
	private String fileFormatTmp;
	private String fileLocation;
	private String processingClass;
	private String frequency;
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
	private boolean leftJustified;
	private int padFieldLength;
	private String padFieldType;
	private String padFieldValue;
	private boolean decrypt;
	private String decryptionKey;
	private String tagValue;
	private String source;
	// Report Generation
	private LocalDate fileDate;
	private LocalDate txnStartDate;
	private LocalDate txnEndDate;
	private LocalDate todayDate;
	private LocalDate yesterdayDate;
	private boolean generate;
	private String institution;
	private String dcmsDbSchema;

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

	public String getFrequency() {
		return frequency;
	}

	public void setFrequency(String frequency) {
		this.frequency = frequency;
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

	public boolean isLeftJustified() {
		return leftJustified;
	}

	public void setLeftJustified(boolean leftJustified) {
		this.leftJustified = leftJustified;
	}

	public int getPadFieldLength() {
		return padFieldLength;
	}

	public void setPadFieldLength(int padFieldLength) {
		this.padFieldLength = padFieldLength;
	}

	public String getPadFieldType() {
		return padFieldType;
	}

	public void setPadFieldType(String padFieldType) {
		this.padFieldType = padFieldType;
	}

	public String getPadFieldValue() {
		return padFieldValue;
	}

	public void setPadFieldValue(String padFieldValue) {
		this.padFieldValue = padFieldValue;
	}

	public boolean isDecrypt() {
		return decrypt;
	}

	public void setDecrypt(boolean decrypt) {
		this.decrypt = decrypt;
	}

	public String getDecryptionKey() {
		return decryptionKey;
	}

	public void setDecryptionKey(String decryptionKey) {
		this.decryptionKey = decryptionKey;
	}

	public String getTagValue() {
		return tagValue;
	}

	public void setTagValue(String tagValue) {
		this.tagValue = tagValue;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public LocalDate getFileDate() {
		return fileDate;
	}

	public void setFileDate(LocalDate fileDate) {
		this.fileDate = fileDate;
	}

	public LocalDate getTxnStartDate() {
		return txnStartDate;
	}

	public void setTxnStartDate(LocalDate txnStartDate) {
		this.txnStartDate = txnStartDate;
	}

	public LocalDate getTxnEndDate() {
		return txnEndDate;
	}

	public void setTxnEndDate(LocalDate txnEndDate) {
		this.txnEndDate = txnEndDate;
	}

	public LocalDate getTodayDate() {
		return todayDate;
	}

	public void setTodayDate(LocalDate todayDate) {
		this.todayDate = todayDate;
	}

	public LocalDate getYesterdayDate() {
		return yesterdayDate;
	}

	public void setYesterdayDate(LocalDate yesterdayDate) {
		this.yesterdayDate = yesterdayDate;
	}

	public boolean isGenerate() {
		return generate;
	}

	public void setGenerate(boolean generate) {
		this.generate = generate;
	}

	public String getInstitution() {
		return institution;
	}

	public void setInstitution(String institution) {
		this.institution = institution;
	}

	public String getDcmsDbSchema() {
		return dcmsDbSchema;
	}

	public void setDcmsDbSchema(String dcmsDbSchema) {
		this.dcmsDbSchema = dcmsDbSchema;
	}

	public String format() {
		String tempValue = null;
		switch (fieldType) {
		case ReportGenerationFields.TYPE_DATE:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = ReportConstants.DATE_FORMAT_02;
			}

			if (value == null || value.isEmpty()) {
				tempValue = "";
			} else {
				if (!value.contains("-")) {
					ZonedDateTime dateTime = ZonedDateTime.ofInstant(Instant.ofEpochMilli(Long.parseLong(value)),
							ZoneId.systemDefault());
					tempValue = DateTimeFormatter.ofPattern(fieldFormat).format(dateTime);
				} else {
					DateTimeFormatter localDateFormatter = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_02);
					LocalDate localDate = LocalDate.parse(value, localDateFormatter);
					tempValue = localDate.format(DateTimeFormatter.ofPattern(fieldFormat));
				}
			}
			break;
		case ReportGenerationFields.TYPE_DATE_TIME:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = DEFAULT_DATE_FORMAT;
			}

			if (value == null || value.isEmpty()) {
				tempValue = "";
			} else {
				ZonedDateTime dateTime = ZonedDateTime.ofInstant(Instant.ofEpochMilli(Long.parseLong(value)),
						ZoneId.systemDefault());
				tempValue = DateTimeFormatter.ofPattern(fieldFormat).format(dateTime);
			}
			break;
		case ReportGenerationFields.TYPE_DECIMAL:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = DEFAULT_DECIMAL_FORMAT;
			}
			if (value == null || value.isEmpty()) {
				value = "0";
			}
			double doubleValue = Double.parseDouble(value);
			DecimalFormat formatter = new DecimalFormat(fieldFormat);
			tempValue = formatter.format(doubleValue);
			break;
		case ReportGenerationFields.TYPE_NUMBER:
			if (value == null || value.isEmpty()) {
				value = "0";
			}
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				tempValue = value;
			} else {
				tempValue = String.format("%,d", Integer.parseInt(value));
			}
			break;
		case ReportGenerationFields.TYPE_STRING:
			tempValue = value;
			break;
		default:
			tempValue = "";
			break;
		}
		return tempValue;
	}

	public String format(ReportGenerationMgr rgm, boolean header, boolean bodyHeader, boolean body, boolean trailer) {
		String tempValue = null;
		switch (fieldType) {
		case ReportGenerationFields.TYPE_DATE:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = ReportConstants.DATE_FORMAT_02;
			}

			if (value == null || value.isEmpty()) {
				tempValue = "";
			} else {
				if (!value.contains("-")) {
					ZonedDateTime dateTime = ZonedDateTime.ofInstant(Instant.ofEpochMilli(Long.parseLong(value)),
							ZoneId.systemDefault());
					tempValue = DateTimeFormatter.ofPattern(fieldFormat).format(dateTime);
				} else {
					DateTimeFormatter localDateFormatter = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_02);
					LocalDate localDate = LocalDate.parse(value, localDateFormatter);
					tempValue = localDate.format(DateTimeFormatter.ofPattern(fieldFormat));
				}
			}
			break;
		case ReportGenerationFields.TYPE_DATE_TIME:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = DEFAULT_DATE_FORMAT;
			}

			if (value == null || value.isEmpty()) {
				tempValue = "";
			} else {
				ZonedDateTime dateTime = ZonedDateTime.ofInstant(Instant.ofEpochMilli(Long.parseLong(value)),
						ZoneId.systemDefault());
				tempValue = DateTimeFormatter.ofPattern(fieldFormat).format(dateTime);
			}
			break;
		case ReportGenerationFields.TYPE_DECIMAL:
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				fieldFormat = DEFAULT_DECIMAL_FORMAT;
			}
			if (value == null || value.isEmpty()) {
				value = "0";
			}
			double doubleValue = Double.parseDouble(value);
			DecimalFormat formatter = new DecimalFormat(fieldFormat);
			tempValue = formatter.format(doubleValue);
			break;
		case ReportGenerationFields.TYPE_NUMBER:
			if (value == null || value.isEmpty()) {
				value = "0";
			}
			if (fieldFormat == null || fieldFormat.isEmpty()) {
				tempValue = value;
			} else {
				tempValue = String.format("%,d", Integer.parseInt(value));
			}
			break;
		case ReportGenerationFields.TYPE_STRING:
			tempValue = value;
			break;
		default:
			tempValue = "";
			break;
		}

		return formatValue(rgm, header, bodyHeader, body, trailer, tempValue);
	}

	public String formatValue(ReportGenerationMgr rgm, boolean header, boolean bodyHeader, boolean body,
			boolean trailer, String tempValue) {
		if (rgm.getFileFormat().equals(ReportConstants.FILE_PDF)) {
			return formatPdfValue(tempValue, header, bodyHeader, body, trailer);
		}

		if (rgm.getFileFormat().equals(ReportConstants.FILE_TXT)) {
			return formatTxtValue(tempValue, header, bodyHeader, body, trailer);
		}

		if (rgm.getFileFormat().equals(ReportConstants.FILE_CSV)) {
			return formatFixCsvValue(tempValue, body);
		}
		return tempValue;
	}

	public String formatPdfValue(String tempValue, boolean header, boolean bodyHeader, boolean body, boolean trailer) {
		if (header) {
			return formatPdfHeaderValue(tempValue);
		} else if (bodyHeader) {
			return formatPdfBodyHeaderValue(tempValue);
		} else if (body) {
			return formatPdfBodyValue(tempValue);
		} else {
			return formatPdfTrailerValue(tempValue);
		}
	}

	public String formatPdfHeaderValue(String tempValue) {
		if (tempValue.trim().length() == 0) {
			tempValue = String.format("%1$" + pdfLength + "s", "");
		} else {
			if (leftJustified) {
				tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
			} else {
				tempValue = String.format("%1$" + pdfLength + "s", tempValue);
			}
		}
		return tempValue;
	}

	public String formatPdfBodyHeaderValue(String tempValue) {
		if (fieldName != null) {
			if (fieldName.contains(ReportConstants.LINE)) {
				tempValue = String.format("%" + pdfLength + "s", " ").replace(' ', tempValue.charAt(0));
			} else {
				if (leftJustified) {
					tempValue = String.format("%1$-" + pdfLength + "s", fieldName);
				} else {
					tempValue = String.format("%1$" + pdfLength + "s", fieldName);
				}
			}
		} else {
			tempValue = String.format("%1$-" + pdfLength + "s", "");
		}
		return tempValue;
	}

	public String formatPdfBodyValue(String tempValue) {
		if(tempValue.length() > pdfLength) {
			return tempValue.substring(0, pdfLength);
		}
		if(leftJustified) {
			return formatLeftJustifiedPdfValue(tempValue);
		} else {
			return formatRightJustifiedPdfValue(tempValue);
		}
	}

	public String formatPdfTrailerValue(String tempValue) {
		if (tempValue.trim().length() == 0) {
			tempValue = String.format("%1$" + pdfLength + "s", "");
		} else {
			if (leftJustified) {
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

	public String formatRightJustifiedPdfValue(String tempValue) {
		if (padFieldLength > 0) {
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}

			if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
					&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
				tempValue = String.format("%1$" + pdfLength + "s",
						String.format("%1$" + padFieldLength + "s", tempValue).replace(' ', '0'));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
					&& padFieldValue.equals(PAD_VALUE_SPACES)) {
				tempValue = String.format("%1$" + pdfLength + "s",
						String.format("%1$" + padFieldLength + "s", tempValue));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
					&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
				tempValue = String.format("%1$" + pdfLength + "s",
						String.format("%1$-" + padFieldLength + "s", tempValue).replace(' ', '0'));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
					&& padFieldValue.equals(PAD_VALUE_SPACES)) {
				tempValue = String.format("%1$" + pdfLength + "s",
						String.format("%1$-" + padFieldLength + "s", tempValue));

			} else {
				tempValue = String.format("%1$" + pdfLength + "s", tempValue);
			}
		} else {
			tempValue = String.format("%1$" + pdfLength + "s", tempValue);
		}
		return tempValue;
	}

	public String formatLeftJustifiedPdfValue(String tempValue) {
		if (padFieldLength > 0) {
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}

			if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
					&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
				tempValue = String.format("%1$-" + pdfLength + "s",
						String.format("%1$" + padFieldLength + "s", tempValue).replace(' ', '0'));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
					&& padFieldValue.equals(PAD_VALUE_SPACES)) {
				tempValue = String.format("%1$-" + pdfLength + "s",
						String.format("%1$" + padFieldLength + "s", tempValue));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
					&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
				tempValue = String.format("%1$-" + pdfLength + "s",
						String.format("%1$-" + padFieldLength + "s", tempValue).replace(' ', '0'));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
					&& padFieldValue.equals(PAD_VALUE_SPACES)) {
				tempValue = String.format("%1$-" + pdfLength + "s",
						String.format("%1$-" + padFieldLength + "s", tempValue));

			} else {
				tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
			}
		} else {
			tempValue = String.format("%1$-" + pdfLength + "s", tempValue);
		}
		return tempValue;
	}

	public String formatTxtValue(String tempValue, boolean header, boolean bodyHeader, boolean body, boolean trailer) {
		if (header) {
			return formatTxtHeaderValue(tempValue);
		} else if (bodyHeader) {
			return formatTxtBodyHeaderValue(tempValue);
		} else if (body) {
			return formatTxtBodyValue(tempValue);
		} else {
			return formatTxtTrailerValue(tempValue);
		}
	}

	public String formatTxtHeaderValue(String tempValue) {
		if (tempValue.trim().length() == 0) {
			tempValue = String.format("%1$" + csvTxtLength + "s", "");
		} else {
			if (leftJustified) {
				tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
			} else {
				tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
			}
		}
		return tempValue;
	}

    public String formatTxtBodyHeaderValue(String tempValue) {
        if (fieldName != null) {
            if (fieldName.contains(ReportConstants.LINE)) {
                tempValue = String.format("%" + csvTxtLength + "s", " ").replace(' ', tempValue.charAt(0));
            } else {
                if (leftJustified) {
                    tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
                } else {
                    tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
                }
            }
        } else {
            tempValue = String.format("%1$-" + csvTxtLength + "s", "");
        }
        return tempValue;
    }

	public String formatTxtBodyValue(String tempValue) {
		if (leftJustified) {
			return formatLeftJustifiedTxtValue(tempValue);
		} else {
			return formatRightJustifiedTxtValue(tempValue);
		}
	}

	public String formatTxtTrailerValue(String tempValue) {
		if (tempValue.trim().length() == 0) {
			tempValue = String.format("%1$" + csvTxtLength + "s", "");
		} else {
			if (leftJustified) {
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

	public String formatRightJustifiedTxtValue(String tempValue) {
		if (padFieldLength > 0) {
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}

			if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
					&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
				tempValue = String.format("%1$" + csvTxtLength + "s",
						String.format("%1$" + padFieldLength + "s", tempValue).replace(' ', '0'));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
					&& padFieldValue.equals(PAD_VALUE_SPACES)) {
				tempValue = String.format("%1$" + csvTxtLength + "s",
						String.format("%1$" + padFieldLength + "s", tempValue));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
					&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
				tempValue = String.format("%1$" + csvTxtLength + "s",
						String.format("%1$-" + padFieldLength + "s", tempValue).replace(' ', '0'));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
					&& padFieldValue.equals(PAD_VALUE_SPACES)) {
				tempValue = String.format("%1$" + csvTxtLength + "s",
						String.format("%1$-" + padFieldLength + "s", tempValue));

			} else {
				tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
			}
		} else {
			tempValue = String.format("%1$" + csvTxtLength + "s", tempValue);
		}
		return tempValue;
	}

	public String formatLeftJustifiedTxtValue(String tempValue) {
		if (padFieldLength > 0) {
			if (tempValue.trim().length() == 0) {
				tempValue = " ";
			}

			if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
					&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
				tempValue = String.format("%1$-" + csvTxtLength + "s",
						String.format("%1$" + padFieldLength + "s", tempValue).replace(' ', '0'));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
					&& padFieldValue.equals(PAD_VALUE_SPACES)) {
				tempValue = String.format("%1$-" + csvTxtLength + "s",
						String.format("%1$" + padFieldLength + "s", tempValue));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
					&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
				tempValue = String.format("%1$-" + csvTxtLength + "s",
						String.format("%1$-" + padFieldLength + "s", tempValue).replace(' ', '0'));

			} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
					&& padFieldValue.equals(PAD_VALUE_SPACES)) {
				tempValue = String.format("%1$-" + csvTxtLength + "s",
						String.format("%1$-" + padFieldLength + "s", tempValue));

			} else {
				tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
			}
		} else {
			tempValue = String.format("%1$-" + csvTxtLength + "s", tempValue);
		}
		return tempValue;
	}

	public String formatFixCsvValue(String tempValue, boolean body) {
		if (fieldName != null) {
			if (body) {
				if (padFieldLength > 0) {
					if (tempValue.trim().length() == 0) {
						tempValue = " ";
					}

					if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
							&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
						tempValue = String.format("%1$" + padFieldLength + "s", tempValue).replace(' ', '0');

					} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_LEADING)
							&& padFieldValue.equals(PAD_VALUE_SPACES)) {
						tempValue = String.format("%1$" + padFieldLength + "s", tempValue);

					} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
							&& padFieldValue.equals(PAD_VALUE_ZEROS)) {
						tempValue = String.format("%1$-" + padFieldLength + "s", tempValue).replace(' ', '0');

					} else if (tempValue.trim().length() <= padFieldLength && padFieldType.equals(PAD_TYPE_TRAILING)
							&& padFieldValue.equals(PAD_VALUE_SPACES)) {
						tempValue = String.format("%1$-" + padFieldLength + "s", tempValue);

					} else {
						return tempValue;
					}
				} else {
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
		return "ReportGenerationFields [reportCategory=" + reportCategory + ", fileName=" + fileName
				+ ", fileNamePrefix=" + fileNamePrefix + ", fileFormat=" + fileFormat + ", fileFormatTmp="
				+ fileFormatTmp + ", fileLocation=" + fileLocation + ", processingClass=" + processingClass
				+ ", frequency=" + frequency + ", headerFields=" + headerFields + ", bodyFields=" + bodyFields
				+ ", trailerFields=" + trailerFields + ", bodyQuery=" + bodyQuery + ", trailerQuery=" + trailerQuery
				+ ", tmpBodyQuery=" + tmpBodyQuery + ", sequence=" + sequence + ", sectionName=" + sectionName
				+ ", fieldName=" + fieldName + ", csvTxtLength=" + csvTxtLength + ", pdfLength=" + pdfLength
				+ ", fieldType=" + fieldType + ", value=" + value + ", delimiter=" + delimiter + ", fieldFormat="
				+ fieldFormat + ", defaultValue=" + defaultValue + ", firstField=" + firstField + ", bodyHeader="
				+ bodyHeader + ", eol=" + eol + ", endOfSection=" + endOfSection + ", leftJustified=" + leftJustified
				+ ", padFieldLength=" + padFieldLength + ", padFieldType=" + padFieldType + ", padFieldValue="
				+ padFieldValue + ", decrypt=" + decrypt + ", decryptionKey=" + decryptionKey + ", tagValue=" + tagValue
				+ ", source=" + source + ", fileDate=" + fileDate + ", txnStartDate=" + txnStartDate + ", txnEndDate="
				+ txnEndDate + ", todayDate=" + todayDate + ", yesterdayDate=" + yesterdayDate + ", generate="
				+ generate + "]";
	}

	public ReportGenerationFields clone() {
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
		field.setLeftJustified(leftJustified);
		field.setPadFieldLength(padFieldLength);
		field.setPadFieldType(padFieldType);
		field.setPadFieldValue(padFieldValue);
		field.setDecrypt(decrypt);
		field.setDecryptionKey(decryptionKey);
		field.setTagValue(tagValue);
		field.setSource(source);
		return field;
	}
}
