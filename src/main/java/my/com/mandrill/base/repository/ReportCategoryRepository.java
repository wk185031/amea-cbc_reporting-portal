package my.com.mandrill.base.repository;

import java.util.List;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.ReportCategory;

/**
 * Spring Data JPA repository for the ReportCategory entity.
 */
@Repository
public interface ReportCategoryRepository extends JpaRepository<ReportCategory, Long> {
	@Query("select reportCategory from ReportCategory reportCategory where reportCategory.branchFlag = 'branch'")
    List<ReportCategory> findAllReportCategoryWithBranch(Sort sort);
}
