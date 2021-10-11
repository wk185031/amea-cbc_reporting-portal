package my.com.mandrill.base.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.reporting.ReportConstants;


/**
 * Spring Data JPA repository for the JobHistory entity.
 */
@SuppressWarnings("unused")
@Repository
public interface JobHistoryRepository extends JpaRepository<JobHistory, Long> {
	
	public JobHistory findFirstByStatusOrderByCreatedDateDesc(String status);
	public JobHistory findFirstByStatusAndJobNameOrderByCreatedDateDesc(String status, String jobName);
	
	@Query("select jobHistory from JobHistory jobHistory join jobHistory.job job where jobHistory.createdBy IN ('system', :loginId) and job.name = :jobName")
    public Page<JobHistory> findLatestReportGenerated(Pageable pageable, @Param("loginId") String loginId, @Param("jobName") String jobName);

	@Query("select jobHistory from JobHistory jobHistory join jobHistory.job job where jobHistory.createdBy IN ('system', :loginId) and job.name = :jobName and "
			+ "jobHistory.createdDate >= TO_DATE(:startDate, 'YYYYMMDD HH24:MI:SS') and jobHistory.createdDate < TO_DATE(:endDate,'YYYYMMDD HH24:MI:SS')")
    public Page<JobHistory> findReportGeneratedByDate(Pageable pageable, @Param("loginId") String loginId, @Param("jobName") String jobName, @Param("startDate") String startDate, @Param("endDate") String endDate);

	@Query("select jobHistory from JobHistory jobHistory join jobHistory.job job where job.name = :jobName and jobHistory.createdDate <= TRUNC(SYSDATE) - :days and jobHistory.status != 'DELETED'")
	public List<JobHistory> getReportGeneratedOlder(@Param("jobName") String jobName, @Param("days") int days);
	
}
