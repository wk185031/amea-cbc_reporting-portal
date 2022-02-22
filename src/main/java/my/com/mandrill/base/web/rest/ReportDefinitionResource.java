package my.com.mandrill.base.web.rest;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.CREATE;
import static my.com.mandrill.base.service.AppPermissionService.DELETE;
import static my.com.mandrill.base.service.AppPermissionService.DOT;
import static my.com.mandrill.base.service.AppPermissionService.OPER;
import static my.com.mandrill.base.service.AppPermissionService.READ;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_REPORT_DEFINITION;
import static my.com.mandrill.base.service.AppPermissionService.UPDATE;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
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
import org.springframework.web.bind.annotation.RestController;

import com.codahale.metrics.annotation.Timed;

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.config.ApplicationProperties;
import my.com.mandrill.base.config.audit.AuditActionService;
import my.com.mandrill.base.config.audit.AuditActionType;
import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.domain.ReportCategory;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.domain.TreeStructure;
import my.com.mandrill.base.domain.User;
import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.repository.ReportCategoryRepository;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import my.com.mandrill.base.repository.UserExtraRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.service.AppService;
import my.com.mandrill.base.service.UserService;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import my.com.mandrill.base.web.rest.util.PaginationUtil;

/**
 * REST controller for managing ReportDefinition.
 */
@RestController
@RequestMapping("/api")
public class ReportDefinitionResource {

	private final Logger log = LoggerFactory.getLogger(ReportDefinitionResource.class);

	private static final String ENTITY_NAME = "reportDefinition";

	private final ReportCategoryRepository reportCategoryRepository;

	private final ReportDefinitionRepository reportDefinitionRepository;
	
	private final UserService userService;
	
	private final UserExtraRepository userExtraRepository;

	//private final ReportDefinitionSearchRepository reportDefinitionSearchRepository;
	
	private final ApplicationProperties applicationProperties;
	
	private final AppService appService;
	
	private final AuditActionService auditActionService;
	
	private static final String MASTER_BRANCH_ID = "2247";

	public ReportDefinitionResource(ReportCategoryRepository reportCategoryRepository,
			ReportDefinitionRepository reportDefinitionRepository,
			//ReportDefinitionSearchRepository reportDefinitionSearchRepository,
			ApplicationProperties applicationProperties,
			AppService appService, UserService userService, UserExtraRepository userExtraRepository,
			 AuditActionService auditActionService) {
		this.reportCategoryRepository = reportCategoryRepository;
		this.reportDefinitionRepository = reportDefinitionRepository;
		//this.reportDefinitionSearchRepository = reportDefinitionSearchRepository;
		this.applicationProperties = applicationProperties;
		this.appService = appService;
		this.userService = userService;
		this.userExtraRepository = userExtraRepository;
		this.auditActionService = auditActionService;
	}

	/**
	 * POST /reportDefinition : Create a new report.
	 *
	 * @param reportDefinition
	 *            the report definition to create
	 * @return the ResponseEntity with status 201 (Created) and with body the new
	 *         report definition, or with status 400 (Bad Request) if the report
	 *         definition has already an ID
	 * @throws URISyntaxException
	 *             if the Location URI syntax is incorrect
	 */
	@PostMapping("/reportDefinition")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + CREATE
			+ "')")
	public ResponseEntity<ReportDefinition> createReportDefinition(
			@Valid @RequestBody ReportDefinition reportDefinition, HttpServletRequest request) throws URISyntaxException {
		log.debug("User: {}, REST request to save ReportDefinition: {}", SecurityUtils.getCurrentUserLogin().orElse(""),
				reportDefinition);
		if (reportDefinition.getId() != null) {
			throw new BadRequestAlertException("A new report cannot already have an ID", ENTITY_NAME, "idexists");
		}
		
		try {
			ReportDefinition result = reportDefinitionRepository.save(reportDefinition);
			//reportDefinitionSearchRepository.save(result);
			auditActionService.addSuccessEvent(AuditActionType.REPORT_DEFINITION_CREATE, reportDefinition.getName(), request);
			return ResponseEntity.created(new URI("/api/reportDefinition/" + result.getId()))
					.headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString())).body(result);
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.REPORT_DEFINITION_CREATE, reportDefinition.getName(), e, request);
			throw e;
		}
		
	}

	/**
	 * PUT /reportDefinition : Updates an existing report.
	 *
	 * @param reportDefinition
	 *            the report definition to update
	 * @return the ResponseEntity with status 200 (OK) and with body the updated
	 *         report definition, or with status 400 (Bad Request) if the report
	 *         definition is not valid, or with status 500 (Internal Server Error)
	 *         if the report definition couldn't be updated
	 * @throws URISyntaxException
	 *             if the Location URI syntax is incorrect
	 */
	@PutMapping("/reportDefinition")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + UPDATE
			+ "')")
	public ResponseEntity<ReportDefinition> updateReportDefinition(
			@Valid @RequestBody ReportDefinition reportDefinition, HttpServletRequest request) throws URISyntaxException {
		log.debug("User: {}, REST request to update ReportDefinition: {}",
				SecurityUtils.getCurrentUserLogin().orElse(""), reportDefinition);
		if (reportDefinition.getId() == null) {
			return createReportDefinition(reportDefinition, request);
		}
		
		ReportDefinition old = org.apache.commons.lang3.SerializationUtils
				.clone(reportDefinitionRepository.findOne(reportDefinition.getId()));
		
		try {
			ReportDefinition result = reportDefinitionRepository.save(reportDefinition);
			// reportDefinitionSearchRepository.save(result);
			auditActionService.addSuccessEvent(AuditActionType.REPORT_DEFINITION_UPDATE, old, result, request);
			return ResponseEntity.ok()
					.headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, reportDefinition.getId().toString()))
					.body(result);
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.REPORT_DEFINITION_UPDATE, reportDefinition.getName(), e, request);
			throw e;
		}
		
	}

	/**
	 * GET /reportDefinition : get all the report definition.
	 *
	 * @param pageable
	 *            the pagination information
	 * @return the ResponseEntity with status 200 (OK) and the list of report
	 *         definition in body
	 */
	@GetMapping("/reportDefinition")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + READ
			+ "')")
	public ResponseEntity<List<ReportDefinition>> getAllReportDefinition(Pageable pageable) {
		// log.debug("User: {}, REST request to get a page of ReportDefinition",
		// SecurityUtils.getCurrentUserLogin().orElse(""));
		Page<ReportDefinition> page = reportDefinitionRepository.findAll(pageable);
		HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/reportDefinition");
		return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
	}

	/**
	 * GET /reportDefinition : get all the report definition without paging
	 *
	 * @return the ResponseEntity with status 200 (OK) and the list of report
	 *         definition in body
	 */
	@GetMapping("/reportDefinition-nopaging")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + READ
			+ "')")
	public ResponseEntity<List<ReportDefinition>> getAllReportDefinitionNoPaging() {		
		List<ReportDefinition> reportDefinition = reportDefinitionRepository.findAllByInstitutionId(getInstitutionId());
		
		return new ResponseEntity<>(reportDefinition, HttpStatus.OK);
	}

	/**
	 * GET /reportDefinition : get all the report definition without paging
	 *
	 * @return the ResponseEntity with status 200 (OK) and the list of report
	 *         definition in body
	 */
	@GetMapping("/reportDefinition-nopaging/{branchId}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + READ
			+ "')")
	public ResponseEntity<List<ReportDefinition>> getAllReportDefinitionNoPagingWithBranch(@PathVariable Long branchId) {
		// log.debug("User: {}, REST request to all ReportDefinition without paging",
		// SecurityUtils.getCurrentUserLogin().orElse(""));
		List<ReportDefinition> reportDefinition = null;
		//if (branchId.toString().equals(MASTER_BRANCH_ID)) {
			reportDefinition = reportDefinitionRepository.findAll(new Sort(Sort.Direction.ASC, "name"));
		//} else {
		//	reportDefinition= reportDefinitionRepository.findAllReportDefinitionWithBranch(new Sort(Sort.Direction.ASC, "name"));
		//}
		reportDefinition.sort(Comparator.comparing(ReportDefinition::getId));
		return new ResponseEntity<>(reportDefinition, HttpStatus.OK);
	}

	/**
	 * GET /reportDefinition/:id : get the "id" reportDefinition.
	 *
	 * @param id
	 *            the id of the report definition to retrieve
	 * @return the ResponseEntity with status 200 (OK) and with body the report
	 *         definition, or with status 404 (Not Found)
	 */
	@GetMapping("/reportDefinition/{id}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + READ
			+ "')")
	public ResponseEntity<ReportDefinition> getReportDefinition(@PathVariable Long id) {
		log.debug("User: {}, REST request to get ReportDefinition: {}", SecurityUtils.getCurrentUserLogin().orElse(""),
				id);

		ReportDefinition reportDefinition = reportDefinitionRepository.findOne(id);

		if (reportDefinition != null) {
			//FIXME: All report standardize generate to a root directory configured in application.yml
			// The front end should display the path as read only
			
			String reportRoot = applicationProperties.getReportDir().getPath();
			Set<Institution> institutions = appService.getAllInstitutionOfUser(SecurityUtils.getCurrentUserLogin().get());
			reportDefinition.setFileLocation(reportRoot + "/" + institutions.iterator().next().getId());
		}

		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(reportDefinition));
	}

	/**
	 * DELETE /reportDefinition/:id : delete the "id" reportDefinition.
	 *
	 * @param id
	 *            the id of the report definition to delete
	 * @return the ResponseEntity with status 200 (OK)
	 */
	@DeleteMapping("/reportDefinition/{id}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + DELETE
			+ "')")
	public ResponseEntity<Void> deleteReportdDefinition(@PathVariable Long id, HttpServletRequest request) {
		log.debug("User: {}, REST request to delete ReportDefinition: {}",
				SecurityUtils.getCurrentUserLogin().orElse(""), id);
		
		ReportDefinition old = reportDefinitionRepository.findOne(id);
		try {
			reportDefinitionRepository.delete(id);
			//reportDefinitionSearchRepository.delete(id);
			auditActionService.addSuccessEvent(AuditActionType.REPORT_DEFINITION_DELETE, old.getName(), request);
			return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.REPORT_DEFINITION_DELETE, old != null ? old.getName() : id.toString(), e, request);
			throw e;
		}	
	}

//	/**
//	 * SEARCH /_search/reportDefinition?query=:query : search for the report
//	 * definition corresponding to the query.
//	 *
//	 * @param query
//	 *            the query of the report definition search
//	 * @param pageable
//	 *            the pagination information
//	 * @return the result of the search
//	 */
//	@GetMapping("/_search/reportDefinition")
//	@Timed
//	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + READ
//			+ "')")
//	public ResponseEntity<List<ReportDefinition>> searchReportDefinition(@RequestParam String query,
//			Pageable pageable) {
//		log.debug("User: {}, REST request to search for a page of ReportDefinition for query: {}",
//				SecurityUtils.getCurrentUserLogin().orElse(""), query);
//		Page<ReportDefinition> page = reportDefinitionSearchRepository.search(queryStringQuery(query), pageable);
//		HttpHeaders headers = PaginationUtil.generateSearchPaginationHttpHeaders(query, page,
//				"/api/_search/reportDefinition");
//		return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
//	}
	
	private Long getInstitutionId() {
		final Optional<User> isUser = userService.getUserWithAuthorities();
		
		List<ReportDefinition> reportDefinition = new ArrayList<>();
		
		Long instId = 0L;
		
		if (isUser.isPresent()) {
			User user = isUser.get();
			// get user extra from given user
			UserExtra userExtra = userExtraRepository.findByUser(user.getId());
			
			instId = userExtra.getInstitutions().iterator().next().getId();
		}
		
		return instId;
	}

	//Previous query without branch filter
	@GetMapping("/reportDefinition-structures")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + READ
			+ "')")
	public ResponseEntity<String> getReportDefinitionStructuresFilterWithBranch() {
		log.debug("User: {}, REST request to get Report Definition Structures",
				SecurityUtils.getCurrentUserLogin().orElse(""));
		List<ReportCategory> parents = reportCategoryRepository.findAll(orderByNameAsc());
		List<ReportDefinition> children = null;
		//HQ User branch ID
		children = reportDefinitionRepository.findAllByInstitutionId(getInstitutionId());
		List<TreeStructure> structures = new ArrayList<>();
		Long incrementNumber = new Long(1);
		for (ReportCategory parent : parents) {
			TreeStructure structure = new TreeStructure(parent);
			structure.setId(incrementNumber);
			incrementNumber++;
			structure.setChildren(buildReportDefinitionTree(children, parent.getId()));

			if (structure.getChildren().isEmpty() || structure.getChildren() == null) {
				continue;
			}
			for (TreeStructure childStructures : structure.getChildren()) {
				childStructures.setId(incrementNumber);
				incrementNumber++;
			}
			structures.add(structure);
		}
		JSONArray jsonStructures = new JSONArray();
		for (TreeStructure reportDefinitionStructure : structures) {
			jsonStructures.put(new JSONObject(reportDefinitionStructure));
		}
		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(jsonStructures.toString()));
	}

	//New URL for retrieve reports with branch
	@GetMapping("/reportDefinition-structures/{branchId}")
	@Timed
	@PreAuthorize("@AppPermissionService.hasPermission('" + OPER + COLON + RESOURCE_REPORT_DEFINITION + DOT + READ
			+ "')")
	public ResponseEntity<String> getReportDefinitionStructuresFilterWithBranch(@PathVariable Long branchId) {
		log.debug("User: {}, REST request to get Report Definition Structures, Branch Id : {}",
				SecurityUtils.getCurrentUserLogin().orElse(""), branchId);
		List<ReportCategory> parents = reportCategoryRepository.findAll(orderByIdAsc());
		List<ReportDefinition> children = null;
		//HQ User branch ID
		if (branchId.toString().equals(MASTER_BRANCH_ID)) {
			children = reportDefinitionRepository.findAll(orderByIdAsc());
		} else {
			children = reportDefinitionRepository.findAllReportDefinitionWithBranch(orderByIdAsc());
		}
		List<TreeStructure> structures = new ArrayList<>();
		Long incrementNumber = new Long(1);
		for (ReportCategory parent : parents) {
			TreeStructure structure = new TreeStructure(parent);
			structure.setId(incrementNumber);
			incrementNumber++;
			structure.setChildren(buildReportDefinitionTree(children, parent.getId()));

			if (structure.getChildren().isEmpty() || structure.getChildren() == null) {
				continue;
			}
			for (TreeStructure childStructures : structure.getChildren()) {
				childStructures.setId(incrementNumber);
				incrementNumber++;
			}
			structures.add(structure);
		}
		JSONArray jsonStructures = new JSONArray();
		for (TreeStructure reportDefinitionStructure : structures) {
			jsonStructures.put(new JSONObject(reportDefinitionStructure));
		}
		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(jsonStructures.toString()));
	}

	public List<TreeStructure> buildReportDefinitionTree(List<ReportDefinition> all, Long parentId) {
		List<ReportDefinition> children = all.stream()
				.filter(reportDefinition -> reportDefinition.getReportCategory() != null
						&& reportDefinition.getReportCategory().getId() == parentId)
				.collect(Collectors.toList());
		List<TreeStructure> childStructures = new ArrayList<>();
		for (ReportDefinition child : children) {
			TreeStructure childStructure = new TreeStructure(child);
			childStructures.add(childStructure);
		}
		return childStructures;
	}

	private Sort orderByIdAsc() {
		return new Sort(Sort.Direction.ASC, "id");
	}
	
	private Sort orderByNameAsc() {
		return new Sort(Sort.Direction.ASC, "name");
	}
}
