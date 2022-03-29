package my.com.mandrill.base.service;

import java.io.File;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import javax.persistence.EntityManager;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.FileSystemUtils;

import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.SpringContext;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.SystemConfigurationRepository;

@Service
@Transactional
public class HouseKeepingService {

	private final static Logger log = LoggerFactory.getLogger(HouseKeepingService.class);

	private static final String SQL_DELETE_TRANSACTION_LOG_CUSTOM = "delete from transaction_log_custom where trl_id in (select trl_id from transaction_log where trl_system_timestamp < ?)";
	private static final String SQL_DELETE_TRANSACTION_LOG = "delete from transaction_log where trl_system_timestamp < ?";
	private static final String SQL_DELETE_ATM_DOWNTIME = "delete from atm_downtime where atd_end_timestamp < ?";
	private static final String SQL_DELETE_ATM_JOURNAL_LOG = "delete from atm_journal_log where ajl_timestamp < ?";
	private static final String SQL_DELETE_ATM_STATUS_HISTORY = "delete from atm_status_history where ash_timestamp < ?";
	private static final String SQL_DELETE_ATM_SUMMARY_COUNTERS = "delete from atm_summary_counters where atnc_entry_date < ?";
	private static final String SQL_DELETE_ATM_TXN_ACTIVITY_LOG = "delete from atm_txn_activity_log where ata_timestamp < ?";
	private static final String SQL_DELETE_DCMS_USER_ACTIVITY = "delete from dcms_user_activity where created_date < ?";

	@Autowired
	private final JobHistoryRepository jobHistoryRepository;

	@Autowired
	private EntityManager em;

	public HouseKeepingService(JobHistoryRepository jobHistoryRepository) {
		this.jobHistoryRepository = jobHistoryRepository;
	}

	/**
	 * Housekeeping job to remove the generated report in server after
	 * SYSTEM_CONFIGURATION.housekeeping.retention.period days.
	 * <p>
	 * This is scheduled to get fired everyday, at 01:00 (am).
	 */
	@Scheduled(cron = "0 0 22 * * ?")
	public void removeOlderGeneratedReport() {
		log.debug("removeOlderGeneratedReport");

		SystemConfigurationRepository configRepo = SpringContext.getBean(SystemConfigurationRepository.class);
		SystemConfiguration config = configRepo.findByName(ReportConstants.HOUSEKEEPING_RETENTION_PERIOD);
		int days = Integer.valueOf(config.getConfig());

		removeExpiredReportFile(days);
		removeExpiredTransactionalData(days);

//        List<JobHistory> jobHistoryList = jobHistoryRepository.getReportGeneratedOlder(ReportConstants.JOB_NAME_GENERATE_REPORT, days);
//        log.debug("jobHistoryList: " + jobHistoryList.size());
//        for (JobHistory jh : jobHistoryList) {
//        	if (jh.getReportPath()!=null){
//        		log.debug("Deleting older job history {}"+ jh.getReportPath());
//                File directoryToDelete = new File(jh.getReportPath());
//        		FileSystemUtils.deleteRecursively(directoryToDelete);
//                jh.setStatus(ReportConstants.STATUS_DELETED);
//                jh.setLastModifiedDate(Instant.now());
//                jh.setLastModifiedBy(ReportConstants.CREATED_BY_USER);
//                
//                jobHistoryRepository.save(jh);
//        	}
//        }
	}

	private void removeExpiredReportFile(int numOfDays) {
		log.debug("removeExpiredReportFile: numOfDays={}", numOfDays);
		List<JobHistory> jobHistoryList = jobHistoryRepository
				.getReportGeneratedOlder(ReportConstants.JOB_NAME_GENERATE_REPORT, numOfDays);

		log.debug("jobHistoryList: " + jobHistoryList.size());
		for (JobHistory jh : jobHistoryList) {
			if (jh.getReportPath() != null) {
				log.debug("Delete report files for: jobHistoryId={}, createdDate={}, reportPath={}" + jh.getId(),
						jh.getCreatedDate(), jh.getReportPath());
				File directoryToDelete = new File(jh.getReportPath());
				FileSystemUtils.deleteRecursively(directoryToDelete);
				jh.setStatus(ReportConstants.STATUS_DELETED);
				jh.setLastModifiedDate(Instant.now());
				jh.setLastModifiedBy(ReportConstants.CREATED_BY_USER);

				jobHistoryRepository.save(jh);
			}
		}
	}

	private void removeExpiredTransactionalData(int numOfDays) {
		log.debug("removeExpiredTransactionalData: numOfDays={}", numOfDays);

		LocalDateTime dateTime = LocalDate.now().atStartOfDay().minusDays(numOfDays);
		Timestamp beforeDate = Timestamp.valueOf(dateTime);
		List<String> statements = Arrays.asList(SQL_DELETE_TRANSACTION_LOG_CUSTOM, SQL_DELETE_TRANSACTION_LOG,
				SQL_DELETE_ATM_DOWNTIME, SQL_DELETE_ATM_JOURNAL_LOG, SQL_DELETE_ATM_STATUS_HISTORY,
				SQL_DELETE_ATM_SUMMARY_COUNTERS, SQL_DELETE_ATM_TXN_ACTIVITY_LOG, SQL_DELETE_DCMS_USER_ACTIVITY);

		for (String s : statements) {
			int deletedCount = em.createNativeQuery(s).setParameter(1, beforeDate).executeUpdate();
			log.debug("deleteData: count={}, beforeDate={}, sql={}", deletedCount, beforeDate, s);
		}
	}

}
