package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.ReportDefinition;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.ReportGeneration;

import java.util.List;

/**
 * Spring Data JPA repository for the ReportGeneration entity.
 */
@Repository
public interface ReportGenerationRepository extends JpaRepository<ReportGeneration, Long> {

}
