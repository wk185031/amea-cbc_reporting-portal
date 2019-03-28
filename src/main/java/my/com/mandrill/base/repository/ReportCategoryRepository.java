package my.com.mandrill.base.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.ReportCategory;

/**
 * Spring Data JPA repository for the ReportCategory entity.
 */
@Repository
public interface ReportCategoryRepository extends JpaRepository<ReportCategory, Long> {

}
