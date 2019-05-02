package my.com.mandrill.base.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.Task;


/**
 * Spring Data JPA repository for the Task entity.
 */
@SuppressWarnings("unused")
@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {

	List<Task> findByTaskGroupId(@Param("taskGroupId") Long taskGroupId);
}
