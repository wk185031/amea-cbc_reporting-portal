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

    @Query("select reportDefinition from ReportDefinition reportDefinition where reportDefinition.branchFlag = 'branch'")
    List<ReportDefinition> findAllReportDefinitionWithBranch(Sort sort);

//    @Query("select reportDefinition from ReportDefinition reportDefinition where operator('ToChar', reportDefinition.dailyScheduleTime,'HH24:MI')= :date" +
//        "@Param(\"date\") LocalDateTime date;")
//    List<ReportDefinition>findByScheduleTime(ZonedDateTime scheduleTime);

    @Query("select r from ReportDefinition r where to_char(r.scheduleTime, 'HH24:MI') = ?1")
    List<ReportDefinition> findReportDefinitionByTime(String time);
    
    //@Query("select r from ReportDefinition r where r.institutionId = ?1 order by r.name") 
    List<ReportDefinition> findByInstitutionIdOrderByName(Long instId);
    
    //@Query("select r from ReportDefinition r where r.institutionId = ?1 and r.frequency order by r.name") 
    List<ReportDefinition> findByInstitutionIdAndFrequencyContainsOrderByName(Long instId, String frequency);
    
    //@Query("select r from ReportDefinition r where r.category.id = ?1 and r.institutionId = ?2 order by r.name") 
    List<ReportDefinition> findByCategoryIdAndInstitutionIdOrderByName(Long categoryId, Long instId);
    
    List<ReportDefinition> findByCategoryIdAndInstitutionIdAndFrequencyContainsOrderByName(Long categoryId, Long instId, String frequency);
    
    List<ReportDefinition> findAllByCategoryId(Long categoryId);
    
    List<ReportDefinition> findAllByInstitutionId(Long institutionId);
    
    long countByInstitutionIdAndFrequencyContains(Long instId, String frequency);

    long countByInstitutionIdAndCategoryIdAndFrequencyContains(Long instId, Long categoryId, String frequency);
    
    ReportDefinition findOneByCategoryIdAndName(Long categoryId, String reportName);
}
