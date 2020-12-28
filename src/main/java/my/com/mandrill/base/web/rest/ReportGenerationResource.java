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
				reportGenerationMgr.setFileLocation(
						directory + reportDefinitionList.getReportCategory().getName() + File.separator);
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
				reportGenerationMgr.setFileLocation(
						directory + reportDefinitionList.getReportCategory().getName() + File.separator);
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

	@GetMapping("/reportGeneration/{institutionId}/{reportCategoryId}/{reportId}/{txnDate}")
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<ReportDefinition> generateReport(@PathVariable Long institutionId, @PathVariable Long reportCategoryId, @PathVariable Long reportId,
			@PathVariable String txnDate) throws ParseException {
		logger.debug(
				"User: {}, Rest to generate Report Institution ID: {}, Category ID: {}, Report ID: {}, Transaction Date: {}",
				SecurityUtils.getCurrentUserLogin().orElse(""),institutionId, reportCategoryId, reportId,
				txnDate);
		ReportDefinition reportDefinition = null;
		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		LocalDate firstDayOfMonth = YearMonth.from(getTxnStartDate(txnDate)).atDay(1);
		LocalDate lastDayOfMonth = YearMonth.from(getTxnStartDate(txnDate)).atEndOfMonth();

		String instShortCode = null;

		List<Institution> institutions = institutionRepository.findAll();
		for (Institution institution : institutions) {
			if ("Institution".equals(institution.getType()) && institution.getId() == institutionId) {
				if (institution.getName().equals(ReportConstants.CBC_INSTITUTION)) {
					instShortCode = "CBC";
				} else if (institution.getName().equals(ReportConstants.CBS_INSTITUTION)) {
					instShortCode = "CBS";
				}
			}
		}

		reportGenerationMgr.setInstitution(instShortCode);
		reportGenerationMgr.setGenerate(true);
		reportGenerationMgr.setFileDate(getTxnStartDate(txnDate));
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));

		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator + txnDate.substring(0, 7);

		if (reportId == 0) {
			List<ReportDefinition> aList = reportDefinitionRepository.findAll(orderByIdAsc());
			for (ReportDefinition reportDefinitionList : aList) {
				if (reportDefinitionList.getReportCategory().getId() == reportCategoryId) {
					reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
					reportGenerationMgr.setFileName(reportDefinitionList.getName());
					reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
					reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
					reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
					reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
					reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
					reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
					reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
					reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());

					if (reportDefinitionList.getFrequency().contains(ReportConstants.DAILY)) {
						reportGenerationMgr.setFileLocation(directory + File.separator + txnDate.substring(8, 10)
								+ File.separator + reportDefinitionList.getReportCategory().getName() + File.separator);
						reportGenerationMgr.setTxnStartDate(getTxnStartDate(txnDate));
						reportGenerationMgr.setTxnEndDate(getTxnEndDate(txnDate));
						runReport(reportGenerationMgr);
					}

					if (reportDefinitionList.getFrequency().contains(ReportConstants.MONTHLY)) {
						reportGenerationMgr.setFileLocation(directory + File.separator + "00" + File.separator
								+ reportDefinitionList.getReportCategory().getName() + File.separator);
						reportGenerationMgr.setTxnStartDate(firstDayOfMonth);
						reportGenerationMgr.setTxnEndDate(lastDayOfMonth);
						runReport(reportGenerationMgr);
					}
				}
			}
			//FIXME: The return type is only ReportDefinition, but this is processing a list
			return ResponseUtil.wrapOrNotFound(Optional.ofNullable((aList == null || aList.isEmpty()) ? null : aList.get(0)));
		} else {
			reportDefinition = reportDefinitionRepository.findOne(reportId);
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

			if (reportDefinition.getFrequency().contains(ReportConstants.DAILY)) {
				reportGenerationMgr.setFileLocation(directory + File.separator + txnDate.substring(8, 10)
						+ File.separator + reportDefinition.getReportCategory().getName() + File.separator);
				reportGenerationMgr.setTxnStartDate(getTxnStartDate(txnDate));
				reportGenerationMgr.setTxnEndDate(getTxnEndDate(txnDate));
				runReport(reportGenerationMgr);
			}

			if (reportDefinition.getFrequency().contains(ReportConstants.MONTHLY)) {
				reportGenerationMgr.setFileLocation(directory + File.separator + "00" + File.separator
						+ reportDefinition.getReportCategory().getName() + File.separator);
				reportGenerationMgr.setTxnStartDate(firstDayOfMonth);
				reportGenerationMgr.setTxnEndDate(lastDayOfMonth);
				runReport(reportGenerationMgr);
			}
			return ResponseUtil.wrapOrNotFound(Optional.ofNullable(reportDefinition));
		}

		
	}

	@GetMapping("/report-get-generated/{institutionId}/{reportDate}/{reportCategoryId}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<GeneratedReportDTO> getGeneratedReportList(@PathVariable Long institutionId, @PathVariable String reportDate, @PathVariable Long reportCategoryId) {
		logger.debug(
				"User: {}, REST request to get generated report by institution and report category",
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
				+ institutionId + File.separator + reportYear + '-' + reportMonth + File.separator + reportDay
				+ File.separator + reportCategory.getName());
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
				+ institutionId + File.separator + reportYear + '-' + reportMonth + File.separator + reportDay);

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
	public ResponseEntity<Resource> downloadReport(@PathVariable Long institutionId,
			@PathVariable String reportDate, @PathVariable Long reportCategoryId, @PathVariable String reportName) {
		logger.debug("User: {}, REST request to download report", SecurityUtils.getCurrentUserLogin());

		Resource resource = null;
		Path outputPath = null;
		Path outputZipFile = null;

		String reportYear = reportDate.substring(0, 4);
		String reportMonth = reportDate.substring(5, 7);
		String reportDay = reportDate.substring(8, 10);

		if (reportCategoryId.equals(new Long(0))) {
			outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
					reportYear + '-' + reportMonth, reportDay);
			outputZipFile = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
					reportYear + '-' + reportMonth, reportDay, reportDate + ".zip");

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
						reportYear + '-' + reportMonth, reportDay, reportCategory.getName(), reportName);
				logger.debug(outputPath.toString());
				resource = new FileSystemResource(outputPath.toFile());
			} else {
				outputPath = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
						reportYear + '-' + reportMonth, reportDay, reportCategory.getName());
				outputZipFile = Paths.get(env.getProperty("application.reportDir.path"), institutionId.toString(),
						reportYear + '-' + reportMonth, reportDay, reportCategory.getName() + reportDate + ".zip");

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
