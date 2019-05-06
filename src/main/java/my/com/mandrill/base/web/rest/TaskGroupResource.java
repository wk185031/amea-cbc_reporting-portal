package my.com.mandrill.base.web.rest;

import static org.elasticsearch.index.query.QueryBuilders.queryStringQuery;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.codahale.metrics.annotation.Timed;

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.domain.Task;
import my.com.mandrill.base.domain.TaskGroup;
import my.com.mandrill.base.repository.TaskGroupRepository;
import my.com.mandrill.base.repository.search.TaskGroupSearchRepository;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;

/**
 * REST controller for managing TaskGroup.
 */
@RestController
@RequestMapping("/api")
public class TaskGroupResource {

    private final Logger log = LoggerFactory.getLogger(TaskGroupResource.class);

    private static final String ENTITY_NAME = "TaskGroup";

    private final TaskGroupRepository taskGroupRepository;

    private final TaskGroupSearchRepository taskGroupSearchRepository;

    public TaskGroupResource(TaskGroupRepository taskGroupRepository, TaskGroupSearchRepository taskGroupSearchRepository) {
        this.taskGroupRepository = taskGroupRepository;
        this.taskGroupSearchRepository = taskGroupSearchRepository;
    }

    /**
     * POST  /task-groups : Create a new TaskGroup.
     *
     * @param TaskGroup the TaskGroup to create
     * @return the ResponseEntity with status 201 (Created) and with body the new TaskGroup, or with status 400 (Bad Request) if the TaskGroup has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/task-groups")
    @Timed
    public ResponseEntity<TaskGroup> createTaskGroup(@Valid @RequestBody TaskGroup TaskGroup) throws URISyntaxException {
        log.debug("REST request to save TaskGroup : {}", TaskGroup);
        if (TaskGroup.getId() != null) {
            throw new BadRequestAlertException("A new TaskGroup cannot already have an ID", ENTITY_NAME, "idexists");
        }
        TaskGroup result = taskGroupRepository.save(TaskGroup);
        taskGroupSearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/task-groups/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
    }

    /**
     * PUT  /task-groups : Updates an existing TaskGroup.
     *
     * @param TaskGroup the TaskGroup to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated TaskGroup,
     * or with status 400 (Bad Request) if the TaskGroup is not valid,
     * or with status 500 (Internal Server Error) if the TaskGroup couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/task-groups")
    @Timed
    public ResponseEntity<TaskGroup> updateTaskGroup(@Valid @RequestBody TaskGroup TaskGroup) throws URISyntaxException {
        log.debug("REST request to update TaskGroup : {}", TaskGroup);
        if (TaskGroup.getId() == null) {
            return createTaskGroup(TaskGroup);
        }
        TaskGroup result = taskGroupRepository.save(TaskGroup);
        taskGroupSearchRepository.save(result);
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, TaskGroup.getId().toString()))
            .body(result);
    }

    /**
     * GET  /task-groups : get all the TaskGroups.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of TaskGroups in body
     */
    @GetMapping("/task-groups")
    @Timed
    public List<TaskGroup> getAllTaskGroups() {
        log.debug("REST request to get all TaskGroups");
        return taskGroupRepository.findAll();
        }

    /**
     * GET  /task-groups/:id : get the "id" TaskGroup.
     *
     * @param id the id of the TaskGroup to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the TaskGroup, or with status 404 (Not Found)
     */
    @GetMapping("/task-groups/{id}")
    @Timed
    public ResponseEntity<TaskGroup> getTaskGroup(@PathVariable Long id) {
        log.debug("REST request to get TaskGroup : {}", id);
        TaskGroup taskGroup = taskGroupRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(taskGroup));
    }

    /**
     * DELETE  /task-groups/:id : delete the "id" TaskGroup.
     *
     * @param id the id of the TaskGroup to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/task-groups/{id}")
    @Timed
    public ResponseEntity<Void> deleteTaskGroup(@PathVariable Long id) {
        log.debug("REST request to delete TaskGroup : {}", id);
        taskGroupRepository.delete(id);
        taskGroupSearchRepository.delete(id);
        return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
    }

    /**
     * SEARCH  /_search/task-groups?query=:query : search for the TaskGroup corresponding
     * to the query.
     *
     * @param query the query of the TaskGroup search
     * @return the result of the search
     */
    @GetMapping("/_search/task-groups")
    @Timed
    public List<TaskGroup> searchTaskGroups(@RequestParam String query) {
        log.debug("REST request to search TaskGroups for query {}", query);
        return StreamSupport
            .stream(taskGroupSearchRepository.search(queryStringQuery(query)).spliterator(), false)
            .collect(Collectors.toList());
    }
    
    @GetMapping("/task-group-by-job/{jobId}")
    @Timed
    public ResponseEntity<TaskGroup> getTaskGroupByJobId(@PathVariable Long jobId) {
        log.debug("REST request to get Task Groups by Job Id : {}", jobId);
        TaskGroup taskgroup = taskGroupRepository.findByJobId(jobId);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(taskgroup));
    }

}
