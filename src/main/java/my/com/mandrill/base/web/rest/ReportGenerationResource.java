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
import my.com.mandrill.base.processor.IReportProcessor;
import my.com.mandrill.base.processor.ReportProcessorLocator;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.repository.InstitutionRepository;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import my.com.mandrill.base.security.SecurityUtils;
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
	private final Environment env;
	private Timer scheduleTimer = null;
	private Calendar nextTime = null;
	private boolean executed = false;

	public ReportGenerationResource(ReportDefinitionRepository reportDefinitionRepository,
			ReportCategoryRepository reportCategoryRepository, JobRepository jobRepository,
			JobHistoryRepository jobHistoryRepository, InstitutionRepository institutionRepository, 
			ReportProcessorLocator reportProcessLocator, Environment env) {
		this.reportDefinitionRepository = reportDefinitionRepository;
		this.reportCategoryRepository = reportCategoryRepository;
		this.jobRepository = jobRepository;
		this.jobHistoryRepository = jobHistoryRepository;
		this.institutionRepository = institutionRepository;
		this.reportProcessLocator = reportProcessLocator;
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

		for (ReportDefinition reportDefinitionList : reportDefinitionRepository.findAll(orderByIdAsc())) {
			if (reportDefinitionList.getFrequency().contains(ReportConstants.DAILY)) {
				reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
				reportGenerationMgr.setFileName(reportDefinitionList.getName());
				reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
				reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
				reportGenerationMgr.setFileBaseDirectory(directory);
				reportGenerationMgr.setFileLocation(
						directory + File.separator + ReportConstants.MAIN_PATH + File.separator + 
						reportDefinitionList.getReportCategory().getName() + File.separator);
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

		for (ReportDefinition reportDefinitionList : reportDefinitionRepository.findAll(orderByIdAsc())) {
			if (reportDefinitionList.getFrequency().contains(ReportConstants.MONTHLY)) {
				reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
				reportGenerationMgr.setFileName(reportDefinitionList.getName());
				reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
				reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
				reportGenerationMgr.setFileBaseDirectory(directory);
				reportGenerationMgr.setFileLocation(
						directory + File.separator + ReportConstants.MAIN_PATH + File.separator + 
						reportDefinitionList.getReportCategory().getName() + File.separator);
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

	//	@GetMapping("/reportGeneration/{institutionId}/{reportCategoryId}/{reportId}/{txnDate}")
	//	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	//	public ResponseEntity<ReportDefinition> generateReport(@PathVariable Long institutionId,
	//			@PathVariable Long reportCategoryId, @PathVariable Long reportId, @PathVariable String txnDate)
	//			throws ParseException {
	//		logger.debug(
	//				"User: {}, Rest to generate Report Institution ID: {}, Category ID: {}, Report ID: {}, Transaction Date: {}",
	//				SecurityUtils.getCurrentUserLogin().orElse(""), institutionId, reportCategoryId, reportId, txnDate);
	//
	//		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
	//		LocalDate firstDayOfMonth = YearMonth.from(getTxnStartDate(txnDate)).atDay(1);
	//		LocalDate lastDayOfMonth = YearMonth.from(getTxnStartDate(txnDate)).atEndOfMonth();
	//
	//		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
	//
	//		LocalDateTime txnStartDate = LocalDate.parse(txnDate, formatter).atStartOfDay();
	//		LocalDateTime txnEndDate = LocalDateTime.parse(txnDate, formatter);
	//
	//		String instShortCode = null;
	//
	//		List<Institution> institutions = institutionRepository.findAll();
	//		for (Institution institution : institutions) {
	//			if ("Institution".equals(institution.getType()) && institution.getId() == institutionId) {
	//				if (institution.getName().equals(ReportConstants.CBC_INSTITUTION)) {
	//					instShortCode = "CBC";
	//				} else if (institution.getName().equals(ReportConstants.CBS_INSTITUTION)) {
	//					instShortCode = "CBS";
	//				}
	//			}
	//		}
	//
	//		reportGenerationMgr.setInstitution(instShortCode);
	//		reportGenerationMgr.setGenerate(true);
	//		reportGenerationMgr.setFileDate(getTxnStartDate(txnDate));
	//		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
	//		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
	//
	//		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
	//				+ institutionId + File.separator + txnDate.substring(0, 7);
	//
	//		if (reportId == 0) {
	//			List<ReportDefinition> aList = reportDefinitionRepository.findAll(orderByIdAsc());
	//			for (ReportDefinition reportDefinition : aList) {
	//				populateReportDetails(reportGenerationMgr, reportDefinition, directory, txnStartDate, txnEndDate);
	//				runReport(reportGenerationMgr);
	//			}
	//			// FIXME: The return type is only ReportDefinition, but this is processing a
	//			// list
	//			return ResponseUtil
	//					.wrapOrNotFound(Optional.ofNullable((aList == null || aList.isEmpty()) ? null : aList.get(0)));
	//		} else {
	//			ReportDefinition reportDefinition = reportDefinitionRepository.findOne(reportId);
	//			populateReportDetails(reportGenerationMgr, reportDefinition, directory, txnStartDate, txnEndDate);
	//			runReport(reportGenerationMgr);
	//			return ResponseUtil.wrapOrNotFound(Optional.ofNullable(reportDefinition));
	//		}
	//	}

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
			populateReportDetails(reportGenerationMgr, reportDefinition, directory, txnStartDateTime,
					txnEndDateTime);
			runReport(reportGenerationMgr);

		}
		return ResponseUtil
				.wrapOrNotFound(Optional.ofNullable((aList == null || aList.isEmpty()) ? null : aList.get(0)));
	}

	private String findInstitutionCode(Long institutionId) {

		Institution inst = institutionRepository.findOne(institutionId);
		if (ReportConstants.CBS_INSTITUTION.equals(inst.getName())) {
			return "CBS";
		} else {
			return "CBC";
		}
	}

	private void populateReportDetails(ReportGenerationMgr rgm, ReportDefinition def, String reportPath,
			LocalDateTime txnStartDate, LocalDateTime txnEndDate) {
		rgm.setReportCategory(def.getReportCategory().getName());
		rgm.setFileName(def.getName());
		rgm.setFileNamePrefix(def.getFileNamePrefix());
		rgm.setFileFormat(def.getFileFormat());
		rgm.setProcessingClass(def.getProcessingClass());
		rgm.setHeaderFields(def.getHeaderFields());
		rgm.setBodyFields(def.getBodyFields());
		rgm.setTrailerFields(def.getTrailerFields());
		rgm.setBodyQuery(def.getBodyQuery());
		rgm.setTrailerQuery(def.getTrailerQuery());
		rgm.setFrequency(def.getFrequency());

		String dayPrefix = rgm.getFrequency().contains(ReportConstants.MONTHLY) ? "00"
				: StringUtils.leftPad(String.valueOf(txnStartDate.getDayOfMonth()), 2, "0");

		if (rgm.getFrequency().contains(ReportConstants.DAILY)) {
			rgm.setFileBaseDirectory(reportPath + File.separator + dayPrefix);
			rgm.setFileLocation(reportPath + File.separator + dayPrefix + File.separator
					+ ReportConstants.MAIN_PATH + File.separator + def.getReportCategory().getName() + File.separator);
			rgm.setTxnStartDate(txnStartDate);
			rgm.setTxnEndDate(txnEndDate.plusMinutes(1L));
		} else if (rgm.getFrequency().contains(ReportConstants.MONTHLY)) {
			rgm.setFileBaseDirectory(reportPath + File.separator + dayPrefix);
			rgm.setFileLocation(reportPath + File.separator + dayPrefix + File.separator
					+ ReportConstants.MAIN_PATH + File.separator + def.getReportCategory().getName() + File.separator);
			LocalDate firstDayOfMonth = txnStartDate.toLocalDate().withDayOfMonth(1);
			LocalDate lastDayOfMonth = txnStartDate.toLocalDate()
					.withDayOfMonth(txnStartDate.toLocalDate().lengthOfMonth());
			rgm.setTxnStartDate(firstDayOfMonth.atStartOfDay());
			rgm.setTxnEndDate(lastDayOfMonth.plusDays(1L).atStartOfDay());
		}
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
			result = retrieveAllReportbyDate(institutionId, reportDate);
		} else {
			result = retrieveReportbyReportCategory(institutionId, reportDate, reportCategoryId);
		}
		logger.debug("REST finish request to get generated report by institution and report category");
		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(result));
	}

	private GeneratedReportDTO retrieveReportbyReportCategory(Long institutionId, String reportDate,
			Long reportCategoryId) {
		logger.debug("User: {}, Rest retrieving generated reports by institution and report category",
				SecurityUtils.getCurrentUserLogin());

		ReportCategory reportCategory = reportCategoryRepository.findOne(reportCategoryId);

		GeneratedReportDTO result = new GeneratedReportDTO();
		result.setReportCategory(reportCategory);
		result.setReportDate(reportDate);

		String reportYear = reportDate.substring(0, 4);
		String reportMonth = reportDate.substring(5, 7);
		String reportDay = reportDate.substring(8, 10);
		File directory = new File(Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator + reportYear + '-' + reportMonth + File.separator + reportDay + File.separator
				+ ReportConstants.MAIN_PATH + File.separator + reportCategory.getName());
		logger.debug("Path =  " + directory.getAbsolutePath());

		if (!directory.exists()) {
			directory.mkdirs();
		}

		List<String> reportList = new ArrayList<>();
		File[] reports = directory.listFiles();

		for (int i = 0; i < reports.length; i++) {
			if (reports[i].isFile()) {
				reportList.add(reports[i].getName());
			}
		}
		result.setReportList(reportList);

		logger.debug("Rest finish retrieving generated reports by report category");
		return result;
	}

	private GeneratedReportDTO retrieveAllReportbyDate(Long institutionId, String reportDate) {
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
			@PathVariable Long reportCategoryId, @PathVariable String reportName) {
		logger.debug("User: {}, REST request to download report", SecurityUtils.getCurrentUserLogin());

		Resource resource = null;
		Path outputPath = null;
		Path outputZipFile = null;

		String reportYear = reportDate.substring(0, 4);
		String reportMonth = reportDate.substring(5, 7);
		String reportDay = reportDate.substring(8, 10);

		if (reportCategoryId.equals(new Long(0))) {
			outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
					reportYear + '-' + reportMonth, reportDay, ReportConstants.MAIN_PATH);
			outputZipFile = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
					reportYear + '-' + reportMonth, reportDay, reportDate, ReportConstants.MAIN_PATH + ".zip");

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

				for (int i = 0; i < filesListInDir.size(); i++) {
					logger.debug("Zipping " + filesListInDir.get(i));
					zout.putNextEntry(new ZipEntry(filesListInDir.get(i)
							.substring(directory.getAbsolutePath().length() + 1, filesListInDir.get(i).length())));
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
		} else {

			ReportCategory reportCategory = reportCategoryRepository.findOne(reportCategoryId);

			if (!reportName.equalsIgnoreCase("All")) {
				outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
						reportYear + '-' + reportMonth, reportDay, ReportConstants.MAIN_PATH, reportCategory.getName(), reportName);
				logger.debug(outputPath.toString());
				resource = new FileSystemResource(outputPath.toFile());
			} else {
				outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
						reportYear + '-' + reportMonth, reportDay, ReportConstants.MAIN_PATH, reportCategory.getName());
				outputZipFile = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
						reportYear + '-' + reportMonth, reportDay, ReportConstants.MAIN_PATH, reportCategory.getName() + reportDate + ".zip");

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

					for (int i = 0; i < filesListInDir.size(); i++) {
						logger.debug("Zipping " + filesListInDir.get(i));
						zout.putNextEntry(new ZipEntry(filesListInDir.get(i)
								.substring(directory.getAbsolutePath().length() + 1, filesListInDir.get(i).length())));
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
}
