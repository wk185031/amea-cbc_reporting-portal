package my.com.mandrill.base.reporting;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import javax.sql.DataSource;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.commons.lang.time.DateUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.scheduling.Trigger;
import org.springframework.scheduling.TriggerContext;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.scheduling.support.CronTrigger;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import com.codahale.metrics.annotation.Timed;

import my.com.mandrill.base.domain.AtmDowntime;
import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.Task;
import my.com.mandrill.base.domain.TaskGroup;
import my.com.mandrill.base.domain.TxnLogCustom;
import my.com.mandrill.base.reporting.security.SecurePANField;
import my.com.mandrill.base.reporting.security.SecureString;
import my.com.mandrill.base.repository.InstitutionRepository;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.TaskGroupRepository;
import my.com.mandrill.base.repository.TaskRepository;
import my.com.mandrill.base.repository.search.JobSearchRepository;
import my.com.mandrill.base.repository.search.TaskGroupSearchRepository;
import my.com.mandrill.base.repository.search.TaskSearchRepository;
import my.com.mandrill.base.service.ReportService;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import my.com.mandrill.mapper.ChannelMapper;

/**
 * REST controller for managing ReportGeneration.
 */
@Configuration
@EnableScheduling
@RestController
@RequestMapping("/api")
public class DatabaseSynchronizer implements SchedulingConfigurer {

	private final Logger log = LoggerFactory.getLogger(DatabaseSynchronizer.class);

	private static final String BILLERCODE_TAG = "BILLERCODE";
	private static final String BILL_PAYMENT_TSC_CODE = "50";
	private static final String ORIGIN_CHANNEL = "A026";
	private static final String ORIGIN_CHANNEL_OLD = "ORIG_CHAN";
	private static final String CASH_CARD_CORPORATE_PRODUCT_CODE = "83";

	private final JobRepository jobRepository;
	private final JobSearchRepository jobSearchRepository;
	private final TaskGroupRepository taskGroupRepository;
	private final TaskGroupSearchRepository taskGroupSearchRepository;
	private final TaskRepository taskRepository;
	private final TaskSearchRepository taskSearchRepository;
	private final JobHistoryRepository jobHistoryRepo;
	private final ReportService reportService;
	private final InstitutionRepository institutionRepository;
	private final DataSource dataSource;

	private static final String SQL_INSERT_TXN_LOG_CUSTOM = "insert into transaction_log_custom values (?,?,?,?,?,?,?,?,?)";
	private static final String SQL_SELECT_CUSTOM_TXN_LOG = "select TRL_ID,TRL_TSC_CODE,TRL_TQU_ID,TRL_PAN,TRL_ACQR_INST_ID,TRL_CARD_ACPT_TERMINAL_IDENT,TRL_ORIGIN_ICH_NAME,TRL_CUSTOM_DATA,TRL_CUSTOM_DATA_EKY_ID,TRL_PAN_EKY_ID,TRL_ISS_NAME,TRL_DEO_NAME from transaction_log {WHERE_CONDITION} order by TRL_SYSTEM_TIMESTAMP";
	private static final String SQL_SELECT_PROPERTY_CORPORATE_CARD = "select PTY_VALUE from {DB_SCHEMA}.PROPERTY@{DB_LINK} where PTY_PTS_NAME='CBC_Institution_Info' and PTY_NAME='EBK_CORP_DUMMY_CARD'";
	private static final String SQL_SELECT_ISSUER_CUSTOM_DATA = "select ISS_CUSTOM_DATA from {DB_SCHEMA}.ISSUER@{DB_LINK} where ISS_STATUS='ACTIVE'";
	private static final String SQL_SELECT_ATM_STATUS_HISTORY = "select ASH_AST_ID,ASH_BUSINESS_DAY,ASH_COMM_STATUS,ASH_TIMESTAMP,ASH_OPERATION_STATUS from ATM_STATUS_HISTORY {WHERE_CONDITION} order by ASH_AST_ID, ASH_TIMESTAMP";
	private static final String SQL_INSERT_ATM_DOWNTIME = "insert into ATM_DOWNTIME values(?, ?, ?, ?)";
	private static final String SQL_SELECT_ALL_BIN = "select CBI_BIN from CBC_BIN";
	private static final int MAX_ROW = 50;

	private static final String TABLE_DETAILS_NAME = "TABLE_DETAILS";
	private static final String INCREMENTAL_UPDATE_TABLES = "ATM_STATUS_HISTORY,ATM_TXN_ACTIVITY_LOG,ATM_JOURNAL_LOG,TRANSACTION_LOG";

	private final Environment env;

	public DatabaseSynchronizer(JobRepository jobRepository, JobSearchRepository jobSearchRepository,
			TaskRepository taskRepository, TaskSearchRepository taskSearchRepository,
			TaskGroupRepository taskGroupRepository, TaskGroupSearchRepository taskGroupSearchRepository,
			JobHistoryRepository jobHistoryRepo, Environment env, ReportService reportService,
			InstitutionRepository institutionRepository, DataSource dataSource) {
		this.jobRepository = jobRepository;
		this.jobSearchRepository = jobSearchRepository;
		this.taskRepository = taskRepository;
		this.taskSearchRepository = taskSearchRepository;
		this.taskGroupRepository = taskGroupRepository;
		this.taskGroupSearchRepository = taskGroupSearchRepository;
		this.jobHistoryRepo = jobHistoryRepo;
		this.env = env;
		this.reportService = reportService;
		this.institutionRepository = institutionRepository;
		this.dataSource = dataSource;
	}

	TaskScheduler taskScheduler;
	private ScheduledFuture<?> syncDbJob;

	@Override
	public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
		ThreadPoolTaskScheduler threadPoolTaskScheduler = new ThreadPoolTaskScheduler();
		threadPoolTaskScheduler.setPoolSize(10);// Set the pool of threads
		threadPoolTaskScheduler.setThreadNamePrefix("scheduler-thread");
		threadPoolTaskScheduler.initialize();
		scheduleSyncDbJob(threadPoolTaskScheduler);// Assign the job to the scheduler
		this.taskScheduler = threadPoolTaskScheduler;// this will be used in later part of the article during refreshing
														// the cron expression dynamically
		taskRegistrar.setTaskScheduler(threadPoolTaskScheduler);
	}

	private void scheduleSyncDbJob(TaskScheduler scheduler) {
		syncDbJob = scheduler.schedule(new Runnable() {
			@Override
			public void run() {
				try {
					synchronizeDatabase(ReportConstants.CREATED_BY_USER);
				} catch (Exception e) {
					log.error("Exception in nextExecutionTime.", e);
				}
			}
		}, new Trigger() {
			@Override
			public Date nextExecutionTime(TriggerContext triggerContext) {
				Job job = jobRepository.findByName(ReportConstants.JOB_NAME);
				Calendar calendar = Calendar.getInstance();
				if (job != null) {
					calendar.setTime(job.getScheduleTime());
					int hour = calendar.get(Calendar.HOUR_OF_DAY);
					int minute = calendar.get(Calendar.MINUTE);
					String cronExp = "0 " + minute + " " + hour + " * * ?";
					log.debug(cronExp.toString());
					return new CronTrigger(cronExp).nextExecutionTime(triggerContext);
				}

				try {
					createSyncDbJob();
				} catch (Exception e) {
					log.error("Exception in nextExecutionTime.", e);
				}
				return new CronTrigger("0 30 0 * * ?").nextExecutionTime(triggerContext);
			}
		});
	}

	public void createSyncDbJob() throws Exception {
		Calendar calendar = Calendar.getInstance();
		calendar.set(Calendar.HOUR_OF_DAY, 0);
		calendar.set(Calendar.MINUTE, 30);
		Timestamp ts = new Timestamp(calendar.getTimeInMillis());

		Job newSyncDbJob = new Job();
		newSyncDbJob.setName(ReportConstants.JOB_NAME);
		newSyncDbJob.setStatus(ReportConstants.STATUS_ACTIVE);
		newSyncDbJob.setCreatedBy(ReportConstants.CREATED_BY_USER);
		newSyncDbJob.setCreatedDate(ZonedDateTime.now());
		newSyncDbJob.setScheduleTime(ts);

		createJob(newSyncDbJob);
	}

	public ResponseEntity<Job> createJob(Job job) throws Exception {
		log.debug("REST request to save Job : {}", job);
		if (job.getId() != null) {
			throw new BadRequestAlertException("A new Job cannot already have an ID", "Job", "idexists");
		}
		Job result = jobRepository.save(job);
		jobSearchRepository.save(result);
		createSyncDbTaskGroup(job);
		return ResponseEntity.created(new URI("/api/jobs/" + result.getId()))
				.headers(HeaderUtil.createEntityCreationAlert("Job", result.getId().toString())).body(result);
	}

	public void createSyncDbTaskGroup(Job job) throws Exception {
		TaskGroup newTaskGroup = new TaskGroup();
		newTaskGroup.setName(ReportConstants.JOB_NAME);
		newTaskGroup.setStatus(ReportConstants.STATUS_ACTIVE);
		newTaskGroup.setCreatedBy(ReportConstants.CREATED_BY_USER);
		newTaskGroup.setCreatedDate(ZonedDateTime.now());
		newTaskGroup.setJob(job);

		createTaskGroup(newTaskGroup);
	}

	public ResponseEntity<TaskGroup> createTaskGroup(TaskGroup taskGroup) throws Exception {
		log.debug("REST request to save TaskGroup : {}", taskGroup);
		if (taskGroup.getId() != null) {
			throw new BadRequestAlertException("A new TaskGroup cannot already have an ID", "TaskGroup", "idexists");
		}
		TaskGroup result = taskGroupRepository.save(taskGroup);
		taskGroupSearchRepository.save(result);
		// createSyncDbTasks(taskGroup);
		return ResponseEntity.created(new URI("/api/task-groups/" + result.getId()))
				.headers(HeaderUtil.createEntityCreationAlert("TaskGroup", result.getId().toString())).body(result);
	}

	public void createSyncDbTasks(TaskGroup taskGroup) throws Exception {
		throw new UnsupportedOperationException("Not required to sync V3 table");
	}

	public ResponseEntity<Task> createTask(Task task) throws URISyntaxException {
		log.debug("REST request to save Task : {}", task);
		if (task.getId() != null) {
			throw new BadRequestAlertException("A new Task cannot already have an ID", "Task", "idexists");
		}
		Task result = taskRepository.save(task);
		taskSearchRepository.save(result);
		return ResponseEntity.created(new URI("/api/tasks/" + result.getId()))
				.headers(HeaderUtil.createEntityCreationAlert("Task", result.getId().toString())).body(result);
	}

	public void refreshCronSchedule() {
		if (syncDbJob != null) {
			syncDbJob.cancel(true);
			scheduleSyncDbJob(taskScheduler);
		}
	}

	@SuppressWarnings("resource")
	@PostMapping("/synchronize-database/{user}")
	public void synchronizeDatabase(@PathVariable String user) throws Exception {
		log.debug("REST request to Synchronize Database");

		// TODO: Check if there is report generation and database sync in process
		createJobHistory(ReportConstants.JOB_NAME, ReportConstants.STATUS_IN_PROGRESS, user);

		Timestamp trxLogLastUpdatedTs = getTableLastUpdatedTimestamp("TRANSACTION_LOG", "TRL_LAST_UPDATE_TS");
		Timestamp atmStatusHistoryLastUpdatedTs = getTableLastUpdatedTimestamp("ATM_STATUS_HISTORY",
				"ASH_LAST_UPDATE_TS");
		Timestamp cardLastUpdatedTs = getTableLastUpdatedTimestamp("CARD", "CRD_LAST_UPDATE_TS");

		syncAuthenticTables();
		Map<String, List<String>> cardBinMap = getCardBinMap();
		postProcessCardData(cardLastUpdatedTs);
		postProcessTransactionLogData(trxLogLastUpdatedTs, cardBinMap);
		postProcessAtmDowntime(atmStatusHistoryLastUpdatedTs);

		createJobHistory(ReportConstants.JOB_NAME, ReportConstants.STATUS_COMPLETED, user);

		log.debug("Database synchronizer done. Start generate report tasks.");
		LocalDate transactionDate = LocalDate.now().minusDays(1L);

		String instShortCode = null;

		List<Institution> institutions = institutionRepository.findAll();
		for (Institution institution : institutions) {
			if ("Institution".equals(institution.getType())) {
				if (institution.getName().equals(ReportConstants.CBC_INSTITUTION)) {
					instShortCode = "CBC";
				} else if (institution.getName().equals(ReportConstants.CBS_INSTITUTION)) {
					instShortCode = "CBS";
				}
				reportService.generateAllReports(transactionDate, institution.getId(), instShortCode);
			}
		}
	}

	private Map<String, List<String>> getCardBinMap() throws Exception {
		log.debug("getCardBinMap");

		Connection conn = dataSource.getConnection();
		PreparedStatement stmt = null;
		ResultSet rs = null;
		Map<String, List<String>> cardBinMap = new HashMap<>();

		try {
			stmt = conn.prepareStatement(SQL_SELECT_ALL_BIN);
			rs = stmt.executeQuery();

			while (rs.next()) {
				String bin = String.valueOf(rs.getInt(1));
				String prefix = bin;
				if (bin.length() > 4) {
					prefix = bin.substring(0, 4);
				}
				if (!cardBinMap.containsKey(prefix)) {
					cardBinMap.put(prefix, new ArrayList<String>());
				}
				cardBinMap.get(prefix).add(bin);
			}
			log.debug("getCardBinMap: size={}", cardBinMap.size());
			return cardBinMap;

		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
					log.warn("Failed to close rs", e);
				}

			}
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
					log.warn("Failed to close stmt", e);
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
					log.warn("Failed to close conn", e);
				}
			}
		}
	}

	private void syncAuthenticTables() throws Exception {
		String[] incrementalUpdateTables = INCREMENTAL_UPDATE_TABLES.split(",");

		toggleForeignKey(false);
		for (String table : getAuthenticTablesToSync()) {
			long start = System.nanoTime();

			boolean isIncrementalUpdateTalble = Arrays.stream(incrementalUpdateTables).anyMatch(table::equals);

			if (isIncrementalUpdateTalble) {
				updateIncrementalRecords(table);
			} else {
				truncateInsertRecords(table);
			}
			log.debug("Complete synchronize table {} in {} ms", table,
					TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - start));
		}
		toggleForeignKey(true);
	}

	private void toggleForeignKey(boolean enable) throws Exception {
		log.debug("toggleForeignKey: {}", enable);
		String sql = "alter table USER_EXTRA_BRANCHES " + (enable ? "ENABLE" : "DISABLE") + " constraint "
				+ "FK_USER_EXTRA_BRANCHES_BRANCH_ID";
		Connection conn = dataSource.getConnection();
		PreparedStatement stmt = null;

		try {
			stmt = conn.prepareStatement(sql);
			stmt.execute();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
					log.warn("Failed to close stmt", e);
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
					log.warn("Failed to close conn", e);
				}
			}
		}
	}

	private void truncateInsertRecords(String table) throws Exception {
		String schemaTableName = env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC) + "." + table + "@"
				+ env.getProperty(ReportConstants.DB_LINK_AUTHENTIC);

		Connection conn = dataSource.getConnection();
		PreparedStatement stmt = null;
		PreparedStatement stmt1 = null;
		String insertSql = "insert into " + table + " (select * from " + schemaTableName + ")";

		log.debug("sync full table:{}, sql={}", table, insertSql);
		try {
			stmt = conn.prepareStatement("truncate table " + table);
			stmt.execute();

			stmt1 = conn.prepareStatement(insertSql);
			stmt1.execute();

		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
					log.warn("Failed to close stmt", e);
				}
			}
			if (stmt1 != null) {
				try {
					stmt1.close();
				} catch (Exception e) {
					log.warn("Failed to close stmt", e);
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
					log.warn("Failed to close conn", e);
				}
			}
		}
	}

	private void updateIncrementalRecords(String table) throws Exception {
		Map<String, String> tableShortNameMap = getTableShortName();
		String schemaTableName = env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC) + "." + table + "@"
				+ env.getProperty(ReportConstants.DB_LINK_AUTHENTIC);
		String lastUpdateColumnName = tableShortNameMap.get(table.toUpperCase()) + "_LAST_UPDATE_TS";

		Timestamp lastUpdatedTs = getTableLastUpdatedTimestamp(table, lastUpdateColumnName);

		String sql = "insert into " + table + " (select * from " + schemaTableName;
		if (lastUpdatedTs != null) {
			String formattedTs = new SimpleDateFormat("yyyyMMdd HH:mm:ss.SSS").format(lastUpdatedTs);
			sql = sql + " where " + lastUpdateColumnName + " > TO_TIMESTAMP('" + formattedTs
					+ "','YYYYMMDD HH24:MI:SS.FF3'))";
		} else {
			sql += ")";
		}

		log.debug("incremental update table:{}, sql={}", table, sql);
		Connection conn = dataSource.getConnection();
		PreparedStatement stmt = null;

		try {
			stmt = conn.prepareStatement(sql);
			stmt.execute();

		} catch (SQLIntegrityConstraintViolationException e) {
			log.error("Duplicate record! Update of data not implemented!");
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
					log.warn("Failed to close stmt", e);
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
					log.warn("Failed to close conn", e);
				}
			}
		}
	}

	private Timestamp getTableLastUpdatedTimestamp(String tableName, String lastUpdateColumnName) throws Exception {
		Connection conn = dataSource.getConnection();
		PreparedStatement stmt = null;
		ResultSet rs = null;

		try {
			String sql = "select max(" + lastUpdateColumnName + ") from " + tableName;
			stmt = conn.prepareStatement(sql);
			rs = stmt.executeQuery();

			if (rs.next()) {
				Timestamp ts = rs.getTimestamp(1);
				return ts;
			}

		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
					log.warn("Failed to close rs", e);
				}

			}
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
					log.warn("Failed to close stmt", e);
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
					log.warn("Failed to close conn", e);
				}
			}
		}
		return null;
	}

	private Map<String, String> getTableShortName() throws Exception {

		Connection conn = dataSource.getConnection();

		PreparedStatement stmt = null;
		ResultSet rs = null;
		Map<String, String> tableShortNameMap = new HashMap<String, String>();

		try {
			String schemaTable = env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC) + "." + TABLE_DETAILS_NAME + "@"
					+ env.getProperty(ReportConstants.DB_LINK_AUTHENTIC);

			String fetchAllSql = "select TDE_TABLE_NAME, TDE_SHORT_NAME from " + schemaTable;

			stmt = conn.prepareStatement(fetchAllSql);
			rs = stmt.executeQuery();
			while (rs.next()) {
				String tableName = rs.getString("TDE_TABLE_NAME");
				String tableShortName = rs.getString("TDE_SHORT_NAME");
				tableShortNameMap.put(tableName.toUpperCase(), tableShortName.toUpperCase());
			}

		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
					log.warn("Failed to close rs", e);
				}

			}
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
					log.warn("Failed to close stmt", e);
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
					log.warn("Failed to close conn", e);
				}
			}
		}
		return tableShortNameMap;
	}

	private List<String> getAuthenticTablesToSync() {
		Job job = jobRepository.findByName(ReportConstants.JOB_NAME);

		if (job.getTableSync() != null) {
			String[] tablesArr = job.getTableSync().split(",");
			if (tablesArr != null && tablesArr.length > 0) {
				return Arrays.asList(tablesArr);
			}
		}
		return new ArrayList<String>();
	}

	private JobHistory createJobHistory(String jobName, String status, String user) {

		JobHistory jobHistory = new JobHistory();
		Job job = jobRepository.findByName(jobName);
		jobHistory.setJob(job);
		jobHistory.setStatus(status);
		jobHistory.setCreatedDate(Instant.now());
		jobHistory.setCreatedBy(user);
		return jobHistoryRepo.save(jobHistory);
	}

	private void postProcessAtmDowntime(Timestamp atmStatusHistoryLastUpdatedTs) {
		Connection conn = null;
		PreparedStatement stmt = null;
		PreparedStatement stmt_insert = null;
		ResultSet rs = null;

		String sql = SQL_SELECT_ATM_STATUS_HISTORY;
		if (atmStatusHistoryLastUpdatedTs == null) {
			sql = sql.replace("{WHERE_CONDITION}", "");
		} else {
			String formattedTs = new SimpleDateFormat("yyyyMMdd HH:mm:ss.SSS").format(atmStatusHistoryLastUpdatedTs);
			String whereCondition = "where ASH_LAST_UPDATE_TS > TO_TIMESTAMP('" + formattedTs
					+ "','YYYYMMDD HH24:MI:SS.FF3')";
			sql = sql.replace("{WHERE_CONDITION}", whereCondition);
		}

		try {
			conn = dataSource.getConnection();

			stmt = conn.prepareStatement(sql);
			stmt.setFetchSize(MAX_ROW);
			rs = stmt.executeQuery();

			AtmDowntime lastDowntime = null;

			while (rs.next()) {
				String operationStatus = rs.getString("ASH_OPERATION_STATUS");
				String commStatus = rs.getString("ASH_COMM_STATUS");
				long astId = rs.getLong("ASH_AST_ID");
				Timestamp statusTimestamp = rs.getTimestamp("ASH_TIMESTAMP");
				java.sql.Date statusDate = new java.sql.Date(
						DateUtils.truncate(new Date(statusTimestamp.getTime()), Calendar.DATE).getTime());

				log.debug("postProcessAtmDowntime: astId={}, statusTimestamp={}, operationSttus={}, commStatus={}",
						astId, statusTimestamp, operationStatus, commStatus);

				if ("Out of service".equals(operationStatus) || "Down".equals(commStatus)) {
					if (lastDowntime != null && lastDowntime.isRepeatedEntry(astId, statusDate, true)) {
						log.debug("Entering criteria 1.1");
						// Do nothing, continue search for next up entry
					} else {
						if (lastDowntime != null && astId != lastDowntime.getAstId()
								&& lastDowntime.getEndTimestamp() == null) {
							log.debug("Entering criteria 1.2");
							// Previous entry is from different ATM, close the entry
							AtmDowntime tempLastDowntime = lastDowntime.clone();
							tempLastDowntime.setEndTimestamp(Timestamp.valueOf(
									LocalDateTime.of(lastDowntime.getStatusDate().toLocalDate(), LocalTime.MAX)));
							insertAtmDownTime(tempLastDowntime);

							lastDowntime = new AtmDowntime(astId, statusDate, statusTimestamp, null);
						} else if (lastDowntime != null && astId == lastDowntime.getAstId()
								&& lastDowntime.getEndTimestamp() == null) {
							log.debug("Entering criteria 1.3");
							// Previous entry is from same ATM but different day, close the entry
							AtmDowntime tempLastDowntime = lastDowntime.clone();
							tempLastDowntime.setEndTimestamp(Timestamp.valueOf(
									LocalDateTime.of(lastDowntime.getStatusDate().toLocalDate(), LocalTime.MAX)));
							insertAtmDownTime(tempLastDowntime);

							// Since ATM not up from yesterday, downtime will start at 00:00
							lastDowntime = new AtmDowntime(astId, statusDate,
									Timestamp.valueOf(LocalDateTime.of(statusDate.toLocalDate(), LocalTime.MIN)), null);
						} else {
							log.debug("Entering criteria 1.4");
							lastDowntime = new AtmDowntime(astId, statusDate, statusTimestamp, null);
						}
					}

				} else if ("In service".equals(operationStatus)) {
					if (lastDowntime != null && lastDowntime.isRepeatedEntry(astId, statusDate, false)) {
						log.debug("Entering criteria 2.1");
						// Do nothing
					} else {
						if (lastDowntime == null) {
							log.debug("Entering criteria 2.2");
							AtmDowntime tempLastDowntime = new AtmDowntime(astId, statusDate,
									Timestamp.valueOf(LocalDateTime.of(statusDate.toLocalDate(), LocalTime.MIN)),
									statusTimestamp);
							insertAtmDownTime(tempLastDowntime);
							lastDowntime = tempLastDowntime;
						} else if (astId == lastDowntime.getAstId() && statusDate.equals(lastDowntime.getStatusDate())
								&& lastDowntime.getEndTimestamp() == null) {
							log.debug("Entering criteria 2.3");
							AtmDowntime tempLastDowntime = lastDowntime.clone();
							tempLastDowntime.setEndTimestamp(statusTimestamp);
							insertAtmDownTime(tempLastDowntime);
							lastDowntime = tempLastDowntime;
						} else {
							if (lastDowntime.getAstId() != astId || !lastDowntime.getStatusDate().equals(statusDate)) {
								log.debug("Entering criteria 2.4");
								// Close previous open entry
								AtmDowntime tempLastDowntime = lastDowntime.clone();
								tempLastDowntime.setEndTimestamp(Timestamp.valueOf(
										LocalDateTime.of(lastDowntime.getStatusDate().toLocalDate(), LocalTime.MAX)));
								insertAtmDownTime(tempLastDowntime);
							}
							log.debug("Entering criteria 2.5");
							AtmDowntime newLastDowntime = new AtmDowntime(astId, statusDate,
									Timestamp.valueOf(LocalDateTime.of(statusDate.toLocalDate(), LocalTime.MIN)),
									statusTimestamp);
							insertAtmDownTime(newLastDowntime);
							lastDowntime = newLastDowntime;
						}
					}
				}
			}

		} catch (Exception e) {
			throw new RuntimeException("Failed to process transaction log", e);
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
				}
			}
			if (stmt_insert != null) {
				try {
					stmt_insert.close();
				} catch (Exception e) {
				}
			}

			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
				}
			}
		}

	}

	private void insertAtmDownTime(AtmDowntime atmDowntime) {
		Connection conn = null;
		PreparedStatement stmt = null;

		try {
			conn = dataSource.getConnection();

			stmt = conn.prepareStatement(SQL_INSERT_ATM_DOWNTIME);
			stmt.setLong(1, atmDowntime.getAstId());
			stmt.setDate(2, atmDowntime.getStatusDate());
			stmt.setTimestamp(3, atmDowntime.getStartTimestamp());
			stmt.setTimestamp(4, atmDowntime.getEndTimestamp());
			stmt.executeUpdate();
		} catch (Exception e) {
			throw new RuntimeException("Failed to process insertAtmDownTime", e);
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
				}
			}
		}
	}

	private void postProcessCardData(Timestamp lastUpdatedTimestamp) {
		log.debug("Post Process Card data");

		Connection conn = null;
		PreparedStatement stmt = null;
		PreparedStatement stmt_insert = null;
		ResultSet rs = null;

		try {
			conn = dataSource.getConnection();

			stmt = conn.prepareStatement("TRUNCATE TABLE CARD_CUSTOM");
			stmt_insert = conn.prepareStatement("insert into card_custom values (?,?)");
			stmt.execute();
			stmt.close();

			stmt = conn.prepareStatement("select CRD_ID,CRD_PAN,CRD_PAN_EKY_ID from CARD");
			rs = stmt.executeQuery();

			while (rs.next()) {
				Long cardId = rs.getLong("CRD_ID");
				String encryptedPan = rs.getString("CRD_PAN");
				int panEkyId = rs.getInt("CRD_PAN_EKY_ID");

				SecurePANField pan = SecurePANField.fromDatabase(encryptedPan, panEkyId);
				String clearPan = pan.getClear();
				String branchCode = clearPan.substring(8, 12);

				stmt_insert.setLong(1, cardId);
				stmt_insert.setString(2, branchCode);
				stmt_insert.executeUpdate();
			}

			// TODO: After run the first time, should NOT truncate all and only process the
			// latest record
//			if (lastUpdatedTimestamp == null) {
//				stmt = conn.prepareStatement(SQL_SELECT_CUSTOM_CARD_DATA.replace("{WHERE_CONDITION}", ""));
//			} else {
//				String formattedTs = new SimpleDateFormat("yyyyMMdd HH:mm:ss.SSS").format(lastUpdatedTimestamp);
//				String whereCondition = "where CRD_LAST_UPDATE_TS > TO_TIMESTAMP('" + formattedTs
//						+ "','YYYYMMDD HH24:MI:SS.FF3')";
//
//				stmt = conn.prepareStatement(SQL_SELECT_CUSTOM_CARD_DATA.replace("{WHERE_CONDITION}", whereCondition));
//			}

		} catch (Exception e) {
			throw new RuntimeException("Failed to process transaction log", e);
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
				}
			}

			if (stmt_insert != null) {
				try {
					stmt_insert.close();
				} catch (Exception e) {
				}
			}

			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
				}
			}

			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
				}
			}
		}

	}

	private void postProcessTransactionLogData(Timestamp lastUpdatedTimestamp, Map<String, List<String>> cardBinMap) {
		log.debug("Post Process Transaction Log data");

		Connection conn = null;
		PreparedStatement stmt = null;
		PreparedStatement stmt_insert = null;
		ResultSet rs = null;

		try {
			conn = dataSource.getConnection();

			if (lastUpdatedTimestamp == null) {
				stmt = conn.prepareStatement(SQL_SELECT_CUSTOM_TXN_LOG.replace("{WHERE_CONDITION}", ""));
			} else {
				String formattedTs = new SimpleDateFormat("yyyyMMdd HH:mm:ss.SSS").format(lastUpdatedTimestamp);
				String whereCondition = "where TRL_LAST_UPDATE_TS > TO_TIMESTAMP('" + formattedTs
						+ "','YYYYMMDD HH24:MI:SS.FF3')";

				stmt = conn.prepareStatement(SQL_SELECT_CUSTOM_TXN_LOG.replace("{WHERE_CONDITION}", whereCondition));
			}

			stmt.setFetchSize(MAX_ROW);
			rs = stmt.executeQuery();

			StringTokenizer corporateCardRange = getCorporateCard(conn);
			List<String> atmDummyCards = getAtmDummyCard(conn);

			while (rs.next()) {
				TxnLogCustom txnCustom = fromResultSet(cardBinMap, rs.getLong("TRL_ID"), rs.getString("TRL_TSC_CODE"),
						rs.getString("TRL_PAN"), rs.getString("TRL_ACQR_INST_ID"), rs.getString("TRL_CUSTOM_DATA"),
						rs.getInt("TRL_CUSTOM_DATA_EKY_ID"), rs.getInt("TRL_PAN_EKY_ID"),
						rs.getString("TRL_ORIGIN_ICH_NAME"), rs.getString("TRL_ISS_NAME"), rs.getString("TRL_DEO_NAME"),
						corporateCardRange, atmDummyCards);
				stmt_insert = conn.prepareStatement(SQL_INSERT_TXN_LOG_CUSTOM);
				stmt_insert.setLong(1, txnCustom.getTrlId());
				stmt_insert.setString(2, txnCustom.getBillerCode());
				stmt_insert.setString(3, txnCustom.getCardBin());
				stmt_insert.setString(4, txnCustom.getOriginChannel());
				stmt_insert.setString(5, txnCustom.getCardBranch());
				stmt_insert.setString(6, txnCustom.getCardProductType());
				stmt_insert.setBoolean(7, txnCustom.isCorporateCard());
				stmt_insert.setBoolean(8, txnCustom.isInterEntity());
				stmt_insert.setBoolean(9, txnCustom.isCardless());

				stmt_insert.executeUpdate();

				if (stmt_insert != null) {
					try {
						stmt_insert.close();
					} catch (Exception e) {
					}

				}
			}
		} catch (Exception e) {
			throw new RuntimeException("Failed to process transaction log", e);
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
				}
			}

			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
				}
			}

			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
				}
			}
		}

	}

	@GetMapping("/getTableName")
	@Timed
	public ArrayList<String> getTableName() throws SQLException {
		log.debug("REST request to get list of tables to display");
		Connection conn = dataSource.getConnection();

		Statement stmt = null;
		ResultSet rs = null;
		ArrayList<String> tablesArr = new ArrayList<String>();
		stmt = conn.createStatement();

		try {
			rs = stmt.executeQuery("SELECT TDE_TABLE_NAME FROM TABLE_DETAILS order by TDE_TABLE_NAME");
		} catch (SQLException e) {
			log.error("Error is: ", e);
		}

		while (rs.next()) {
			tablesArr.add(rs.getString("TDE_TABLE_NAME"));
		}

		if (rs != null) {
			if (!rs.isClosed()) {
				rs.close();
			}
		}
		if (stmt != null) {
			stmt.close();
		}
		if (conn != null) {
			conn.close();
		}

		return tablesArr;
	}

	private TxnLogCustom fromResultSet(Map<String, List<String>> cardBinMap, Long id, String tscCode,
			String encryptedPan, String acqInstId, String encryptedCustomData, int encryptionKeyId,
			int panEncryptionKeyId, String originInterchange, String issuerName, String deoName,
			StringTokenizer corporatePanRange, List<String> atmDummyCards) throws Exception {

		log.debug(
				"Post process txn log: id={}, tscCode={}, encryptedPan={}, acqInstId={}, encryptionKeyId={}, panEncryptionKeyId={}, issuerName={}, deoName={}, corporatePanRange={}",
				id, tscCode, encryptedPan, acqInstId, encryptionKeyId, panEncryptionKeyId, issuerName, deoName,
				corporatePanRange == null ? "" : corporatePanRange.toString());

		try {
			SecurePANField pan = SecurePANField.fromDatabase(encryptedPan, panEncryptionKeyId);
			String clearPan = pan.getClear();
			Map<String, String> customDataMap = retrieveCustomData(encryptedCustomData, encryptionKeyId);

			TxnLogCustom o = new TxnLogCustom();
			o.setTrlId(id);

			if (BILL_PAYMENT_TSC_CODE.equals(tscCode)) {
				o.setBillerCode(customDataMap.get(BILLERCODE_TAG));
			} else {
				o.setBillerCode(null);
			}

			o.setOriginChannel(determineOriginChannel(customDataMap, acqInstId, originInterchange));
			o.setInterEntity(isInterEntity(tscCode, acqInstId, issuerName, deoName));

			if (encryptedPan != null) {
				o.setCardBin(findBin(pan, cardBinMap));

				if (isOnUs(issuerName)) {
					o.setCardProductType(pan.getClear().substring(6, 8));
					o.setCardBranch(pan.getClear().substring(8, 12));
					log.trace("Card data: pan={}, cardBranch={}, cardProductType={}", pan.getClear(), o.getCardBranch(),
							o.getCardProductType());

					if (CASH_CARD_CORPORATE_PRODUCT_CODE.equals(o.getCardProductType())) {
						o.setCorporateCard(true);
					} else if ("EBK".equals(o.getOriginChannel())) {
						o.setCorporateCard(isCorporateCard(clearPan, corporatePanRange));
					}
				}
			}

			if ("MBK".equals(o.getOriginChannel()) || "EBK".equals(o.getOriginChannel())) {
				o.setCardless(true);
			} else {
				if (atmDummyCards.contains(clearPan)) {
					o.setCardless(true);
				} else {
					o.setCardless(false);
				}
			}

			return o;
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}

	}

	private boolean isOnUs(String issuerName) {
		return "CBC".equals(issuerName) || "CBS".equals(issuerName);
	}

	private String findBin(SecurePANField pan, Map<String, List<String>> cardBinMap) throws Exception {
		String clearPan = pan.getClear();

		String binPrefix = clearPan.substring(0, 4);
		log.debug("findBin start: clearPan={}, binPrefix={}", clearPan, binPrefix);
		String binFound = null;
		if (cardBinMap.containsKey(binPrefix)) {
			for (String bin : cardBinMap.get(binPrefix)) {
				if (clearPan.length() >= bin.length() && bin.equals(clearPan.substring(0, bin.length()))) {
					if (binFound == null) {
						binFound = bin;
					} else if (bin.length() > binFound.length()) {
						binFound = bin;
					}
				}
			}
		}
		log.debug("findBin end: clearPan={}, binFound={}", clearPan, binFound);
		return binFound;
	}

	private String determineOriginChannel(Map<String, String> customDataMap, String acqInstId,
			String originInterchange) {
		String originChannel = customDataMap.get(ORIGIN_CHANNEL);

		if (originChannel == null || originChannel.trim().isEmpty()) {
			originChannel = customDataMap.get(ORIGIN_CHANNEL_OLD);
		}

		String mappedChannel = ChannelMapper.fromAuth(originChannel, originInterchange, acqInstId);

		log.debug("originChannel = {}, mappedChannel = {}", originChannel, mappedChannel);

		return mappedChannel;
	}

	private Map<String, String> retrieveCustomData(String customData, int encryptionKeyId) {

		Map<String, String> map = new HashMap<String, String>();

		if (customData == null || customData.isEmpty()) {
			return map;
		}

		String dataXml = customData;
		if (encryptionKeyId != -1) {
			SecureString secureStr = SecureString.fromDatabase(customData, encryptionKeyId);
			dataXml = secureStr.getClear();
		}

		log.trace("Custom data clear text: {}", dataXml);

		String clearXml = "<Root>" + StringUtils.defaultString(dataXml) + "</Root>";
		InputStream in = null;

		try {
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			in = new ByteArrayInputStream(clearXml.getBytes("utf-8"));

			Document document = builder.parse(in);
			document.getDocumentElement().normalize();
			Element root = document.getDocumentElement();
			if (root.getChildNodes().getLength() > 0) {
				for (int i = 0; i < root.getChildNodes().getLength(); i++) {
					Node aNode = root.getChildNodes().item(i);

					if (aNode.getNodeName().contains("secure-field")) {
						aNode.getNodeName().replace("secure-field" + "=Y", "");
					}
					map.put(aNode.getNodeName(), aNode.getTextContent());
					log.debug("custom data: tag={}, value={}", aNode.getNodeName(), aNode.getTextContent());
				}
			}
			return map;
		} catch (Exception e) {
			log.error("Failed to retrieve custom data", e);
			throw new RuntimeException(e);
		} finally {
			if (in != null) {
				try {
					in.close();
				} catch (IOException e) {
				}
			}
		}

	}

	private StringTokenizer getCorporateCard(Connection conn) {

		PreparedStatement stmt = null;
		ResultSet rs = null;

		String schema = env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC);
		String dblink = env.getProperty(ReportConstants.DB_LINK_AUTHENTIC);
		String sql = SQL_SELECT_PROPERTY_CORPORATE_CARD.replace("{DB_SCHEMA}", schema);
		sql = sql.replace("{DB_LINK}", dblink);
		log.debug("SQL to fetch corporate card: {}", sql);

		try {
			stmt = conn.prepareStatement(sql);
			rs = stmt.executeQuery();

			while (rs.next()) {
				String corporateCardRange = rs.getString("PTY_VALUE");
				if (corporateCardRange != null && !corporateCardRange.trim().isEmpty()) {
					return new StringTokenizer(corporateCardRange, ";");
				}
			}

		} catch (Exception e) {
			throw new RuntimeException("Failed to process transaction log", e);
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
				}
			}

			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
				}

			}
		}

		return null;
	}

	private List<String> getAtmDummyCard(Connection conn) {

		PreparedStatement stmt = null;
		ResultSet rs = null;
		List<String> dummyCards = new ArrayList<String>();

		String schema = env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC);
		String dblink = env.getProperty(ReportConstants.DB_LINK_AUTHENTIC);
		String sql = SQL_SELECT_ISSUER_CUSTOM_DATA.replace("{DB_SCHEMA}", schema);
		sql = sql.replace("{DB_LINK}", dblink);
		log.debug("SQL to fetch issuer custom data: {}", sql);

		try {
			stmt = conn.prepareStatement(sql);
			rs = stmt.executeQuery();

			while (rs.next()) {
				String customData = rs.getString("ISS_CUSTOM_DATA");
				Map<String, String> dataMap = retrieveCustomData(customData, -1);

				if (dataMap.containsKey("ATM_DUMMY_CARD")) {
					dummyCards.add(dataMap.get("ATM_DUMMY_CARD"));
				}
			}

		} catch (Exception e) {
			throw new RuntimeException("Failed to process transaction log", e);
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
				}
			}

			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
				}

			}
		}

		return dummyCards;
	}

	private boolean isCorporateCard(String clearPan, StringTokenizer corporatePanRange) {
		if (corporatePanRange == null) {
			return false;
		}
		while (corporatePanRange.hasMoreElements()) {
			if (clearPan.equals(corporatePanRange.nextElement())) {
				return true;
			}
		}
		return false;
	}

	private boolean isInterEntity(String tscCode, String acqInsId, String issuerName, String deoName) {
		if ("42".equals(tscCode) || "45".equals(tscCode) || "48".equals(tscCode) || "49".equals(tscCode)) {
			return true;
		}

		if ("CBC".equals(issuerName) && "CBS".equals(deoName)) {
			return true;
		}

		if ("CBS".equals(issuerName) && "CBC".equals(deoName)) {
			return true;
		}

		String acquiringInstId = StringUtils.removeStart(acqInsId, "0");
		if ("10".equals(acquiringInstId) && "CBS".equals(issuerName)) {
			return true;
		}

		if ("112".equals(acquiringInstId) && "CBC".equals(issuerName)) {
			return true;
		}

		return false;
	}

}
