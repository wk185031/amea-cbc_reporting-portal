package my.com.mandrill.base.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.TaskGroup;


/**
 * Spring Data JPA repository for the TaskGroup entity.
 */
@SuppressWarnings("unused")
@Repository
public interface TaskGroupRepository extends JpaRepository<TaskGroup, Long> {
	
	TaskGroup findByName(@Param("name") String taskGroupName);
	
	TaskGroup findByJobId(@Param("jobId") Long jobId);

}
