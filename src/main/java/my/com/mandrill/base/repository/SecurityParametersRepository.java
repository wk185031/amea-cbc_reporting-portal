package my.com.mandrill.base.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.SecurityParameters;

/**
 * Spring Data JPA repository for the SecurityParameters entity.
 */
@Repository
public interface SecurityParametersRepository extends JpaRepository<SecurityParameters, Long> {

}
