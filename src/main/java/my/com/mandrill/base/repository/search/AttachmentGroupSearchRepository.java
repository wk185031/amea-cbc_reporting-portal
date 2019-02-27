package my.com.mandrill.base.repository.search;

import my.com.mandrill.base.domain.AttachmentGroup;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

/**
 * Spring Data Elasticsearch repository for the AttachmentGroup entity.
 */
public interface AttachmentGroupSearchRepository extends ElasticsearchRepository<AttachmentGroup, Long> {
}
