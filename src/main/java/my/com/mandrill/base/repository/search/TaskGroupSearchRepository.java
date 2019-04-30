package my.com.mandrill.base.repository.search;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import my.com.mandrill.base.domain.TaskGroup;

/**
 * Spring Data Elasticsearch repository for the TaskGroup entity.
 */
public interface TaskGroupSearchRepository extends ElasticsearchRepository<TaskGroup, Long> {
}
