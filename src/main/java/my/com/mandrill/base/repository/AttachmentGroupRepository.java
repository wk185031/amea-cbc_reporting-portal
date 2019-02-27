package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.AttachmentGroup;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.*;


/**
 * Spring Data JPA repository for the AttachmentGroup entity.
 */
@SuppressWarnings("unused")
@Repository
public interface AttachmentGroupRepository extends JpaRepository<AttachmentGroup, Long> {

}
