package my.com.mandrill.base.reporting;

public final class ReportConstants {

	private ReportConstants() {
	}
	
	// System Configuration
	public static final String ALLOW_CONCURRENT_LOGIN = "spring.application.allow-concurrent-login";

	// DB Configuration
	public static final String DB_URL = "spring.datasource.url";
	public static final String DB_USERNAME = "spring.datasource.username";
	public static final String DB_PASSWORD = "spring.datasource.password";
	public static final String DB_LINK_AUTHENTIC = "spring.datasource.dblink.authentic";
	public static final String DB_SCHEMA_AUTHENTIC = "spring.datasource.schema.authentic";
	public static final String DB_SCHEMA_DCMS = "spring.datasource.schema.dcms";
	public static final String DB_LINK_DCMS = "spring.datasource.dblink.dcms";

	// DB Synchronizer
	public static final String JOB_NAME_DB_SYNC = "DB_SYNC";
	public static final String JOB_NAME_REPORT_GENERATE = "REPORT_GENERATE";
	public static final String STATUS_IN_PROGRESS = "IN PROGRESS";
	public static final String STATUS_COMPLETED = "COMPLETED";
	public static final String STATUS_FAILED = "FAILED";
	public static final String REPORTS_GENERATED = "REPORTS GENERATED";
	public static final String STATUS_ACTIVE = "ACTIVE";
	public static final String CREATED_BY_USER = "system";

	// Report Generation Frequency
	public static final String DAILY = "Daily";
	public static final String WEEKLY = "Weekly";
	public static final String MONTHLY = "Monthly";
	public static final String MONDAY = "MONDAY";
	public static final String SATURDAY = "SATURDAY";
	public static final String SUNDAY = "SUNDAY";


	// Report Generation Time
	public static final String START_TIME = "00:00:00";
	public static final String END_TIME = "23:59:59";

	// Report Generation Institution
	public static final String CBC_INSTITUTION = "ChinaBank (CBC)";
	public static final String CBS_INSTITUTION = "China Bank Savings (CBS)";
	public static final String DCMS_CBC_INSTITUTION = "1";
	public static final String DCMS_CBS_INSTITUTION = "2";

	// Report Generation Date Format
	public static final String DATE_FORMAT_01 = "yyyyMMdd";
	public static final String DATE_FORMAT_02 = "yyyy-MM-dd";
	public static final String DATE_FORMAT_03 = "MMddyyyy";
	public static final String DATE_FORMAT_04 = "MMdd";
	public static final String DATE_FORMAT_05 = "HH:mm";
	public static final String DATE_FORMAT_06 = "yyyy-MM";
	public static final String DATE_FORMAT_07 = "dd";
    public static final String DATE_FORMAT_08 = "HH";
	public static final String DATETIME_FORMAT_01 = "yyyyMMdd HH:mm:ss";
    public static final String DATETIME_FORMAT_02 = "yyyyMMdd hh:mm a";
    public static final String DATETIME_FORMAT_03 = "yyyyMMdd HH:mm a";
    public static final String DATETIME_FORMAT_04 = "MMdd HH:mm a";
    public static final String DATETIME_FORMAT_05 = "yyyyMMdd hhmma";
	public static final String FORMAT_TXN_DATE = "YYYYMMDD HH24:MI:SS";

	// Report Generation Path
	public static final String MAIN_PATH = "MAIN";

	// Report Generation Parameter
	public static final String PARAM_FILE_DATE = "FileDate";
	public static final String PARAM_TXN_DATE = "Txn_Date";
	public static final String PARAM_RECEIVING_BRANCH_CODE = "Receiving_Branch_Code";
	public static final String PARAM_BRANCH_CODE = "Branch_Code";
	public static final String PARAM_BRANCH_NAME = "Branch_Name";
	public static final String PARAM_BANK_CODE = "Bank_Code";
	public static final String PARAM_ACQ_BANK_CODE = "Acq_Bank_Code";
	public static final String PARAM_TERMINAL = "Terminal";
	public static final String PARAM_CARD_PRODUCT = "Card_Product";
	public static final String PARAM_TRANSACTION_GROUP = "Transaction_Group";
	public static final String PARAM_GL_DESCRIPTION = "GL_Description";
	public static final String PARAM_CHANNEL = "Channel";
	public static final String PARAM_TXN_TYPE = "Txn_Type";
	public static final String PARAM_BILLER_CODE = "Biller_Code";
	public static final String PARAM_IBFT_CRITERIA = "IBFT_Criteria";
	public static final String PARAM_FIELD_CRITERIA = "Field_Criteria";
	public static final String PARAM_JOIN_CRITERIA = "Join_Criteria";
	public static final String PARAM_CORPORATE_COUNT = "Corporate_Count";
	public static final String PARAM_CORPORATE_INCOME = "Corporate_Income";
	public static final String PARAM_TXN_CRITERIA = "Txn_Criteria";
	public static final String PARAM_MERCHANT = "Merchant";
	public static final String PARAM_CIF = "CIF_No";
	public static final String PARAM_TO_ACCOUNT = "To_Account";
	public static final String PARAM_ACC_TYPE = "Acc_Type";
	public static final String PARAM_DEO_NAME = "Deo_Name";
	public static final String PARAM_ISSUER_NAME = "Iss_Name";
	public static final String PARAM_ISSUER_ID = "Iss_Id";
	public static final String PARAM_FROM_DATE = "From_Date";
	public static final String PARAM_TO_DATE = "To_Date";
	public static final String PARAM_DCMS_DB_SCHEMA = "DCMS_Schema";
	public static final String PARAM_DB_LINK_DCMS = "DB_LINK_DCMS";
    public static final String PARAM_AUTH_DB_SCHEMA = "AUTH_Schema";
    public static final String PARAM_DB_LINK_AUTH = "DB_LINK_AUTH";
	public static final String PARAM_TOTAL_DAY = "Total_Day";
	public static final String PARAM_TXN_END_DATE = "Txn_End_Date";
	public static final String PARAM_DOWN_REASON = "DOWN_REASON";
	public static final String PARAM_TXN_TIME = "Txn_Time";
	public static final String PARAM_BANK_MNEM = "Bank_Mnem";
	public static final String PARAM_BRANCH_INST_FILTER = "Branch_Inst_Filter";

	public static final String VALUE_DEO_NAME = "V_Deo_Name";
	public static final String VALUE_INTER_DEO_NAME = "V_IE_Deo_Name";
	public static final String VALUE_ISSUER_NAME = "V_Iss_Name";
	public static final String VALUE_INTER_ISSUER_NAME = "V_IE_Iss_Name";
	public static final String VALUE_ACQUIRER_NAME = "V_Acq_Name";
	public static final String VALUE_INTER_ACQUIRER_NAME = "V_IE_Acq_Name";
	public static final String VALUE_GLA_INST = "V_Gla_Inst";
	public static final String VALUE_ACQR_INST_ID = "V_Acqr_Inst_Id";
	public static final String VALUE_INTER_ACQR_INST_ID = "V_IE_Acqr_Inst_Id";
	public static final String VALUE_RECV_INST_ID = "V_Recv_Inst_Id";
	public static final String VALUE_INTER_RECV_INST_ID = "V_IE_Recv_Inst_Id";

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
	public static final String DPS_FORMAT = ".dps";
	public static final String SUM_FORMAT = ".sum";

	// Report Fields
	public static final String TOTAL_PAYMENTS = "Total Payments";
	public static final String PAGE_NUMBER = "Page Number";
	public static final String FROM_DATE = "From Date";
	public static final String TO_DATE = "To Date";
	public static final String POSTING_DATE = "Posting Date";
	public static final String REPORT_TO_DATE = "Report To Date";
	public static final String TODAYS_DATE_VALUE = "Todays Date Value";
	public static final String AS_OF_DATE_VALUE = "As of Date Value";
	public static final String RUNDATE_VALUE = "RunDate Value";
	public static final String TIME_VALUE = "Time Value";
	public static final String REPORT_ID = "Report Id";
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
	public static final String REGION = "REGION";
	public static final String BRANCH_CODE = "BRANCH CODE";
	public static final String BRANCH_NAME = "BRANCH NAME";
	public static final String BRANCH = "BRANCH";
	public static final String TERMINAL = "TERMINAL";
	public static final String TRANSACTION_GROUP = "TRANSACTION GROUP";
	public static final String LOCATION = "LOCATION";
	public static final String CHANNEL = "CHANNEL";
	public static final String CARD_PRODUCT = "CARD PRODUCT";
	public static final String GL_ACCOUNT_NUMBER = "GL ACCOUNT NUMBER";
	public static final int GL_ACCOUNT_NUMBER_MAX_LENGTH = 14;
	public static final String GL_ACCOUNT_NAME = "GL ACCOUNT NAME";
	public static final String CODE = "CODE";
	public static final String DESCRIPTION = "DESCRIPTION";
	public static final String ATM_CARD_NUMBER = "ATM CARD NUMBER";
	public static final String ACCOUNT_NAME = "ACCOUNT NAME";
	public static final String FROM_ACCOUNT_NO = "FROM ACCOUNT NO";
	public static final String TO_ACCOUNT_NO = "TO ACCOUNT NO";
	public static final String TO_ACCOUNT_NO_EKY_ID = "TRL_ACCOUNT_2_ACN_ID_EKY_ID";
	public static final String TO_ACCOUNT_TYPE = "TO ACC TYPE";
	public static final String SEQ_NUMBER = "SEQ NUMBER";
	public static final String TRACE_NUMBER = "TRACE NUMBER";
	public static final String COMMENT = "COMMENT";
	public static final String DEBITS = "DEBITS";
	public static final String CREDITS = "CREDITS";
	public static final String TOTAL_DEBIT = "TOTAL DEBIT";
	public static final String TOTAL_CREDIT = "TOTAL CREDIT";
	public static final String TOTAL_AMOUNT = "TOTAL AMOUNT";
	public static final String SUB_TOTAL = "SUB-TOTAL";
	public static final String OVERALL_TOTAL = "OVER-ALL TOTAL";
	public static final String BP_BILLER_CODE = "BILLER CODE";
	public static final String BP_BILLER_MNEM = "BILLER MNEM";
	public static final String BP_BILLER_NAME = "BILLER NAME";
	public static final String BANK_CODE = "BANK CODE";
	public static final String BANK_CODE_ACQ = "BANK CODE ACQ";
	public static final String BANK_NAME = "BANK NAME";
	public static final String BANK_NAME_ACQ = "BANK NAME ACQ";
	public static final String ACQUIRER_BANK_MNEM = "ACQUIRER BANK MNEM";
	public static final String AMOUNT = "AMOUNT";
	public static final String REV_AMOUNT = "REV AMOUNT";
	public static final String DR_AMOUNT = "DR AMOUNT";
	public static final String CR_AMOUNT = "CR AMOUNT";
	public static final String VOID_CODE = "VOID CODE";
	public static final String TOTAL = "TOTAL";
	public static final String TOTAL_TRAN = "TOTAL TRAN";
	public static final String AR_PER_TERMINAL = "A/R PER TERMINAL";
	public static final String TOTAL_AR_AMOUNT = "TOTAL A/R AMOUNT";
	public static final String TRANSMITTING_TOTAL = "TRANSMITTING TOTAL";
	public static final String RECEIVING_TOTAL = "RECEIVING TOTAL";
	public static final String NET_SETTLEMENT = "NET SETTLEMENT";
	public static final String NET_COUNT = "NET COUNT";
	public static final String DEBIT_CREDIT = "DEBIT CREDIT";
	public static final String TXN_QUALIFIER = "TXN QUALIFIER";
	public static final String ACQUIRER_BANK = "ACQUIRER BANK";
	public static final String SUBSCRIBER_ACCT_NUMBER = "SUBSCRIBER ACCT NUMBER";
	public static final String ISSUER_BRANCH_CODE = "ISSUER BRANCH CODE";
	public static final String ISSUER_BRANCH_NAME = "ISSUER BRANCH NAME";
	public static final String RECEIVING_BRANCH_CODE = "RECEIVING BRANCH CODE";
	public static final String RECEIVING_BRANCH_NAME = "RECEIVING BRANCH NAME";
	public static final String BANCNET_FEE = "BANCNET FEE";
	public static final String ISSUER_EXPENSE = "ISSUER EXPENSE";
	public static final String ISSUER_INCOME = "ISSUER INCOME";
	public static final String CORP_INCOME = "CORP. INCOME";
	public static final String BEG_BALANCE = "BEG. BALANCE";
	public static final String BALANCE = "BALANCE";
	public static final String CIF_NO = "CIF NO";
	public static final String CUSTOMER_ID = "CUSTOMER ID";
	public static final String CLIENT_NAME = "CLIENT'S NAME";
	public static final String CUSTOMER_NAME = "CUSTOMER NAME";
	public static final String TRANSACTION_TYPE = "TRANSACTION TYPE";
	public static final String REASON = "REASON";
	public static final String MERCHANT_NAME = "MERCHANT NAME";
	public static final String POS_COMMISSION = "COMMISSION";
	public static final String POS_REV_COMMISSION = "REV COMMISSION";
	public static final String POS_COMMISSION_AMOUNT = "COMMISSION AMOUNT";
	public static final String POS_NET_SETT_AMT = "NET SETT AMOUNT";
	public static final String TRAN_COUNT = "TRAN COUNT";
	public static final String REV_TRAN_COUNT = "REV TRAN COUNT";
	public static final String TRANSMITTING_COUNT = "TRANSMITTING COUNT";
	public static final String TRANSMITTING_EXPENSE = "TRANSMITTING EXPENSE";
	public static final String TRANSMITTING_INCOME = "TRANSMITTING INCOME";
	public static final String ACQUIRER_COUNT = "ACQUIRER COUNT";
	public static final String ACQUIRER_INCOME = "ACQUIRER INCOME";
	public static final String RECEIVING_COUNT = "RECEIVING COUNT";
	public static final String RECEIVING_INCOME = "RECEIVING INCOME";
	public static final String TOTAL_BILLING = "TOTAL BILLING";
	public static final String TIME_UP = "TIME UP";
	public static final String TIME_DOWN = "TIME DOWN";
	public static final String TOTAL_DOWN_TIME = "TOTAL DOWN TIME";
	public static final String ITEMS = "ITEMS";
	public static final String HOUR = "HOUR";
	public static final String MINUTE = "MINUTE";
	public static final String SECOND = "SECOND";
	public static final String OUTAGE_HOUR = "OUTAGE HOUR";
	public static final String OUTAGE_MINUTE = "OUTAGE MINUTE";
	public static final String PERCENTAGE = "PERCENTAGE";
	public static final String AVAILABLE = "AVAILABLE";
	public static final String UNAVAILABLE = "UNAVAILABLE";
	public static final String STANDARD = "STANDARD";
	public static final int PAGE_HEIGHT_THRESHOLD = 70;
	public static final String PRODUCT_CODE = "PRODUCT_CODE";
	public static final String PRODUCT_NAME = "PRODUCT_NAME";
	public static final String CAUSE = "CAUSE";
	public static final String CAUSE_TERMINAL_TOTAL = "SUB TOTAL";
	public static final String TRAN_MNEM = "TRAN MNEM";
	public static final String VALUE_DATE = "Value Date";
	public static final String TRAN_DATE = "TRAN_DATE";
	public static final String CASH_DISPENSED_AMOUNT = "CASH DISPENSED";
	public static final String DEPOSITS_AMOUNT = "DEPOSITS";
	public static final String BILL_PAYMENTS_AMOUNT = "BILL PAYMENTS";
	public static final String TRANSFERS_AMOUNT = "TRANSFERS";
	public static final String REVERSAL_SIGN_CD = "REVERSAL SIGN CD";
	public static final String REVERSAL_SIGN_DP = "REVERSAL SIGN DP";
	public static final String REVERSAL_SIGN_BP = "REVERSAL SIGN BP";
	public static final String REVERSAL_SIGN_TRFR = "REVERSAL SIGN TRFR";

	// Channels
	public static final String CHINABANK_ATM = "ChinaBank ATM";
	public static final String CHINABANK_EBK = "ChinaBank Online";
	public static final String CHINABANK_MBK = "Mobile Banking";
	public static final String CHINABANK_IVR = "Tellerphone";
	public static final String BANCNET_ATM = "Other Bank ATM";
	public static final String BANCNET_EBK = "BancNet Online";
	public static final String ATM = "ATM";
	public static final String CAM = "CAM";
	public static final String CDM = "CDM";
	public static final String EBK = "EBK";
	public static final String MBK = "MBK";
	public static final String IVR = "IVR";
	public static final String OB = "OB";

	// Custom Data
	public static final String CUSTOM_DATA = "CUSTOM DATA";
	public static final String ORIGIN_CHANNEL = "ORIG_CHAN";
	public static final String BILLER_CODE = "BILLERCODE";
	public static final String COMMISSION = "Commission";
	public static final String DEPOSITORY_BANK = "DepositoryBank";

	// Result Code Description
	public static final String APPROVED = "Approved";
	public static final String FULL_REVERSAL = "Full Reversal";

	// Query
	public static final String SUBSTRING_SELECT = "SELECT";
	public static final String SUBSTRING_END = "END";
	public static final String SUBSTRING_START = "START";
	public static final String SUBSTRING_SECOND_QUERY_START = "START SELECT";
	
	public static final String SUBSTRING_START_ACQ = "START ACQ";
	public static final String SUBSTRING_START_ISS = "START ISS";
	public static final String SUBSTRING_SECOND_QUERY_ACQ = "START ACQ SELECT";
	public static final String SUBSTRING_SECOND_QUERY_ISS = "START ISS SELECT";
	public static final String SUBSTRING_END_ACQ = "END ACQ";
	
	// Query - AtmDowntime
	public static final String SUBSTRING_STARTING = "STARTING";
	public static final String SUBSTRING_SECOND_QUERY_STARTING = "STARTING SELECT";

	// GL Constants
	public static final String INTER_ENTITY_IBFT_CHARGE = "INTER-ENTITY IBFT CHARGE";
	public static final String INTER_ENTITY_INQUIRY_CHARGE = "INTER-ENTITY INQUIRY CHARGE";
	public static final String INTER_ENTITY_SERVICE_CHARGE = "INTER-ENTITY SERVICE CHARGE";
	public static final String INTER_ENTITY_AP_ATM_WITHDRAWAL = "INTER-ENTITY AP ATM WITHDRAWAL";
	public static final String INTER_ENTITY_AR_ATM_WITHDRAWAL = "INTER-ENTITY AR ATM WITHDRAWAL";
	public static final String INTER_ENTITY_FUND_TRANSFER_DR = "INTER-ENTITY FUND TRANSFER DR";
	public static final String INTER_ENTITY_FUND_TRANSFER_CR = "INTER-ENTITY FUND TRANSFER CR";
	public static final String BANCNET_INTERBANK_TRANSFER_DR = "BANCNET INTERBANK TRANSFER DR";
	public static final String BANCNET_INTERBANK_TRANSFER_CR = "BANCNET INTERBANK TRANSFER CR";
	public static final String CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL = "CC ON-US/INTRBRNCH WITHDRAWAL";
	public static final String CASH_CARD_BANCNET_INQUIRY_CHARGE = "CC BANCNET INQUIRY CHARGE";
	public static final String IE_BEEP_LOADING = "I/E BEEP LOADING";
	public static final String IE_BEEP_SERVICE_CHARGE = "I/E BEEP SERVICE CHARGE";
	public static final String ATM_PAY_TO_MOBILE_WITHDRAWAL = "ATM PAY TO MOBILE WITHDRAWAL";
	public static final String ATM_EMERGENCY_CASH_WITHDRAWAL = "ATM EMERGENCY CASH WITHDRAWAL";
	public static final String MBK_PAY_TO_MOBILE_OB_DEPOSIT = "MBK PAY TO MOBILE - OB DEPOSIT";

	// GL Bills Payment Constants
	public static final String ATM_BILLS_PAYMENT = "ATM BILLS PAYMENT";
	public static final String BIR_REMITTANCE = "BIR REMITTANCE";
	public static final String BANCNET_EGOV_PHILHEALTH = "BANCNET EGOV-PHILHEALTH";
	public static final String BANCNET_EGOV_PAG_IBIG = "BANCNET EGOV-PAG IBIG";
	public static final String BANCNET_EGOV_SSS = "BANCNET EGOV - SSS";

	// Constants
	public static final String DEBIT_IND = "debit";
	public static final String CREDIT_IND = "credit";
	public static final String SEPARATOR = ",";
	public static final String NO_RECORD = "**NO TRANSACTIONS FOR THE DAY**";
	
	public static final String SECUREFIELD = "secure-field";
	
	// Report Name
	public static final String ATM_DAILY_TRANSACTION_SUMMARY = "ATM Daily Transaction Summary";
	public static final String ATM_MONTHLY_TRANSACTION_SUMMARY = "ATM Monthly Transaction Summary";
	public static final String ATM_MONTHLY_TRANSACTION_SUMMARY_REPORT_HEADER = "ATM MONTHLY TRANSACTION SUMMARY REPORT";

	
}
