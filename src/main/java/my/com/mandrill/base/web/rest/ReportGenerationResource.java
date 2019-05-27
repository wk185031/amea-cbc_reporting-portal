package my.com.mandrill.base.web.rest;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.MENU;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_GENERATE_REPORT;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.Date;
import java.util.Optional;
import java.util.Timer;
import java.util.TimerTask;
import java.util.stream.Collectors;

import javax.persistence.EntityManager;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import my.com.mandrill.base.repository.search.JobHistorySearchRepository;
import my.com.mandrill.base.repository.search.JobSearchRepository;
import my.com.mandrill.base.repository.search.ReportCategorySearchRepository;
import my.com.mandrill.base.repository.search.ReportDefinitionSearchRepository;
import my.com.mandrill.base.security.SecurityUtils;

/**
 * REST controller for managing ReportGeneration.
 */
@RestController
@RequestMapping("/api")
public class ReportGenerationResource {

	private final Logger logger = LoggerFactory.getLogger(ReportGenerationResource.class);
	private static final String ENTITY_NAME = "reportGeneration";
	private final ReportCategoryRepository reportCategoryRepository;
	private final ReportCategorySearchRepository reportCategorySearchRepository;
	private final ReportDefinitionRepository reportDefinitionRepository;
	private final ReportDefinitionSearchRepository reportDefinitionSearchRepository;
	private final JobRepository jobRepository;
	private final JobSearchRepository jobSearchRepository;
	private final JobHistoryRepository jobHistoryRepository;
	private final JobHistorySearchRepository jobHistorySearchRepository;
	private final EntityManager entityManager;
	private final Environment env;
	private Timer scheduleTimer = null;
	private Calendar nextTime = null;
	private boolean executed = false;

	public ReportGenerationResource(ReportCategoryRepository reportCategoryRepository,
			ReportCategorySearchRepository reportCategorySearchRepository,
			ReportDefinitionRepository reportDefinitionRepository,
			ReportDefinitionSearchRepository reportDefinitionSearchRepository, JobRepository jobRepository,
			JobSearchRepository jobSearchRepository, JobHistoryRepository jobHistoryRepository,
			JobHistorySearchRepository jobHistorySearchRepository, EntityManager entityManager, Environment env) {
		this.reportCategoryRepository = reportCategoryRepository;
		this.reportCategorySearchRepository = reportCategorySearchRepository;
		this.reportDefinitionRepository = reportDefinitionRepository;
		this.reportDefinitionSearchRepository = reportDefinitionSearchRepository;
		this.jobRepository = jobRepository;
		this.jobSearchRepository = jobSearchRepository;
		this.jobHistoryRepository = jobHistoryRepository;
		this.jobHistorySearchRepository = jobHistorySearchRepository;
		this.entityManager = entityManager;
		this.env = env;
	}

	@Scheduled(cron = "0 0 0 * * *")
	public void initialise() {
		executed = false;
		if (scheduleTimer != null) {
			scheduleTimer.cancel();
		}
		if (scheduleTimer == null) {
			scheduleTimer = new Timer();
		}
		startScheduleTimer();
	}

	private void startScheduleTimer() {
		scheduleTimer.schedule(new TimerTask() {
			public void run() {
				startScheduleTimer();
				new Thread() {
					@Override
					public void run() {
						if (!executed) {
							generateDailyReport();
						}
					}
				}.start();
			}
		}, getNextWakeUpTime());
	}

	private Date getNextWakeUpTime() {
		if (nextTime == null) {
			nextTime = Calendar.getInstance();
		}
		nextTime.add(Calendar.MINUTE, 1);
		return nextTime.getTime();
	}

	private void generateDailyReport() {
		Job job = jobRepository.findByName(ReportConstants.JOB_NAME);
		ZonedDateTime currentDate = ZonedDateTime.of(LocalDateTime.now(), ZoneId.systemDefault());
		Calendar cal = Calendar.getInstance();
		cal.add(Calendar.DATE, -1);
		Date yesterdayDate = cal.getTime();
		String todayDate = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01).format(currentDate);

		for (JobHistory jobHistoryList : jobHistoryRepository.findAll().stream()
				.filter(jobHistory -> jobHistory.getJob().getId() == job.getId()).collect(Collectors.toList())) {
			logger.debug("Job ID: {}, Job History Status: {}", jobHistoryList.getJob().getId(),
					jobHistoryList.getStatus());
			if (jobHistoryList.getStatus().equalsIgnoreCase(ReportConstants.STATUS_COMPLETED)
					&& DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01)
							.format(jobHistoryList.getCreatedDate()).equals(todayDate)) {
				logger.debug(
						"Job History Status: {}, Created Date: {}. Start generating reports. Yesterday Date: {}, Today Date: {}",
						jobHistoryList.getStatus(), jobHistoryList.getCreatedDate(), yesterdayDate, currentDate);
				ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
				reportGenerationMgr.setYesterdayDate(yesterdayDate);
				reportGenerationMgr.setTodayDate(yesterdayDate);

				for (ReportDefinition reportDefinitionList : reportDefinitionRepository.findAll(orderByIdAsc())) {
					reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
					reportGenerationMgr.setFileName(reportDefinitionList.getName());
					reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
					reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
					reportGenerationMgr.setFileLocation(reportDefinitionList.getFileLocation());
					reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
					reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
					reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
					reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
					reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
					reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());
					reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
							env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
				}
			}
			executed = true;
			jobHistoryList.setStatus(ReportConstants.REPORTS_GENERATED);
		}
	}

	@GetMapping("/reportGeneration/{reportCategoryId}/{reportId}/{fileDate}/{txnStart}/{txnEnd}")
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<ReportDefinition> generateReport(@PathVariable Long reportCategoryId,
			@PathVariable Long reportId, @PathVariable String fileDate, @PathVariable String txnStart,
			@PathVariable String txnEnd) throws ParseException {
		logger.debug(
				"User: {}, Rest to generate Report Category ID: {}, Report ID: {}, File Date: {}, Txn Start Date: {}, Txn End Date: {}",
				SecurityUtils.getCurrentUserLogin().orElse(""), reportCategoryId, reportId, fileDate, txnStart, txnEnd);
		ReportDefinition reportDefinition = null;
		txnStart = txnStart.replace("-", "");
		txnEnd = txnEnd.replace("-", "");
		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		reportGenerationMgr.setGenerate(true);
		reportGenerationMgr.setFileDate(getFileDate(fileDate));
		reportGenerationMgr.setTxnStartDate(getTxnStartDate(txnStart));
		reportGenerationMgr.setTxnEndDate(getTxnEndDate(txnEnd));

		if (reportId == 0) {
			for (ReportDefinition reportDefinitionList : reportDefinitionRepository.findAll(orderByIdAsc())) {
				if (reportDefinitionList.getReportCategory().getId() == reportCategoryId) {
					reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
					reportGenerationMgr.setFileName(reportDefinitionList.getName());
					reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
					reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
					reportGenerationMgr.setFileLocation(reportDefinitionList.getFileLocation());
					reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
					reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
					reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
					reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
					reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
					reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());
					reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
							env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
				}
			}
		} else {
			reportDefinition = reportDefinitionRepository.findOne(reportId);
			reportGenerationMgr.setReportCategory(reportDefinition.getReportCategory().getName());
			reportGenerationMgr.setFileName(reportDefinition.getName());
			reportGenerationMgr.setFileNamePrefix(reportDefinition.getFileNamePrefix());
			reportGenerationMgr.setFileFormat(reportDefinition.getFileFormat());
			reportGenerationMgr.setFileLocation(reportDefinition.getFileLocation());
			reportGenerationMgr.setProcessingClass(reportDefinition.getProcessingClass());
			reportGenerationMgr.setHeaderFields(reportDefinition.getHeaderFields());
			reportGenerationMgr.setBodyFields(reportDefinition.getBodyFields());
			reportGenerationMgr.setTrailerFields(reportDefinition.getTrailerFields());
			reportGenerationMgr.setBodyQuery(reportDefinition.getBodyQuery());
			reportGenerationMgr.setTrailerQuery(reportDefinition.getTrailerQuery());
			reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
					env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
		}

		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(reportDefinition));
	}

	private Date getFileDate(String fileDate) throws ParseException {
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
		Date date = df.parse(fileDate);
		return date;
	}

	private Date getTxnStartDate(String txnStart) throws ParseException {
		String txnStartTime = txnStart + " " + ReportConstants.START_TIME;
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_07);
		Date date = df.parse(txnStartTime);
		return date;
	}

	private Date getTxnEndDate(String txnEnd) throws ParseException {
		String txnStartTime = txnEnd + " " + ReportConstants.END_TIME;
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_07);
		Date date = df.parse(txnStartTime);
		return date;
	}

	private Sort orderByIdAsc() {
		return new Sort(Sort.Direction.ASC, "id");
	}
}
