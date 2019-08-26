package my.com.mandrill.base.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.ReportGeneration;

/**
 * Spring Data JPA repository for the ReportGeneration entity.
 */
@Repository
public interface ReportGenerationRepository extends JpaRepository<ReportGeneration, Long> {

}
