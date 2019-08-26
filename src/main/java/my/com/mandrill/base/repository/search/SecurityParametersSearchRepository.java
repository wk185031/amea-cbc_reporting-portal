package my.com.mandrill.base.repository.search;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import my.com.mandrill.base.domain.SecurityParameters;

/**
 * Spring Data Elasticsearch repository for the SecurityParameters entity.
 */
public interface SecurityParametersSearchRepository extends ElasticsearchRepository<SecurityParameters, Long> {

}
