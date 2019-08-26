package my.com.mandrill.base.repository.search;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import my.com.mandrill.base.domain.SecureKey;

/**
 * Spring Data Elasticsearch repository for the SecureKey entity.
 */
public interface SecureKeySearchRepository extends ElasticsearchRepository<SecureKey, Long> {

}
