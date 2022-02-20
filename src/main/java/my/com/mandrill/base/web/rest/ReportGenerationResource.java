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

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
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

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.config.audit.AuditActionService;
import my.com.mandrill.base.config.audit.AuditActionType;
import my.com.mandrill.base.domain.GeneratedReportDTO;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.JobHistoryDetails;
import my.com.mandrill.base.domain.ReportCategory;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.domain.User;
import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import my.com.mandrill.base.repository.UserExtraRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.service.JobHistoryService;
import my.com.mandrill.base.service.ReportService;
import my.com.mandrill.base.service.UserService;
import my.com.mandrill.base.service.util.FileUtils;
import my.com.mandrill.base.web.rest.util.HeaderUtil;

/**
 * REST controller for managing ReportGeneration.
 */
@RestController
@RequestMapping("/api")
public class ReportGenerationResource {

	private final Logger logger = LoggerFactory.getLogger(ReportGenerationResource.class);
	private final ReportCategoryRepository reportCategoryRepository;
	private final ReportDefinitionRepository reportDefinitionRepository;
	private final JobHistoryRepository jobHistoryRepository;
	private final UserService userService;
	private final UserExtraRepository userExtraRepository;
	private final AuditActionService auditActionService;
	private final JobHistoryService jobHistoryService;
	private final ReportService reportService;
	private final Environment env;
	private static String userInsId = "";

	private DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");

	public ReportGenerationResource(ReportCategoryRepository reportCategoryRepository,
			JobHistoryRepository jobHistoryRepository, Environment env, UserService userService,
			UserExtraRepository userExtraRepository, AuditActionService auditActionService,
			JobHistoryService jobHistoryService, ReportDefinitionRepository reportDefinitionRepository,
			ReportService reportService) {
		this.reportCategoryRepository = reportCategoryRepository;
		this.reportDefinitionRepository = reportDefinitionRepository;
		this.jobHistoryRepository = jobHistoryRepository;
		this.userService = userService;
		this.userExtraRepository = userExtraRepository;
		this.auditActionService = auditActionService;
		this.jobHistoryService = jobHistoryService;
		this.reportService = reportService;
		this.env = env;
	}

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

	@DeleteMapping("/delete-report/{jobId}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<Void> deleteReport(@PathVariable Long jobId, HttpServletRequest request) throws IOException {

		JobHistory jobHistory = jobHistoryRepository.findOne(jobId);
		try {
			File directoryToDelete = new File(jobHistory.getReportPath());
			FileSystemUtils.deleteRecursively(directoryToDelete);

			jobHistory.setStatus(ReportConstants.STATUS_DELETED);
			jobHistoryRepository.save(jobHistory);
			auditActionService.addSuccessEvent(AuditActionType.REPORT_DELETE, jobHistory.getId().toString(), request);
			return ResponseEntity.ok().headers(HeaderUtil.createAlert("baseApp.report.deleted", jobId.toString()))
					.build();
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.REPORT_DELETE, jobHistory.getId().toString(), e, request);
			throw e;
		}
	}

	public static void deleteDirectory(Path path) {
		try {
			Files.delete(path);
		} catch (IOException e) {

		}
	}

	@GetMapping("/download-report/{jobId}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<Resource> downloadReport(@PathVariable Long jobId, HttpServletRequest request) {
		String username = SecurityUtils.getCurrentUserLogin().get();

		String branchCode = getUserBranchCode();

		Resource resource = null;
		try {
			JobHistory jobHistory = jobHistoryRepository.getOne(jobId);
			if (jobHistory == null) {
				throw new IllegalArgumentException("No job history found.");
			}

			String reportPathStr = jobHistory.getReportPath();
			String outputFileName = generateReportFileName(jobId, jobHistory.getReportStartDate(),
					jobHistory.getReportEndDate(), branchCode);

			if (branchCode != null && !branchCode.trim().isEmpty()) {
				reportPathStr = Paths.get(reportPathStr, branchCode).toString();
			} 

			File reportPath = new File(reportPathStr);
			logger.debug("downloadReport: [username={}, branchCode={}, jobId={}, reportPath={}]", username, branchCode,
					jobId, reportPath.getAbsolutePath());
			if (!reportPath.exists()) {
				throw new IllegalArgumentException("No available report for download.");
			}

			String outputAbsolutePath = FileUtils.zipFiles(outputFileName, reportPath.toPath(), reportPath.toPath());
			resource = new FileSystemResource(new File(outputAbsolutePath));

			auditActionService.addSuccessEvent(AuditActionType.REPORT_DOWNLOAD, jobId.toString(), request);

			logger.debug("REST finish request to download report");
			return ResponseEntity.ok()
					.header(HttpHeaders.CONTENT_TYPE, Files.probeContentType(resource.getFile().toPath()))
					.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
					.body(resource);

		} catch (Exception e) {
			logger.error("Failed to download file for jobId:{}", jobId, e);
			auditActionService.addFailedEvent(AuditActionType.REPORT_DOWNLOAD, jobId.toString(), e, request);
			throw new RuntimeException(e);
		}
	}

	private String generateReportFileName(long jobId, LocalDateTime startDateTime, LocalDateTime endDateTime,
			String branchCode) {
		StringBuffer sb = new StringBuffer();
		sb.append("REPORT");
		sb.append("_").append(String.valueOf(jobId));

		if (startDateTime != null) {
			sb.append("_").append(startDateTime.format(formatter));
		}

		if (endDateTime != null) {
			sb.append("_").append(endDateTime.format(formatter));
		}

		if (branchCode == null || branchCode.trim().isEmpty()) {
			sb.append("_ALL");
		} else {
			sb.append("_").append(branchCode);
		}

		return sb.toString();
	}

	@GetMapping("/download-report/{institutionId}/{reportDate}/{reportCategoryId}/{reportName:.+}/{jobId}/{frequency}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<Resource> downloadReport(@PathVariable Long institutionId, @PathVariable String reportDate,
			@PathVariable Long reportCategoryId, @PathVariable String reportName, @PathVariable Long jobId,
			@PathVariable String frequency, HttpServletRequest request) throws IOException {
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
		logger.debug(
				"downloadReport: [branch={}, institutionId={}, reportDate={}, reportCategoryId={}, reportName={}, jobId={}, frequency={}]",
				branchCode, institutionId, reportDate, reportCategoryId, reportName, jobId, frequency);
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
			auditActionService.addFailedEvent(AuditActionType.REPORT_DOWNLOAD, jobId.toString(), e, request);
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
	
	@GetMapping("/export-report/{reportCategoryName}/{reportName}")
	@Timed
	public ResponseEntity<Resource> exportReport(@PathVariable String reportCategoryName, @PathVariable String reportName, 
			@RequestParam String startDate,@RequestParam String endDate) throws IOException {
		
		ReportCategory reportCategory = reportCategoryRepository.findOneByName(reportCategoryName);
		
		Resource resource = null;
		
		try {
			
			ReportDefinition reportDefinition = reportDefinitionRepository.findOneByCategoryIdAndName(reportCategory.getId(), reportName);
			
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

			LocalDateTime inputStartDate = (startDate!= null && !startDate.isEmpty()) ? LocalDateTime.parse(startDate, formatter) : null;
			LocalDateTime inputEndDate = (endDate!= null && !endDate.isEmpty()) ? LocalDateTime.parse(endDate, formatter) : null;
			
			ReportGenerationMgr mgr = reportService.generateSystemReport(reportDefinition.getId(), inputStartDate, inputEndDate);
			
			String outputFileName = generateSystemReportFileName(mgr.getFileNamePrefix(), inputStartDate, inputEndDate, ReportConstants.CSV_FORMAT);
			
			Path reportPath = Paths.get(mgr.getFileLocation(), outputFileName);
			
			resource = new FileSystemResource(new File(reportPath.toString()));
			
			logger.debug("REST finish request to export report");
			return ResponseEntity.ok()
					.header(HttpHeaders.CONTENT_TYPE, Files.probeContentType(resource.getFile().toPath()))
					.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
					.body(resource);
			
		}catch (Exception e) {
			logger.error("Failed to export file for reportName{}", reportName, e);
			throw new RuntimeException(e);
		}
		
	}
	
	private String generateSystemReportFileName(String fileNamePrefix, LocalDateTime startDateTime, LocalDateTime endDateTime, String reportExtension) {
		
		if (startDateTime == null && endDateTime == null) {
        	return fileNamePrefix + "_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_MMDDYYYY)) + reportExtension; 
        } else {
        	String startDateStr = startDateTime.format(DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_05)).replace("1200AM", "0000AM");
            String endDateStr = endDateTime.format(DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_05));
            
            return fileNamePrefix + " " + startDateStr + "-" + endDateStr + reportExtension;
        }

	}
}
