package my.com.mandrill.base.web.rest;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.MENU;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_GENERATE_REPORT;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.ParseException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.FileSystemUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.config.audit.AuditActionService;
import my.com.mandrill.base.config.audit.AuditActionType;
import my.com.mandrill.base.domain.GeneratedReportDTO;
import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.JobHistoryDetails;
import my.com.mandrill.base.domain.ReportCategory;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.domain.User;
import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.repository.InstitutionRepository;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import my.com.mandrill.base.repository.UserExtraRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.service.EncryptionService;
import my.com.mandrill.base.service.JobHistoryService;
import my.com.mandrill.base.service.ReportService;
import my.com.mandrill.base.service.UserService;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import net.logstash.logback.encoder.org.apache.commons.lang.StringUtils;

/**
 * REST controller for managing ReportGeneration.
 */
@RestController
@RequestMapping("/api")
public class ReportGenerationResource {

	private final Logger logger = LoggerFactory.getLogger(ReportGenerationResource.class);
	private final ReportDefinitionRepository reportDefinitionRepository;
	private final ReportCategoryRepository reportCategoryRepository;
	private final JobRepository jobRepository;
	private final JobHistoryRepository jobHistoryRepository;
	private final InstitutionRepository institutionRepository;
	private final UserService userService;
	private final UserExtraRepository userExtraRepository;
	private final EncryptionService encryptionService;
	private final ReportService reportService;
	private final AuditActionService auditActionService;
	private final JobHistoryService jobHistoryService;
	private final Environment env;
	private static String userInsId = "";
	private ObjectMapper mapper = new ObjectMapper();

	public ReportGenerationResource(ReportDefinitionRepository reportDefinitionRepository,
			ReportCategoryRepository reportCategoryRepository, JobRepository jobRepository,
			JobHistoryRepository jobHistoryRepository, InstitutionRepository institutionRepository,
			EncryptionService encryptionService, Environment env, UserService userService,
			UserExtraRepository userExtraRepository, ReportService reportService, AuditActionService auditActionService,
			JobHistoryService jobHistoryService) {
		this.reportDefinitionRepository = reportDefinitionRepository;
		this.reportCategoryRepository = reportCategoryRepository;
		this.jobRepository = jobRepository;
		this.jobHistoryRepository = jobHistoryRepository;
		this.institutionRepository = institutionRepository;
		this.userService = userService;
		this.userExtraRepository = userExtraRepository;
		this.encryptionService = encryptionService;
		this.reportService = reportService;
		this.auditActionService = auditActionService;
		this.jobHistoryService = jobHistoryService;
		this.env = env;
	}

	// @Scheduled(cron = "0 13 6 * * *")
//	public void initialise() {
//		executed = false;
//		if (scheduleTimer != null) {
//			scheduleTimer.cancel();
//		}
//		if (scheduleTimer == null) {
//			scheduleTimer = new Timer();
//		}
//		startScheduleTimer();
//	}
//
//	private void startScheduleTimer() {
//		scheduleTimer.schedule(new TimerTask() {
//			public void run() {
//				startScheduleTimer();
//				new Thread() {
//					@Override
//					public void run() {
//						if (!executed) {
//							Job job = jobRepository.findByName(ReportConstants.JOB_NAME_DB_SYNC);
//
//							ZonedDateTime currentDate = ZonedDateTime.of(LocalDateTime.now(), ZoneId.systemDefault());
//							LocalDate yesterdayDate = LocalDate.now().minusDays(1L);
//							String todayDate = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01)
//									.format(currentDate);
//							LocalDate lastDayOfMonth = YearMonth
//									.from(LocalDateTime.now().atZone(ZoneId.systemDefault())).atEndOfMonth();
//
//							for (JobHistory jobHistoryList : jobHistoryRepository.findAll().stream()
//									.filter(jobHistory -> jobHistory.getJob().getId() == job.getId())
//									.collect(Collectors.toList())) {
//								logger.debug("Job ID: {}, Job History Status: {}", jobHistoryList.getJob().getId(),
//										jobHistoryList.getStatus());
//
//								if (jobHistoryList.getStatus().equalsIgnoreCase(ReportConstants.STATUS_COMPLETED)
//										&& DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01)
//												.format(jobHistoryList.getCreatedDate()).equals(todayDate)) {
//									logger.debug(
//											"Job History Status: {}, Created Date: {}. Start generating reports. Transaction Date: {}, Report Run Date: {}",
//											jobHistoryList.getStatus(), jobHistoryList.getCreatedDate(), yesterdayDate,
//											currentDate);
//
//									for (Map.Entry<Long, String> mapEntry : reportService
//											.getAllInstitutionIdAndShortCode().entrySet()) {
//										try {
//											preGenerateReport(LocalDate.now().minusDays(1L).atStartOfDay(),
//													LocalDate.now().minusDays(1L).atTime(23, 59), mapEntry.getKey(),
//													mapEntry.getValue(), null, null, false, false,
//													ReportConstants.CREATED_BY_USER);
//										} catch (JsonProcessingException e) {
//											throw new RuntimeException(e);
//										}
//									}
//
//									executed = true;
//									jobHistoryList.setStatus(ReportConstants.REPORTS_GENERATED);
//									jobHistoryRepository.save(jobHistoryList);
//								}
//							}
//						}
//						if (executed) {
//							return;
//						}
//					}
//				}.start();
//			}
//		}, getNextWakeUpTime());
//	}
//
//	private Date getNextWakeUpTime() {
//		if (nextTime == null) {
//			nextTime = Calendar.getInstance();
//		}
//		nextTime.add(Calendar.MINUTE, 1);
//		return nextTime.getTime();
//	}

	@GetMapping("/reportGeneration/{institutionId}/{reportCategoryId}/{reportId}")
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<ReportDefinition> generateReport(@PathVariable Long institutionId,
			@PathVariable Long reportCategoryId, @PathVariable Long reportId, @RequestParam String startDateTime,
			@RequestParam String endDateTime) throws ParseException, JsonProcessingException {
		logger.debug(
				"User: {}, Rest to generate Report Institution ID: {}, Category ID: {}, Report ID: {}, StartDateTime: {}, EndDateTime: {}",
				SecurityUtils.getCurrentUserLogin().orElse(""), institutionId, reportCategoryId, reportId,
				startDateTime, endDateTime);

		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

		LocalDateTime inputStartDateTime = LocalDateTime.parse(startDateTime, formatter);
		LocalDateTime inputEndDateTime = LocalDateTime.parse(endDateTime, formatter);

		JobHistoryDetails jobHistoryDetails = new JobHistoryDetails(institutionId,
				reportCategoryId != null ? reportCategoryId : 0L, null, reportId != null ? reportId : 0L, null, null,
				inputStartDateTime, inputEndDateTime);

		jobHistoryService.queueReportJob(jobHistoryDetails);

		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(new ReportDefinition()));
	}

//	public void generateReportByInstitutionAndCategory(LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime,
//			Long institutionId, String instShortCode, Long reportCategoryId, Long reportId, boolean manualMonthly,
//			boolean manualGenerate, String user) {
//		logger.debug(
//				"generateReportByInstitutionAndCategory: [institution={}, inputStartDateTime={}, inputEndDateTime={}, institutionId={}, instShortCode={}, reportCategoryId={}, reportId={}, includeMonthly={}, manualGenerate={}]",
//				institutionId, inputStartDateTime, inputEndDateTime, institutionId, instShortCode, reportCategoryId,
//				reportId, manualMonthly, manualGenerate);
//
//		String yearMonth = inputStartDateTime.toLocalDate().format(DateTimeFormatter.ofPattern("yyyy-MM"));
//		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
//				+ institutionId + File.separator + yearMonth;
//
//		try {
//			List<ReportDefinition> aList = new ArrayList<>();
//			String reportCategory = null;
//			String report = null;
//
//			if (reportCategoryId == null || reportCategoryId <= 0) {
//				aList = reportDefinitionRepository.findByInstitutionIdOrderByName(institutionId);
//				reportCategory = "ALL";
//				report = "ALL";
//			} else if (reportId == null || reportId <= 0) {
//				aList = reportDefinitionRepository.findByCategoryIdAndInstitutionIdOrderByName(reportCategoryId,
//						institutionId);
//				reportCategory = reportCategoryRepository.findOne(reportCategoryId).getName();
//				report = "ALL";
//			} else {
//				ReportDefinition reportDefinition = reportDefinitionRepository.findOne(reportId);
//				if (reportDefinition != null) {
//					aList.add(reportDefinition);
//				}
//
//				reportCategory = reportCategoryRepository.findOne(reportCategoryId).getName();
//				report = reportDefinition.getName();
//			}
//			logger.debug("Process {} reports", aList.size());
//			String description = "REPORT CATEGORY: " + reportCategory + ", REPORT: " + report + ", FROM: "
//					+ inputStartDateTime.toString() + ", TO: " + inputEndDateTime.toString();
//
//			Job job = jobRepository.findByName(ReportConstants.JOB_NAME_GENERATE_REPORT);
//			JobHistoryDetails jobHistoryDetails = new JobHistoryDetails(institutionId,
//					reportCategoryId != null ? reportCategoryId : 0L, reportCategory, reportId, report, description,
//					inputStartDateTime, inputEndDateTime);
//
//			String dailyReportPath = null;
//			String monthlyReportPath = null;
//
//			boolean isDailyFreq = aList.stream().anyMatch(p -> p.getFrequency().contains("Daily"));
//			boolean isMonthlyOnlyFreq = aList.stream().anyMatch(p -> p.getFrequency().matches("Monthly"));
//
//			long dailyJobId = 0;
//			long monthlyJobId = 0;
//
//			if (isDailyFreq) {
//				dailyJobId = reportService.createJobHistory(job, user, inputStartDateTime, inputEndDateTime,
//						mapper.writeValueAsString(jobHistoryDetails), ReportConstants.DAILY);
//				dailyReportPath = directory + File.separator
//						+ StringUtils.leftPad(String.valueOf(inputStartDateTime.getDayOfMonth()), 2, "0")
//						+ File.separator + dailyJobId;
//			}
//
//			if (reportService.isGenerateMonthlyReport(isDailyFreq, isMonthlyOnlyFreq, manualMonthly,
//					inputStartDateTime)) {
//				monthlyJobId = reportService.createJobHistory(job, user, inputStartDateTime, inputEndDateTime,
//						mapper.writeValueAsString(jobHistoryDetails), ReportConstants.MONTHLY);
//				monthlyReportPath = directory + File.separator + "00" + File.separator + monthlyJobId;
//			}
//
//			for (ReportDefinition reportDefinition : aList) {
//				ReportGenerationMgr mgr = ReportGenerationMgr.create(0L, instShortCode, manualGenerate, inputStartDateTime,
//						env, encryptionService, reportDefinition);
//
//				reportService.generateReport(mgr, reportDefinition, inputStartDateTime, inputEndDateTime, aList,
//						manualGenerate, directory, dailyJobId, monthlyJobId, isDailyFreq, isMonthlyOnlyFreq,
//						manualMonthly, jobHistoryDetails, dailyReportPath, monthlyReportPath, user, job);
//			}
//
//		} catch (Exception e) {
//			throw new RuntimeException("Failed to generate report", e);
//		}
//
//	}

//	public void preGenerateReport(LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime, Long institutionId,
//			String instShortCode, Long reportCategoryId, Long reportId, boolean manualMonthly, boolean manualGenerate, String user) throws JsonProcessingException {
//		
//		logger.debug(
//				"Generate report for institution={} [inputStartDateTime={}, inputEndDateTime={}, institutionId={}, instShortCode={}, reportCategoryId={}, reportId={}, includeMonthly={}, manualGenerate={}",
//				institutionId, inputStartDateTime, inputEndDateTime, institutionId, instShortCode, reportCategoryId,
//				reportId, manualMonthly, manualGenerate);
//
//		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
//		reportGenerationMgr.setInstitution(instShortCode);
//		reportGenerationMgr.setGenerate(manualGenerate);
//		reportGenerationMgr.setFileDate(inputStartDateTime.toLocalDate());
//		reportGenerationMgr.setYesterdayDate(LocalDate.now().minusDays(1L));
//		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
//		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
//		reportGenerationMgr.setAuthenticDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC));
//		reportGenerationMgr.setAuthenticDbLink(env.getProperty(ReportConstants.DB_LINK_AUTHENTIC));
//		reportGenerationMgr.setEncryptionService(encryptionService);
//
//		String yearMonth = inputStartDateTime.toLocalDate().format(DateTimeFormatter.ofPattern("yyyy-MM"));
//		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
//				+ institutionId + File.separator + yearMonth;
//
//		List<ReportDefinition> aList = new ArrayList<>();
//				
//		String reportCategory = null;
//		String report = null;
//
//		if (reportCategoryId == null || reportCategoryId <= 0) {
//			aList = reportDefinitionRepository.findReportDefinitionByInstitution(institutionId);
//			reportCategory = "ALL";
//			report = "ALL";
//		} else if (reportId == null || reportId <= 0) {
//			aList = reportDefinitionRepository.findAllByCategoryIdAndInstitutionId(reportCategoryId, institutionId);
//			reportCategory = reportCategoryRepository.findOne(reportCategoryId).getName();
//			report = "ALL";
//		} else {
//			ReportDefinition reportDefinition = reportDefinitionRepository.findOne(reportId);
//			if (reportDefinition != null) {
//				aList.add(reportDefinition);
//			}
//			
//			reportCategory = reportCategoryRepository.findOne(reportCategoryId).getName();
//			report = reportDefinition.getName();
//		}
//		logger.debug("Process {} reports", aList.size());
//		
//		LocalDateTime currentTs = LocalDateTime.now();
//		String description = "REPORT CATEGORY: " + reportCategory + ", REPORT: " + report + ", FROM: " + inputStartDateTime.toString() + ", TO: " + inputEndDateTime.toString();
//		
//		Job job = jobRepository.findByName(ReportConstants.JOB_NAME_GENERATE_REPORT);
//		JobHistoryDetails jobHistoryDetails = new JobHistoryDetails(institutionId.toString(), reportCategoryId != null ? reportCategoryId.toString() : "0", reportCategory, 
//				report, description, inputStartDateTime.toString(), inputStartDateTime.toString(), inputEndDateTime.toString(), currentTs.toString(), null);
//				
//		String dailyReportPath = null;
//		String monthlyReportPath = null;
//		
//		boolean isDailyFreq = aList.stream().anyMatch(p -> p.getFrequency().contains("Daily"));
//		boolean isMonthlyOnlyFreq = aList.stream().anyMatch(p -> p.getFrequency().matches("Monthly"));
//		
//		long dailyJobId = 0; 
//		long monthlyJobId = 0;
//		
//		if(isDailyFreq) {
//			dailyJobId = reportService.createJobHistory(job, user, inputStartDateTime, inputEndDateTime, mapper.writeValueAsString(jobHistoryDetails), ReportConstants.DAILY);
//			dailyReportPath = directory + File.separator + StringUtils.leftPad(String.valueOf(inputStartDateTime.getDayOfMonth()), 2, "0") + File.separator + dailyJobId;		
//		} 
//		
//		if (reportService.isGenerateMonthlyReport(isDailyFreq, isMonthlyOnlyFreq, manualMonthly, inputStartDateTime)) {
//			monthlyJobId = reportService.createJobHistory(job, user, inputStartDateTime, inputEndDateTime, mapper.writeValueAsString(jobHistoryDetails), ReportConstants.MONTHLY);
//			monthlyReportPath = directory + File.separator + "00" + File.separator + monthlyJobId;	
//		}
//		
//		reportService.generateReport(reportGenerationMgr, null, inputStartDateTime, inputEndDateTime, aList, manualGenerate, directory, dailyJobId, monthlyJobId, isDailyFreq,
//				isMonthlyOnlyFreq, manualMonthly, jobHistoryDetails, dailyReportPath, monthlyReportPath, user, job);
//
//	}

	private String findInstitutionCode(Long institutionId) {

		Institution inst = institutionRepository.findOne(institutionId);
		if (ReportConstants.CBS_INSTITUTION.equals(inst.getName())) {
			setUserInsId("CBS");
			return "CBS";
		} else {
			setUserInsId("CBC");
			return "CBC";
		}
	}

	private String getUserBranchCode() {
		String branchCode = null;

		final Optional<User> isUser = userService.getUserWithAuthorities();

		if (isUser.isPresent()) {
			User user = isUser.get();
			// get user extra from given user
			UserExtra userExtra = userExtraRepository.findByUser(user.getId());
			if (null != userExtra.getBranches() && !userExtra.getBranches().isEmpty()) {
				branchCode = userExtra.getBranches().stream().findFirst().get().getAbr_code();
			}
		}

		return branchCode;
	}

	private String getUsername() {
		return userExtraRepository.findByUser(userService.getUserWithAuthorities().get().getId()).getName();
	}

	@GetMapping("/report-get-generated/{institutionId}/{reportDate}/{reportCategoryId}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<GeneratedReportDTO> getGeneratedReportList(@PathVariable Long institutionId,
			@PathVariable String reportDate, @PathVariable Long reportCategoryId) {
		logger.debug("User: {}, REST request to get generated report by institution and report category",
				SecurityUtils.getCurrentUserLogin());

		GeneratedReportDTO result = null;

		if (reportCategoryId.equals(new Long(0))) {
			result = retrieveAllReportbyDate(institutionId, reportDate, getUserBranchCode());
		} else {
			result = retrieveReportbyReportCategory(institutionId, reportDate, reportCategoryId, getUserBranchCode());
		}
		logger.debug("REST finish request to get generated report by institution and report category");
		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(result));
	}

	private GeneratedReportDTO retrieveReportbyReportCategory(Long institutionId, String reportDate,
			Long reportCategoryId, String branchCode) {
		logger.debug("User: {}, Rest retrieving generated reports by institution and report category",
				SecurityUtils.getCurrentUserLogin());

		ReportCategory reportCategory = reportCategoryRepository.findOne(reportCategoryId);

		GeneratedReportDTO result = new GeneratedReportDTO();
		result.setReportCategory(reportCategory);
		result.setReportDate(reportDate);

		String reportYear = reportDate.substring(0, 4);
		String reportMonth = reportDate.substring(5, 7);
		String reportDay = reportDate.substring(8, 10);

		List<File> files = new ArrayList<>();

		// cater for master user
		if (branchCode == null) {
			File mainDirectory = new File(
					Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator + institutionId
							+ File.separator + reportYear + '-' + reportMonth + File.separator + reportDay
							+ File.separator + ReportConstants.MAIN_PATH + File.separator + reportCategory.getName());

			files.add(mainDirectory);

			// include branch report as well for master user
			File rootDirectory = new File(Paths.get(env.getProperty("application.reportDir.path")).toString()
					+ File.separator + institutionId + File.separator + reportYear + '-' + reportMonth + File.separator
					+ reportDay + File.separator);

			List<String> branchFolders = getBranchFolders(rootDirectory, reportCategory.getBranchFlag());
			File branchDirectory = null;

			for (String branchFolder : branchFolders) {
				branchDirectory = new File(Paths.get(env.getProperty("application.reportDir.path")).toString()
						+ File.separator + institutionId + File.separator + reportYear + '-' + reportMonth
						+ File.separator + reportDay + File.separator + branchFolder + File.separator
						+ reportCategory.getName());
				files.add(branchDirectory);
			}
		}
		// cater for branch user
		else {
			File branchDirectory = new File(Paths.get(env.getProperty("application.reportDir.path")).toString()
					+ File.separator + institutionId + File.separator + reportYear + '-' + reportMonth + File.separator
					+ reportDay + File.separator + branchCode + File.separator + reportCategory.getName());
			files.add(branchDirectory);
		}

		List<String> reportList = new ArrayList<>();
		File[] reports = null;

		for (File directory : files) {
			if (!directory.exists()) {
				directory.mkdirs();
			}

			reports = directory.listFiles();

			for (int i = 0; i < reports.length; i++) {
				if (reports[i].isFile()) {
					reportList.add(reports[i].getName());
				}
			}
		}

		result.setReportList(reportList);

		logger.debug("Rest finish retrieving generated reports by report category");
		return result;
	}

	private GeneratedReportDTO retrieveAllReportbyDate(Long institutionId, String reportDate, String branchCode) {
		logger.debug("User: {}, Rest retrieving generated reports by institution and report date",
				SecurityUtils.getCurrentUserLogin());

		GeneratedReportDTO result = new GeneratedReportDTO();
		result.setReportDate(reportDate);

		String reportYear = reportDate.substring(0, 4);
		String reportMonth = reportDate.substring(5, 7);
		String reportDay = reportDate.substring(8, 10);
		File directory = new File(Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator + reportYear + '-' + reportMonth + File.separator + reportDay
				+ File.separator + ReportConstants.MAIN_PATH + File.separator);

		if (!directory.exists()) {
			directory.mkdirs();
		}

		List<String> reportList = new ArrayList<>();
		File[] dirs = directory.listFiles();

		for (int i = 0; i < dirs.length; i++) {
			if (dirs[i].isDirectory() && dirs[i].listFiles().length > 0) {
				reportList.add("Download All");
				break;
			}
		}
		result.setReportList(reportList);

		logger.debug("Rest finish retrieving generated reports by report category");
		return result;
	}

	@DeleteMapping("/delete-report/{jobId}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<Void> deleteReport(@PathVariable Long jobId) throws IOException {

		JobHistory jobHistory = jobHistoryRepository.findOne(jobId);
		try {
			File directoryToDelete = new File(jobHistory.getReportPath());
			FileSystemUtils.deleteRecursively(directoryToDelete);

			jobHistory.setStatus(ReportConstants.STATUS_DELETED);
			jobHistoryRepository.save(jobHistory);
			auditActionService.addSuccessEvent(AuditActionType.REPORT_DELETE, jobHistory.getId().toString());
			return ResponseEntity.ok().headers(HeaderUtil.createAlert("baseApp.report.deleted", jobId.toString()))
					.build();
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.REPORT_DELETE, jobHistory.getId().toString(), e);
			throw e;
		}
	}

	public static void deleteDirectory(Path path) {
		try {
			Files.delete(path);
		} catch (IOException e) {

		}
	}

	@GetMapping("/download-report/{institutionId}/{reportDate}/{reportCategoryId}/{reportName:.+}/{jobId}/{frequency}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<Resource> downloadReport(@PathVariable Long institutionId, @PathVariable String reportDate,
			@PathVariable Long reportCategoryId, @PathVariable String reportName, @PathVariable Long jobId,
			@PathVariable String frequency) throws IOException {
		logger.debug("User: {}, REST request to download report", SecurityUtils.getCurrentUserLogin());

		Resource resource = null;
		Path rootOutputPath = null;
		Path mainOutputPath = null;
		Path mainOutputZipFile = null;
		Path branchOutputPath = null;
		Path branchOutputZipFile = null;
		List<Path> outputPathList = new ArrayList<>();
		List<Path> outputZipFileList = new ArrayList<>();

		String reportYear = reportDate.substring(0, 4);
		String reportMonth = reportDate.substring(5, 7);
		String reportDay = reportDate.substring(8, 10);

		if (frequency != null && frequency.equalsIgnoreCase("Monthly")) {
			logger.debug("Downloading " + frequency);
			reportDay = "00";
		}

		String branchCode = getUserBranchCode();
		try {
			// master user
			if (branchCode == null) {
				// job having 'ALL' instead of specific report category
				if (reportCategoryId.equals(new Long(0))) {
					mainOutputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
							reportYear + '-' + reportMonth, reportDay, jobId.toString(), ReportConstants.MAIN_PATH);
					mainOutputZipFile = Paths.get(env.getProperty("application.reportDir.path"),
							institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
							ReportConstants.MAIN_PATH + ".zip");

					outputPathList.add(mainOutputPath);
					outputZipFileList.add(mainOutputZipFile);

					List<String> branchFolders = getBranchFolders(
							new File(Paths.get(env.getProperty("application.reportDir.path")).toString()
									+ File.separator + institutionId + File.separator + reportYear + '-' + reportMonth
									+ File.separator + reportDay + File.separator + jobId + File.separator),
							null);

					for (String branchFolder : branchFolders) {
						branchOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
								branchFolder);

						outputPathList.add(branchOutputPath);
					}

					List<String> filesListInDir = new ArrayList<String>();
					List<String> combineFileListInDir = new ArrayList<String>();
					List<File> directoryList = new ArrayList<>();

					File mainDirectory = new File(mainOutputPath.toString());

					for (int i = 0; i < outputPathList.size(); i++) {
						filesListInDir.clear();
						File directory = new File(outputPathList.get(i).toString());
						filesListInDir = populateFilesList(directory, filesListInDir);
						directoryList.add(directory);
						combineFileListInDir.addAll(filesListInDir);
					}

					String zipFile = mainOutputZipFile.toString();

					byte[] buffer = new byte[1024];
					FileOutputStream fout = null;
					ZipOutputStream zout = null;

					try {

						fout = new FileOutputStream(zipFile);
						zout = new ZipOutputStream(fout);

						for (int j = 0; j < combineFileListInDir.size(); j++) {
							logger.debug("Zipping " + combineFileListInDir.get(j));
							zout.putNextEntry(new ZipEntry(
									combineFileListInDir.get(j).substring(mainDirectory.getAbsolutePath().length() - 4,
											combineFileListInDir.get(j).length())));

							FileInputStream fin = new FileInputStream(combineFileListInDir.get(j));
							int length;
							while ((length = fin.read(buffer)) > 0) {
								zout.write(buffer, 0, length);
							}
							zout.closeEntry();
							fin.close();
						}
						zout.close();
						fout.close();
						resource = new FileSystemResource(mainOutputZipFile.toFile());
					} catch (IOException e) {
						e.printStackTrace();
					} finally {
						IOUtils.closeQuietly(zout);
						IOUtils.closeQuietly(fout);
					}
				} else {
					// job having specific report category
					ReportCategory reportCategory = reportCategoryRepository.findOne(reportCategoryId);
					Path outputZipFile = null;

					// job having specific specific report selected
					if (!reportName.equalsIgnoreCase("All")) {
						rootOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString());
						outputZipFile = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
								ReportConstants.MAIN_PATH, reportCategory.getName() + ".zip");
						logger.debug("rootOutputPath: " + rootOutputPath.toString());
						List<String> filesListInDir = new ArrayList<String>();

						File directory = new File(rootOutputPath.toString());
						filesListInDir = populateFilesList(directory, filesListInDir);
						logger.debug("DIR: " + directory);
						String zipFile = outputZipFile.toString();

						byte[] buffer = new byte[1024];
						FileOutputStream fout = null;
						ZipOutputStream zout = null;

						File rootDirectory = new File(rootOutputPath.toString());

						try {

							fout = new FileOutputStream(zipFile);
							zout = new ZipOutputStream(fout);

							for (int k = 0; k < filesListInDir.size(); k++) {
								logger.debug("Zipping " + filesListInDir.get(k));
								zout.putNextEntry(new ZipEntry(
										filesListInDir.get(k).substring(rootDirectory.getAbsolutePath().length() + 1)));
								FileInputStream fin = new FileInputStream(filesListInDir.get(k));
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
					}
					// job having 'All' reports from given category
					else {
						rootOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString());
						mainOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
								ReportConstants.MAIN_PATH, reportCategory.getName());
						mainOutputZipFile = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
								ReportConstants.MAIN_PATH,
								reportCategory.getName() + reportYear + '-' + reportMonth + '-' + reportDay + ".zip");

						outputPathList.add(mainOutputPath);

						List<String> branchFolders = getBranchFolders(new File(
								Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
										+ institutionId + File.separator + reportYear + '-' + reportMonth
										+ File.separator + reportDay + File.separator + jobId + File.separator),
								reportCategory.getBranchFlag());

						for (String branchFolder : branchFolders) {
							branchOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
									institutionId.toString(), reportYear + '-' + reportMonth, reportDay,
									jobId.toString(), branchFolder);

							outputPathList.add(branchOutputPath);
						}

						List<String> filesListInDir = new ArrayList<String>();
						List<String> combineFileListInDir = new ArrayList<String>();

						File rootDirectory = new File(rootOutputPath.toString());

						for (int i = 0; i < outputPathList.size(); i++) {
							filesListInDir.clear();
							File directory = new File(outputPathList.get(i).toString());
							filesListInDir = populateFilesList(directory, filesListInDir);
							combineFileListInDir.addAll(filesListInDir);
						}

						String zipFile = mainOutputZipFile.toString();

						byte[] buffer = new byte[1024];
						FileOutputStream fout = null;
						ZipOutputStream zout = null;

						try {

							fout = new FileOutputStream(zipFile);
							zout = new ZipOutputStream(fout);

							for (int k = 0; k < combineFileListInDir.size(); k++) {
								logger.debug("Zipping " + combineFileListInDir.get(k));
								zout.putNextEntry(new ZipEntry(combineFileListInDir.get(k)
										.substring(rootDirectory.getAbsolutePath().length() + 1)));
								FileInputStream fin = new FileInputStream(combineFileListInDir.get(k));
								int length;
								while ((length = fin.read(buffer)) > 0) {
									zout.write(buffer, 0, length);
								}
								zout.closeEntry();
								fin.close();
							}
							zout.close();
							fout.close();
							resource = new FileSystemResource(mainOutputZipFile.toFile());
						} catch (IOException e) {
							e.printStackTrace();
						} finally {
							IOUtils.closeQuietly(zout);
							IOUtils.closeQuietly(fout);
						}
					}
				}
			}
			// branch user
			else {
				// job having 'ALL' instead of specific report category
				if (reportCategoryId.equals(new Long(0))) {

					branchOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
							institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
							branchCode);
					branchOutputZipFile = Paths.get(env.getProperty("application.reportDir.path"),
							institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
							branchCode + ".zip");

					List<String> filesListInDir = new ArrayList<String>();
					List<File> directoryList = new ArrayList<>();

					File branchDirectory = new File(branchOutputPath.toString());

					File directory = new File(branchOutputPath.toString());
					filesListInDir = populateFilesList(directory, filesListInDir);
					directoryList.add(directory);

					String zipFile = branchOutputZipFile.toString();

					byte[] buffer = new byte[1024];
					FileOutputStream fout = null;
					ZipOutputStream zout = null;

					try {

						fout = new FileOutputStream(zipFile);
						zout = new ZipOutputStream(fout);

						for (int j = 0; j < filesListInDir.size(); j++) {
							logger.debug("Zipping " + filesListInDir.get(j));
							zout.putNextEntry(new ZipEntry(filesListInDir.get(j).substring(
									branchDirectory.getAbsolutePath().length() - 4, filesListInDir.get(j).length())));

							FileInputStream fin = new FileInputStream(filesListInDir.get(j));
							int length;
							while ((length = fin.read(buffer)) > 0) {
								zout.write(buffer, 0, length);
							}
							zout.closeEntry();
							fin.close();
						}
						zout.close();
						fout.close();
						resource = new FileSystemResource(branchOutputZipFile.toFile());
					} catch (IOException e) {
						e.printStackTrace();
					} finally {
						IOUtils.closeQuietly(zout);
						IOUtils.closeQuietly(fout);
					}
				} else {
					// job having specific report category
					logger.debug("reportName " + reportName);
					// job having specific report
					if (!reportName.equalsIgnoreCase("All")) {

						ReportCategory reportCategory = reportCategoryRepository.findOne(reportCategoryId);
						branchOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
								branchCode, reportCategory.getName(), reportName);
						branchOutputZipFile = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
								branchCode, reportCategory.getName(), reportName + ".zip");

						List<String> filesListInDir = new ArrayList<String>();
						List<File> directoryList = new ArrayList<>();

						File branchDirectory = new File(branchOutputPath.toString());

						File directory = new File(branchOutputPath.toString());
						filesListInDir = populateFilesList(directory, filesListInDir);
						directoryList.add(directory);

						String zipFile = branchOutputZipFile.toString();

						byte[] buffer = new byte[1024];
						FileOutputStream fout = null;
						ZipOutputStream zout = null;

						try {

							fout = new FileOutputStream(zipFile);
							zout = new ZipOutputStream(fout);

							for (int j = 0; j < filesListInDir.size(); j++) {
								logger.debug("Zipping " + filesListInDir.get(j));
								zout.putNextEntry(new ZipEntry(
										filesListInDir.get(j).substring(branchDirectory.getAbsolutePath().length() - 4,
												filesListInDir.get(j).length())));

								FileInputStream fin = new FileInputStream(filesListInDir.get(j));
								int length;
								while ((length = fin.read(buffer)) > 0) {
									zout.write(buffer, 0, length);
								}
								zout.closeEntry();
								fin.close();
							}
							zout.close();
							fout.close();
							resource = new FileSystemResource(branchOutputZipFile.toFile());
						} catch (IOException e) {
							e.printStackTrace();
						} finally {
							IOUtils.closeQuietly(zout);
							IOUtils.closeQuietly(fout);
						}
					}
					// job having 'All' reports from given category
					else {
						branchOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
								branchCode);
						branchOutputZipFile = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, jobId.toString(),
								branchCode + ".zip");

						List<String> filesListInDir = new ArrayList<String>();
						List<File> directoryList = new ArrayList<>();

						File branchDirectory = new File(branchOutputPath.toString());

						File directory = new File(branchOutputPath.toString());
						filesListInDir = populateFilesList(directory, filesListInDir);
						directoryList.add(directory);

						String zipFile = branchOutputZipFile.toString();

						byte[] buffer = new byte[1024];
						FileOutputStream fout = null;
						ZipOutputStream zout = null;

						try {

							fout = new FileOutputStream(zipFile);
							zout = new ZipOutputStream(fout);

							for (int j = 0; j < filesListInDir.size(); j++) {
								logger.debug("Zipping " + filesListInDir.get(j));
								zout.putNextEntry(new ZipEntry(
										filesListInDir.get(j).substring(branchDirectory.getAbsolutePath().length() - 4,
												filesListInDir.get(j).length())));

								FileInputStream fin = new FileInputStream(filesListInDir.get(j));
								int length;
								while ((length = fin.read(buffer)) > 0) {
									zout.write(buffer, 0, length);
								}
								zout.closeEntry();
								fin.close();
							}
							zout.close();
							fout.close();
							resource = new FileSystemResource(branchOutputZipFile.toFile());
						} catch (IOException e) {
							e.printStackTrace();
						} finally {
							IOUtils.closeQuietly(zout);
							IOUtils.closeQuietly(fout);
						}
					}
				}
			}
			auditActionService.addSuccessEvent(AuditActionType.REPORT_DOWNLOAD, jobId.toString());
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.REPORT_DOWNLOAD, jobId.toString(), e);
			throw e;
		}

		logger.debug("REST finish request to download report");
		return ResponseEntity.ok().body(resource);
	}

	private List<String> populateFilesList(File dir, List<String> filesListInDir) throws IOException {
		File[] files = dir.listFiles();
		for (int i = 0; i < files.length; i++) {
			logger.debug("File path = " + files[i].getAbsolutePath());
			if (files[i].isFile() && !files[i].getName().contains(".zip")) {
				filesListInDir.add(files[i].getAbsolutePath());
			} else if (files[i].isDirectory()) {
				populateFilesList(files[i], filesListInDir);
			}
		}
		return filesListInDir;
	}

	private List<String> getBranchFolders(File root, String reportCategoryBranchFlag) {
		List<String> branchFolderList = new ArrayList<>();
		File[] list = root.listFiles();

		if (list == null)
			return null;

		for (File f : list) {
			if (f.isDirectory()) {
				if (isBranchFolder(f.getName())
						&& (null == reportCategoryBranchFlag || reportCategoryBranchFlag.equalsIgnoreCase("BRANCH"))) {
					branchFolderList.add(f.getName());
				}
			}
		}

		return branchFolderList;
	}

	public boolean isBranchFolder(String folderName) {
		if (folderName == null) {
			return false;
		}
		try {
			double d = Double.parseDouble(folderName);
		} catch (NumberFormatException nfe) {
			return false;
		}
		return true;
	}

	public static String getUserInsId() {
		return userInsId;
	}

	public void setUserInsId(String userInsId) {
		this.userInsId = userInsId;
	}
}
