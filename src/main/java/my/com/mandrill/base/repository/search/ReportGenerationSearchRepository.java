package my.com.mandrill.base.repository.search;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import my.com.mandrill.base.domain.ReportGeneration;

/**
 * Spring Data Elasticsearch repository for the ReportGeneration entity.
 */
public interface ReportGenerationSearchRepository extends ElasticsearchRepository<ReportGeneration, Long> {

}
