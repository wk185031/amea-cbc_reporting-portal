package my.com.mandrill.base.reporting;

public final class ReportConstants {

	private ReportConstants() {
	}

	// DB Configuration
	public static final String DB_URL = "spring.datasource.url";
	public static final String DB_USERNAME = "spring.datasource.username";
	public static final String DB_PASSWORD = "spring.datasource.password";

	// DB Synchronizer
	public static final String JOB_NAME = "DB_SYNC";
	public static final String STATUS_IN_PROGRESS = "IN PROGRESS";
	public static final String STATUS_COMPLETED = "COMPLETED";
	public static final String REPORTS_GENERATED = "REPORTS GENERATED";
	public static final String STATUS_ACTIVE = "ACTIVE";
	public static final String CREATED_BY_USER = "system";

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
	public static final String DATE_FORMAT_12 = "MMddyyyy";
	public static final String FORMAT_TXN_DATE = "YYYYMMDD HH24:MI:SS";

	// Report Generation Parameter
	public static final String PARAM_FILE_DATE = "FileDate";
	public static final String PARAM_TXN_DATE = "Txn_Date";
	public static final String PARAM_BRANCH_CODE = "Branch_Code";
	public static final String PARAM_BRANCH_NAME = "Branch_Name";
	public static final String PARAM_TERMINAL = "Terminal";
	public static final String PARAM_CARD_PRODUCT = "Card_Product";
	public static final String PARAM_GL_DESCRIPTION = "GL_Description";
	public static final String PARAM_CHANNEL = "Channel";
	public static final String PARAM_BILLER = "Biller";

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
	public static final String FILE_NAME = "File Name";
	public static final String FILE_UPLOAD_DATE = "File Upload Date";
	public static final String AC_NUMBER = "A/C Number";
	public static final String TRAN_AMOUNT = "Tran Amount";
	public static final String TRAN_PARTICULAR = "Tran Particular";
	public static final String TRAN_REMARKS = "Tran Remarks";
	public static final String THIRD_PARTY_TRAN_DESCRIPTION = "Third Party Tran Description";
	public static final String GROUP_ID = "GROUP_ID";
	public static final String FILE_HASH = "File Hash";
	public static final String NO_OF_DATA_RECORDS = "Number of Data Records";
	public static final String LINE = "Line";
	public static final String BRANCH_CODE = "BRANCH CODE";
	public static final String BRANCH_NAME = "BRANCH NAME";
	public static final String TERMINAL = "TERMINAL";
	public static final String CARD_PRODUCT = "CARD PRODUCT";
	public static final String GL_ACCOUNT_NUMBER = "GL ACCOUNT NUMBER";
	public static final String GL_ACCOUNT_NAME = "GL ACCOUNT NAME";
	public static final String CODE = "CODE";
	public static final String ACCOUNT_NUMBER = "ACCOUNT NUMBER";
	public static final String DESCRIPTION = "DESCRIPTION";
	public static final String ATM_CARD_NUMBER = "ATM CARD NUMBER";
	public static final String ACCOUNT = "ACCOUNT";
	public static final String FROM_ACCOUNT_NO = "FROM ACCOUNT NO";
	public static final String TO_ACCOUNT_NO = "TO ACCOUNT NO";
	public static final String SEQ_NUMBER = "SEQ NUMBER";
	public static final String TRACE_NUMBER = "TRACE NUMBER";
	public static final String COMMENT = "COMMENT";
	public static final String DEBIT = "DEBIT";
	public static final String CREDIT = "CREDIT";
	public static final String DEBITS = "DEBITS";
	public static final String CREDITS = "CREDITS";
	public static final String TOTAL_DEBIT = "TOTAL DEBIT";
	public static final String TOTAL_CREDIT = "TOTAL CREDIT";
	public static final String CUSTOM_DATA = "CUSTOM DATA";
	public static final String BP_BILLER_CODE = "BILLER CODE";
	public static final String BANK_NAME = "BANK NAME";
	public static final int PAGE_HEIGHT_THRESHOLD = 70;

	// Custom Data
	public static final String BILLER_CODE = "BILLERCODE";

	// Result Code Description
	public static final String APPROVED = "Approved";

	// Query
	public static final String SUBSTRING_SELECT = "SELECT";
	public static final String SUBSTRING_END = "END";
	public static final String SUBSTRING_START = "START";
	public static final String SUBSTRING_SECOND_QUERY_START = "START SELECT";

	// GL Constants
	public static final String INTER_ENTITY_AP_ATM_WITHDRAWAL = "INTER-ENTITY AP ATM WITHDRAWAL";
	public static final String INTER_ENTITY_AR_ATM_WITHDRAWAL = "INTER-ENTITY AR ATM WITHDRAWAL";
	public static final String INTER_ENTITY_FUND_TRANSFER_DR = "INTER-ENTITY FUND TRANSFER DR";
	public static final String INTER_ENTITY_FUND_TRANSFER_CR = "INTER-ENTITY FUND TRANSFER CR";
	public static final String BANCNET_INTERBANK_TRANSFER_DR = "BANCNET INTERBANK TRANSFER DR";
	public static final String BANCNET_INTERBANK_TRANSFER_CR = "BANCNET INTERBANK TRANSFER CR";
	public static final String CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL = "CC ON-US/INTRBRNCH WITHDRAWAL";
	public static final String IE_BEEP_LOADING = "I/E BEEP LOADING";
	public static final String IE_BEEP_SERVICE_CHARGE = "I/E BEEP SERVICE CHARGE";
	public static final String ATM_PAY_TO_MOBILE_WITHDRAWAL = "ATM PAY TO MOBILE WITHDRAWAL";
	public static final String ATM_EMERGENCY_CASH_WITHDRAWAL = "ATM EMERGENCY CASH WITHDRAWAL";
	public static final String MBK_PAY_TO_MOBILE_OB_DEPOSIT = "MBK PAY TO MOBILE - OB DEPOSIT";

	// TBC
	public static final String ATM_BILLS_PAYMENT = "ATM BILLS PAYMENT";
	public static final String BIR_REMITTANCE = "BIR REMITTANCE";
	public static final String BANCNET_EGOV_PHILHEALTH = "BANCNET EGOV-PHILHEALTH";
	public static final String BANCNET_EGOV_PAG_IBIG = "BANCNET EGOV-PAG IBIG";
	public static final String BANCNET_EGOV_SSS = "BANCNET EGOV - SSS";

	// Constants
	public static final String DEBIT_IND = "debit";
	public static final String CREDIT_IND = "credit";
}
