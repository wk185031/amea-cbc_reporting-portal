package my.com.mandrill.base.service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.JobHistoryDetails;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
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

	public List<JobHistory> queueReportJob(JobHistoryDetails jobHistoryDetails) {

		List<JobHistory> jobList = new ArrayList<>();
		Job job = jobRepository.findByName(ReportConstants.JOB_NAME_GENERATE_REPORT);

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

		String details = null;
		try {
			details = new ObjectMapper().writeValueAsString(jobHistoryDetails);
		} catch (JsonProcessingException e) {
			throw new RuntimeException("Failed to retrieve jobHistoryDetails.", e);
		}

		JobHistory jobHistory = new JobHistory();
		if (SecurityUtils.getCurrentUserLogin().isPresent()) {
			jobHistory.setCreatedBy(SecurityUtils.getCurrentUserLogin().get());
		} else {
			jobHistory.setCreatedBy("system");
		}
		jobHistory.setCreatedDate(Instant.now());
		jobHistory.setDetails(details);
		jobHistory.setFrequency(jobHistoryDetails.getFrequency());
		jobHistory.setGenerationStartDate(null);
		jobHistory.setJob(job);
		jobHistory.setReportEndDate(jobHistoryDetails.getTransactionEndDate());
		jobHistory.setReportStartDate(jobHistoryDetails.getTransactionStartDate());
		jobHistory.setStatus(ReportConstants.STATUS_IN_QUEUE);
		
		jobHistory.setFrequency(ReportConstants.DAILY);
		jobHistory = jobHistoryRepository.saveAndFlush(jobHistory);
		

//		if (jobHistoryDetails.getFrequency() != null) {
//			if (ReportConstants.DAILY.contentEquals(jobHistoryDetails.getFrequency())) {
//				jobList.add(createReportGenerationJob(jobHistory, ReportConstants.DAILY));
//			} else if (ReportConstants.MONTHLY.contentEquals(jobHistoryDetails.getFrequency())) {
//				jobList.add(createReportGenerationJob(jobHistory, ReportConstants.MONTHLY));
//			} else {
//				throw new IllegalArgumentException(
//						"Frequency " + jobHistoryDetails.getFrequency() + "is not supported");
//			}
//		} else {
//			long totalDailyReport = 0;
//			long totalMonthlyReport = 0;
//
//			if (jobHistoryDetails.isAllCategory()) {
//				totalDailyReport = reportDefinitionRepository.countByInstitutionIdAndFrequencyContains(
//						jobHistoryDetails.getInstitutionId(), ReportConstants.DAILY);
//				totalDailyReport = reportDefinitionRepository.countByInstitutionIdAndFrequencyContains(
//						jobHistoryDetails.getInstitutionId(), ReportConstants.MONTHLY);
//
//			} else if (jobHistoryDetails.isAllReport()) {
//				totalDailyReport = reportDefinitionRepository.countByInstitutionIdAndCategoryIdAndFrequencyContains(
//						jobHistoryDetails.getInstitutionId(), jobHistoryDetails.getReportCategoryId(),
//						ReportConstants.DAILY);
//				totalDailyReport = reportDefinitionRepository.countByInstitutionIdAndCategoryIdAndFrequencyContains(
//						jobHistoryDetails.getInstitutionId(), jobHistoryDetails.getReportCategoryId(),
//						ReportConstants.MONTHLY);
//			} else {
//				ReportDefinition def = reportDefinitionRepository.getOne(jobHistoryDetails.getReportId());
//				if (def == null) {
//					throw new IllegalArgumentException(
//							"Report with ID:" + jobHistoryDetails.getReportId() + " not found.");
//				}
//				if (def.getFrequency().contains(ReportConstants.DAILY)) {
//					totalDailyReport = 1;
//				}
//				if (def.getFrequency().contains(ReportConstants.MONTHLY)) {
//					totalMonthlyReport = 1;
//				}
//			}
//
//			if (totalDailyReport > 0) {
//				jobList.add(createReportGenerationJob(jobHistory, ReportConstants.DAILY));
//			}
//
//			if (totalMonthlyReport > 0) {
//				jobList.add(createReportGenerationJob(jobHistory, ReportConstants.MONTHLY));
//			}
//		}

		return jobList;
	}

	private JobHistory createReportGenerationJob(JobHistory jobHistory, String frequency) {
		jobHistory.setFrequency(frequency);
		jobHistory = jobHistoryRepository.saveAndFlush(jobHistory);

		return jobHistory;
	}

}
