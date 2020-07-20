package my.com.mandrill.base.repository;

import java.util.List;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.ReportDefinition;

/**
 * Spring Data JPA repository for the ReportDefinition entity.
 */
@Repository
public interface ReportDefinitionRepository extends JpaRepository<ReportDefinition, Long> {
	
}
