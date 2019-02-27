package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.SystemConfiguration;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.*;


/**
 * Spring Data JPA repository for the SystemConfiguration entity.
 */
@SuppressWarnings("unused")
@Repository
public interface SystemConfigurationRepository extends JpaRepository<SystemConfiguration, Long> {
	SystemConfiguration findByName(String name);
}
