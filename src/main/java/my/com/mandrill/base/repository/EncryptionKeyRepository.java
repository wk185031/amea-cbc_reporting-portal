package my.com.mandrill.base.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import my.com.mandrill.base.domain.EncryptionKey;

/**
 * Spring Data JPA repository for the EncryptionKey entity.
 */
@Repository
public interface EncryptionKeyRepository extends JpaRepository<EncryptionKey, Long> {

}
