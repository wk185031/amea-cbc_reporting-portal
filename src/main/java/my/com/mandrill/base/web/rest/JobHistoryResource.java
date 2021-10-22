package my.com.mandrill.base.web.rest;

import static org.elasticsearch.index.query.QueryBuilders.queryStringQuery;

import java.net.URI;
import java.net.URISyntaxException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
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
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.search.JobHistorySearchRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import my.com.mandrill.base.web.rest.util.PaginationUtil;

/**
 * REST controller for managing JobHistory.
 */
@RestController
@RequestMapping("/api")
public class JobHistoryResource {

    private final Logger log = LoggerFactory.getLogger(JobHistoryResource.class);

    private static final String ENTITY_NAME = "JobHistory";

    private final JobHistoryRepository jobHistoryRepository;

    private final JobHistorySearchRepository jobHistorySearchRepository;
    
    public JobHistoryResource(JobHistoryRepository jobHistoryRepository, JobHistorySearchRepository jobHistorySearchRepository) {
        this.jobHistoryRepository = jobHistoryRepository;
        this.jobHistorySearchRepository = jobHistorySearchRepository;
    }

    /**
     * POST  /jobHistory : Create a new JobHistory.
     *
     * @param JobHistory the JobHistory to create
     * @return the ResponseEntity with status 201 (Created) and with body the new JobHistory, or with status 400 (Bad Request) if the JobHistory has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/job-history")
    @Timed
    public ResponseEntity<JobHistory> createJobHistory(@Valid @RequestBody JobHistory jobHistory) throws URISyntaxException {
        log.debug("REST request to save JobHistory : {}", jobHistory);
        if (jobHistory.getId() != null) {
            throw new BadRequestAlertException("A new JobHistory cannot already have an ID", ENTITY_NAME, "idexists");
        }
        JobHistory result = jobHistoryRepository.save(jobHistory);
        jobHistorySearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/jobHistory/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
    }

    /**
     * PUT  /jobHistory : Updates an existing JobHistory.
     *
     * @param JobHistory the JobHistory to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated JobHistory,
     * or with status 400 (Bad Request) if the JobHistory is not valid,
     * or with status 500 (Internal Server Error) if the JobHistory couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/job-history")
    @Timed
    public ResponseEntity<JobHistory> updateJobHistory(@Valid @RequestBody JobHistory jobHistory) throws URISyntaxException {
        log.debug("REST request to update JobHistory : {}", jobHistory);
        if (jobHistory.getId() == null) {
            return createJobHistory(jobHistory);
        }
        JobHistory result = jobHistoryRepository.save(jobHistory);
        jobHistorySearchRepository.save(result);
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, jobHistory.getId().toString()))
            .body(result);
    }

    /**
     * GET  /jobHistory : get all the JobHistorys.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of JobHistorys in body
     */
    @GetMapping("/job-history")
    @Timed
    public List<JobHistory> getAllJobHistorys() {
        log.debug("REST request to get all JobHistorys");
        return jobHistoryRepository.findAll();
        }

    /**
     * GET  /jobHistory/:id : get the "id" JobHistory.
     *
     * @param id the id of the JobHistory to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the JobHistory, or with status 404 (Not Found)
     */
    @GetMapping("/job-history/{id}")
    @Timed
    public ResponseEntity<JobHistory> getJobHistory(@PathVariable Long id) {
        log.debug("REST request to get JobHistory : {}", id);
        JobHistory jobHistory = jobHistoryRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(jobHistory));
    }

    /**
     * DELETE  /jobHistory/:id : delete the "id" JobHistory.
     *
     * @param id the id of the JobHistory to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/job-history/{id}")
    @Timed
    public ResponseEntity<Void> deleteJobHistory(@PathVariable Long id) {
        log.debug("REST request to delete JobHistory : {}", id);
        jobHistoryRepository.delete(id);
        jobHistorySearchRepository.delete(id);
        return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
    }

    /**
     * SEARCH  /_search/jobHistory?query=:query : search for the JobHistory corresponding
     * to the query.
     *
     * @param query the query of the JobHistory search
     * @return the result of the search
     */
    @GetMapping("/_search/job-history")
    @Timed
    public List<JobHistory> searchJobHistorys(@RequestParam String query) {
        log.debug("REST request to search JobHistorys for query {}", query);
        return StreamSupport
            .stream(jobHistorySearchRepository.search(queryStringQuery(query)).spliterator(), false)
            .collect(Collectors.toList());
    }

    @GetMapping("/_searchlatest/job-history")
    @Timed
    public JobHistory getLatestJobHistorys(@RequestParam String query) {
        log.debug("REST request to search JobHistorys for query {}", query);

        return jobHistoryRepository.findFirstByStatusOrderByCreatedDateDesc("COMPLETED");
    }

    @GetMapping("/job-history-generated")
    @Timed
    public ResponseEntity<List<JobHistory>> getJobHistoryByDate(@RequestParam String institutionId, @RequestParam(required=false) String query, Pageable pageable) {
        log.debug("REST request to get JobHistoryByDate : {}");
        log.debug("date selected:: "+query);

        String currentUserLogin = SecurityUtils.getCurrentUserLogin().orElse("");
        Page<JobHistory> page = null;
        if(query!=null && !query.isEmpty()){
        	 String startDate = formatDate(query, -1) + " 00:00:00";
             String endDate = formatDate(query, 1) + " 00:00:00";
             page = jobHistoryRepository.findReportGeneratedByDate(pageable, currentUserLogin, ReportConstants.JOB_NAME_GENERATE_REPORT, startDate, endDate, institutionId);
        }
        else{
        	page = jobHistoryRepository.findLatestReportGenerated(pageable, currentUserLogin, ReportConstants.JOB_NAME_GENERATE_REPORT, institutionId);
        }
              
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/job-history-generated");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
        
    }
    
    private String formatDate(String dateSelected, int addDays){
    	
    	SimpleDateFormat format1 = new SimpleDateFormat("yyyy-MM-dd");
    	SimpleDateFormat format2 = new SimpleDateFormat("yyyyMMdd");
    	Date date = null;
    	String strDate = null;
		try {
			date = format1.parse(dateSelected);
			if(addDays > 0){
				date = addDays(date, 1);
			}
			strDate = format2.format(date);
		} catch (ParseException e) {
			log.debug("Error formatting date ");
			e.printStackTrace();
		}
		log.debug("date formatted: "+strDate);
    	return strDate;
    }
    
    private Date addDays(Date date, int days){
    	
    	Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.add(Calendar.DATE, days);
        return cal.getTime();
    }
}
