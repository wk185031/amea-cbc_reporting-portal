package my.com.mandrill.base.web.rest;

import static org.elasticsearch.index.query.QueryBuilders.queryStringQuery;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Base64;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.validation.Valid;

import org.apache.commons.io.FileUtils;
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
import my.com.mandrill.base.domain.Attachment;
import my.com.mandrill.base.domain.Task;
import my.com.mandrill.base.repository.TaskRepository;
import my.com.mandrill.base.repository.search.TaskSearchRepository;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;

/**
 * REST controller for managing Task.
 */
@RestController
@RequestMapping("/api")
public class TaskResource {

    private final Logger log = LoggerFactory.getLogger(TaskResource.class);

    private static final String ENTITY_NAME = "Task";

    private final TaskRepository taskRepository;

    private final TaskSearchRepository taskSearchRepository;

    public TaskResource(TaskRepository taskRepository, TaskSearchRepository taskSearchRepository) {
        this.taskRepository = taskRepository;
        this.taskSearchRepository = taskSearchRepository;
    }

    /**
     * POST  /tasks : Create a new Task.
     *
     * @param Task the Task to create
     * @return the ResponseEntity with status 201 (Created) and with body the new Task, or with status 400 (Bad Request) if the Task has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/tasks")
    @Timed
    public ResponseEntity<Task> createTask(@Valid @RequestBody Task task) throws URISyntaxException {
        log.debug("REST request to save Task : {}", task);
        if (task.getId() != null) {
            throw new BadRequestAlertException("A new Task cannot already have an ID", ENTITY_NAME, "idexists");
        }
        Task result = taskRepository.save(task);
        taskSearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/tasks/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
    }

    /**
     * PUT  /tasks : Updates an existing Task.
     *
     * @param Task the Task to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated Task,
     * or with status 400 (Bad Request) if the Task is not valid,
     * or with status 500 (Internal Server Error) if the Task couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/tasks")
    @Timed
    public ResponseEntity<Task> updateTask(@Valid @RequestBody Task task) throws URISyntaxException {
        log.debug("REST request to update Task : {}", task);
        if (task.getId() == null) {
            return createTask(task);
        }
        Task result = taskRepository.save(task);
        taskSearchRepository.save(result);
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, task.getId().toString()))
            .body(result);
    }

    /**
     * GET  /tasks : get all the Tasks.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of Tasks in body
     */
    @GetMapping("/tasks")
    @Timed
    public List<Task> getAllTasks() {
        log.debug("REST request to get all Tasks");
        return taskRepository.findAll();
        }

    /**
     * GET  /tasks/:id : get the "id" Task.
     *
     * @param id the id of the Task to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the Task, or with status 404 (Not Found)
     */
    @GetMapping("/tasks/{id}")
    @Timed
    public ResponseEntity<Task> getTask(@PathVariable Long id) {
        log.debug("REST request to get Task : {}", id);
        Task Task = taskRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(Task));
    }

    /**
     * DELETE  /tasks/:id : delete the "id" Task.
     *
     * @param id the id of the Task to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/tasks/{id}")
    @Timed
    public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
        log.debug("REST request to delete Task : {}", id);
        taskRepository.delete(id);
        taskSearchRepository.delete(id);
        return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
    }

    /**
     * SEARCH  /_search/tasks?query=:query : search for the Task corresponding
     * to the query.
     *
     * @param query the query of the Task search
     * @return the result of the search
     */
    @GetMapping("/_search/tasks")
    @Timed
    public List<Task> searchTasks(@RequestParam String query) {
        log.debug("REST request to search Tasks for query {}", query);
        return StreamSupport
            .stream(taskSearchRepository.search(queryStringQuery(query)).spliterator(), false)
            .collect(Collectors.toList());
    }
    
    @GetMapping("/tasks-by-task-group/{taskGroupId}")
    @Timed
    public ResponseEntity<List<Task>> getTasksByTaskGroupId(@PathVariable Long taskGroupId) {
        log.debug("REST request to get Tasks by Task Group Id : {}", taskGroupId);
        List<Task> tasks = taskRepository.findByTaskGroupId(taskGroupId);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(tasks));
    }

}
