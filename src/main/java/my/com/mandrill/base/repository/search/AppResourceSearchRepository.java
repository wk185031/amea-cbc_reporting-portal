package my.com.mandrill.base.repository.search;

import my.com.mandrill.base.domain.AppResource;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

/**
 * Spring Data Elasticsearch repository for the AppResource entity.
 */
public interface AppResourceSearchRepository extends ElasticsearchRepository<AppResource, Long> {
}
