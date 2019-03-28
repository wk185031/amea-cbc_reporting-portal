package my.com.mandrill.base.repository.search;

import my.com.mandrill.base.domain.ReportCategory;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

/**
 * Spring Data Elasticsearch repository for the ReportCategory entity.
 */
public interface ReportCategorySearchRepository extends ElasticsearchRepository<ReportCategory, Long> {

}
