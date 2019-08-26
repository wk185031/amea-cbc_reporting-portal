package my.com.mandrill.base.repository.search;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import my.com.mandrill.base.domain.LocalWebService;

/**
 * Spring Data Elasticsearch repository for the LocalWebService entity.
 */
public interface LocalWebServiceSearchRepository extends ElasticsearchRepository<LocalWebService, String> {

}
