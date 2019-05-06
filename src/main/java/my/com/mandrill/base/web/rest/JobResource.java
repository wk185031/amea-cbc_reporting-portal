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
import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.reporting.DatabaseSynchronizer;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.search.JobSearchRepository;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;

/**
 * REST controller for managing Job.
 */
@RestController
@RequestMapping("/api")
public class JobResource {

    private final Logger log = LoggerFactory.getLogger(JobResource.class);

    private static final String ENTITY_NAME = "Job";

    private final JobRepository jobRepository;

    private final JobSearchRepository jobSearchRepository;

    private final DatabaseSynchronizer databaseSynchronizer;

    public JobResource(JobRepository jobRepository, JobSearchRepository jobSearchRepository, DatabaseSynchronizer databaseSynchronizer) {
        this.jobRepository = jobRepository;
        this.jobSearchRepository = jobSearchRepository;
        this.databaseSynchronizer = databaseSynchronizer;
    }

    /**
     * POST  /jobs : Create a new Job.
     *
     * @param Job the Job to create
     * @return the ResponseEntity with status 201 (Created) and with body the new Job, or with status 400 (Bad Request) if the Job has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/jobs")
    @Timed
    public ResponseEntity<Job> createJob(@Valid @RequestBody Job job) throws URISyntaxException {
        log.debug("REST request to save Job : {}", job);
        if (job.getId() != null) {
            throw new BadRequestAlertException("A new Job cannot already have an ID", ENTITY_NAME, "idexists");
        }
        Job result = jobRepository.save(job);
        jobSearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/jobs/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
    }

    /**
     * PUT  /jobs : Updates an existing Job.
     *
     * @param job, the Job to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated Job,
     * or with status 400 (Bad Request) if the Job is not valid,
     * or with status 500 (Internal Server Error) if the Job couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/jobs")
    @Timed
    public ResponseEntity<Job> updateJob(@Valid @RequestBody Job job) throws URISyntaxException {
        log.debug("REST request to update Job : {}", job);
        if (job.getId() == null) {
            return createJob(job);
        }
        Job result = jobRepository.save(job);
        jobSearchRepository.save(result);
        if (job.getName().equalsIgnoreCase("DB_SYNC")) {
        	databaseSynchronizer.refreshCronSchedule();
        }
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, job.getId().toString()))
            .body(result);
    }

    /**
     * GET  /jobs : get all the Jobs.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of Jobs in body
     */
    @GetMapping("/jobs")
    @Timed
    public List<Job> getAllJobs() {
        log.debug("REST request to get all Jobs");
        return jobRepository.findAll();
        }

    /**
     * GET  /jobs/:id : get the "id" Job.
     *
     * @param id the id of the Job to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the Job, or with status 404 (Not Found)
     */
    @GetMapping("/jobs/{id}")
    @Timed
    public ResponseEntity<Job> getJob(@PathVariable Long id) {
        log.debug("REST request to get Job : {}", id);
        Job job = jobRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(job));
    }

    /**
     * DELETE  /jobs/:id : delete the "id" Job.
     *
     * @param id the id of the Job to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/jobs/{id}")
    @Timed
    public ResponseEntity<Void> deleteJob(@PathVariable Long id) {
        log.debug("REST request to delete Job : {}", id);
        jobRepository.delete(id);
        jobSearchRepository.delete(id);
        return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
    }

    /**
     * SEARCH  /_search/jobs?query=:query : search for the Job corresponding
     * to the query.
     *
     * @param query the query of the Job search
     * @return the result of the search
     */
    @GetMapping("/_search/jobs")
    @Timed
    public List<Job> searchJobs(@RequestParam String query) {
        log.debug("REST request to search Jobs for query {}", query);
        return StreamSupport
            .stream(jobSearchRepository.search(queryStringQuery(query)).spliterator(), false)
            .collect(Collectors.toList());
    }

}
