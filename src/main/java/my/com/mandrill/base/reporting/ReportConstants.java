package my.com.mandrill.base.reporting;

public final class ReportConstants {

	private ReportConstants() {
	}

	// DB Configuration
	public static final String DB_URL = "spring.datasource.url";
	public static final String DB_USERNAME = "spring.datasource.username";
	public static final String DB_PASSWORD = "spring.datasource.password";

	// Report Category
	public static final String GL_HANDOFF_FILES = "GL Handoff Files";
			
	// Report Generation Time
	public static final String START_TIME = "00:00:00";
	public static final String END_TIME = "23:59:59";

	// Report Generation Date Format
	public static final String DATE_FORMAT_01 = "yyyyMMdd";
	public static final String DATE_FORMAT_02 = "_yyyyMMdd";
	public static final String DATE_FORMAT_03 = "yyMMdd";
	public static final String DATE_FORMAT_04 = "_yyMMdd";
	public static final String DATE_FORMAT_05 = "_yyMM";
	public static final String DATE_FORMAT_06 = "_yyMMdd_HHmm";
	public static final String DATE_FORMAT_07 = "yyyyMMdd HH:mm:ss";
	public static final String DATE_FORMAT_08 = "dd/MM/yyyy";
	public static final String DATE_FORMAT_09 = "dd/MM/yy HH:mm";
	public static final String DATE_FORMAT_10 = "dd/MM/yy";
	public static final String DATE_FORMAT_11 = "_ddMMyy";
	public static final String FORMAT_TXN_DATE = "YYYYMMDD HH24:MI:SS";

	// Report Generation Parameter
	public static final String PARAM_FILE_DATE = "FileDate";
	public static final String PARAM_TXN_DATE = "Txn_Date";
	public static final String PARAM_BRANCH_CODE = "Branch_Code";
	public static final String PARAM_BRANCH_NAME = "Branch_Name";
	public static final String PARAM_TERMINAL = "Terminal";

	// Report Definition Section
	public static final String SECTION_NAME = "name";
	public static final String FIELD_NAME = "fieldName";
	public static final String FIELD_LENGTH_PDF = "fieldLengthPdf";
	public static final String FIELD_LENGTH_CSV_TXT = "fieldLengthCsvTxt";
	public static final String FIELD_TYPE = "fieldType";
	public static final String FIELD_DELIMITER = "fieldDelimiter";
	public static final String FIELD_DEFAULT_VALUE = "fieldDefaultValue";
	public static final String FIELD_FIRST = "fieldfirst";
	public static final String FIELD_BODY_HEADER = "fieldBodyHeader";
	public static final String FIELD_END_OF_LINE = "fieldEndOfLine";
	public static final String FIELD_END_OF_BODY_HEADER = "fieldEndOfBodyHeader";

	// Report Format
	public static final String FILE_PDF = "PDF";
	public static final String FILE_CSV = "CSV";
	public static final String FILE_TXT = "TXT";
	public static final String PDF_FORMAT = ".pdf";
	public static final String CSV_FORMAT = ".csv";
	public static final String TXT_FORMAT = ".txt";

	// Report Fields
	public static final String PAGE_NUMBER = "Page Number";
	public static final String TODAYS_DATE_VALUE = "Todays Date Value";
	public static final String AS_OF_DATE_VALUE = "As of Date Value";
	public static final String RUNDATE_VALUE = "RunDate Value";
	public static final String TIME_VALUE = "Time Value";
	public static final String FILE_UPLOAD_DATE = "File Upload Date";
	public static final String FILE_NAME = "File Name";
	public static final String NO_OF_DATA_RECORDS = "Number of Data Records";
	public static final String LINE = "Line";
	public static final String GL_ACCOUNT_NUMBER = "GL ACCOUNT NUMBER";
	public static final String GL_ACCOUNT_NAME = "GL ACCOUNT NAME";
	public static final String DESCRIPTION = "DESCRIPTION";
	public static final String BRANCH_CODE = "BRANCH CODE";
	public static final String BRANCH_NAME = "BRANCH NAME";
	public static final String TERMINAL = "TERMINAL";
	public static final String COMMENT = "COMMENT";
	public static final int SUCCESS_THRESHOLD = 70;
}
