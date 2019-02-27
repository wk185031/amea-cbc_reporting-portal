package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.Institution;
import org.springframework.stereotype.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.*;


/**
 * Spring Data JPA repository for the Institution entity.
 */
@SuppressWarnings("unused")
@Repository
public interface InstitutionRepository extends JpaRepository<Institution, Long> {
	
	List<Institution> findAllInstitutionByParentId(Long id);
	
	@Query("select institution from Institution institution where institution.parent is null")
    List<Institution> findAllInstitutionRoot();
}
