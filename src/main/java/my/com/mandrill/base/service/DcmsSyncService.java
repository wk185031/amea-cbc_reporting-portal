package my.com.mandrill.base.service;

import java.io.Reader;
import java.math.BigDecimal;
import java.sql.Clob;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

import javax.persistence.EntityManager;
import javax.persistence.Query;
import javax.transaction.Transactional;

import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.domain.DcmsUserActivity;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.repository.DcmsUserActivityRepository;

@Service
public class DcmsSyncService {

	private final Logger log = LoggerFactory.getLogger(DcmsSyncService.class);

	@Autowired
	private DcmsUserActivityRepository userActivityRepo;

	@Autowired
	private EntityManager em;

	@Autowired
	private Environment env;

	private static final String TABLE_DCMS_DEBIT_CARD = "ISSUANCE_CARD";

	private static final String COL_DCMS_DEBIT_CARD_UPDATED_TS = "CRD_UPDATED_TS";

	private static final String TABLE_DCMS_CASH_CARD = "ISSUANCE_CASH_CARD";

	private static final String COL_DCMS_CASH_CARD_UPDATED_TS = "CSH_UPDATED_TS";

	private static final String TABLE_LOCAL_USER_ACTIVITY = "dcms_user_activity";

	private static final String COL_LOCAL_USER_ACTIVITY_UPDATED_TS = "CREATED_DATE";

	private static final String TABLE_DCMS_ADDRESS_UPDATE = "SUPPORT_ADDRESS_UPDATE_REQ_MAP";

	private static final String COL_DCMS_ADDRESS_UPDATED_TS = "AUR_UPDATED_TS";

	private static final String TABLE_DCMS_CC_ADDRESS_UPDATE = "SUPPORT_CC_ADD_UPDATE_REQ_MAP";

	private static final String COL_DCMS_CC_ADDRESS_UPDATED_TS = "CC_AUR_UPDATED_TS";

	private static final String TABLE_DCMS_UPDATE_EMBOSS_NAME = "SUPPORT_UPDATE_EMBOSS_NAME";

	private static final String COL_DCMS_UPDATE_EMBOSS_NAME_TS = "UEN_UPDATED_TS";

	private static final String TABLE_DCMS_CC_UPDATE_EMBOSS_NAME = "SUPPORT_CC_UPDATE_EMBOSS_NAME";

	private static final String COL_DCMS_CC_UPDATE_EMBOSS_NAME_TS = "UEN_CC_UPDATED_TS";

	private static final String TABLE_ISSUANCE_CLIENT = "ISSUANCE_CLIENT";

	private static final String TABLE_ISSUANCE_MODIFY_CIF = "ISSUANCE_MODIFY_CIF";

	private static final String TABLE_ISSUANCE_CASH_CARD_ACCOUNT = "ISSUANCE_CASH_CARD_ACCOUNT";

	private static final String TABLE_ISSUANCE_CASH_CARD_BALANCE = "ISSUANCE_CASH_CARD_BALANCE";
	
	private static final String TABLE_USER_ACTIVITY_LOGS = "USER_ACTIVITY_LOGS";

	private static final String COL_DCMS_ISSUANCE_CLIENT_TS = "CLT_UPDATED_TS";

	private static final String COL_DCMS_ISSUANCE_MODIFY_CIF_TS = "MOC_UPDATED_TS";

	private static final String COL_DCMS_ISSUANCE_CASH_CARD_ACCOUNT_TS = "CAC_UPDATED_TS";

	private static final String COL_DCMS_ISSUANCE_CASH_CARD_BALANCE_TS = "CCB_UPDATED_TS";
	
	private static final String COL_DCMS_USER_ACTIVITY_DATE = "AUD_USER_ACTIVTIY_DATE";

	private static final String SQL_SELECT_AUDIT_LOG_DEBIT_CARD = "select CRD_ID, CRD_AUDIT_LOG, CRD_INS_ID, CRD_UPDATED_TS, STF_LOGIN_NAME, CRD_NUMBER_ENC, CRD_KEY_ROTATION_NUMBER from {DB_SCHEMA}.ISSUANCE_CARD@{DB_LINK} left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CRD_UPDATED_BY=STF_ID or CRD_CREATED_BY=STF_ID where CRD_UPDATED_TS is not null ";

	private static final String SQL_SELECT_AUDIT_LOG_CASH_CARD = "select CSH_ID, CSH_AUDIT_LOG, CSH_INS_ID, CSH_UPDATED_TS, STF_LOGIN_NAME, CSH_CARD_NUMBER_ENC, CSH_KEY_ROTATION_NUMBER from {DB_SCHEMA}.ISSUANCE_CASH_CARD@{DB_LINK} left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CSH_UPDATED_BY=STF_ID or CSH_CREATED_BY=STF_ID where CSH_UPDATED_TS is not null ";

	private static final String SQL_SELECT_AUDIT_LOG_ADDRESS_UPDATE = "select null as CRD_ID, CLT_CIF_NUMBER, AUR_INS_ID, AUR_UPDATED_TS, STF_LOGIN_NAME, null as CRD_CARD_NUMBER_ENC, null as CRD_KEY_ROTATION_NUMBER from {DB_SCHEMA}.SUPPORT_ADDRESS_UPDATE_REQ_MAP@{DB_LINK} left join {DB_SCHEMA}.ISSUANCE_CLIENT@{DB_LINK} on AUR_CLT_ID=CLT_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on AUR_UPDATED_BY=STF_ID or AUR_CREATED_BY=STF_ID where TO_TIMESTAMP(AUR_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS')  > ? and AUR_STS_ID in (88,91)";

	private static final String SQL_SELECT_AUDIT_LOG_CC_ADDRESS_UPDATE = "select null as CRD_ID, CLT_CIF_NUMBER, CC_AUR_INS_ID, CC_AUR_UPDATED_TS, STF_LOGIN_NAME, null as CRD_CARD_NUMBER_ENC, null as CRD_KEY_ROTATION_NUMBER from {DB_SCHEMA}.SUPPORT_CC_ADD_UPDATE_REQ_MAP@{DB_LINK} left join {DB_SCHEMA}.ISSUANCE_CLIENT@{DB_LINK} on CC_AUR_CLT_ID=CLT_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CC_AUR_UPDATED_BY=STF_ID or CC_AUR_CREATED_BY=STF_ID where TO_TIMESTAMP(CC_AUR_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS')   > ? and CC_AUR_STS_ID in (88,91)";

	private static final String SQL_SELECT_AUDIT_LOG_UPDATE_EMBOSS_NAME = "select CRD_ID, null as CLT_CIF_NUMBER, UEN_INS_ID, UEN_UPDATED_TS, STF_LOGIN_NAME, CRD_NUMBER_ENC, CRD_KEY_ROTATION_NUMBER from {DB_SCHEMA}.SUPPORT_UPDATE_EMBOSS_NAME@{DB_LINK} left join {DB_SCHEMA}.ISSUANCE_CARD@{DB_LINK} on UEN_CRD_ID=CRD_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on UEN_UPDATED_BY=STF_ID or UEN_CREATED_BY=STF_ID where TO_TIMESTAMP(UEN_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS')  > ? and UEN_STS_ID in (88,91)";

	private static final String SQL_SELECT_AUDIT_LOG_CC_UPDATE_EMBOSS_NAME = "select CSH_ID, null as CLT_CIF_NUMBER, UEN_CC_INS_ID, UEN_CC_UPDATED_TS, STF_LOGIN_NAME, CSH_CARD_NUMBER_ENC, CSH_KEY_ROTATION_NUMBER from {DB_SCHEMA}.SUPPORT_CC_UPDATE_EMBOSS_NAME@{DB_LINK} left join {DB_SCHEMA}.ISSUANCE_CASH_CARD@{DB_LINK} on UEN_CC_CSH_ID=CSH_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on UEN_CC_UPDATED_BY=STF_ID or UEN_CC_CREATED_BY=STF_ID where TO_TIMESTAMP(UEN_CC_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS')  > ? and UEN_CC_STS_ID in (88,91)";
	
	private static final String SQL_SELECT_AUDIT_LOG_ISSUANCE_CLIENT = "select null as CRD_ID, CLT_CIF_NUMBER, CLT_INS_ID, CLT_UPDATED_TS, STF_LOGIN_NAME, null as CRD_CARD_NUMBER_ENC, null as CRD_KEY_ROTATION_NUMBER, CLT_AUDIT_LOG from {DB_SCHEMA}.ISSUANCE_CLIENT@{DB_LINK} left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CLT_UPDATED_BY=STF_ID or CLT_CREATED_BY=STF_ID where CLT_AUDIT_LOG is not null and CLT_UPDATED_TS > ?";

	private static final String SQL_SELECT_AUDIT_LOG_ISSUANCE_CLIENT_ATM = "SELECT NULL AS CRD_ID, CLT_CIF_NUMBER, CLT_INS_ID, CLT_UPDATED_TS, STF_LOGIN_NAME, null as CRD_CARD_NUMBER_ENC, null as CRD_KEY_ROTATION_NUMBER, CLT_AUDIT_LOG from {DB_SCHEMA}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK} join {DB_SCHEMA}.ISSUANCE_CARD@{DB_LINK} on CRD_ID = DCR_CRD_ID join {DB_SCHEMA}.ISSUANCE_CLIENT@{DB_LINK} on DCR_CLT_ID = CLT_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} ON DCR_CREATED_BY = STF_ID WHERE CLT_AUDIT_LOG is not null AND DCR_CREATED_TS > ? AND DCR_CRN_ID is null AND DCR_REQUEST_TYPE = 'Manual' AND DCR_STS_ID not in (67,69) AND CRD_KIT_NUMBER IS NOT NULL ";
	
	private static final String SQL_SELECT_AUDIT_LOG_ISSUANCE_CLIENT_CASH = "SELECT NULL AS CRD_ID, CLT_CIF_NUMBER, CLT_INS_ID, CLT_UPDATED_TS, STF_LOGIN_NAME, null as CRD_CARD_NUMBER_ENC, null as CRD_KEY_ROTATION_NUMBER, CLT_AUDIT_LOG from {DB_SCHEMA}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK} join {DB_SCHEMA}.ISSUANCE_CASH_CARD@{DB_LINK} on CSH_ID = CCR_CSH_ID join {DB_SCHEMA}.ISSUANCE_CLIENT@{DB_LINK} on CCR_CLT_ID = CLT_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} ON CCR_CREATED_BY = STF_ID WHERE CLT_AUDIT_LOG is not null AND CCR_CREATED_TS > ? AND CCR_CRN_ID is null AND CCR_REQUEST_TYPE = 'Manual' AND CCR_STS_ID not in (67,69) AND CSH_KIT_NUMBER IS NOT NULL ";

	private static final String SQL_SELECT_AUDIT_LOG_CARD_TRANSACTION_SET = "select cts_id as CRD_ID, null as CTS_CIF, CTS_INS_ID, CTS_UPDATED_TS, STF_LOGIN_NAME, null as CRD_CARD_NUMBER_ENC, null as CRD_KEY_ROTATION_NUMBER, CTS_AUDIT_LOG, CTS_NAME "
			+ "from {DB_SCHEMA}.CARD_TRANSACTION_SET@{DB_LINK} left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CTS_UPDATED_BY=STF_ID where CTS_AUDIT_LOG is not null and CTS_UPDATED_TS > ?";

	private static final String SQL_SELECT_FUNCTION_PATTERN = "select name,config from SYSTEM_CONFIGURATION where name like 'dcms.function.pattern%'";

	private static final String FUNCTION_FETCH_CIF = "Fetch CIF";

	private static final String FUNCTION_UPDATE_EMBOSS_NAME = "Update Emboss Name";

	private static final String FUNCTION_UPDATE_ADDRESS = "Update Address";

	private static final String FUNCTION_MODIFY_CIF = "Modify CIF";

	private static final String FUNCTION_UPDATE_CC_BALANCE = "Update CC Balance";

	private static final String FUNCTION_UPDATE_CC_ACC_STATUS = "Update CC Acc Sts";
	
	private static final String FUNCTION_PRE_GEN_ACTIVATION = "Pre-gen card activation";

	private DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

	private DateTimeFormatter FORMATTER_DDMMYY = DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss");

	private static final String RESET_PIN_COUNTER_PATTERN_STR = ".*(Reset Pin).*";

	private static final Pattern RESET_PIN_COUNTER_PATTERN = Pattern.compile(RESET_PIN_COUNTER_PATTERN_STR);

	private static final String REPIN_PATTERN_STR = ".*(Repin).*";

	private static final Pattern REPIN_PATTERN = Pattern.compile(REPIN_PATTERN_STR);

	private static final String SQL_SELECT_AUDIT_LOG_MODIFY_CIF = "select MOC_AUDIT_LOGS, MOC_INS_ID, MOC_UPDATED_TS, STF_LOGIN_NAME, MOC_CIF_NUMBER from {DB_SCHEMA}.ISSUANCE_MODIFY_CIF@{DB_LINK} left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on MOC_CREATED_BY=STF_ID where MOC_UPDATED_TS  > ? ";

	private static final String SQL_SELECT_AUDIT_LOG_CASH_CARD_BALANCE = "select CSH_ID, CCB_AUDIT_LOG, CCB_INS_ID, TO_TIMESTAMP (CCB_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS'), STF_LOGIN_NAME, CSH_CARD_NUMBER_ENC, CSH_KEY_ROTATION_NUMBER from {DB_SCHEMA}.ISSUANCE_CASH_CARD_BALANCE@{DB_LINK} join {DB_SCHEMA}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK} ON CAM_ID = CCB_CAM_ID join {DB_SCHEMA}.ISSUANCE_CASH_CARD@{DB_LINK} ON CSH_ID = CAM_CSH_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CCB_UPDATED_BY=STF_ID where TO_TIMESTAMP(CCB_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS') > ? AND CCB_AUDIT_LOG IS NOT NULL ";

	private static final String SQL_SELECT_AUDIT_LOG_CASH_CARD_ACC_STATUS = "select CSH_ID, CAC_AUDIT_LOG, CAC_INS_ID, CAC_UPDATED_TS, STF_LOGIN_NAME, CSH_CARD_NUMBER_ENC, CSH_KEY_ROTATION_NUMBER from {DB_SCHEMA}.ISSUANCE_CASH_CARD_ACCOUNT@{DB_LINK} join {DB_SCHEMA}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK} on CAM_CAC_ID = CAC_ID join {DB_SCHEMA}.ISSUANCE_CASH_CARD@{DB_LINK} ON CSH_ID = CAM_CSH_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CAC_UPDATED_BY=STF_ID where CAC_UPDATED_TS > ? AND CAC_AUDIT_LOG IS NOT NULL ";
	
	private static final String SQL_SELECT_AUDIT_LOG_USER_ACTIVITY_LOGS = "select TO_CHAR(AUD_USER_ACTIVITY), STF_INS_ID, STF_LOGIN_NAME, AUD_USER_ACTIVTIY_DATE FROM {DB_SCHEMA}.USER_ACTIVITY_LOGS@{DB_LINK} JOIN {DB_SCHEMA}.USER_STAFF@{DB_LINK} ON STF_ID = AUD_USER_ID where AUD_USER_ACTIVTIY_DATE > ? AND AUD_USER_ACTIVITY LIKE '%Kit Number%'";

	public void syncDcmsUserActivity() {
		Timestamp userActivityLastUpdatedTs = getLastUpdatedTs(TABLE_LOCAL_USER_ACTIVITY,
				COL_LOCAL_USER_ACTIVITY_UPDATED_TS, false, false);
		Timestamp dcmsDebitCardLastUpdatedTs = getLastUpdatedTs(TABLE_DCMS_DEBIT_CARD, COL_DCMS_DEBIT_CARD_UPDATED_TS,
				true, false);
		Timestamp dcmsCashCardLastUpdatedTs = getLastUpdatedTs(TABLE_DCMS_CASH_CARD, COL_DCMS_CASH_CARD_UPDATED_TS,
				true, false);

		long start = System.nanoTime();
		Map<String, Pattern> patternConfigList = getListOfSupportPatterns();
		if (patternConfigList == null || patternConfigList.isEmpty()) {
			log.warn("Pattern config for support function is not configured! Sync DCMS activity log will not proceed.");
			return;
		} else {
			log.debug("Loaded {} DCMS audit pattern config", patternConfigList.size());
		}

		// Sync DEBIT CARD History
		if (dcmsDebitCardLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}", TABLE_DCMS_DEBIT_CARD,
					userActivityLastUpdatedTs, dcmsDebitCardLastUpdatedTs);
			syncCardAuditLog(userActivityLastUpdatedTs, patternConfigList, false);
		}

		// Sync CASH CARD History
		if (dcmsCashCardLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}", TABLE_DCMS_CASH_CARD,
					userActivityLastUpdatedTs, dcmsCashCardLastUpdatedTs);
			syncCardAuditLog(userActivityLastUpdatedTs, patternConfigList, true);
		}

		// Sync Address Update
		Timestamp dcmsAddressUpdateLastUpdatedTs = getLastUpdatedTs(TABLE_DCMS_ADDRESS_UPDATE,
				COL_DCMS_ADDRESS_UPDATED_TS, true, true);
		if (dcmsAddressUpdateLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}", TABLE_DCMS_ADDRESS_UPDATE,
					userActivityLastUpdatedTs, dcmsAddressUpdateLastUpdatedTs);
			syncSupportTable(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_ADDRESS_UPDATE,
					"Mailing address updated using Address Update", FUNCTION_UPDATE_ADDRESS, false);
		}

		// Sync CC Address Update
		Timestamp dcmsCcAddressUpdateLastUpdatedTs = getLastUpdatedTs(TABLE_DCMS_CC_ADDRESS_UPDATE,
				COL_DCMS_CC_ADDRESS_UPDATED_TS, true, true);
		if (dcmsCcAddressUpdateLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}",
					TABLE_DCMS_CC_ADDRESS_UPDATE, userActivityLastUpdatedTs, dcmsCcAddressUpdateLastUpdatedTs);
			syncSupportTable(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_CC_ADDRESS_UPDATE,
					"Mailing address updated using Address Update", FUNCTION_UPDATE_ADDRESS, true);
		}

		// Sync Update Emboss Name
		Timestamp dcmsUpdateEmbossLastUpdatedTs = getLastUpdatedTs(TABLE_DCMS_UPDATE_EMBOSS_NAME,
				COL_DCMS_UPDATE_EMBOSS_NAME_TS, true, true);
		if (dcmsUpdateEmbossLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}",
					TABLE_DCMS_UPDATE_EMBOSS_NAME, userActivityLastUpdatedTs, dcmsUpdateEmbossLastUpdatedTs);
			syncSupportTable(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_UPDATE_EMBOSS_NAME,
					"Mailing address updated using Address Update", FUNCTION_UPDATE_EMBOSS_NAME, false);
		}

		// Sync CC Update Emboss Name
		Timestamp dcmsCcUpdateEmbossLastUpdatedTs = getLastUpdatedTs(TABLE_DCMS_CC_UPDATE_EMBOSS_NAME,
				COL_DCMS_CC_UPDATE_EMBOSS_NAME_TS, true, true);
		if (dcmsCcUpdateEmbossLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}",
					TABLE_DCMS_CC_UPDATE_EMBOSS_NAME, userActivityLastUpdatedTs, dcmsCcUpdateEmbossLastUpdatedTs);
			syncSupportTable(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_CC_UPDATE_EMBOSS_NAME,
					"Mailing address updated using Address Update", FUNCTION_UPDATE_EMBOSS_NAME, true);
		}

		//Fetch CIF 
		syncIssuanceClient(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_ISSUANCE_CLIENT, FUNCTION_FETCH_CIF,
				false, false, "Modified");
		//Pre-gen card activation ATM
		syncIssuanceClient(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_ISSUANCE_CLIENT_ATM, FUNCTION_FETCH_CIF,
				false, false, "Registered");
		//Pre-gen card activation Cash
		syncIssuanceClient(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_ISSUANCE_CLIENT_CASH, FUNCTION_FETCH_CIF,
				false, true, "Registered");
//		}

		// sync transaction data
//		Timestamp dcmsTxnSetLastUpdatedTs = getLastUpdatedTs("CARD_TRANSACTION_SET", "CTS_UPDATED_TS", true, false);
//		if (dcmsTxnSetLastUpdatedTs.after(userActivityLastUpdatedTs)) {
//			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}", "CARD_TRANSACTION_SET",
//					userActivityLastUpdatedTs, dcmsTxnSetLastUpdatedTs);
//			syncIssuanceClient(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_CARD_TRANSACTION_SET, "UPD TXN SET",
//					true);
//		}

		// sync modify CIF
		Timestamp dcmsModifyCIFLastUpdatedTs = getLastUpdatedTs(TABLE_ISSUANCE_MODIFY_CIF,
				COL_DCMS_ISSUANCE_MODIFY_CIF_TS, true, false);
		if (dcmsModifyCIFLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}", TABLE_ISSUANCE_MODIFY_CIF,
					userActivityLastUpdatedTs, dcmsModifyCIFLastUpdatedTs);
			syncIssuanceModifyCIF(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_MODIFY_CIF, FUNCTION_MODIFY_CIF,
					patternConfigList);
		}

		// sync update cash card balance
		Timestamp dcmsCCBalanceLastUpdatedTs = getLastUpdatedTs(TABLE_ISSUANCE_CASH_CARD_BALANCE,
				COL_DCMS_ISSUANCE_CASH_CARD_BALANCE_TS, true, false);
		if (dcmsCCBalanceLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}",
					TABLE_ISSUANCE_CASH_CARD_BALANCE, userActivityLastUpdatedTs, dcmsCCBalanceLastUpdatedTs);
			syncIssuanceCashCardAccStatBalance(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_CASH_CARD_BALANCE,
					FUNCTION_UPDATE_CC_BALANCE, patternConfigList);
		}

		// sync update cash card account status
		Timestamp dcmsCCAccStatLastUpdatedTs = getLastUpdatedTs(TABLE_ISSUANCE_CASH_CARD_ACCOUNT,
				COL_DCMS_ISSUANCE_CASH_CARD_ACCOUNT_TS, true, false);
		if (dcmsCCAccStatLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}",
					COL_DCMS_ISSUANCE_CASH_CARD_ACCOUNT_TS, userActivityLastUpdatedTs, dcmsCCAccStatLastUpdatedTs);
			syncIssuanceCashCardAccStatBalance(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_CASH_CARD_ACC_STATUS,
					FUNCTION_UPDATE_CC_ACC_STATUS, patternConfigList);
		}

		// sync pregen activation
		Timestamp dcmsActivityLogLastUpdatedTs = getLastUpdatedTs(TABLE_USER_ACTIVITY_LOGS, COL_DCMS_USER_ACTIVITY_DATE,
				true, false);
		if (dcmsActivityLogLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}",
					COL_DCMS_USER_ACTIVITY_DATE, userActivityLastUpdatedTs, dcmsActivityLogLastUpdatedTs);
			syncUserActivity(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_USER_ACTIVITY_LOGS,
					FUNCTION_PRE_GEN_ACTIVATION, patternConfigList);
		}

		log.debug("ELAPSED TIME: syncDcmsUserActivity completed in {}s",
				TimeUnit.NANOSECONDS.toSeconds(System.nanoTime() - start));

	}

	@Transactional
	private void syncIssuanceClient(Timestamp userActivityLastUpdatedTs, String sql, String function,
			boolean isApproveReject, boolean isCashCard, String auditLogDesc) {

		List<Object[]> resultList = em.createNativeQuery(sanitizeSql(sql)).setParameter(1, userActivityLastUpdatedTs)
				.getResultList();
		ObjectMapper mapper = new ObjectMapper();
		log.debug("APPROVED/REJECTED: resultList: {}" + resultList.size());
		for (Object[] resultRow : resultList) {
			DcmsUserActivity row = new DcmsUserActivity();
			Object cardId = resultRow[0];

			if (cardId != null) {
				row.setCardId(((BigDecimal) cardId).toBigInteger());
			}

			Object cifNumber = resultRow[1];
			if (cifNumber != null) {
				row.setCustomerCifNumber((String) cifNumber);
			}

			row.setInstitutionId(((BigDecimal) resultRow[2]).toBigInteger());
			Object updatedTs = resultRow[3];
			if (updatedTs != null) {
				if (updatedTs instanceof Timestamp) {
					row.setCreatedDate(((Timestamp) resultRow[3]).toInstant());
				} else {
					String dateStr = (String) updatedTs;

					if (dateStr.length() == 17) {
						row.setCreatedDate(
								Timestamp.valueOf(LocalDateTime.from(FORMATTER_DDMMYY.parse(dateStr))).toInstant());
					} else {
						row.setCreatedDate(Timestamp.valueOf(LocalDateTime.from(FORMATTER.parse(dateStr))).toInstant());
					}
				}
			}

			row.setCreatedBy((String) resultRow[4]);

			Object cardNumberEnc = resultRow[5];
			if (cardNumberEnc != null) {
				row.setCardNumberEnc((String) cardNumberEnc);
			}

			Object keyRotationNumber = resultRow[6];
			if (keyRotationNumber != null) {
				row.setCardKeyRotationNumber(((BigDecimal) resultRow[6]).intValue());
			}

			Clob auditLogRaw = (Clob) resultRow[7];
			if (auditLogRaw != null) {
				row.setAuditLog(clobToString(auditLogRaw));
			}
			row.setFunction(function);
			row.setCashCard(isCashCard);

			if (isApproveReject) {
				if (resultRow[8] != null) {
					Object ctsName = resultRow[8];
					if (ctsName != null) {
						row.setDescription((String) ctsName);
					}
				}
				insertApprovedRejectedLog(row, userActivityLastUpdatedTs, false, mapper);
			} else {
				insertClientActivityLog(row, userActivityLastUpdatedTs, isCashCard, mapper, auditLogDesc);
			}

		}
	}

	private void insertClientActivityLog(DcmsUserActivity clientRow, Timestamp userActivityLastUpdatedTs,
			boolean isCashCard, ObjectMapper mapper, String auditLogDesc) {
		String auditLog = clientRow.getAuditLog();

		if (auditLog != null && !auditLog.trim().isEmpty()) {
			List<Map<String, String>> clientHistories = null;
			try {
				clientHistories = mapper.readValue(auditLog, new TypeReference<List<Map<String, String>>>() {
				});

				for (Map<String, String> history : clientHistories) {
					Timestamp historyDate = getHistoryDate(history);
					if (historyDate.after(userActivityLastUpdatedTs)) {
						String description = history.get("description");
						if (description != null && description.contains(auditLogDesc)) {
							String createdBy = getMapValueWithKeys(history, "username", "usernam");
							DcmsUserActivity activity = new DcmsUserActivity();
							activity.setCardId(clientRow.getCardId());
							activity.setInstitutionId(clientRow.getInstitutionId());
							activity.setCashCard(isCashCard);
							if (createdBy != null) {
								activity.setCreatedBy(createdBy);
							} else {
								activity.setCreatedBy(clientRow.getCreatedBy());
							}
							activity.setCustomerCifNumber(clientRow.getCustomerCifNumber());
							activity.setCreatedDate(historyDate.toInstant());
							activity.setDescription(description);
							activity.setFunction(clientRow.getFunction());
							activity.setCardKeyRotationNumber(clientRow.getCardKeyRotationNumber());
							activity.setCardNumberEnc(clientRow.getCardNumberEnc());
							userActivityRepo.save(activity);
						}
					}
				}

			} catch (Exception e) {
				log.warn("Failed to parse audit log for card: cardId={}", clientRow.getCardId(), e);
			}
		}
	}

	private void insertApprovedRejectedLog(DcmsUserActivity clientRow, Timestamp userActivityLastUpdatedTs,
			boolean isCashCard, ObjectMapper mapper) {
		String auditLog = clientRow.getAuditLog();
		log.debug("APPROVED/REJECTED: auditLog: {}" + auditLog);
		if (auditLog != null && !auditLog.trim().isEmpty()) {
			List<Map<String, String>> clientHistories = null;
			try {
				clientHistories = mapper.readValue(auditLog, new TypeReference<List<Map<String, String>>>() {
				});
				boolean insert = false;
				String status = "A";
				String maker = "";
				Timestamp historyDate = null;
				String ctsName = clientRow.getDescription();
				DcmsUserActivity activity = new DcmsUserActivity();

				for (Map<String, String> history : clientHistories) {

					String description = history.get("description");

					historyDate = getHistoryDate(history);
					if (historyDate.after(userActivityLastUpdatedTs)) {

						if (description != null) {

							if (description.contains("Approved") || description.contains("Rejected")) {
								insert = true;
								historyDate = getHistoryDate(history);
								String createdBy = getMapValueWithKeys(history, "username", "usernam");

								activity.setCardId(clientRow.getCardId());
								activity.setInstitutionId(clientRow.getInstitutionId());
								activity.setCashCard(isCashCard);
								if (createdBy != null) {
									activity.setCreatedBy(createdBy);
								} else {
									activity.setCreatedBy(clientRow.getCreatedBy());
								}
								activity.setCustomerCifNumber(clientRow.getCustomerCifNumber());
								activity.setCreatedDate(historyDate.toInstant());
								activity.setDescription(description);
								activity.setFunction(clientRow.getFunction());
								activity.setCardKeyRotationNumber(clientRow.getCardKeyRotationNumber());
								activity.setCardNumberEnc(clientRow.getCardNumberEnc());
								if (description.contains("Rejected")) {
									status = "R";
								}
							}
						}
					}
					if (description != null && description.contains("raised")) {
						maker = getMapValueWithKeys(history, "username", "usernam");
					}

				}

				if (insert) {
					String jsonString = new JSONObject().put("cts_name", ctsName)
							.put("date_update", historyDate.toLocalDateTime().format(FORMATTER_DDMMYY))
							.put("maker", maker).put("checker", activity.getCreatedBy()).put("status", status)
							.toString();
					activity.setDetails(jsonString);
					log.debug("APPROVED/REJECTED: jsonString: {} " + jsonString);
					userActivityRepo.save(activity);
				}

			} catch (Exception e) {
				log.warn("Failed to parse audit log for card: cardId={}", clientRow.getCardId(), e);
			}
		}
	}

	@Transactional
	private void syncSupportTable(Timestamp userActivityLastUpdatedTs, String sql, String description, String function,
			boolean isCashCard) {

		List<Object[]> resultList = em.createNativeQuery(sanitizeSql(sql)).setParameter(1, userActivityLastUpdatedTs)
				.getResultList();

		for (Object[] resultRow : resultList) {
			DcmsUserActivity row = new DcmsUserActivity();
			Object cardId = resultRow[0];
			if (cardId != null) {
				row.setCardId(((BigDecimal) cardId).toBigInteger());
			}

			Object cifNumber = resultRow[1];
			if (cifNumber != null) {
				row.setCustomerCifNumber((String) cifNumber);
			}

			row.setInstitutionId(((BigDecimal) resultRow[2]).toBigInteger());
			Object updatedTs = resultRow[3];
			if (updatedTs != null) {
				if (updatedTs instanceof Timestamp) {
					row.setCreatedDate(((Timestamp) resultRow[3]).toInstant());
				} else {
					String dateStr = (String) updatedTs;

					if (dateStr.length() == 17) {
						row.setCreatedDate(
								Timestamp.valueOf(LocalDateTime.from(FORMATTER_DDMMYY.parse(dateStr))).toInstant());
					} else {
						row.setCreatedDate(Timestamp.valueOf(LocalDateTime.from(FORMATTER.parse(dateStr))).toInstant());
					}
				}
			}

			row.setCreatedBy((String) resultRow[4]);

			Object cardNumberEnc = resultRow[5];
			if (cardNumberEnc != null) {
				row.setCardNumberEnc((String) cardNumberEnc);
			}

			Object keyRotationNumber = resultRow[6];
			if (keyRotationNumber != null) {
				row.setCardKeyRotationNumber(((BigDecimal) resultRow[6]).intValue());
			}
			row.setDescription(description);
			row.setFunction(function);
			row.setCashCard(isCashCard);
			userActivityRepo.save(row);
		}
	}

	@Transactional
	private void syncCardAuditLog(Timestamp userActivityLastUpdatedTs, Map<String, Pattern> patternConfigList,
			boolean isCashCard) {

		String sql = null;
		if (isCashCard) {
			sql = SQL_SELECT_AUDIT_LOG_CASH_CARD;
		} else {
			sql = SQL_SELECT_AUDIT_LOG_DEBIT_CARD;
		}
		//List<Object[]> resultList = em.createNativeQuery(sanitizeSql(sql)).setParameter(1, userActivityLastUpdatedTs)
//				.getResultList();
		List<Object[]> resultList = em.createNativeQuery(sanitizeSql(sql))
				.getResultList();
		
		ObjectMapper mapper = new ObjectMapper();

		for (Object[] resultRow : resultList) {
			DcmsUserActivity row = new DcmsUserActivity();
			row.setCardId(((BigDecimal) resultRow[0]).toBigInteger());
			Clob auditLogRaw = (Clob) resultRow[1];
			if (auditLogRaw != null) {
				row.setAuditLog(clobToString(auditLogRaw));
			}
			row.setInstitutionId(((BigDecimal) resultRow[2]).toBigInteger());
			row.setCreatedDate(((Timestamp) resultRow[3]).toInstant());
			row.setCreatedBy((String) resultRow[4]);
			row.setCardNumberEnc((String) resultRow[5]);
			Object keyRotationNumber = resultRow[6];
			if (keyRotationNumber != null) {
				row.setCardKeyRotationNumber(((BigDecimal) resultRow[6]).intValue());
			}

			insertActivityLog(row, userActivityLastUpdatedTs, patternConfigList, isCashCard, mapper);
		}

	}

	@Transactional
	private void syncIssuanceModifyCIF(Timestamp userActivityLastUpdatedTs, String sql, String function,
			Map<String, Pattern> patternConfigList) {

		List<Object[]> resultList = em.createNativeQuery(sanitizeSql(sql)).setParameter(1, userActivityLastUpdatedTs)
				.getResultList();
		// List<DcmsUserActivity> recentUpdatedCards = new ArrayList<>();
		ObjectMapper mapper = new ObjectMapper();

		for (Object[] resultRow : resultList) {
			DcmsUserActivity row = new DcmsUserActivity();
//			row.setCardId(((BigDecimal) resultRow[0]).toBigInteger());
			Clob auditLogRaw = (Clob) resultRow[0];
			if (auditLogRaw != null) {
				row.setAuditLog(clobToString(auditLogRaw));
			}
			row.setInstitutionId(((BigDecimal) resultRow[1]).toBigInteger());
			row.setCreatedDate(((Timestamp) resultRow[2]).toInstant());
			row.setCreatedBy((String) resultRow[3]);
			row.setCustomerCifNumber((String) resultRow[4]);
			row.setFunction(function);

			insertActivityLog(row, userActivityLastUpdatedTs, patternConfigList, false, mapper);
		}
	}

	@Transactional
	private void syncIssuanceCashCardAccStatBalance(Timestamp userActivityLastUpdatedTs, String sql, String function,
			Map<String, Pattern> patternConfigList) {

		List<Object[]> resultList = em.createNativeQuery(sanitizeSql(sql)).setParameter(1, userActivityLastUpdatedTs)
				.getResultList();
		// List<DcmsUserActivity> recentUpdatedCards = new ArrayList<>();
		ObjectMapper mapper = new ObjectMapper();

		for (Object[] resultRow : resultList) {
			DcmsUserActivity row = new DcmsUserActivity();
			row.setCardId(((BigDecimal) resultRow[0]).toBigInteger());
			Clob auditLogRaw = (Clob) resultRow[1];
			if (auditLogRaw != null) {
				row.setAuditLog(clobToString(auditLogRaw));
			}
			row.setInstitutionId(((BigDecimal) resultRow[2]).toBigInteger());
			row.setCreatedDate(((Timestamp) resultRow[3]).toInstant());
			row.setCreatedBy((String) resultRow[4]);
			row.setCardNumberEnc((String) resultRow[5]);
			Object keyRotationNumber = resultRow[6];
			if (keyRotationNumber != null) {
				row.setCardKeyRotationNumber(((BigDecimal) resultRow[6]).intValue());
			}

			row.setFunction(function);

			insertActivityLog(row, userActivityLastUpdatedTs, patternConfigList, true, mapper);
		}

	}
	
	
	@Transactional
	private void syncUserActivity(Timestamp userActivityLastUpdatedTs, String sql, String function, Map<String, Pattern> patternConfigList) {

		List<Object[]> resultList = em.createNativeQuery(sanitizeSql(sql)).setParameter(1, userActivityLastUpdatedTs)
				.getResultList();
		
		ObjectMapper mapper = new ObjectMapper();
		
		for (Object[] resultRow : resultList) {
			DcmsUserActivity activity = new DcmsUserActivity();
			
			activity.setFunction(function);
			activity.setCardId(null);
			activity.setCashCard(false);
			activity.setCardNumberEnc(null);
			activity.setCardKeyRotationNumber(null);
			
			String description = (String) resultRow[0];
			String kitNo = description.substring(description.indexOf("Number"), description.indexOf(" assigned")).replace("Number ", "");
			String cifNo = description.substring(description.lastIndexOf(" ")+1);
			
			//activity.setDescription((String) resultRow[0]);
			activity.setDescription(cifNo);
			activity.setCustomerCifNumber(cifNo);
			activity.setCardNumberEnc(kitNo);
			activity.setInstitutionId(((BigDecimal) resultRow[1]).toBigInteger());
			activity.setCreatedBy((String) resultRow[2]);
			activity.setCreatedDate(((Timestamp) resultRow[3]).toInstant());
			
			userActivityRepo.save(activity);
		}
	}

	private void insertActivityLog(DcmsUserActivity cardRow, Timestamp userActivityLastUpdatedTs,
			Map<String, Pattern> patternConfigList, boolean isCashCard, ObjectMapper mapper) {
		String auditLog = cardRow.getAuditLog();

		if (auditLog != null && !auditLog.trim().isEmpty()) {
			List<Map<String, String>> cardHistories = null;
			try {
				cardHistories = mapper.readValue(auditLog, new TypeReference<List<Map<String, Object>>>() {
				});

				for (Map<String, String> history : cardHistories) {
					Timestamp historyDate = getHistoryDate(history);
					if (historyDate.after(userActivityLastUpdatedTs)) {
						String description = history.get("description");
						String function = determineSupportFunction(description, patternConfigList);
						if (function != null) {
							String createdBy = getMapValueWithKeys(history, "username", "usernam");
							DcmsUserActivity activity = new DcmsUserActivity();
							activity.setCardId(cardRow.getCardId());
							activity.setInstitutionId(cardRow.getInstitutionId());
							activity.setCashCard(isCashCard);
							if (createdBy != null) {
								activity.setCreatedBy(createdBy);
							} else {
								activity.setCreatedBy(cardRow.getCreatedBy());
							}
							activity.setCustomerCifNumber(cardRow.getCustomerCifNumber());
							activity.setCreatedDate(historyDate.toInstant());
							activity.setDescription(function.equalsIgnoreCase(FUNCTION_MODIFY_CIF)
									? getActivityDescription(function, description, cardRow.getCustomerCifNumber())
									: description);
							activity.setFunction(function);
							activity.setCardKeyRotationNumber(cardRow.getCardKeyRotationNumber());
							activity.setCardNumberEnc(cardRow.getCardNumberEnc());
							userActivityRepo.save(activity);
						}
					}
				}

			} catch (Exception e) {
				log.warn("Failed to parse audit log for card: cardId={}", cardRow.getCardId(), e);
			}
		}
	}

	private String clobToString(Clob clob) {
		if (clob == null) {
			return null;
		}
		try {
			Reader r = clob.getCharacterStream();
			StringBuffer buffer = new StringBuffer();
			int ch;
			while ((ch = r.read()) != -1) {
				buffer.append("" + (char) ch);
			}
			return buffer.toString();
		} catch (Exception e) {
			throw new RuntimeException("Failed to convert clob to string.", e);
		}

	}

	private String getMapValueWithKeys(Map<String, String> history, String... keys) {
		for (String key : keys) {
			if (history.containsKey(key)) {
				return history.get(key);
			}
		}
		return null;
	}

	private Timestamp getHistoryDate(Map<String, String> history) {
		String dateStr = null;
		if (history.containsKey("date")) {
			dateStr = history.get("date");
		} else {
			dateStr = history.get("DATE");
		}

		if (dateStr.length() == 17) {
			return Timestamp.valueOf(LocalDateTime.from(FORMATTER_DDMMYY.parse(dateStr)));
		} else {
			return Timestamp.valueOf(LocalDateTime.from(FORMATTER.parse(dateStr)));
		}
	}

	private String determineSupportFunction(String description, Map<String, Pattern> patternConfigList) {
		for (Map.Entry<String, Pattern> pattern : patternConfigList.entrySet()) {

			if (description != null) {
				if (pattern.getValue().matcher(description).matches()) {
					log.debug("Match pattern: description={}, pattern = {} -> SUCCESS!", description,
							pattern.getValue().pattern());

					String function = pattern.getKey().substring(pattern.getKey().lastIndexOf(".") + 1).replace("_",
							" ");

					if (function.matches(".*Change Card Status")
							&& RESET_PIN_COUNTER_PATTERN.matcher(description).matches()) {
						return "Reset Pin Counter";
					} else {
						return function;
					}

				} else {
					log.trace("Match pattern: description={}, pattern = {} -> FAILED!", description,
							pattern.getValue().pattern());
				}
			}
		}
		return null;
	}

	private Timestamp getLastUpdatedTs(String tableName, String lastUpdateColumnName, boolean remote,
			boolean castToTimestamp) {
		if (remote) {
			tableName = getFullyQualifiedTableName(tableName);
		}

		StringBuffer sb = new StringBuffer();
		sb.append("select max(");
		if (castToTimestamp) {
			sb.append("to_timestamp(");
		}
		sb.append(lastUpdateColumnName);
		if (castToTimestamp) {
			sb.append(", 'YYYY-MM-DD HH24:MI:SS')");
		}
		sb.append(") from ");
		sb.append(tableName);

		String sql = sb.toString();

		Object lastUpdatedTs = em.createNativeQuery(sql).getSingleResult();

		if (lastUpdatedTs != null) {
			if (lastUpdatedTs instanceof Timestamp) {
				return (Timestamp) lastUpdatedTs;
			} else {
				String dateStr = (String) lastUpdatedTs;
				if (dateStr.length() == 17) {
					return Timestamp.valueOf(LocalDateTime.from(FORMATTER_DDMMYY.parse(dateStr)));
				} else {
					return Timestamp.valueOf(LocalDateTime.from(FORMATTER.parse(dateStr)));
				}
			}
		}

		return java.sql.Timestamp.valueOf("2001-01-01 00:00:00.0");
	}

	private Map<String, Pattern> getListOfSupportPatterns() {
		Query q = em.createNativeQuery(SQL_SELECT_FUNCTION_PATTERN);

		Map<String, Pattern> supportPatternConfigs = new TreeMap<>();

		List<Object[]> patterns = q.getResultList();
		for (Object[] config : patterns) {
			String configName = config[0].toString();
			String configValue = config[1].toString();
			String function = configName.substring(configName.lastIndexOf(".") + 1).replace("_", " ");
			Pattern p = Pattern.compile(configValue);

			supportPatternConfigs.put(function, p);
		}

		return supportPatternConfigs;

	}

	/**
	 * To replace the placeholder in SQL with DCMS schema and DB link name
	 * 
	 * @param sql
	 * @return
	 */
	private String sanitizeSql(String sql) {
		String schemaName = env.getProperty(ReportConstants.DB_SCHEMA_DCMS);
		String dbLink = env.getProperty(ReportConstants.DB_LINK_DCMS);

		sql = sql.replaceAll("\\{DB_SCHEMA\\}", schemaName);
		sql = sql.replaceAll("\\{DB_LINK\\}", dbLink);

		return sql;
	}

	private String getFullyQualifiedTableName(String tableName) {
		String schemaName = env.getProperty(ReportConstants.DB_SCHEMA_DCMS);
		String dbLink = env.getProperty(ReportConstants.DB_LINK_DCMS);

		StringBuilder sb = new StringBuilder();
		if (schemaName != null) {
			sb.append(schemaName);
			sb.append(".");
		}
		sb.append(tableName);
		if (dbLink != null) {
			sb.append("@");
			sb.append(dbLink);
		}

		return sb.toString();
	}

	private String getActivityDescription(String function, String originalDescription, String newValue) {

		StringBuilder sb = new StringBuilder(originalDescription);

		if (function.equalsIgnoreCase(FUNCTION_MODIFY_CIF)) {
			sb = sb.append(" to " + newValue);
			return sb.toString();
		} else {
			return originalDescription;
		}
	}
}
