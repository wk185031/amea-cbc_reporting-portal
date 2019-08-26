package my.com.mandrill.base.repository.search;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import my.com.mandrill.base.domain.EncryptionKey;

/**
 * Spring Data Elasticsearch repository for the EncryptionKey entity.
 */
public interface EncryptionKeySearchRepository extends ElasticsearchRepository<EncryptionKey, Long> {

}
