package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.Branch;
import org.springframework.stereotype.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.*;


/**
 * Spring Data JPA repository for the Branch entity.
 */
@SuppressWarnings("unused")
@Repository
public interface BranchRepository extends JpaRepository<Branch, String> {

	@Query("select b from Branch b order by abr_name asc")
	public List<Branch> findAllByOrderNameAsc();
}
