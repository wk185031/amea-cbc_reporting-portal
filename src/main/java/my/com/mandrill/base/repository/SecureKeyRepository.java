package my.com.mandrill.base.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.SecureKey;

/**
 * Spring Data JPA repository for the SecureKey entity.
 */
@Repository
public interface SecureKeyRepository extends JpaRepository<SecureKey, Long> {

	public SecureKey findByNameAndCategory(String name, String category);
}
