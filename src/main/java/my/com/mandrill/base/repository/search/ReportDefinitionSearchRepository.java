package my.com.mandrill.base.repository.search;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import my.com.mandrill.base.domain.ReportDefinition;

/**
 * Spring Data Elasticsearch repository for the ReportDefinition entity.
 */
public interface ReportDefinitionSearchRepository extends ElasticsearchRepository<ReportDefinition, Long> {

}
