package my.com.mandrill.base.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityManager;
import javax.sql.DataSource;

import org.apache.commons.lang3.SerializationUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.JobHistoryDetails;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import my.com.mandrill.base.repository.SystemConfigurationRepository;
import my.com.mandrill.base.security.SecurityUtils;

@Service
public class JobHistoryService {

	@Autowired
	private JobRepository jobRepository;

	@Autowired
	private JobHistoryRepository jobHistoryRepository;

	@Autowired
	private ReportCategoryRepository reportCategoryRepository;

	@Autowired
	private ReportDefinitionRepository reportDefinitionRepository;

	@Autowired
	private ReportService reportService;

	@Autowired
	private SystemConfigurationRepository systemConfigurationRepo;

	@Autowired
	private Environment env;

	@Autowired
	private EntityManager em;

	@Autowired
	private DataSource datasource;

	private final Logger log = LoggerFactory.getLogger(JobHistoryService.class);

	public List<JobHistory> queueReportJob(JobHistoryDetails jobHistoryDetails) {

		List<JobHistory> jobList = new ArrayList<>();
		Job job = jobRepository.findByName(ReportConstants.JOB_NAME_GENERATE_REPORT);

		populateJobHistoryDetails(jobHistoryDetails);
		JobHistory jobHistory = initJobHistory(jobHistoryDetails, job);

		boolean generateForDaily = checkGenerateForFrequency(jobHistoryDetails, ReportConstants.DAILY);
		boolean generateForMonthly = checkGenerateForFrequency(jobHistoryDetails, ReportConstants.MONTHLY);

		if (generateForDaily) {
			jobList.add(createReportGenerationJob(jobHistory, ReportConstants.DAILY));
		}
		if (generateForMonthly) {
			jobList.add(createReportGenerationJob(jobHistory, ReportConstants.MONTHLY));
		}

		if (jobList.size() == 0) {
			throw new RuntimeException("error.report.noJobInQueue");
		}

		return jobList;
	}

	private void populateJobHistoryDetails(JobHistoryDetails jobHistoryDetails) {
		if (jobHistoryDetails.isAllCategory()) {
			jobHistoryDetails.setReportCategory("ALL");
		} else {
			jobHistoryDetails.setReportCategory(
					reportCategoryRepository.findOne(jobHistoryDetails.getReportCategoryId()).getName());

		}

		if (jobHistoryDetails.isAllReport()) {
			jobHistoryDetails.setReport("ALL");
		} else {
			jobHistoryDetails.setReport(reportDefinitionRepository.findOne(jobHistoryDetails.getReportId()).getName());
		}
	}

	private JobHistory initJobHistory(JobHistoryDetails jobHistoryDetails, Job job) {
		JobHistory jobHistory = new JobHistory();
		if (SecurityUtils.getCurrentUserLogin().isPresent()) {
			jobHistory.setCreatedBy(SecurityUtils.getCurrentUserLogin().get());
		} else {
			jobHistory.setCreatedBy("system");
		}
		jobHistory.setCreatedDate(Instant.now());

		String details = null;
		try {
			details = new ObjectMapper().writeValueAsString(jobHistoryDetails);
		} catch (JsonProcessingException e) {
			throw new RuntimeException("Failed to retrieve jobHistoryDetails.", e);
		}
		jobHistory.setDetails(details);
		jobHistory.setFrequency(jobHistoryDetails.getFrequency());
		jobHistory.setGenerationStartDate(null);
		jobHistory.setJob(job);
		jobHistory.setReportEndDate(jobHistoryDetails.getTransactionEndDate());
		jobHistory.setReportStartDate(jobHistoryDetails.getTransactionStartDate());
		jobHistory.setStatus(ReportConstants.STATUS_IN_QUEUE);
		return jobHistory;
	}

	private boolean checkGenerateForFrequency(JobHistoryDetails jobHistoryDetails, String frequency) {
		log.debug(
				"checkGenerateForFrequency {}: [startDate={}, endDate={}, presetFrequency={}, isAllCategory={}, isAllReport={}]",
				frequency, jobHistoryDetails.getTransactionStartDate(), jobHistoryDetails.getTransactionEndDate(),
				jobHistoryDetails.getFrequency(), jobHistoryDetails.isAllCategory(), jobHistoryDetails.isAllReport());
		if (jobHistoryDetails != null && jobHistoryDetails.getFrequency() != null
				&& frequency.contentEquals(jobHistoryDetails.getFrequency())) {
			return true;
		} else {
			if (ReportConstants.MONTHLY.contentEquals(frequency)) {
				// From and To is same day, and it is end of the month
				if (!jobHistoryDetails.getTransactionStartDate().toInstant(ZoneOffset.UTC).truncatedTo(ChronoUnit.DAYS)
						.equals(jobHistoryDetails.getTransactionEndDate().toInstant(ZoneOffset.UTC)
								.truncatedTo(ChronoUnit.DAYS))
						|| !YearMonth.from(jobHistoryDetails.getTransactionStartDate()).atEndOfMonth()
								.isEqual(jobHistoryDetails.getTransactionStartDate().toLocalDate())) {
					log.debug("Not end of month or Not specific day. Skip MONTHLY.");
					return false;
				}
			}

			long reportCount = 0;

			if (jobHistoryDetails.isAllCategory()) {
				reportCount = reportDefinitionRepository
						.countByInstitutionIdAndFrequencyContains(jobHistoryDetails.getInstitutionId(), frequency);
			} else if (jobHistoryDetails.isAllReport()) {
				reportCount = reportDefinitionRepository.countByInstitutionIdAndCategoryIdAndFrequencyContains(
						jobHistoryDetails.getInstitutionId(), jobHistoryDetails.getReportCategoryId(), frequency);
			} else {
				ReportDefinition def = reportDefinitionRepository.getOne(jobHistoryDetails.getReportId());
				if (def != null && def.getFrequency() != null && def.getFrequency().contains(frequency)) {
					reportCount = 1;
				}
			}
			log.debug("Total reports for {} frequency = {}.", frequency, reportCount);
			return reportCount > 0;
		}
	}

	private JobHistory createReportGenerationJob(JobHistory jobHistory, String frequency) {
		JobHistory cloneJobHistory = SerializationUtils.clone(jobHistory);

		cloneJobHistory.setFrequency(frequency);
		cloneJobHistory = jobHistoryRepository.saveAndFlush(cloneJobHistory);
		log.debug("Queue report generation job for frequency:{}, jobHistoryId = {}", frequency,
				cloneJobHistory.getId());

		return cloneJobHistory;
	}

	@Scheduled(cron = "0 * * * * ?")
	public void executeQueuedReportGenerationJob() {
		log.debug("executeQueuedReportGenerationJob: START");
		if (reportService.isDbSyncRunning()) {
			log.debug("DB sync is running. Report Generation Job will not be executed.");
			return;
		}

		SystemConfiguration config = systemConfigurationRepo.findByName("job.report.generate.max");
		int maxJobToExecute = 2;
		if (config != null && config.getConfig() != null) {
			maxJobToExecute = Integer.parseInt(config.getConfig());
		}

		long reportInQueueCount = jobHistoryRepository.countByJobNameAndStatus(ReportConstants.JOB_NAME_GENERATE_REPORT,
				ReportConstants.STATUS_IN_QUEUE);
		if (reportInQueueCount == 0) {
			log.debug("No job in queue. Skip.");
			return;
		}

		long reportInProgressCount = jobHistoryRepository
				.countByJobNameAndStatus(ReportConstants.JOB_NAME_GENERATE_REPORT, ReportConstants.STATUS_IN_PROGRESS);
		if (reportInProgressCount >= maxJobToExecute) {
			log.debug("Max job IN PROGRESS. Wait for existing job to complete.");
			return;
		}

		@SuppressWarnings("unchecked")
		List<JobHistory> jobsToExecute = em.createQuery(
				"select j from JobHistory j where j.job.name = :jobName and j.status = :status order by j.createdDate")
				.setParameter("jobName", ReportConstants.JOB_NAME_GENERATE_REPORT)
				.setParameter("status", ReportConstants.STATUS_IN_QUEUE)
				.setMaxResults((int) (maxJobToExecute - reportInProgressCount)).getResultList();
		log.debug("Report generation job to execute={}.", jobsToExecute.size());
		for (JobHistory h : jobsToExecute) {
			log.debug("Execute job [jobHistoryId={}]", h.getId());
			h.setStatus(ReportConstants.STATUS_IN_PROGRESS);
			h.setGenerationStartDate(LocalDateTime.now());
			h.setLastModifiedDate(Instant.now());
			h.setLastModifiedBy(
					SecurityUtils.getCurrentUserLogin().isPresent() ? SecurityUtils.getCurrentUserLogin().get()
							: "system");
			jobHistoryRepository.saveAndFlush(h);

			try {
				JobHistoryDetails jobHistoryDetails = new ObjectMapper().readValue(h.getDetails(),
						JobHistoryDetails.class);
				log.debug("Read jobHistoryDetails from json: {}", jobHistoryDetails.toString());

				reportService.generateReport(h.getId(), "system".equals(h.getCreatedBy()) ? false : true,
						jobHistoryDetails, h.getCreatedBy());
			} catch (Exception e) {
				log.error("Failed to generate report [jobHistoryId={}]", h.getId(), e);
				h.setStatus(ReportConstants.STATUS_FAILED);
				h.setLastModifiedDate(Instant.now());
				h.setLastModifiedBy(
						SecurityUtils.getCurrentUserLogin().isPresent() ? SecurityUtils.getCurrentUserLogin().get()
								: "system");
				jobHistoryRepository.saveAndFlush(h);
			}
		}

		log.debug("executeQueuedReportGenerationJob: END");
	}

	@Scheduled(cron = "0/5 * * * * ?")
	public void syncDcmsIssuanceCardTable() {
		Connection conn = null;
		PreparedStatement ps = null;
		PreparedStatement ps1 = null;
		try {
			conn = datasource.getConnection();
			ps = conn.prepareStatement("delete from DCMS_ISSUANCE_CARD");
			ps.executeUpdate();

			String sql = "INSERT INTO DCMS_ISSUANCE_CARD (SELECT CRD_ID, CRD_NUMBER, CRD_AUDIT_LOG FROM {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} "
					+ "WHERE CRD_AUDIT_LOG LIKE '%Account Delinked%')";

			sql = sql
					.replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA + "}",
							env.getProperty(ReportConstants.DB_SCHEMA_DCMS))
					.replace("{" + ReportConstants.PARAM_DB_LINK_DCMS + "}",
							env.getProperty(ReportConstants.DB_LINK_DCMS));
			ps1 = conn.prepareStatement(sql);
			ps1.executeUpdate();

		} catch (Exception e) {
			log.error("Failed to execute job: syncDcmsIssuanceCardTable", e);
		} finally {
			try {
				if (ps != null) {
					ps.close();
				}
			} catch (SQLException e) {
				log.warn("Failed to close prepared statement", e);
			}

			try {
				if (ps1 != null) {
					ps1.close();
				}
			} catch (SQLException e) {
				log.warn("Failed to close prepared statement", e);
			}

			try {
				if (conn != null) {
					conn.close();
				}
			} catch (Exception e) {
				log.warn("Failed to close db connection: ", e);
			}
		}
	}

}
