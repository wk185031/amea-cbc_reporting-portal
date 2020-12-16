package my.com.mandrill.base.repository.search;

import my.com.mandrill.base.domain.Branch;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

/**
 * Spring Data Elasticsearch repository for the RoleExtra entity.
 */
public interface BranchSearchRepository extends ElasticsearchRepository<Branch, String> {
}
