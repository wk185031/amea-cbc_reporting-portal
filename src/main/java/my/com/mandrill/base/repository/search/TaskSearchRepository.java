package my.com.mandrill.base.repository.search;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import my.com.mandrill.base.domain.Task;

/**
 * Spring Data Elasticsearch repository for the Task entity.
 */
public interface TaskSearchRepository extends ElasticsearchRepository<Task, Long> {
}
