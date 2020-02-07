package my.com.mandrill.base.web.rest;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.MENU;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_GENERATE_REPORT;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.ParseException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.Timer;
import java.util.TimerTask;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import com.codahale.metrics.annotation.Timed;

import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.domain.GeneratedReportDTO;
import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import my.com.mandrill.base.security.SecurityUtils;

/**
 * REST controller for managing ReportGeneration.
 */
@RestController
@RequestMapping("/api")
public class ReportGenerationResource {

	private final Logger logger = LoggerFactory.getLogger(ReportGenerationResource.class);
	private final ReportDefinitionRepository reportDefinitionRepository;
	private final JobRepository jobRepository;
	private final JobHistoryRepository jobHistoryRepository;
	private final Environment env;
	private Timer scheduleTimer = null;
	private Calendar nextTime = null;
	private boolean executed = false;

	public ReportGenerationResource(ReportDefinitionRepository reportDefinitionRepository, ReportCategoryRepository reportCategoryRepository, JobRepository jobRepository,
			JobHistoryRepository jobHistoryRepository, Environment env) {
		this.reportDefinitionRepository = reportDefinitionRepository;
		this.jobRepository = jobRepository;
		this.jobHistoryRepository = jobHistoryRepository;
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
							for (ReportDefinition reportDefinitionList : reportDefinitionRepository
									.findAll(orderByIdAsc())) {
								if (reportDefinitionList.getFrequency().contains(ReportConstants.DAILY)) {
									generateDailyReport();
								}
								if (reportDefinitionList.getFrequency().contains(ReportConstants.MONTHLY)) {
									generateMonthlyReport();
								}
							}
						}
						if (executed) {
							return;
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
		logger.info("In ReportGenerationResource.generateDailyReport()");
		Job job = jobRepository.findByName(ReportConstants.JOB_NAME);
		ZonedDateTime currentDate = ZonedDateTime.of(LocalDateTime.now(), ZoneId.systemDefault());
		LocalDate yesterdayDate = LocalDate.now().minusDays(1L);
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
					reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
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

	private void generateMonthlyReport() {
		logger.info("In ReportGenerationResource.generateMonthlyReport()");
		Job job = jobRepository.findByName(ReportConstants.JOB_NAME);
		LocalDate firstDayOfMonth = YearMonth.from(LocalDateTime.now().atZone(ZoneId.systemDefault())).atDay(1);
		LocalDate lastDayOfMonth = YearMonth.from(LocalDateTime.now().atZone(ZoneId.systemDefault())).atEndOfMonth();
		ZonedDateTime currentDate = ZonedDateTime.from(lastDayOfMonth);
		String endDayOfMonth = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01).format(currentDate);

		for (JobHistory jobHistoryList : jobHistoryRepository.findAll().stream()
				.filter(jobHistory -> jobHistory.getJob().getId() == job.getId()).collect(Collectors.toList())) {
			logger.debug("Job ID: {}, Job History Status: {}", jobHistoryList.getJob().getId(),
					jobHistoryList.getStatus());
			if (jobHistoryList.getStatus().equalsIgnoreCase(ReportConstants.STATUS_COMPLETED)
					&& DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01)
							.format(jobHistoryList.getCreatedDate()).equals(endDayOfMonth)) {
				logger.debug(
						"Job History Status: {}, Created Date: {}. Start generating reports. Yesterday Date: {}, Today Date: {}",
						jobHistoryList.getStatus(), jobHistoryList.getCreatedDate(), firstDayOfMonth, lastDayOfMonth);
				ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
				reportGenerationMgr.setYesterdayDate(firstDayOfMonth);
				reportGenerationMgr.setTodayDate(lastDayOfMonth);

				for (ReportDefinition reportDefinitionList : reportDefinitionRepository.findAll(orderByIdAsc())) {
					reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
					reportGenerationMgr.setFileName(reportDefinitionList.getName());
					reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
					reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
					reportGenerationMgr.setFileLocation(reportDefinitionList.getFileLocation());
					reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
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

	@GetMapping("/report-get-generated-list/{institutionId}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<List<GeneratedReportDTO>> getGeneratedReportList(@PathVariable Long institutionId) {
		logger.debug("User: {}, REST request to get list of reports by institution", SecurityUtils.getCurrentUserLogin());
		List<GeneratedReportDTO> results = retrieveReportsList(institutionId);
		logger.debug("REST finish request to get list of reports by institution");
		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(results));
	}

	private List<GeneratedReportDTO> retrieveReportsList(Long institutionId) {
		logger.debug("User: {}, Rest retrieving list of reports by institution", SecurityUtils.getCurrentUserLogin());

		List<GeneratedReportDTO> results = new ArrayList<>();
		File directory = new File(Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator + institutionId);
		logger.debug("Path =  " + directory.getAbsolutePath());

		if (directory != null) {
			File[] listOfMonth = directory.listFiles();
			for (int i = 0; i < listOfMonth.length; i++) {
				if (listOfMonth[i].isDirectory()) {

					logger.debug("***** Directory: " + listOfMonth[i].getName());
					File daysDir = new File(directory.getAbsolutePath() + File.separator + listOfMonth[i].getName());
					File[] daysDirs = daysDir.listFiles();
					for(int j = 0; j < daysDirs.length; j++){
						if (daysDirs[j].isDirectory() && daysDirs[j].list().length > 0){
							GeneratedReportDTO generateReportDto = new GeneratedReportDTO();
							generateReportDto.setDate(listOfMonth[i].getName() + '-' + daysDirs[j].getName());
							List<String> reportList = new ArrayList<>();
							File reportDir = new File(daysDir.getAbsolutePath() + File.separator + daysDirs[j].getName());
							File[] reportDirs = reportDir.listFiles();

							for (int k = 0; k < reportDirs.length; k++) {
								if ( reportDirs[k].isDirectory() && reportDirs[k].list().length > 0){
									reportList.add(reportDirs[k].getName());
								}
							}
							generateReportDto.setReportList(reportList);
							results.add(generateReportDto);
						}
					}
				}
			}
			logger.debug("Rest finish retrieving list of reports by report category");
		}
		return results;
	}

	@GetMapping("/download-report/{institutionId}/{date}/{reportName}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<Resource> downloadReport(@PathVariable Long institutionId, @PathVariable String date, 
			@PathVariable String reportName) {
		logger.debug("User: {}, REST request to download report", SecurityUtils.getCurrentUserLogin());

		Resource resource = null;
		Path outputPath = null;
		Path outputZipFile =  null;

		String month = date.substring(0,7);
		String day = date.substring(8,10);

		if (reportName.equalsIgnoreCase("All")) {
			logger.debug("Download All Report in " + date);

			outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(), month, day);
			outputZipFile = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(), month, date + ".zip");

		} else {
			logger.debug("Download All Report of " + reportName + "in " + date);

			outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(), month, day, reportName);
			outputZipFile = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(), month, day, date + '-' + reportName + ".zip");
		}

		String zipFile = outputZipFile.toString();
		File directory = new File(outputPath.toString());
		byte[] buffer = new byte[1024];
		FileOutputStream fout = null;
		ZipOutputStream zout = null;
		List<String> filesListInDir = new ArrayList<String>();
		try {
			filesListInDir = populateFilesList(directory, filesListInDir);
			fout = new FileOutputStream(zipFile);
			zout = new ZipOutputStream(fout);

			for (int i=0; i<filesListInDir.size(); i++) {
				logger.debug("Zipping " + filesListInDir.get(i));
				zout.putNextEntry(new ZipEntry(filesListInDir.get(i).substring(directory.getAbsolutePath().length()+1, filesListInDir.get(i).length())));
				FileInputStream fin = new FileInputStream(filesListInDir.get(i));
				int length;
				while ((length = fin.read(buffer)) > 0) {
					zout.write(buffer, 0, length);
				}
				zout.closeEntry();
				fin.close();
			}
			zout.close();
			fout.close();
			resource = new FileSystemResource(outputZipFile.toFile());
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			IOUtils.closeQuietly(zout);
			IOUtils.closeQuietly(fout);
		}
		logger.debug("REST finish request to download report");
		return ResponseEntity.ok().body(resource);
	}

	private List<String> populateFilesList(File dir, List<String> filesListInDir) throws IOException {
		File[] files = dir.listFiles();
        for(int i=0; i<files.length; i++){
			logger.debug("File path = " + files[i].getAbsolutePath());
			if(files[i].isFile()) {
				filesListInDir.add(files[i].getAbsolutePath());
			}
            else populateFilesList(files[i], filesListInDir);
		}
		return filesListInDir;
    }

	private LocalDate getFileDate(String fileDate) throws ParseException {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01);
		LocalDate date = LocalDate.parse(fileDate, formatter);
		return date;
	}

	private LocalDate getTxnStartDate(String txnStart) throws ParseException {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_02);
		LocalDate date = LocalDate.parse(txnStart, formatter);
		return date;
	}

	private LocalDate getTxnEndDate(String txnEnd) throws ParseException {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_02);
		LocalDate date = LocalDate.parse(txnEnd, formatter);
		return date;
	}

	private Sort orderByIdAsc() {
		return new Sort(Sort.Direction.ASC, "id");
	}
}
