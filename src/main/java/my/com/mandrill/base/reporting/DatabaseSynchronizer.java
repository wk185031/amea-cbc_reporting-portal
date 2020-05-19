package my.com.mandrill.base.reporting;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

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

import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.Task;
import my.com.mandrill.base.domain.TaskGroup;
import my.com.mandrill.base.domain.TxnLogCustom;
import my.com.mandrill.base.reporting.security.SecurePANField;
import my.com.mandrill.base.reporting.security.SecureString;
import my.com.mandrill.base.reporting.security.StandardEncryptionService;
import my.com.mandrill.base.repository.InstitutionRepository;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.TaskGroupRepository;
import my.com.mandrill.base.repository.TaskRepository;
import my.com.mandrill.base.repository.search.JobSearchRepository;
import my.com.mandrill.base.repository.search.TaskGroupSearchRepository;
import my.com.mandrill.base.repository.search.TaskSearchRepository;
import my.com.mandrill.base.service.ReportService;
import my.com.mandrill.base.web.rest.JobHistoryResource;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;

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
	private static final String ORIGIN_CHANNEL = "ORIG_CHAN";
	private static final String BANCNET_ONLINE_ACQ_ID = "9990";
	private static final String BANCNET_ONLINE_CHANNEL_LABEL = "BANCNET_ONLINE";

	private Map<String, String> matchingBinCache = new HashMap<String, String>();

	private final JobRepository jobRepository;
	private final JobSearchRepository jobSearchRepository;
	private final TaskGroupRepository taskGroupRepository;
	private final TaskGroupSearchRepository taskGroupSearchRepository;
	private final TaskRepository taskRepository;
	private final TaskSearchRepository taskSearchRepository;
	private final JobHistoryResource jobHistoryResource;
	private final StandardEncryptionService encryptionService;
	private final ReportService reportService;
	private final InstitutionRepository institutionRepository;

	private static final String SQL_INSERT_TXN_LOG_CUSTOM = "insert into transaction_log_custom values (?,?,?,?)";
	private static final String SQL_SELECT_CUSTOM_TXN_LOG = "select TRL_ID,TRL_TSC_CODE,TRL_TQU_ID,TRL_PAN,TRL_ACQR_INST_ID,TRL_CARD_ACPT_TERMINAL_IDENT,TRL_CUSTOM_DATA,TRL_CUSTOM_DATA_EKY_ID,TRL_PAN_EKY_ID from transaction_log order by TRL_SYSTEM_TIMESTAMP";
	private static final String SQL_SELECT_BIN = "select CBI_BIN from CBC_BIN where CBI_BIN like ?";
	private static final String SQL_TRUNCATE_TXN_LOG_CUSTOM = "TRUNCATE TABLE TRANSACTION_LOG_CUSTOM";
	private static final int MAX_ROW = 50;

	private final Environment env;

	public DatabaseSynchronizer(JobRepository jobRepository, JobSearchRepository jobSearchRepository,
			TaskRepository taskRepository, TaskSearchRepository taskSearchRepository,
			TaskGroupRepository taskGroupRepository, TaskGroupSearchRepository taskGroupSearchRepository,
			JobHistoryResource jobHistoryResource, StandardEncryptionService encryptionService, Environment env,
			ReportService reportService, InstitutionRepository institutionRepository) {
		this.jobRepository = jobRepository;
		this.jobSearchRepository = jobSearchRepository;
		this.taskRepository = taskRepository;
		this.taskSearchRepository = taskSearchRepository;
		this.taskGroupRepository = taskGroupRepository;
		this.taskGroupSearchRepository = taskGroupSearchRepository;
		this.jobHistoryResource = jobHistoryResource;
		this.encryptionService = encryptionService;
		this.env = env;
		this.reportService = reportService;
		this.institutionRepository = institutionRepository;
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
		;

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
//    	Task task1 = new Task();
//    	task1.setName("Truncate DB");
//    	task1.setStatus(ReportConstants.STATUS_ACTIVE);
//    	task1.setContent("TRUNCATE TABLE TRANSACTION_LOG_V3");
//    	task1.setSequence(1);
//    	task1.setType("DB");
//    	task1.setCreatedBy(ReportConstants.CREATED_BY_USER);
//    	task1.setCreatedDate(ZonedDateTime.now());
//    	task1.setTaskGroup(taskGroup);
//    	createTask(task1);
//    	
//    	Task task2 = new Task();
//    	task2.setName("Sync DB Oracle-11g");
//    	task2.setStatus(ReportConstants.STATUS_ACTIVE);
//    	task2.setContent("INSERT INTO TRANSACTION_LOG_V3 SELECT * FROM TRANSACTION_LOG@DBLINK_11G");
//    	task2.setSequence(2);
//    	task2.setType("DB");
//    	task2.setCreatedBy(ReportConstants.CREATED_BY_USER);
//    	task2.setCreatedDate(ZonedDateTime.now());
//    	task2.setTaskGroup(taskGroup);
//    	createTask(task2);
//    	
//    	Task task3 = new Task();
//    	task3.setName("Sync DB Oracle-12c");
//    	task3.setStatus(ReportConstants.STATUS_ACTIVE);
//    	task3.setContent("INSERT INTO TRANSACTION_LOG_V3 SELECT * FROM TRANSACTION_LOG@DBLINK_12C");
//    	task3.setSequence(3);
//    	task3.setType("DB");
//    	task3.setCreatedBy(ReportConstants.CREATED_BY_USER);
//    	task3.setCreatedDate(ZonedDateTime.now());
//    	task3.setTaskGroup(taskGroup);
//    	createTask(task3);
//    }

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

		Connection conn = DriverManager.getConnection(env.getProperty(ReportConstants.DB_URL),
				env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));

		long start = 0;
		long end = 0;
		Statement stmt = null;
		ResultSet rs = null;
		String[] tablesArr = null;
		List<String> tables = null;
		stmt = conn.createStatement();
		Job job = jobRepository.findByName(ReportConstants.JOB_NAME);

		if (job.getTableSync() != null) {
			tablesArr = job.getTableSync().split(",");
			tables = Arrays.asList(tablesArr);
		}

//        TaskGroup taskGroup = taskGroupRepository.findByJobId(job.getId());
//        List<Task> tasks = taskRepository.findByTaskGroupId(taskGroup.getId());
//        Collections.sort(tasks, (a, b) -> a.getSequence() - b.getSequence());

		JobHistory jobHistory1 = new JobHistory();
		jobHistory1.setJob(job);
		jobHistory1.setStatus(ReportConstants.STATUS_IN_PROGRESS);
		jobHistory1.setCreatedDate(Instant.now());
		jobHistory1.setCreatedBy(user);
		jobHistoryResource.createJobHistory(jobHistory1);

		if (tables != null) {
			stmt.executeQuery("TRUNCATE TABLE TRANSACTION_LOG_CUSTOM");

			for (String table : tables) {
				try {
					log.debug("Synchronizing table " + table);
					start = System.nanoTime();

					log.debug("Truncating table " + table);
					try {
						rs = stmt.executeQuery("TRUNCATE TABLE " + table);
					} finally {
						if (rs != null) {
							rs.close();
						}
					}

					log.debug("Inserting latest data into table " + table);
					try {
						rs = stmt.executeQuery("INSERT INTO " + table + " SELECT * FROM " + table + "@"
								+ env.getProperty(ReportConstants.DB_LINK));
					} finally {
						if (rs != null) {
							rs.close();
						}
					}
					end = System.nanoTime();
					log.debug("Complete synchronizing table {} in {} ms", table,
							TimeUnit.NANOSECONDS.toMillis(end - start));
				} catch (SQLException e) {
					log.error("Error is: ", e);
				}
			}
			postProcessData();

		} else {
			log.info("There is no table to sync");
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

		JobHistory jobHistory2 = new JobHistory();
		jobHistory2.setJob(job);
		jobHistory2.setStatus(ReportConstants.STATUS_COMPLETED);
		jobHistory2.setCreatedDate(Instant.now());
		jobHistory2.setCreatedBy(user);
		jobHistoryResource.createJobHistory(jobHistory2);
		
		log.debug("Database synchronizer done. Start generate report tasks.");
		LocalDate transactionDate = LocalDate.now().minusDays(1L);
		
		List<Institution> institutions = institutionRepository.findAll();
		for (Institution institution : institutions) {
			if ("Institution".equals(institution.getType())) {
				reportService.generateAllReports(transactionDate, institution.getId());
			}		
		}	
	}

	private void postProcessData() {
		log.debug("Post Process Transaction Log data");

		Connection conn = null;
		PreparedStatement stmt = null;
		PreparedStatement stmt_insert = null;
		ResultSet rs = null;

		try {
			conn = DriverManager.getConnection(env.getProperty(ReportConstants.DB_URL),
					env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));

			stmt = conn.prepareStatement(SQL_SELECT_CUSTOM_TXN_LOG);
			stmt.setFetchSize(MAX_ROW);
			rs = stmt.executeQuery();

			while (rs.next()) {
				TxnLogCustom txnCustom = fromResultSet(rs.getLong("TRL_ID"), rs.getString("TRL_TSC_CODE"),
						rs.getString("TRL_PAN"), rs.getString("TRL_ACQR_INST_ID"), rs.getString("TRL_CUSTOM_DATA"),
						rs.getInt("TRL_CUSTOM_DATA_EKY_ID"), rs.getInt("TRL_PAN_EKY_ID"));
				stmt_insert = conn.prepareStatement(SQL_INSERT_TXN_LOG_CUSTOM);
				stmt_insert.setLong(1, txnCustom.getTrlId());
				stmt_insert.setString(2, txnCustom.getBillerCode());
				stmt_insert.setString(3, txnCustom.getCardBin());
				stmt_insert.setString(4, txnCustom.getOriginChannel());

				stmt_insert.executeUpdate();

				if (stmt_insert != null) {
					try {
						stmt_insert.close();
					} catch (Exception e) {
					}

				}
			}

			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
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
		Connection conn = DriverManager.getConnection(env.getProperty(ReportConstants.DB_URL),
				env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));

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

	private TxnLogCustom fromResultSet(Long id, String tscCode, String encryptedPan, String acqInstId,
			String encryptedCustomData, int encryptionKeyId, int panEncryptionKeyId) throws Exception {

		log.debug(
				"Post process txn log: id={}, tscCode={}, encryptedPan={}, acqInstId={}, encryptionKeyId={}, panEncryptionKeyId={}",
				id, tscCode, encryptedPan, acqInstId, encryptionKeyId, panEncryptionKeyId);

		try {

			SecurePANField pan = SecurePANField.fromDatabase(encryptedPan, panEncryptionKeyId);
			Map<String, String> customDataMap = retrieveCustomData(encryptedCustomData, encryptionKeyId);

			TxnLogCustom o = new TxnLogCustom();
			o.setTrlId(id);

			if (BILL_PAYMENT_TSC_CODE.equals(tscCode)) {
				o.setBillerCode(customDataMap.get(BILLERCODE_TAG));
			} else {
				o.setBillerCode(null);
			}

			if (encryptedPan != null) {
				o.setCardBin(findBin(pan));
			}

			o.setOriginChannel(determineOriginChannel(customDataMap, acqInstId));

			return o;
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}

	}

	private String findBin(SecurePANField pan) throws Exception {
		String clearPan = pan.getClear();
		String truncatedPan = clearPan.substring(0, 6);

		String binFound = null;
		log.debug("Find matching BIN. pan={}, truncatedPan={}", clearPan, truncatedPan);

		if (matchingBinCache.containsKey(truncatedPan)) {
			binFound = matchingBinCache.get(truncatedPan);
		} else {
			binFound = findMatchingBin(truncatedPan);
			matchingBinCache.put(truncatedPan, binFound);
		}
		log.debug("Find matching BIN: source={}, results={}", truncatedPan, binFound);
		return binFound;
	}

	private String findMatchingBin(String binToMatch) throws Exception {

		Connection conn = null;
		PreparedStatement stmt = null;
		ResultSet rs = null;

		try {
			conn = DriverManager.getConnection(env.getProperty(ReportConstants.DB_URL),
					env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));

			stmt = conn.prepareStatement(SQL_SELECT_BIN);
			stmt.setString(1, binToMatch + "%");
			stmt.setFetchSize(MAX_ROW);
			rs = stmt.executeQuery();

			String matchedBin = "";
			while (rs.next()) {
				if (matchedBin.length() < rs.getString("CBI_BIN").length()) {
					matchedBin = rs.getString("CBI_BIN");
				}
			}

			return matchedBin;

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

	private String determineOriginChannel(Map<String, String> customDataMap, String acqInstId) {
		String originChannel = customDataMap.get(ORIGIN_CHANNEL);

		if (originChannel != null) {
			return originChannel;
		}

		if (acqInstId != null && StringUtils.removeFirst(acqInstId, "0").equals(BANCNET_ONLINE_ACQ_ID)) {
			return BANCNET_ONLINE_CHANNEL_LABEL;
		}

		return null;
	}

	private Map<String, String> retrieveCustomData(String customData, int encryptionKeyId) {

		Map<String, String> map = new HashMap<String, String>();

		if (customData == null || customData.isEmpty()) {
			return map;
		}

		SecureString secureStr = SecureString.fromDatabase(customData, encryptionKeyId);

		String clearXml = "<Root>" + StringUtils.defaultString(secureStr.getClear()) + "</Root>";
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

}
