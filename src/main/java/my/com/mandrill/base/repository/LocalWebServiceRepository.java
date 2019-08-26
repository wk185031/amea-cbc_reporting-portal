package my.com.mandrill.base.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.LocalWebService;

/**
 * Spring Data JPA repository for the LocalWebService entity.
 */
@Repository
public interface LocalWebServiceRepository extends JpaRepository<LocalWebService, String> {

	public LocalWebService findByServiceName(String serviceName);
}
