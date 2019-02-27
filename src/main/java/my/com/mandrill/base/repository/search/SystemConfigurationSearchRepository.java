package my.com.mandrill.base.repository.search;

import my.com.mandrill.base.domain.SystemConfiguration;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

/**
 * Spring Data Elasticsearch repository for the SystemConfiguration entity.
 */
public interface SystemConfigurationSearchRepository extends ElasticsearchRepository<SystemConfiguration, Long> {
}
