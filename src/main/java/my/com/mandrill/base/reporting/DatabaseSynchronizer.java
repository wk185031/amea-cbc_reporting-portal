package my.com.mandrill.base.reporting;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.ZonedDateTime;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.scheduling.Trigger;
import org.springframework.scheduling.TriggerContext;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.scheduling.support.CronTrigger;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.Task;
import my.com.mandrill.base.domain.TaskGroup;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.TaskGroupRepository;
import my.com.mandrill.base.repository.TaskRepository;
import my.com.mandrill.base.web.rest.JobHistoryResource;
import springfox.documentation.spring.web.json.Json;




/**
 * REST controller for managing ReportGeneration.
 */
@Configuration
@EnableScheduling
@RestController
@RequestMapping("/api")
public class DatabaseSynchronizer implements SchedulingConfigurer {

	private final Logger log = LoggerFactory.getLogger(DatabaseSynchronizer.class);
	private static final String DRIVER = "oracle.jdbc.OracleDriver";
	private static final String DB_URL = "jdbc:oracle:thin:@192.168.222.101:59161/orclcdb.localdomain";
	private static final String USERNAME = "CBC_OWNER";
    private final JobRepository jobRepository;
	private final TaskGroupRepository taskGroupRepository;
    private final TaskRepository taskRepository;
    private final JobHistoryResource jobHistoryResource;
    
    volatile boolean isStopIssued;
    
	public DatabaseSynchronizer(JobRepository jobRepository, TaskRepository taskRepository, TaskGroupRepository taskGroupRepository, JobHistoryResource jobHistoryResource) {
		this.jobRepository = jobRepository;
		this.taskRepository = taskRepository;
		this.taskGroupRepository = taskGroupRepository;
		this.jobHistoryResource = jobHistoryResource;
	}
	
	TaskScheduler taskScheduler;
    private ScheduledFuture<?> job1;
    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
        ThreadPoolTaskScheduler threadPoolTaskScheduler =new ThreadPoolTaskScheduler();
        threadPoolTaskScheduler.setPoolSize(10);// Set the pool of threads
        threadPoolTaskScheduler.setThreadNamePrefix("scheduler-thread");
        threadPoolTaskScheduler.initialize();
        scheduleJob(threadPoolTaskScheduler);// Assign the job to the scheduler
        this.taskScheduler=threadPoolTaskScheduler;// this will be used in later part of the article during refreshing the cron expression dynamically
        taskRegistrar.setTaskScheduler(threadPoolTaskScheduler);
    }
    
    private void scheduleJob(TaskScheduler scheduler) {
       job1 = scheduler.schedule(new Runnable() {
       @Override
       public void run() {
            try {
            	synchronizeDatabase("system");
            } catch (Exception e) {
              // TODO Auto-generated catch block
              e.printStackTrace();
          }
          }
       }, new Trigger() {
            @Override
            public Date nextExecutionTime(TriggerContext triggerContext) {
            	Job job = jobRepository.findByName("DB_SYNC");
            	Calendar calendar = Calendar.getInstance();
            	calendar.setTime(job.getScheduleTime());
            	int hour = calendar.get(Calendar.HOUR_OF_DAY);
            	int minute = calendar.get(Calendar.MINUTE);
            	String cronExp = "0 " + minute + " " + hour + " * * ?"; 
            	log.debug(cronExp.toString());
	            return new CronTrigger(cronExp).nextExecutionTime(triggerContext);
          }
        });
    }
    
	public void refreshCronSchedule(){
		if(job1!=null){
			job1.cancel(true);
		  	scheduleJob(taskScheduler);
		}
	}

	@PostMapping("/synchronize-database/{user}")
    public void synchronizeDatabase(@PathVariable String user) throws Exception {
        log.debug("REST request to Synchronize Database");
        Class.forName(DRIVER);
        Connection conn = DriverManager.getConnection(DB_URL, USERNAME, USERNAME);
        
        long start = 0;
        long end = 0;
        Statement stmt = null;
        ResultSet rs = null;
        stmt = conn.createStatement();
        Job job = jobRepository.findByName("DB_SYNC");
        TaskGroup taskGroup = taskGroupRepository.findByJobId(job.getId());
        List<Task> tasks = taskRepository.findByTaskGroupId(taskGroup.getId());
        Collections.sort(tasks, (a, b) -> a.getSequence() - b.getSequence());
        
        JobHistory jobHistory1 = new JobHistory();
        jobHistory1.setJob(job);
        jobHistory1.setStatus("EXECUTED");
        jobHistory1.setCreatedDate(ZonedDateTime.now());
        jobHistory1.setCreatedBy(user);
        jobHistoryResource.createJobHistory(jobHistory1);
			
        for (Task task: tasks) {
			try {
            	log.debug("Executing task " + task.getName());
            	start = System.nanoTime();
            	rs = stmt.executeQuery(task.getContent());
            	end = System.nanoTime();
            	log.debug("Complete executing task " + task.getName() + " in " + (TimeUnit.NANOSECONDS.toMillis(end - start)) + "ms");
	        } catch (SQLException e ) {
	        	log.error("Error is: ", e);
	        }
		}
        if (!rs.isClosed()) { rs.close(); }
        if (stmt != null) { stmt.close(); }
        if (conn != null) { conn.close(); }
        
        JobHistory jobHistory2 = new JobHistory();
        jobHistory2.setJob(job);
        jobHistory2.setStatus("COMPLETED");
        jobHistory2.setCreatedDate(ZonedDateTime.now());
        jobHistory2.setCreatedBy(user);
        jobHistoryResource.createJobHistory(jobHistory2);
        
    }

}
