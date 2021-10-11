package my.com.mandrill.base.service;

import java.io.File;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

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
	
	private final Logger log = LoggerFactory.getLogger(HouseKeepingService.class);
	
	@Autowired
	private final JobHistoryRepository jobHistoryRepository;
	
	public HouseKeepingService(JobHistoryRepository jobHistoryRepository){
		this.jobHistoryRepository = jobHistoryRepository;
	}
	
	/**
     * Housekeeping job to remove the generated report in server after SYSTEM_CONFIGURATION.housekeeping.retention.period days.
     * <p>
     * This is scheduled to get fired everyday, at 01:00 (am).
     */
	@Scheduled(cron = "0 0 1 * * ?")
    public void removeOlderGeneratedReport() {
    	log.debug("removeOlderGeneratedReport");
    	
    	SystemConfigurationRepository configRepo = SpringContext.getBean(SystemConfigurationRepository.class);
		SystemConfiguration config = configRepo.findByName(ReportConstants.HOUSEKEEPING_RETENTION_PERIOD);
		int days = Integer.valueOf(config.getConfig());
    	
        List<JobHistory> jobHistoryList = jobHistoryRepository.getReportGeneratedOlder(ReportConstants.JOB_NAME_GENERATE_REPORT, days);
        log.debug("jobHistoryList: " + jobHistoryList.size());
        for (JobHistory jh : jobHistoryList) {
        	if (jh.getReportPath()!=null){
        		log.debug("Deleting older job history {}"+ jh.getReportPath());
                File directoryToDelete = new File(jh.getReportPath());
        		FileSystemUtils.deleteRecursively(directoryToDelete);
                jh.setStatus(ReportConstants.STATUS_DELETED);
                jh.setLastModifiedDate(Instant.now());
                jh.setLastModifiedBy(ReportConstants.CREATED_BY_USER);
                
                jobHistoryRepository.save(jh);
        	}
        }
    }

}
