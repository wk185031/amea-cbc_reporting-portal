package my.com.mandrill.base.repository.search;

import my.com.mandrill.base.domain.RoleExtra;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

/**
 * Spring Data Elasticsearch repository for the RoleExtra entity.
 */
public interface RoleExtraSearchRepository extends ElasticsearchRepository<RoleExtra, Long> {
}
