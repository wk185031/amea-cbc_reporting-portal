package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.AppResource;
import org.springframework.stereotype.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.*;


/**
 * Spring Data JPA repository for the AppResource entity.
 */
@SuppressWarnings("unused")
@Repository
public interface AppResourceRepository extends JpaRepository<AppResource, Long> {

	public List<AppResource> findAllByParentId(Long id);
}
