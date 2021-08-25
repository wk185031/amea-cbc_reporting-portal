package my.com.mandrill.base.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.JobHistory;


/**
 * Spring Data JPA repository for the JobHistory entity.
 */
@SuppressWarnings("unused")
@Repository
public interface JobHistoryRepository extends JpaRepository<JobHistory, Long> {
	
	public JobHistory findFirstByStatusOrderByCreatedDateDesc(String status);
	public JobHistory findFirstByStatusAndJobNameOrderByCreatedDateDesc(String status, String jobName);
}
