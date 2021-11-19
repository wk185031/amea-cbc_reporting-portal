package my.com.mandrill.base.web.rest;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.CREATE;
import static my.com.mandrill.base.service.AppPermissionService.DELETE;
import static my.com.mandrill.base.service.AppPermissionService.DOT;
import static my.com.mandrill.base.service.AppPermissionService.OPER;
import static my.com.mandrill.base.service.AppPermissionService.READ;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_REPORT_CATEGORY;
import static my.com.mandrill.base.service.AppPermissionService.UPDATE;
import static org.elasticsearch.index.query.QueryBuilders.queryStringQuery;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Optional;

import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
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
import my.com.mandrill.base.config.audit.AuditActionService;
import my.com.mandrill.base.config.audit.AuditActionType;
import my.com.mandrill.base.domain.ReportCategory;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.search.ReportCategorySearchRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import my.com.mandrill.base.web.rest.util.PaginationUtil;

/**
 * REST controller for managing ReportCategory.
 */
@RestController
@RequestMapping("/api")
public class ReportCategoryResource {

	private final Logger log = LoggerFactory.getLogger(ReportCategoryResource.class);

	private static final String ENTITY_NAME = "reportCategory";

	private final ReportCategoryRepository reportCategoryRepository;

	private final ReportCategorySearchRepository reportCategorySearchRepository;
	
	private final AuditActionService auditActionService;
	
	private static final String MASTER_BRANCH_ID = "2247";

	public ReportCategoryResource(ReportCategoryRepository reportCategoryRepository,
			ReportCategorySearchRepository reportCategorySearchRepository, AuditActionService auditActionService) {
		this.reportCategoryRepository = reportCategoryRepository;
		this.reportCategorySearchRepository = reportCategorySearchRepository;
		this.auditActionService = auditActionService;
	}

	/**
	 * POST /reportCategory : Create a new report category.
	 *
	 * @param reportCategory
	 *            the report category to create
	 * @return the ResponseEntity with status 201 (Created) and with body the new
	 *         report category, or with status 400 (Bad Request) if the report
	 *         category has already an ID
	 * @throws URISyntaxException
	 *             if the Location URI syntax is incorrect
	 */
	@PostMapping("/reportCategory")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_CATEGORY + DOT + CREATE
			+ "')")
	public ResponseEntity<ReportCategory> createReportCategory(@Valid @RequestBody ReportCategory reportCategory)
			throws URISyntaxException {
		log.debug("User: {}, REST request to save ReportCategory: {}", SecurityUtils.getCurrentUserLogin().orElse(""),
				reportCategory);
		if (reportCategory.getId() != null) {
			throw new BadRequestAlertException("A new report category cannot already have an ID", ENTITY_NAME,
					"idexists");
		}
		try {
			ReportCategory result = reportCategoryRepository.save(reportCategory);
			reportCategorySearchRepository.save(result);
			auditActionService.addSuccessEvent(AuditActionType.REPORT_CATEGORY_CREATE, reportCategory.getName());
			return ResponseEntity.created(new URI("/api/reportCategory/" + result.getId()))
					.headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString())).body(result);			
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.REPORT_CATEGORY_CREATE, reportCategory.getName(), e);
			throw e;
		}

	}

	/**
	 * PUT /reportCategory : Updates an existing report category.
	 *
	 * @param reportCategory
	 *            the report category to update
	 * @return the ResponseEntity with status 200 (OK) and with body the updated
	 *         report category, or with status 400 (Bad Request) if the report
	 *         category is not valid, or with status 500 (Internal Server Error) if
	 *         the report category couldn't be updated
	 * @throws URISyntaxException
	 *             if the Location URI syntax is incorrect
	 */
	@PutMapping("/reportCategory")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_CATEGORY + DOT + UPDATE
			+ "')")
	public ResponseEntity<ReportCategory> updateReportCategory(@Valid @RequestBody ReportCategory reportCategory)
			throws URISyntaxException {
		log.debug("User: {}, REST request to update ReportCategory: {}", SecurityUtils.getCurrentUserLogin().orElse(""),
				reportCategory);
		if (reportCategory.getId() == null) {
			return createReportCategory(reportCategory);
		}
		try {
			ReportCategory result = reportCategoryRepository.save(reportCategory);
			reportCategorySearchRepository.save(result);
			auditActionService.addSuccessEvent(AuditActionType.REPORT_CATEGORY_UPDATE, reportCategory.getName());
			return ResponseEntity.ok()
					.headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, reportCategory.getId().toString()))
					.body(result);
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.REPORT_CATEGORY_UPDATE, reportCategory.getName(), e);
			throw e;
		}
		
	}

	/**
	 * GET /reportCategory : get all the report categories.
	 *
	 * @param pageable
	 *            the pagination information
	 * @return the ResponseEntity with status 200 (OK) and the list of report
	 *         categories in body
	 */
	@GetMapping("/reportCategory")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_CATEGORY + DOT + READ + "')")
	public ResponseEntity<List<ReportCategory>> getAllReportCategories(Pageable pageable) {
		log.debug("User: {}, REST request to get a page of ReportCategory",
				SecurityUtils.getCurrentUserLogin().orElse(""));
		Page<ReportCategory> page = reportCategoryRepository.findAll(new PageRequest(0, 1, new Sort(Sort.Direction.ASC, "name")));
		HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/reportCategory");
		return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
	}
	
	/**
	 * GET /reportCategory : get all the report categories without paging
	 *
	 * @return the ResponseEntity with status 200 (OK) and the list of report
	 *         categories in body
	 */
	@GetMapping("/reportCategory-nopaging")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_CATEGORY + DOT + READ + "')")
	public ResponseEntity<List<ReportCategory>> getAllReportCategoriesNoPaging() {
		log.debug("User: {}, REST request to all Report Categories without paging",
				SecurityUtils.getCurrentUserLogin().orElse(""));
		List<ReportCategory> reportCategory = reportCategoryRepository.findAll(new Sort(Sort.Direction.ASC, "name"));
		return new ResponseEntity<>(reportCategory, HttpStatus.OK);
	}

	/**
	 * GET /reportCategory : get all the report categories without paging
	 *
	 * @return the ResponseEntity with status 200 (OK) and the list of report
	 *         categories in body
	 */
	@GetMapping("/reportCategory-nopaging/{branchId}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_CATEGORY + DOT + READ + "')")
	public ResponseEntity<List<ReportCategory>> getAllReportCategoriesNoPagingWithBranch(@PathVariable Long branchId) {
		log.debug("User: {}, REST request to all Report Categories without paging",
				SecurityUtils.getCurrentUserLogin().orElse(""));
		List<ReportCategory> reportCategory = null;
		//if (branchId.toString().equals(MASTER_BRANCH_ID)) {
			reportCategory = reportCategoryRepository.findAll(new Sort(Sort.Direction.ASC, "name"));
		//} else {
		//	reportCategory= reportCategoryRepository.findAllReportCategoryWithBranch(new Sort(Sort.Direction.ASC, "name"));
		//}
		return new ResponseEntity<>(reportCategory, HttpStatus.OK);
	}

	/**
	 * GET /reportCategory/:id : get the "id" reportCategory.
	 *
	 * @param id
	 *            the id of the report category to retrieve
	 * @return the ResponseEntity with status 200 (OK) and with body the report
	 *         category, or with status 404 (Not Found)
	 */
	@GetMapping("/reportCategory/{id}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_CATEGORY + DOT + READ + "')")
	public ResponseEntity<ReportCategory> getReportCategory(@PathVariable Long id) {
		log.debug("User: {}, REST request to get ReportCategory: {}", SecurityUtils.getCurrentUserLogin().orElse(""),
				id);
		ReportCategory reportCategory = reportCategoryRepository.findOne(id);
		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(reportCategory));
	}

	/**
	 * DELETE /reportCategory/:id : delete the "id" reportCategory.
	 *
	 * @param id
	 *            the id of the report category to delete
	 * @return the ResponseEntity with status 200 (OK)
	 */
	@DeleteMapping("/reportCategory/{id}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_CATEGORY + DOT + DELETE
			+ "')")
	public ResponseEntity<Void> deleteReportCategory(@PathVariable Long id) {
		log.debug("User: {}, REST request to delete ReportCategory: {}", SecurityUtils.getCurrentUserLogin().orElse(""),
				id);
		try {
			reportCategoryRepository.delete(id);
			reportCategorySearchRepository.delete(id);
			auditActionService.addSuccessEvent(AuditActionType.REPORT_CATEGORY_DELETE, String.valueOf(id));
			return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.REPORT_CATEGORY_DELETE, id.toString(), e);
			throw e;
		}
		
	}

	/**
	 * SEARCH /_search/reportCategory?query=:query : search for the report category
	 * corresponding to the query.
	 *
	 * @param query
	 *            the query of the report category search
	 * @param pageable
	 *            the pagination information
	 * @return the result of the search
	 */
	@GetMapping("/_search/reportCategory")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_CATEGORY + DOT + READ + "')")
	public ResponseEntity<List<ReportCategory>> searchReportCategory(@RequestParam String query, Pageable pageable) {
		log.debug("User: {}, REST request to search for a page of ReportCategory for query: {}",
				SecurityUtils.getCurrentUserLogin().orElse(""), query);
		Page<ReportCategory> page = reportCategorySearchRepository.search(queryStringQuery(query), pageable);
		HttpHeaders headers = PaginationUtil.generateSearchPaginationHttpHeaders(query, page,
				"/api/_search/reportCategory");
		return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
	}
}
