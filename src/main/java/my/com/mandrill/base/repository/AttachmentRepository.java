package my.com.mandrill.base.repository;

import my.com.mandrill.base.domain.Attachment;
import org.springframework.stereotype.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

/**
 * Spring Data JPA repository for the Attachment entity.
 */
@SuppressWarnings("unused")
@Repository
public interface AttachmentRepository extends JpaRepository<Attachment, Long> {

    List<Attachment> findByAttachmentGroupId(@Param("attachmentGroupId") Long attachmentGroupId);

}
