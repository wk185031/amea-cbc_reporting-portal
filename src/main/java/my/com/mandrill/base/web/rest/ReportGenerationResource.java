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
import java.time.LocalTime;
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

import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.codahale.metrics.annotation.Timed;

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.domain.GeneratedReportDTO;
import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.ReportCategory;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.domain.User;
import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.processor.IReportProcessor;
import my.com.mandrill.base.processor.ReportProcessorLocator;
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
import my.com.mandrill.base.service.UserService;
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
	private final ReportProcessorLocator reportProcessLocator;
	private final UserService userService;
	private final UserExtraRepository userExtraRepository;
	private final EncryptionService encryptionService;
	private final Environment env;
	private Timer scheduleTimer = null;
	private Calendar nextTime = null;
	private boolean executed = false;
    private static String userInsId = "";

	public ReportGenerationResource(ReportDefinitionRepository reportDefinitionRepository,
			ReportCategoryRepository reportCategoryRepository, JobRepository jobRepository,
			JobHistoryRepository jobHistoryRepository, InstitutionRepository institutionRepository,
			ReportProcessorLocator reportProcessLocator, EncryptionService encryptionService, Environment env,
			UserService userService, UserExtraRepository userExtraRepository) {
		this.reportDefinitionRepository = reportDefinitionRepository;
		this.reportCategoryRepository = reportCategoryRepository;
		this.jobRepository = jobRepository;
		this.jobHistoryRepository = jobHistoryRepository;
		this.institutionRepository = institutionRepository;
		this.reportProcessLocator = reportProcessLocator;
		this.userService = userService;
		this.userExtraRepository = userExtraRepository;
		this.encryptionService = encryptionService;
		this.env = env;
	}

	// @Scheduled(cron = "0 13 6 * * *")
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
							Job job = jobRepository.findByName(ReportConstants.JOB_NAME);

							ZonedDateTime currentDate = ZonedDateTime.of(LocalDateTime.now(), ZoneId.systemDefault());
							LocalDate yesterdayDate = LocalDate.now().minusDays(1L);
							String todayDate = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01)
									.format(currentDate);
							LocalDate lastDayOfMonth = YearMonth
									.from(LocalDateTime.now().atZone(ZoneId.systemDefault())).atEndOfMonth();

							for (JobHistory jobHistoryList : jobHistoryRepository.findAll().stream()
									.filter(jobHistory -> jobHistory.getJob().getId() == job.getId())
									.collect(Collectors.toList())) {
								logger.debug("Job ID: {}, Job History Status: {}", jobHistoryList.getJob().getId(),
										jobHistoryList.getStatus());

								if (jobHistoryList.getStatus().equalsIgnoreCase(ReportConstants.STATUS_COMPLETED)
										&& DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01)
												.format(jobHistoryList.getCreatedDate()).equals(todayDate)) {
									logger.debug(
											"Job History Status: {}, Created Date: {}. Start generating reports. Transaction Date: {}, Report Run Date: {}",
											jobHistoryList.getStatus(), jobHistoryList.getCreatedDate(), yesterdayDate,
											currentDate);

									String instShortCode = null;

									List<Institution> institutions = institutionRepository.findAll();
									for (Institution institution : institutions) {
										if ("Institution".equals(institution.getType())) {
											if (institution.getName().equals(ReportConstants.CBC_INSTITUTION)) {
												instShortCode = "CBC";
											} else if (institution.getName().equals(ReportConstants.CBS_INSTITUTION)) {
												instShortCode = "CBS";
											}
										}

										generateDailyReport(institution.getId(), instShortCode);
										if (yesterdayDate.equals(lastDayOfMonth)) {
											generateMonthlyReport(institution.getId(), instShortCode);
										}

									}
									executed = true;
									jobHistoryList.setStatus(ReportConstants.REPORTS_GENERATED);
									jobHistoryRepository.save(jobHistoryList);
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

	private void generateDailyReport(Long institutionId, String instShortCode) {
		logger.info("generateDailyReport: institutionId={}, intShortCode={}", institutionId, instShortCode);
		LocalDate yesterdayDate = LocalDate.now().minusDays(1L);

		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator
				+ DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(yesterdayDate) + File.separator
				+ DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_07).format(yesterdayDate) + File.separator;

		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		reportGenerationMgr.setYesterdayDate(yesterdayDate);
		reportGenerationMgr.setTodayDate(yesterdayDate);
		reportGenerationMgr.setInstitution(instShortCode);
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
		reportGenerationMgr.setEncryptionService(encryptionService);

		for (ReportDefinition reportDefinitionList : reportDefinitionRepository.findAll(orderByIdAsc())) {
			if (reportDefinitionList.getFrequency().contains(ReportConstants.DAILY)) {
				reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
				reportGenerationMgr.setFileName(reportDefinitionList.getName());
				reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
				reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
				reportGenerationMgr.setFileBaseDirectory(directory);
				reportGenerationMgr.setFileLocation(directory + File.separator + ReportConstants.MAIN_PATH
						+ File.separator + reportDefinitionList.getReportCategory().getName() + File.separator);
				reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
				reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
				reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
				reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
				reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
				reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
				reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());

				runReport(reportGenerationMgr);

			}
		}
	}

	private void generateMonthlyReport(Long institutionId, String instShortCode) {
		logger.info("In ReportGenerationResource.generateMonthlyReport()");
		LocalDate firstDayOfMonth = YearMonth.from(LocalDateTime.now().atZone(ZoneId.systemDefault())).atDay(1);
		LocalDate lastDayOfMonth = YearMonth.from(LocalDateTime.now().atZone(ZoneId.systemDefault())).atEndOfMonth();

		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator
				+ DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(lastDayOfMonth) + File.separator
				+ "00" + File.separator;

		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		reportGenerationMgr.setYesterdayDate(firstDayOfMonth);
		reportGenerationMgr.setTodayDate(lastDayOfMonth);
		reportGenerationMgr.setInstitution(instShortCode);
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
		reportGenerationMgr.setEncryptionService(encryptionService);

		for (ReportDefinition reportDefinitionList : reportDefinitionRepository.findAll(orderByIdAsc())) {
			if (reportDefinitionList.getFrequency().contains(ReportConstants.MONTHLY)) {
				reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
				reportGenerationMgr.setFileName(reportDefinitionList.getName());
				reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
				reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
				reportGenerationMgr.setFileBaseDirectory(directory);
				reportGenerationMgr.setFileLocation(directory + File.separator + ReportConstants.MAIN_PATH
						+ File.separator + reportDefinitionList.getReportCategory().getName() + File.separator);
				reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
				reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
				reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
				reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
				reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
				reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
				reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());

				runReport(reportGenerationMgr);

			}
		}
	}

	// @GetMapping("/reportGeneration/{institutionId}/{reportCategoryId}/{reportId}/{txnDate}")
	// @PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON +
	// RESOURCE_GENERATE_REPORT + "')")
	// public ResponseEntity<ReportDefinition> generateReport(@PathVariable Long
	// institutionId,
	// @PathVariable Long reportCategoryId, @PathVariable Long reportId,
	// @PathVariable String txnDate)
	// throws ParseException {
	// logger.debug(
	// "User: {}, Rest to generate Report Institution ID: {}, Category ID: {},
	// Report ID: {}, Transaction Date: {}",
	// SecurityUtils.getCurrentUserLogin().orElse(""), institutionId,
	// reportCategoryId, reportId, txnDate);
	//
	// ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
	// LocalDate firstDayOfMonth =
	// YearMonth.from(getTxnStartDate(txnDate)).atDay(1);
	// LocalDate lastDayOfMonth =
	// YearMonth.from(getTxnStartDate(txnDate)).atEndOfMonth();
	//
	// DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
	//
	// LocalDateTime txnStartDate = LocalDate.parse(txnDate,
	// formatter).atStartOfDay();
	// LocalDateTime txnEndDate = LocalDateTime.parse(txnDate, formatter);
	//
	// String instShortCode = null;
	//
	// List<Institution> institutions = institutionRepository.findAll();
	// for (Institution institution : institutions) {
	// if ("Institution".equals(institution.getType()) && institution.getId() ==
	// institutionId) {
	// if (institution.getName().equals(ReportConstants.CBC_INSTITUTION)) {
	// instShortCode = "CBC";
	// } else if (institution.getName().equals(ReportConstants.CBS_INSTITUTION)) {
	// instShortCode = "CBS";
	// }
	// }
	// }
	//
	// reportGenerationMgr.setInstitution(instShortCode);
	// reportGenerationMgr.setGenerate(true);
	// reportGenerationMgr.setFileDate(getTxnStartDate(txnDate));
	// reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
	// reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
	//
	// String directory =
	// Paths.get(env.getProperty("application.reportDir.path")).toString() +
	// File.separator
	// + institutionId + File.separator + txnDate.substring(0, 7);
	//
	// if (reportId == 0) {
	// List<ReportDefinition> aList =
	// reportDefinitionRepository.findAll(orderByIdAsc());
	// for (ReportDefinition reportDefinition : aList) {
	// populateReportDetails(reportGenerationMgr, reportDefinition, directory,
	// txnStartDate, txnEndDate);
	// runReport(reportGenerationMgr);
	// }
	// // FIXME: The return type is only ReportDefinition, but this is processing a
	// // list
	// return ResponseUtil
	// .wrapOrNotFound(Optional.ofNullable((aList == null || aList.isEmpty()) ? null
	// : aList.get(0)));
	// } else {
	// ReportDefinition reportDefinition =
	// reportDefinitionRepository.findOne(reportId);
	// populateReportDetails(reportGenerationMgr, reportDefinition, directory,
	// txnStartDate, txnEndDate);
	// runReport(reportGenerationMgr);
	// return ResponseUtil.wrapOrNotFound(Optional.ofNullable(reportDefinition));
	// }
	// }

	@GetMapping("/reportGeneration/{institutionId}/{reportCategoryId}/{reportId}")
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<ReportDefinition> generateReport(@PathVariable Long institutionId,
			@PathVariable Long reportCategoryId, @PathVariable Long reportId, @RequestParam String startDateTime,
			@RequestParam String endDateTime) throws ParseException {
		logger.debug(
				"User: {}, Rest to generate Report Institution ID: {}, Category ID: {}, Report ID: {}, StartDateTime: {}, EndDateTime: {}",
				SecurityUtils.getCurrentUserLogin().orElse(""), institutionId, reportCategoryId, reportId,
				startDateTime, endDateTime);

		// ReportDefinition reportDefinition = null;
		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();

		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

		LocalDateTime txnStartDateTime = LocalDateTime.parse(startDateTime, formatter);
		LocalDateTime txnEndDateTime = LocalDateTime.parse(endDateTime, formatter);

		String instShortCode = findInstitutionCode(institutionId);

		reportGenerationMgr.setInstitution(instShortCode);
		reportGenerationMgr.setGenerate(true);
		reportGenerationMgr.setFileDate(txnStartDateTime.toLocalDate());
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
		reportGenerationMgr.setEncryptionService(encryptionService);

		String yearMonth = txnStartDateTime.toLocalDate().format(DateTimeFormatter.ofPattern("yyyy-MM"));
		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator + yearMonth;

		List<ReportDefinition> aList = new ArrayList<>();

		if (reportCategoryId == 0) {
			aList = reportDefinitionRepository.findAll();
		} else if (reportId == 0) {
			aList = reportDefinitionRepository.findAllByCategoryId(reportCategoryId);
		} else {
			ReportDefinition reportDefinition = reportDefinitionRepository.findOne(reportId);
			if (reportDefinition != null) {
				aList.add(reportDefinition);
			}
		}
		logger.debug("Process {} reports", aList.size());
		for (ReportDefinition reportDefinition : aList) {

			reportGenerationMgr.setReportCategory(reportDefinition.getReportCategory().getName());
			reportGenerationMgr.setFileName(reportDefinition.getName());
			reportGenerationMgr.setFileNamePrefix(reportDefinition.getFileNamePrefix());
			reportGenerationMgr.setFileFormat(reportDefinition.getFileFormat());
			reportGenerationMgr.setProcessingClass(reportDefinition.getProcessingClass());
			reportGenerationMgr.setHeaderFields(reportDefinition.getHeaderFields());
			reportGenerationMgr.setBodyFields(reportDefinition.getBodyFields());
			reportGenerationMgr.setTrailerFields(reportDefinition.getTrailerFields());
			reportGenerationMgr.setBodyQuery(reportDefinition.getBodyQuery());
			reportGenerationMgr.setTrailerQuery(reportDefinition.getTrailerQuery());
			reportGenerationMgr.setFrequency(reportDefinition.getFrequency());

			String dayPrefix = null; 

			if (reportGenerationMgr.getFrequency().contains(ReportConstants.DAILY)) {
				dayPrefix = StringUtils.leftPad(String.valueOf(txnStartDateTime.getDayOfMonth()), 2, "0");
				reportGenerationMgr.setFileBaseDirectory(directory + File.separator + dayPrefix);
				reportGenerationMgr.setFileLocation(directory + File.separator + dayPrefix + File.separator + ReportConstants.MAIN_PATH
						+ File.separator + reportDefinition.getReportCategory().getName() + File.separator);
				reportGenerationMgr.setTxnStartDate(txnStartDateTime);
				reportGenerationMgr.setTxnEndDate(txnEndDateTime.plusMinutes(1L));
				reportGenerationMgr.setReportTxnEndDate(txnEndDateTime);
				runReport(reportGenerationMgr);
			} 

			if (reportGenerationMgr.getFrequency().contains(ReportConstants.MONTHLY)) {
				dayPrefix = "00";
				reportGenerationMgr.setFileBaseDirectory(directory + File.separator + dayPrefix);
				reportGenerationMgr.setFileLocation(directory + File.separator + dayPrefix + File.separator + ReportConstants.MAIN_PATH
						+ File.separator + reportDefinition.getReportCategory().getName() + File.separator);
				LocalDate firstDayOfMonth = txnStartDateTime.toLocalDate().withDayOfMonth(1);
				LocalDate lastDayOfMonth = txnStartDateTime.toLocalDate()
						.withDayOfMonth(txnStartDateTime.toLocalDate().lengthOfMonth());
				reportGenerationMgr.setTxnStartDate(firstDayOfMonth.atStartOfDay());
				reportGenerationMgr.setTxnEndDate(lastDayOfMonth.plusDays(1L).atStartOfDay());
				reportGenerationMgr.setReportTxnEndDate(YearMonth.from(txnEndDateTime).atEndOfMonth().atTime(LocalTime.MAX));
				runReport(reportGenerationMgr);
			}
		}
		return ResponseUtil
				.wrapOrNotFound(Optional.ofNullable((aList == null || aList.isEmpty()) ? null : aList.get(0)));
	}

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

	@GetMapping("/download-report/{institutionId}/{reportDate}/{reportCategoryId}/{reportName:.+}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<Resource> downloadReport(@PathVariable Long institutionId, @PathVariable String reportDate,
			@PathVariable Long reportCategoryId, @PathVariable String reportName) throws IOException {
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

		String branchCode = getUserBranchCode();

		// master user
		if (branchCode == null) {
			// user find 'ALL' instead of specific category
			if (reportCategoryId.equals(new Long(0))) {
				mainOutputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
						reportYear + '-' + reportMonth, reportDay, ReportConstants.MAIN_PATH);
				mainOutputZipFile = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
						reportYear + '-' + reportMonth, reportDay, ReportConstants.MAIN_PATH + ".zip");

				outputPathList.add(mainOutputPath);
				outputZipFileList.add(mainOutputZipFile);

				List<String> branchFolders = getBranchFolders(
						new File(Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
								+ institutionId + File.separator + reportYear + '-' + reportMonth + File.separator
								+ reportDay + File.separator),
						null);

				for (String branchFolder : branchFolders) {
					branchOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
							institutionId.toString(), reportYear + '-' + reportMonth, reportDay, branchFolder);

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
						zout.putNextEntry(new ZipEntry(combineFileListInDir.get(j).substring(
								mainDirectory.getAbsolutePath().length() - 4, combineFileListInDir.get(j).length())));

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
				// user find specific category to download
			} else {
				// user click download only specific report from given list
				ReportCategory reportCategory = reportCategoryRepository.findOne(reportCategoryId);
				Path outputPath = null;

				if (!reportName.equalsIgnoreCase("All")) {
//					String[] reportNameArray = reportName.split("_");
//					if(reportNameArray.length > 2) {
//						outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
//								reportYear + '-' + reportMonth, reportDay, reportNameArray[1], reportCategory.getName(), reportName);
//					} else {
					outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
							reportYear + '-' + reportMonth, reportDay, ReportConstants.MAIN_PATH,
							reportCategory.getName(), reportName);
//					}

					logger.debug(outputPath.toString());
					resource = new FileSystemResource(outputPath.toFile());
				}
				// user click download 'All' from given list
				else {
					rootOutputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
							reportYear + '-' + reportMonth, reportDay);
					mainOutputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
							reportYear + '-' + reportMonth, reportDay, ReportConstants.MAIN_PATH,
							reportCategory.getName());
					mainOutputZipFile = Paths.get(env.getProperty("application.reportDir.path"),
							institutionId.toString(), reportYear + '-' + reportMonth, reportDay,
							ReportConstants.MAIN_PATH, reportCategory.getName() + reportDate + ".zip");

					outputPathList.add(mainOutputPath);

					List<String> branchFolders = getBranchFolders(
							new File(Paths.get(env.getProperty("application.reportDir.path")).toString()
									+ File.separator + institutionId + File.separator + reportYear + '-' + reportMonth
									+ File.separator + reportDay + File.separator),
							reportCategory.getBranchFlag());

					for (String branchFolder : branchFolders) {
						branchOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
								institutionId.toString(), reportYear + '-' + reportMonth, reportDay, branchFolder);

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
			// user find 'ALL' instead of specific category
			if (reportCategoryId.equals(new Long(0))) {

				branchOutputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
						reportYear + '-' + reportMonth, reportDay, branchCode);
				branchOutputZipFile = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
						reportYear + '-' + reportMonth, reportDay, branchCode + ".zip");

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
				// user find specific category to download
			} else {
				// user click download only specific report from given list
				if (!reportName.equalsIgnoreCase("All")) {
					ReportCategory reportCategory = reportCategoryRepository.findOne(reportCategoryId);
					Path outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
							reportYear + '-' + reportMonth, reportDay, branchCode, reportCategory.getName(),
							reportName);

					logger.debug(outputPath.toString());
					resource = new FileSystemResource(outputPath.toFile());
				}
				// user click download 'All' from given list
				else {
					branchOutputPath = Paths.get(env.getProperty("application.reportDir.path"),
							institutionId.toString(), reportYear + '-' + reportMonth, reportDay, branchCode);
					branchOutputZipFile = Paths.get(env.getProperty("application.reportDir.path"),
							institutionId.toString(), reportYear + '-' + reportMonth, reportDay, branchCode + ".zip");

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
				}
			}
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

	private Sort orderByIdAsc() {
		return new Sort(Sort.Direction.ASC, "id");
	}

	private void runReport(ReportGenerationMgr reportGenerationMgr) {
		IReportProcessor reportProcessor = reportProcessLocator.locate(reportGenerationMgr.getProcessingClass());

		if (reportProcessor != null) {
			logger.debug("runReport with processor: {}", reportProcessor);
			reportProcessor.process(reportGenerationMgr);
		} else {
			reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
					env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
		}
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
