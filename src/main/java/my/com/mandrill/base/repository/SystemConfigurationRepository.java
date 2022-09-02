package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.domain.UserExtra;

import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.*;


/**
 * Spring Data JPA repository for the SystemConfiguration entity.
 */
@SuppressWarnings("unused")
@Repository
public interface SystemConfigurationRepository extends JpaRepository<SystemConfiguration, Long> {
	SystemConfiguration findByName(String name);
	
	Page<SystemConfiguration> findByNameContaining(String searchString, Pageable pageable);
}
