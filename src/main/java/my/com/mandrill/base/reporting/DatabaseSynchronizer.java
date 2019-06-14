package my.com.mandrill.base.reporting;

import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

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

import com.codahale.metrics.annotation.Timed;

import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.Task;
import my.com.mandrill.base.domain.TaskGroup;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.TaskGroupRepository;
import my.com.mandrill.base.repository.TaskRepository;
import my.com.mandrill.base.repository.search.JobSearchRepository;
import my.com.mandrill.base.repository.search.TaskGroupSearchRepository;
import my.com.mandrill.base.repository.search.TaskSearchRepository;
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
    private final JobRepository jobRepository;
    private final JobSearchRepository jobSearchRepository;
    private final TaskGroupRepository taskGroupRepository;
    private final TaskGroupSearchRepository taskGroupSearchRepository;
    private final TaskRepository taskRepository;
    private final TaskSearchRepository taskSearchRepository;
    private final JobHistoryResource jobHistoryResource;

    private final Environment env;
    
	public DatabaseSynchronizer(JobRepository jobRepository, JobSearchRepository jobSearchRepository, TaskRepository taskRepository, 
								TaskSearchRepository taskSearchRepository, TaskGroupRepository taskGroupRepository, 
								TaskGroupSearchRepository taskGroupSearchRepository, JobHistoryResource jobHistoryResource, 
								Environment env) {
		this.jobRepository = jobRepository;
		this.jobSearchRepository = jobSearchRepository;
		this.taskRepository = taskRepository;
		this.taskSearchRepository = taskSearchRepository;
		this.taskGroupRepository = taskGroupRepository;
		this.taskGroupSearchRepository = taskGroupSearchRepository;
		this.jobHistoryResource = jobHistoryResource;
		this.env = env;
	}
	
	TaskScheduler taskScheduler;
    private ScheduledFuture<?> syncDbJob;
    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
        ThreadPoolTaskScheduler threadPoolTaskScheduler =new ThreadPoolTaskScheduler();
        threadPoolTaskScheduler.setPoolSize(10);// Set the pool of threads
        threadPoolTaskScheduler.setThreadNamePrefix("scheduler-thread");
        threadPoolTaskScheduler.initialize();
        scheduleSyncDbJob(threadPoolTaskScheduler);// Assign the job to the scheduler
        this.taskScheduler=threadPoolTaskScheduler;// this will be used in later part of the article during refreshing the cron expression dynamically
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
            .headers(HeaderUtil.createEntityCreationAlert("Job", result.getId().toString()))
            .body(result);
    }
    
    public void createSyncDbTaskGroup(Job job) throws Exception {
    	TaskGroup newTaskGroup = new TaskGroup();
    	newTaskGroup.setName(ReportConstants.JOB_NAME);
    	newTaskGroup.setStatus(ReportConstants.STATUS_ACTIVE);
    	newTaskGroup.setCreatedBy(ReportConstants.CREATED_BY_USER);
    	newTaskGroup.setCreatedDate(ZonedDateTime.now());
    	newTaskGroup.setJob(job);;
    	
    	createTaskGroup(newTaskGroup);
    }
    
    public ResponseEntity<TaskGroup> createTaskGroup(TaskGroup taskGroup) throws Exception {
        log.debug("REST request to save TaskGroup : {}", taskGroup);
        if (taskGroup.getId() != null) {
            throw new BadRequestAlertException("A new TaskGroup cannot already have an ID", "TaskGroup", "idexists");
        }
        TaskGroup result = taskGroupRepository.save(taskGroup);
        taskGroupSearchRepository.save(result);
        createSyncDbTasks(taskGroup);
        return ResponseEntity.created(new URI("/api/task-groups/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert("TaskGroup", result.getId().toString()))
            .body(result);
    }
    
    public void createSyncDbTasks(TaskGroup taskGroup) throws Exception {
    	Task task1 = new Task();
    	task1.setName("Truncate DB");
    	task1.setStatus(ReportConstants.STATUS_ACTIVE);
    	task1.setContent("TRUNCATE TABLE TRANSACTION_LOG_V3");
    	task1.setSequence(1);
    	task1.setType("DB");
    	task1.setCreatedBy(ReportConstants.CREATED_BY_USER);
    	task1.setCreatedDate(ZonedDateTime.now());
    	task1.setTaskGroup(taskGroup);
    	createTask(task1);
    	
    	Task task2 = new Task();
    	task2.setName("Sync DB Oracle-11g");
    	task2.setStatus(ReportConstants.STATUS_ACTIVE);
    	task2.setContent("INSERT INTO TRANSACTION_LOG_V3 SELECT * FROM TRANSACTION_LOG@DBLINK_11G");
    	task2.setSequence(2);
    	task2.setType("DB");
    	task2.setCreatedBy(ReportConstants.CREATED_BY_USER);
    	task2.setCreatedDate(ZonedDateTime.now());
    	task2.setTaskGroup(taskGroup);
    	createTask(task2);
    	
    	Task task3 = new Task();
    	task3.setName("Sync DB Oracle-12c");
    	task3.setStatus(ReportConstants.STATUS_ACTIVE);
    	task3.setContent("INSERT INTO TRANSACTION_LOG_V3 SELECT * FROM TRANSACTION_LOG@DBLINK_12C");
    	task3.setSequence(3);
    	task3.setType("DB");
    	task3.setCreatedBy(ReportConstants.CREATED_BY_USER);
    	task3.setCreatedDate(ZonedDateTime.now());
    	task3.setTaskGroup(taskGroup);
    	createTask(task3);
    }
    
    public ResponseEntity<Task> createTask(Task task) throws URISyntaxException {
        log.debug("REST request to save Task : {}", task);
        if (task.getId() != null) {
            throw new BadRequestAlertException("A new Task cannot already have an ID", "Task", "idexists");
        }
        Task result = taskRepository.save(task);
        taskSearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/tasks/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert("Task", result.getId().toString()))
            .body(result);
    }
    
	public void refreshCronSchedule(){
		if(syncDbJob!=null){
			syncDbJob.cancel(true);
		  	scheduleSyncDbJob(taskScheduler);
		}
	}

	@SuppressWarnings("resource")
	@PostMapping("/synchronize-database/{user}")
    public void synchronizeDatabase(@PathVariable String user) throws Exception {
        log.debug("REST request to Synchronize Database");
        Connection conn = DriverManager.getConnection(env.getProperty(ReportConstants.DB_URL), env.getProperty(ReportConstants.DB_USERNAME),
				env.getProperty(ReportConstants.DB_PASSWORD));
        
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
        jobHistory1.setCreatedDate(ZonedDateTime.now());
        jobHistory1.setCreatedBy(user);
        jobHistoryResource.createJobHistory(jobHistory1);
			
        if (tables != null) {
        	for (String table: tables) {
    			try {
                	log.debug("Synchronizing table " + table);
                	start = System.nanoTime();
                	
                	try {
                    	rs = stmt.executeQuery("DROP TABLE " + table + "_BACKUP");
                	} catch (SQLException e) {
                		log.info("Missing table " + table + "_BACKUP");
                	}
                	rs = stmt.executeQuery("CREATE TABLE " + table + "_BACKUP AS SELECT * FROM " + table);

                	rs = stmt.executeQuery("SELECT CONSTRAINT_NAME FROM USER_CONSTRAINTS WHERE TABLE_NAME = '"+ table +"' AND CONSTRAINT_TYPE='P'");
                	while (rs.next()) {
                    	rs = stmt.executeQuery("ALTER TABLE " + table + " DISABLE CONSTRAINT " + rs.getString("CONSTRAINT_NAME") + " CASCADE");
                    }
                	
                	rs = stmt.executeQuery("ALTER TABLE " + table + " DISABLE ALL TRIGGERS");
                	
                	try {
                    	rs = stmt.executeQuery("TRUNCATE TABLE " + table);
                	} catch (SQLException e) {
                		log.error("Error is: ", e);
                	}          

                	try {
                    	rs = stmt.executeQuery("INSERT INTO " + table + " SELECT * FROM " + table + "@DBLINK_12C");
                	} catch (SQLException e) {
                		rs = stmt.executeQuery("INSERT INTO " + table + " (SELECT * FROM " + table + "_BACKUP)");
                		log.error("Error is: ", e);
                	}
                	
                	end = System.nanoTime();
                	log.debug("Complete synchronizing table " + table + " in " + (TimeUnit.NANOSECONDS.toMillis(end - start)) + "ms");
    	        } catch (SQLException e) {
    	        	log.error("Error is: ", e);
    	        }
    		}
        } else {
        	log.info("There is no table to sync");
        }
        
        if (rs != null) { if (!rs.isClosed()) { rs.close(); } }
        if (stmt != null) { stmt.close(); }
        if (conn != null) { conn.close(); }
        
        JobHistory jobHistory2 = new JobHistory();
        jobHistory2.setJob(job);
        jobHistory2.setStatus(ReportConstants.STATUS_COMPLETED);
        jobHistory2.setCreatedDate(ZonedDateTime.now());
        jobHistory2.setCreatedBy(user);
        jobHistoryResource.createJobHistory(jobHistory2);
    }
	
	@GetMapping("/getTableName")
    @Timed
    public ArrayList<String> getTableName() throws SQLException {
        log.debug("REST request to get list of tables to display");
        Connection conn = DriverManager.getConnection(env.getProperty(ReportConstants.DB_URL), env.getProperty(ReportConstants.DB_USERNAME),
				env.getProperty(ReportConstants.DB_PASSWORD));
        
        Statement stmt = null;
        ResultSet rs = null;
        ArrayList<String> tablesArr = new ArrayList<String>();
        stmt = conn.createStatement();
        
        try {
        	rs = stmt.executeQuery("SELECT TDE_TABLE_NAME FROM TABLE_DETAILS");
        } catch (SQLException e ) {
        	log.error("Error is: ", e);
        }
        
        while (rs.next()) {
        	tablesArr.add(rs.getString("TDE_TABLE_NAME"));
        }
        
        if (rs != null) { if (!rs.isClosed()) { rs.close(); } }
        if (stmt != null) { stmt.close(); }
        if (conn != null) { conn.close(); }

        return tablesArr;
    }

}
