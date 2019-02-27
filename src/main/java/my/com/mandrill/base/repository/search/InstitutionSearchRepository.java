package my.com.mandrill.base.repository.search;

import my.com.mandrill.base.domain.Institution;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

/**
 * Spring Data Elasticsearch repository for the Institution entity.
 */
public interface InstitutionSearchRepository extends ElasticsearchRepository<Institution, Long> {
}
