package my.com.mandrill.base.service;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

import javax.annotation.PostConstruct;
import javax.persistence.EntityManager;
import javax.persistence.Query;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.JobHistoryDetails;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.ReportGenerationResult;
import my.com.mandrill.base.repository.InstitutionRepository;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.service.util.BusinessDay;
import net.logstash.logback.encoder.org.apache.commons.lang.StringUtils;

@Service
public class ReportService {

	private final Logger log = LoggerFactory.getLogger(ReportService.class);

	@Autowired
	private Environment env;

	@Autowired
	private ReportDefinitionRepository reportDefinitionRepository;

	@Autowired
	private JobHistoryRepository jobHistoryRepository;

	@Autowired
	private InstitutionRepository institutionRepository;

	@Autowired
	private EncryptionService encryptionService;

	@Autowired
	private ReportAsyncService reportAsyncService;

	@Autowired
	private EntityManager em;

	@Autowired
	private PlatformTransactionManager transactionManager;

	private TransactionTemplate transactionTemplate;

	@PostConstruct
	private void init() {
		transactionTemplate = new TransactionTemplate(transactionManager);
	}

	public Path generateSystemReport(long reportId, LocalDateTime txnStartDate, LocalDateTime txnEndDate) {

		if (txnStartDate == null) {
			txnStartDate = LocalDateTime.now();
		}

		if (txnEndDate == null) {
			txnEndDate = LocalDateTime.now();
		}

		String baseDirectory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ "0";

		ReportDefinition def = reportDefinitionRepository.findOne(reportId);
		ReportGenerationMgr mgr = ReportGenerationMgr.create(0, ReportConstants.INSTITUTION_CBC, true, txnStartDate,
				env, encryptionService, def);
		mgr.setFileBaseDirectory(baseDirectory);
		mgr.setFileLocation(baseDirectory);
		mgr.setReportTxnEndDate(txnEndDate.plusMinutes(1L));
		mgr.setFileNamePrefix(def.getFileNamePrefix());
		mgr.setTxnStartDate(txnStartDate);
		mgr.setTxnEndDate(txnEndDate != null ? txnEndDate.plusMinutes(1L) : txnEndDate);
		mgr.setSystemReport(true);

		try {
			reportAsyncService.runReport(mgr).get();
		} catch (ExecutionException | InterruptedException e) {
			throw new RuntimeException(e);
		}

		return Paths.get(mgr.getFileLocation(), mgr.getFileName());
	}

	public void generateReport(long jobHistoryId, boolean manualGenerate, JobHistoryDetails jobHistoryDetails,
			String user) {

		// Get list of reports to generate
		String institutionCode = findInstitutionCode(jobHistoryDetails.getInstitutionId());
		Optional<List<LocalDate>> holidays = getHolidayList();
		List<ReportDefinition> aList = getReportsByCategoryIdOrReportId(jobHistoryDetails.getReportCategoryId(),
				jobHistoryDetails.getReportId(), jobHistoryDetails.getInstitutionId(),
				jobHistoryDetails.getFrequency());
		List<CompletableFuture<ReportGenerationResult>> futures = new ArrayList<>();
		String yearMonth = jobHistoryDetails.getTransactionStartDate().toLocalDate()
				.format(DateTimeFormatter.ofPattern("yyyy-MM"));
		String baseDirectory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ jobHistoryDetails.getInstitutionId() + File.separator + yearMonth;

		Map<String, String> reportCategory = new HashMap<String, String>();

		for (ReportDefinition def : aList) {
			if (def.isSystem()) {
				log.debug("skip system report: {}", def.getName());
			}

			if (skipReportGeneration(manualGenerate, def.isByBusinessDate(),
					jobHistoryDetails.getTransactionStartDate().toLocalDate(), holidays)) {
				log.debug("Skip report generation [reportId={}, reportName={}]", def.getId(), def.getName());
				continue;
			} else {
				ReportGenerationMgr mgr = ReportGenerationMgr.create(jobHistoryId, institutionCode, manualGenerate,
						jobHistoryDetails.getTransactionStartDate(), env, encryptionService, def);
				handleExceptionFilePrefix(mgr, def.getFileNamePrefix(), jobHistoryDetails.getTransactionStartDate(),
						jobHistoryDetails.getTransactionEndDate());
				setTransactionDateRange(mgr, ReportConstants.MONTHLY.equals(jobHistoryDetails.getFrequency()),
						jobHistoryDetails.getTransactionStartDate(), jobHistoryDetails.getTransactionEndDate(),
						baseDirectory, def.getReportCategory().getName(), def.isByBusinessDate(), manualGenerate,
						holidays, jobHistoryId);
				reportCategory.put(def.getName(), def.getReportCategory().getName());
				futures.add(reportAsyncService.runReport(mgr));
			}
		}

		int successCount = 0;
		int failedCount = 0;

		CompletableFuture.allOf(futures.toArray(new CompletableFuture[futures.size()])).join();

		for (CompletableFuture<ReportGenerationResult> f : futures) {
			try {
				ReportGenerationResult r = f.get();

				if (r.isSuccess()) {
					successCount++;
					jobHistoryDetails.getReportStatusMap().put(r.getReportName(),
							reportCategory.get(r.getReportName()) + "|" + ReportConstants.STATUS_COMPLETED);
				} else {
					failedCount++;
					jobHistoryDetails.getReportStatusMap().put(r.getReportName(),
							reportCategory.get(r.getReportName()) + "|" + ReportConstants.STATUS_FAILED);
				}
			} catch (Exception e) {
				log.error("Failed to complete report.", e);
			}
		}

		postUpdateReportGeneration(jobHistoryId, jobHistoryDetails, baseDirectory, successCount, failedCount);
	}

	public void postUpdateReportGeneration(long jobHistoryId, JobHistoryDetails jobHistoryDetails, String baseDirectory,
			int successCount, int failedCount) {

		JobHistory result = transactionTemplate.execute(status -> {
			JobHistory jobHistory = jobHistoryRepository.getOne(jobHistoryId);
			try {
				jobHistory.setDetails(new ObjectMapper().writeValueAsString(jobHistoryDetails));
			} catch (Exception e) {
				log.warn("Failed to write jobHistory details: ", jobHistoryDetails.toString(), e);
				jobHistory.setDetails("UNKNOWN");
			}

			if (successCount > 0 && failedCount == 0) {
				jobHistory.setStatus(ReportConstants.STATUS_COMPLETED);
			} else if (successCount > 0 && failedCount > 0) {
				jobHistory.setStatus(ReportConstants.STATUS_PARTIAL_FAILED);
			} else {
				jobHistory.setStatus(ReportConstants.STATUS_FAILED);
			}

			jobHistory.setLastModifiedDate(Instant.now());
			jobHistory.setLastModifiedBy(
					SecurityUtils.getCurrentUserLogin().isPresent() ? SecurityUtils.getCurrentUserLogin().get()
							: "system");
			jobHistory.setGenerationEndDate(LocalDateTime.now());
			String reportPath = baseDirectory + File.separator
					+ (StringUtils
							.leftPad(
									ReportConstants.MONTHLY.equals(jobHistory.getFrequency()) ? "00"
											: String.valueOf(
													jobHistoryDetails.getTransactionStartDate().getDayOfMonth()),
									2, "0"))
					+ File.separator + jobHistoryId;
			jobHistory.setReportPath(reportPath);
			jobHistory = jobHistoryRepository.save(jobHistory);
			status.flush();

			return jobHistory;
		});
		log.debug("postUpdateReportGeneration [jobHistoryId={}, successCount={}, failedCount={}, status={}]",
				jobHistoryId, successCount, failedCount, result.getStatus());

	}

	public boolean isDbSyncRunning() {
		JobHistory dbsyncJob = jobHistoryRepository.findFirstByStatusAndJobNameOrderByCreatedDateDesc(
				ReportConstants.STATUS_IN_PROGRESS, ReportConstants.JOB_NAME_DB_SYNC);
		if (dbsyncJob != null) {
			return true;
		}
		return false;
	}

	private String findInstitutionCode(Long institutionId) {

		Institution inst = institutionRepository.findOne(institutionId);
		if (ReportConstants.CBS_INSTITUTION.equals(inst.getName())) {
			return "CBS";
		} else {
			return "CBC";
		}
	}

	private boolean skipReportGeneration(boolean isManualGenerate, boolean isFinancialReport, LocalDate reportStartDate,
			Optional<List<LocalDate>> holidays) {
		boolean isWorkingDay = BusinessDay.isWorkingDay(reportStartDate, holidays);
		boolean toSkip = !isManualGenerate && isFinancialReport && !isWorkingDay;

		log.debug(
				"skipReportGeneration [reportStartDate={}, isManualGenerate={}, isFinancialReport={}, isWorkingDay={}] => {}",
				reportStartDate, isManualGenerate, isFinancialReport, isWorkingDay, toSkip);

		return toSkip;
	}

	private List<ReportDefinition> getReportsByCategoryIdOrReportId(Long reportCategoryId, Long reportId,
			Long institutionId, String frequency) {
		if (reportCategoryId == null || reportCategoryId <= 0) {
			if (frequency != null) {
				return reportDefinitionRepository.findByInstitutionIdAndFrequencyContainsOrderByName(institutionId,
						frequency);
			} else {
				return reportDefinitionRepository.findByInstitutionIdOrderByName(institutionId);
			}

		} else if (reportId == null || reportId <= 0) {
			if (frequency != null) {
				return reportDefinitionRepository.findByCategoryIdAndInstitutionIdAndFrequencyContainsOrderByName(
						reportCategoryId, institutionId, frequency);
			} else {
				return reportDefinitionRepository.findByCategoryIdAndInstitutionIdOrderByName(reportCategoryId,
						institutionId);
			}
		} else {
			List<ReportDefinition> aList = new ArrayList<>();
			ReportDefinition def = reportDefinitionRepository.findOne(reportId);

			if (frequency == null || frequency.trim().isEmpty()) {
				aList.add(reportDefinitionRepository.findOne(reportId));
				return aList;
			} else if (def.getFrequency().contains(frequency)) {
				aList.add(reportDefinitionRepository.findOne(reportId));
				return aList;
			} else {
				return aList;
			}
		}
	}

	public boolean isGenerateMonthlyReport(boolean isDailyFreq, boolean isMonthlyOnlyFreq, boolean manualMonthly,
			LocalDateTime inputStartDateTime) {
		return (!isDailyFreq && isMonthlyOnlyFreq && manualMonthly) || (!manualMonthly
				&& YearMonth.from(inputStartDateTime).atEndOfMonth().isEqual(inputStartDateTime.toLocalDate()));
	}

	private Optional<List<LocalDate>> getHolidayList() {
		List<LocalDate> holidayList = new ArrayList<LocalDate>();

		StringBuilder sb = new StringBuilder();
		sb.append("select CEX_DATE from ").append(env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC))
				.append(".CALENDAR_EXCEPTION@").append(env.getProperty(ReportConstants.DB_LINK_AUTHENTIC))
				.append(" where cex_cgp_id in (select CGP_ID from ")
				.append(env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC)).append(".CALENDAR_GROUP@")
				.append(env.getProperty(ReportConstants.DB_LINK_AUTHENTIC)).append(" where CGP_NAME = ?)");

		Query q = em.createNativeQuery(sb.toString());
		q.setParameter(1, "Report Calendar");
		for (Object d : q.getResultList()) {
			holidayList.add(((java.sql.Timestamp) d).toLocalDateTime().toLocalDate());
		}
		log.debug("holiday list size = {}", holidayList == null ? 0 : holidayList.size());
		return Optional.of(holidayList);
	}

	private void setTransactionDateRange(ReportGenerationMgr reportGenerationMgr, boolean isMonthly,
			LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime, String directory, String reportCategory,
			boolean byBusinessDate, boolean manualGenerate, Optional<List<LocalDate>> holidays, long jobId) {
		if (isMonthly) {
			String dayPrefix = "00";
			reportGenerationMgr.setFileBaseDirectory(directory + File.separator + dayPrefix + File.separator + jobId);
			reportGenerationMgr.setFileLocation(directory + File.separator + dayPrefix + File.separator + jobId
					+ File.separator + ReportConstants.MAIN_PATH + File.separator + reportCategory + File.separator);
			LocalDate firstDayOfMonth = inputStartDateTime.toLocalDate().withDayOfMonth(1);
			LocalDate lastDayOfMonth = inputStartDateTime.toLocalDate()
					.withDayOfMonth(inputStartDateTime.toLocalDate().lengthOfMonth());
			reportGenerationMgr.setTxnStartDate(firstDayOfMonth.atStartOfDay());
			reportGenerationMgr.setTxnEndDate(lastDayOfMonth.plusDays(1L).atStartOfDay());
			reportGenerationMgr
					.setReportTxnEndDate(YearMonth.from(inputEndDateTime).atEndOfMonth().atTime(LocalTime.MAX));
		} else {
			String dayPrefix = StringUtils.leftPad(String.valueOf(inputStartDateTime.getDayOfMonth()), 2, "0");
			reportGenerationMgr.setFileBaseDirectory(directory + File.separator + dayPrefix + File.separator + jobId);
			reportGenerationMgr.setFileLocation(directory + File.separator + dayPrefix + File.separator + jobId
					+ File.separator + ReportConstants.MAIN_PATH + File.separator + reportCategory + File.separator);
			calculateTxnDateTime(reportGenerationMgr, inputStartDateTime, inputEndDateTime, byBusinessDate,
					manualGenerate, holidays);
			reportGenerationMgr.setReportTxnEndDate(inputEndDateTime);
		}
		log.debug("setTransactionDateRange: txnStartDateTime={}, txnEndDateTime={}, postingDate={}",
				reportGenerationMgr.getTxnStartDate(), reportGenerationMgr.getTxnEndDate(),
				reportGenerationMgr.getPostingDate());
	}

	private void calculateTxnDateTime(ReportGenerationMgr reportGenerationMgr, LocalDateTime inputStartDateTime,
			LocalDateTime inputEndDateTime, boolean byBusinessDate, boolean manualGenerate,
			Optional<List<LocalDate>> holidays) {
		if (byBusinessDate) {
			if (manualGenerate) {
				LocalDate endDate = inputEndDateTime.toLocalDate();
				LocalDate postingDate = BusinessDay.rollForward(endDate, holidays);
				reportGenerationMgr.setTxnStartDate(inputStartDateTime);
				reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
				reportGenerationMgr.setPostingDate(postingDate);
			} else {
				LocalDate startDate = inputStartDateTime.toLocalDate();
				LocalDate rollbackStartDate = BusinessDay.rollBackward(startDate, holidays);
				reportGenerationMgr.setTxnStartDate(rollbackStartDate.atStartOfDay());
				reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
				reportGenerationMgr.setPostingDate(inputEndDateTime.toLocalDate());
			}
		} else {
			reportGenerationMgr.setTxnStartDate(inputStartDateTime);
			// Plus 1 minute to make it from 11:59 to 00:00 as criteria in report use less
			// than '<' in date range
			reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
		}
	}

	private void handleExceptionFilePrefix(ReportGenerationMgr reportGenerationMgr, String filePrefix,
			LocalDateTime startDateTime, LocalDateTime endDateTime) {
		long noOfDaysBetween = ChronoUnit.DAYS.between(startDateTime, endDateTime);
		if (reportGenerationMgr.getFileName().equalsIgnoreCase(ReportConstants.ATM_DAILY_TRANSACTION_SUMMARY)
				&& noOfDaysBetween > 0) {
			reportGenerationMgr.setFileNamePrefix(ReportConstants.ATM_MONTHLY_TRANSACTION_SUMMARY);
		} else {
			reportGenerationMgr.setFileNamePrefix(filePrefix);
		}
	}

	public Map<Long, String> getAllInstitutionIdAndShortCode() {
		Map<Long, String> institutionMap = new HashMap<>();

		institutionRepository.findAll().forEach(i -> {
			if ("Institution".equals(i.getType())) {
				if (ReportConstants.CBC_INSTITUTION.equals(i.getName())) {
					institutionMap.put(i.getId(), "CBC");
				} else if (ReportConstants.CBS_INSTITUTION.equals(i.getName())) {
					institutionMap.put(i.getId(), "CBS");
				}
			}
		});
		return institutionMap;
	}

}
