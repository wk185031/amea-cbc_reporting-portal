package my.com.mandrill.base.reporting;

public class Column {

	public static final String STRING_TYPE = "String";
	public static final String NUMBER_TYPE = "Number";
	public static final String DATE_TYPE = "Date";
	public static final String REFERENCE = "Reference";
	public static final String ENCRYPTED_STRING_TYPE = "EncryptedString";

	private String columnName;
	private String type;
	private String source;
	private String sequenceName;
	private String format;
	private String defaultValue;

	public String getColumnName() {
		return this.columnName;
	}

	public String getSource() {
		return this.source;
	}

	public String getDefaultValue() {
		return this.defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public void setName(String columnName) {
		this.columnName = columnName;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public void setDbSequenceName(String sequenceName) {
		this.sequenceName = sequenceName;
	}

	public String getDbSequenceName() {
		return this.sequenceName;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public void setFormat(String format) {
		this.format = format;
	}

	public String getFormat() {
		return format;
	}
}
