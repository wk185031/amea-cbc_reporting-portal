package my.com.mandrill.base.service;

import java.io.Reader;
import java.math.BigDecimal;
import java.sql.Clob;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

import javax.persistence.EntityManager;
import javax.persistence.Query;
import javax.transaction.Transactional;

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

	private static final String COL_DCMS_ISSUANCE_CLIENT_TS = "CLT_UPDATED_TS";

	private static final String SQL_SELECT_AUDIT_LOG_DEBIT_CARD = "select CRD_ID, CRD_AUDIT_LOG, CRD_INS_ID, CRD_UPDATED_TS, STF_LOGIN_NAME, CRD_NUMBER_ENC, CRD_KEY_ROTATION_NUMBER from {DB_SCHEMA}.ISSUANCE_CARD@{DB_LINK} left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CRD_UPDATED_BY=STF_ID or CRD_CREATED_BY=STF_ID where CRD_UPDATED_TS  > ?";

	private static final String SQL_SELECT_AUDIT_LOG_CASH_CARD = "select CSH_ID, CSH_AUDIT_LOG, CSH_INS_ID, CSH_UPDATED_TS, STF_LOGIN_NAME, CSH_CARD_NUMBER_ENC, CSH_KEY_ROTATION_NUMBER from {DB_SCHEMA}.ISSUANCE_CASH_CARD@{DB_LINK} left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CSH_UPDATED_BY=STF_ID or CSH_CREATED_BY=STF_ID  where CSH_UPDATED_TS  > ?";

	private static final String SQL_SELECT_AUDIT_LOG_ADDRESS_UPDATE = "select null as CRD_ID, CLT_CIF_NUMBER, AUR_INS_ID, AUR_UPDATED_TS, STF_LOGIN_NAME, null as CRD_CARD_NUMBER_ENC, null as CRD_KEY_ROTATION_NUMBER from {DB_SCHEMA}.SUPPORT_ADDRESS_UPDATE_REQ_MAP@{DB_LINK} left join {DB_SCHEMA}.ISSUANCE_CLIENT@{DB_LINK} on AUR_CLT_ID=CLT_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on AUR_UPDATED_BY=STF_ID or AUR_CREATED_BY=STF_ID where TO_TIMESTAMP(AUR_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS')  > ? and AUR_STS_ID in (88,91)";

	private static final String SQL_SELECT_AUDIT_LOG_CC_ADDRESS_UPDATE = "select null as CRD_ID, CLT_CIF_NUMBER, CC_AUR_INS_ID, CC_AUR_UPDATED_TS, STF_LOGIN_NAME, null as CRD_CARD_NUMBER_ENC, null as CRD_KEY_ROTATION_NUMBER from {DB_SCHEMA}.SUPPORT_CC_ADD_UPDATE_REQ_MAP@{DB_LINK} left join {DB_SCHEMA}.ISSUANCE_CLIENT@{DB_LINK} on CC_AUR_CLT_ID=CLT_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CC_AUR_UPDATED_BY=STF_ID or CC_AUR_CREATED_BY=STF_ID where TO_TIMESTAMP(CC_AUR_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS')   > ? and CC_AUR_STS_ID in (88,91)";

	private static final String SQL_SELECT_AUDIT_LOG_UPDATE_EMBOSS_NAME = "select CRD_ID, null as CLT_CIF_NUMBER, UEN_INS_ID, UEN_UPDATED_TS, STF_LOGIN_NAME, CRD_NUMBER_ENC, CRD_KEY_ROTATION_NUMBER from {DB_SCHEMA}.SUPPORT_UPDATE_EMBOSS_NAME@{DB_LINK} left join {DB_SCHEMA}.ISSUANCE_CARD@{DB_LINK} on UEN_CRD_ID=CRD_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on UEN_UPDATED_BY=STF_ID or UEN_CREATED_BY=STF_ID where TO_TIMESTAMP(UEN_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS')  > ? and UEN_STS_ID in (88,91)";

	private static final String SQL_SELECT_AUDIT_LOG_CC_UPDATE_EMBOSS_NAME = "select CSH_ID, null as CLT_CIF_NUMBER, UEN_CC_INS_ID, UEN_CC_UPDATED_TS, STF_LOGIN_NAME, CSH_CARD_NUMBER_ENC, CSH_KEY_ROTATION_NUMBER from {DB_SCHEMA}.SUPPORT_CC_UPDATE_EMBOSS_NAME@{DB_LINK} left join {DB_SCHEMA}.ISSUANCE_CASH_CARD@{DB_LINK} on UEN_CC_CSH_ID=CSH_ID left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on UEN_CC_UPDATED_BY=STF_ID or UEN_CC_CREATED_BY=STF_ID where TO_TIMESTAMP(UEN_CC_UPDATED_TS, 'YYYY-MM-DD HH24:MI:SS')  > ? and UEN_CC_STS_ID in (88,91)";

	private static final String SQL_SELECT_AUDIT_LOG_ISSUANCE_CLIENT = "select null as CRD_ID, CLT_CIF_NUMBER, CLT_INS_ID, CLT_UPDATED_TS, STF_LOGIN_NAME, null as CRD_CARD_NUMBER_ENC, null as CRD_KEY_ROTATION_NUMBER, CLT_AUDIT_LOG from {DB_SCHEMA}.ISSUANCE_CLIENT@{DB_LINK} left join {DB_SCHEMA}.USER_STAFF@{DB_LINK} on CLT_UPDATED_BY=STF_ID or CLT_CREATED_BY=STF_ID where CLT_AUDIT_LOG is not null and TO_TIMESTAMP(CLT_UPDATED_TS, 'DD/MM/YYYY HH24:MI:SS.FF') > ?";

	private static final String SQL_SELECT_FUNCTION_PATTERN = "select name,config from SYSTEM_CONFIGURATION where name like 'dcms.function.pattern%'";

	private static final String FUNCTION_FETCH_CIF = "Fetch CIF";
	
	private static final String FUNCTION_UPDATE_EMBOSS_NAME = "Update Emboss Name";
	
	private static final String FUNCTION_UPDATE_ADDRESS = "Update Address";
	
	private DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

	private DateTimeFormatter FORMATTER_DDMMYY = DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss");

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

		// Sync ISSUANCE CLIENT
		Timestamp dcmsIssuanceClientLastUpdatedTs = getLastUpdatedTs(TABLE_ISSUANCE_CLIENT, COL_DCMS_ISSUANCE_CLIENT_TS,
				true, false);
		if (dcmsIssuanceClientLastUpdatedTs.after(userActivityLastUpdatedTs)) {
			log.debug("Sync DCMS activity log: table={}, min timestamp={}, max timestamp={}", TABLE_ISSUANCE_CLIENT,
					userActivityLastUpdatedTs, dcmsIssuanceClientLastUpdatedTs);
			syncIssuanceClient(userActivityLastUpdatedTs, SQL_SELECT_AUDIT_LOG_ISSUANCE_CLIENT, FUNCTION_FETCH_CIF);
		}

		log.debug("ELAPSED TIME: syncDcmsUserActivity completed in {}s",
				TimeUnit.NANOSECONDS.toSeconds(System.nanoTime() - start));

	}

	@Transactional
	private void syncIssuanceClient(Timestamp userActivityLastUpdatedTs, String sql, String function) {

		List<Object[]> resultList = em.createNativeQuery(sanitizeSql(sql)).setParameter(1, userActivityLastUpdatedTs)
				.getResultList();
		ObjectMapper mapper = new ObjectMapper();

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
			row.setCashCard(false);

			insertClientActivityLog(row, userActivityLastUpdatedTs, false, mapper);

		}
	}

	private void insertClientActivityLog(DcmsUserActivity clientRow, Timestamp userActivityLastUpdatedTs,
			boolean isCashCard, ObjectMapper mapper) {
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
						if (description != null && description.contains("Modified")
								|| description.contains("Registered")) {
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

			insertActivityLog(row, userActivityLastUpdatedTs, patternConfigList, isCashCard, mapper);
		}

	}

	private void insertActivityLog(DcmsUserActivity cardRow, Timestamp userActivityLastUpdatedTs,
			Map<String, Pattern> patternConfigList, boolean isCashCard, ObjectMapper mapper) {
		String auditLog = cardRow.getAuditLog();

		if (auditLog != null && !auditLog.trim().isEmpty()) {
			List<Map<String, String>> cardHistories = null;
			try {
				cardHistories = mapper.readValue(auditLog, new TypeReference<List<Map<String, String>>>() {
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
							activity.setDescription(description);
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

			if (pattern.getValue().matcher(description).matches()) {
				log.debug("Match pattern: description={}, pattern = {} -> SUCCESS!", description,
						pattern.getValue().pattern());
				return pattern.getKey().substring(pattern.getKey().lastIndexOf(".") + 1).replace("_", " ");
			} else {
				log.trace("Match pattern: description={}, pattern = {} -> FAILED!", description,
						pattern.getValue().pattern());
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

		Map<String, Pattern> supportPatternConfigs = new HashMap<>();

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
}
