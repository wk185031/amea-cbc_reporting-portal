package my.com.mandrill.base.repository.search;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import my.com.mandrill.base.domain.JobHistory;

/**
 * Spring Data Elasticsearch repository for the JobHistory entity.
 */
public interface JobHistorySearchRepository extends ElasticsearchRepository<JobHistory, Long> {
}
