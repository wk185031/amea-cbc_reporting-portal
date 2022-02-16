package my.com.mandrill.base.web.rest;

import com.codahale.metrics.annotation.Timed;

import my.com.mandrill.base.config.audit.AuditActionService;
import my.com.mandrill.base.config.audit.AuditActionType;
import my.com.mandrill.base.domain.Attachment;
import my.com.mandrill.base.domain.AttachmentGroup;
import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.domain.InstitutionStructure;
import my.com.mandrill.base.repository.InstitutionRepository;
import my.com.mandrill.base.repository.search.InstitutionSearchRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.service.AppService;
import my.com.mandrill.base.service.AttachmentService;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import my.com.mandrill.base.web.rest.util.PaginationUtil;
import io.github.jhipster.web.util.ResponseUtil;

import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.net.URI;
import java.net.URISyntaxException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static my.com.mandrill.base.service.AppPermissionService.*;
import static org.elasticsearch.index.query.QueryBuilders.*;

/**
 * REST controller for managing Institution.
 */
@RestController
@RequestMapping("/api")
public class InstitutionResource {

    private final Logger log = LoggerFactory.getLogger(InstitutionResource.class);

    private static final String ENTITY_NAME = "institution";

    private final InstitutionRepository institutionRepository;

    private final InstitutionSearchRepository institutionSearchRepository;
    
    private final AuditActionService auditActionService;

    private final AppService appService;

    private final AttachmentService attachmentService;

    public InstitutionResource(InstitutionRepository institutionRepository,
    		InstitutionSearchRepository institutionSearchRepository,
    		AppService appService,
            AttachmentService attachmentService,
            AuditActionService auditActionService) {
        this.institutionRepository = institutionRepository;
        this.institutionSearchRepository = institutionSearchRepository;
        this.appService = appService;
        this.attachmentService = attachmentService;
        this.auditActionService = auditActionService;
    }

    /**
     * POST  /institutions : Create a new institution.
     *
     * @param institution the institution to create
     * @return the ResponseEntity with status 201 (Created) and with body the new institution, or with status 400 (Bad Request) if the institution has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/institutions")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_INSTITUTION+DOT+CREATE+"')")
    public ResponseEntity<Institution> createInstitution(@Valid @RequestBody Institution institution, HttpServletRequest request) throws URISyntaxException {
        log.debug("REST request to save Institution : {}", institution);
        if (institution.getId() != null) {
            throw new BadRequestAlertException("A new institution cannot already have an ID", ENTITY_NAME, "idexists");
        }
        
        try {
        	Institution result = institutionRepository.save(institution);
            institutionSearchRepository.save(result);
            auditActionService.addSuccessEvent(AuditActionType.INSTITUTION_CREATE, institution.getName(), request);
            return ResponseEntity.created(new URI("/api/institutions/" + result.getId()))
                .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
                .body(result);
        } catch (Exception e) {
        	auditActionService.addFailedEvent(AuditActionType.INSTITUTION_CREATE, institution.getName(), e, request);
        	throw e;
        }
        
    }

    /**
     * PUT  /institutions : Updates an existing institution.
     *
     * @param institution the institution to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated institution,
     * or with status 400 (Bad Request) if the institution is not valid,
     * or with status 500 (Internal Server Error) if the institution couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/institutions")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_INSTITUTION+DOT+UPDATE+"')")
    public ResponseEntity<Institution> updateInstitution(@Valid @RequestBody Institution institution, HttpServletRequest request) throws URISyntaxException {
        log.debug("REST request to update Institution : {}", institution);
        if (institution.getId() == null) {
            return createInstitution(institution, request);
        }
        try {
        	Institution result = institutionRepository.save(institution);
            institutionSearchRepository.save(result);
            auditActionService.addSuccessEvent(AuditActionType.INSTITUTION_UPDATE, institution.getName(), request);
            return ResponseEntity.ok()
                .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, institution.getId().toString()))
                .body(result);
        } catch (Exception e) {
        	auditActionService.addFailedEvent(AuditActionType.INSTITUTION_UPDATE, institution.getName(), e, request);
        	throw e;
        }
        
    }

    /**
     * GET  /institutions : get all the institutions.
     *
     * @param pageable the pagination information
     * @return the ResponseEntity with status 200 (OK) and the list of institutions in body
     */
    @GetMapping("/institutions")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_INSTITUTION+DOT+READ+"')")
    public ResponseEntity<List<Institution>> getAllInstitutions(Pageable pageable) {
        log.debug("REST request to get a page of Institutions");
        Page<Institution> page = institutionRepository.findAll(pageable);
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/institutions");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }
    
    /**
     * GET  /institutions : get all the institutions.
     *
     * @param pageable the pagination information
     * @return the ResponseEntity with status 200 (OK) and the list of institutions in body
     */
    @GetMapping("/institutions/child")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_INSTITUTION+DOT+READ+"')")
    public ResponseEntity<List<Institution>> getAllChildInstitutions() {
        log.debug("REST request to get all child institutions");
        List<Institution> results = institutionRepository.findInstitutionWithInstitutionType();
        return new ResponseEntity<>(results, HttpStatus.OK);
    }
    

    /**
     * GET  /companies : get all the companies without paging
     *
     * @return the ResponseEntity with status 200 (OK) and the list of companies in body
     */
    @GetMapping("/institutions-nopaging")
    @Timed
    public ResponseEntity<List<Institution>> getAllInstitutionNoPaging() {
        log.debug("REST request to all Institutions without paging");
        List<Institution> institutions = institutionRepository.findAll();
        return new ResponseEntity<>(institutions, HttpStatus.OK);
    }
    /**
     * GET  /institutions/:id : get the "id" institution.
     *
     * @param id the id of the institution to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the institution, or with status 404 (Not Found)
     */
    @GetMapping("/institutions/{id}")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_INSTITUTION+DOT+READ+"')")
    public ResponseEntity<Institution> getInstitution(@PathVariable Long id) {
        log.debug("REST request to get Institution : {}", id);
        Institution institution = institutionRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(institution));
    }

    /**
     * DELETE  /institutions/:id : delete the "id" institution.
     *
     * @param id the id of the institution to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/institutions/{id}")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_INSTITUTION+DOT+DELETE+"')")
    public ResponseEntity<Void> deleteInstitution(@PathVariable Long id, HttpServletRequest request) {
        log.debug("REST request to delete Institution : {}", id);
        try {
        	institutionRepository.delete(id);
            institutionSearchRepository.delete(id);
            auditActionService.addSuccessEvent(AuditActionType.INSTITUTION_DELETE, String.valueOf(id), request);
            return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
        } catch (Exception e) {
        	auditActionService.addFailedEvent(AuditActionType.INSTITUTION_DELETE, String.valueOf(id), e, request);
        	throw e;
        }
        
    }

    /**
     * SEARCH  /_search/institutions?query=:query : search for the institution corresponding
     * to the query.
     *
     * @param query the query of the institution search
     * @param pageable the pagination information
     * @return the result of the search
     */
    @GetMapping("/_search/institutions")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_INSTITUTION+DOT+READ+"')")
    public ResponseEntity<List<Institution>> searchInstitutions(@RequestParam String query, Pageable pageable) {
        log.debug("REST request to search for a page of Institutions for query {}", query);
        Page<Institution> page = institutionSearchRepository.search(queryStringQuery(query), pageable);
        HttpHeaders headers = PaginationUtil.generateSearchPaginationHttpHeaders(query, page, "/api/_search/institutions");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }

    /**
     * GET  /companies-for-user : get all the companies associated with the current user.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of companies in body
     */
    @GetMapping("/institutions-for-user")
    @Timed
    public List<Institution> getInstitutionForUser() {
        log.debug("REST request to get Insitutions for user");
        String username = SecurityUtils.getCurrentUserLogin().orElse("");
        List<Institution> companies = new ArrayList<>();
        if (username != null) {
            companies.addAll(appService.getAllInstitutionWithChildsOfUser(username));
        }
        return companies;
    }

    /**
     * GET  /institutions-for-user : get all the parent institutions associated with the current user and related to current institutions.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of institutions in body
     */
    @GetMapping("/institutions-parent-for-institutions-and-user/{id}")
    @Timed
    public List<Institution> getParentInstitutionByInstitutionIdAndUser(@PathVariable Long id) {
        log.debug("REST request getParentInstitutionByInstitutionIdAndUser");
        String username = SecurityUtils.getCurrentUserLogin().orElse("");
        List<Institution> institutions = new ArrayList<>();
        Institution currentInstitution =null;
        if(id!=null) {
        	currentInstitution = institutionRepository.findOne(id);
            if(currentInstitution!=null && currentInstitution.getParent()!=null)
            	institutions.add(currentInstitution.getParent());
        }
        if (username != null) {
            Set<Institution> institutionSet= appService.getAllInstitutionWithChildsOfUser(username);
            for (Institution institution : institutionSet) {
                if(currentInstitution==null){
                	institutions.add(institution);
                }
                else if(currentInstitution!=null && !institution.getId().equals(currentInstitution.getId())){
                    if(currentInstitution.getParent()==null){
                    	institutions.add(institution);
                    }
                    else if(currentInstitution.getParent()!=null && !institution.getId().equals(currentInstitution.getParent().getId())){
                    	institutions.add(institution);
                    }
                }
            }
        }
        return institutions;
    }

    @GetMapping("/institution-structures")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_INSTITUTION+DOT+READ+"')")
    public ResponseEntity<String> getCompanyStructures() {
        log.debug("REST request to get All Institution");
        List<Institution> all = institutionRepository.findAll();
        List<Institution> parents = all.stream().filter((institution) -> institution.getParent() == null).collect(Collectors.toList());
        List<InstitutionStructure> structures = new ArrayList<>();
        for(Institution parent: parents){
        	InstitutionStructure structure = new InstitutionStructure(parent);
        	structure.setChildren(appService.generateInstitutionStructure(parent.getId()));
        	structures.add(structure);
        }

        JSONArray jsonStructures = new JSONArray();
        for(InstitutionStructure institutionStructure : structures){
            jsonStructures.put(new JSONObject(institutionStructure));
        }
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(jsonStructures.toString()));
    }

    /**
    /**
     * POST /institutions : Create a new institutions with attachment.
     *
     * @param institution the institution to create
     * @return the ResponseEntity with status 201 (Created) and with body the new institution, or with status 400 (Bad Request) if the institution has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/institution-with-attachment")
    // @Timed
    @Transactional
    public ResponseEntity<Institution> createInstitutionWithAttachment(@Valid @RequestBody Institution institution) throws Exception {
        log.debug("REST request to save Institution and Attachment: {}", institution);
        if (institution.getId() != null) {
            throw new BadRequestAlertException("A new institution cannot already have an ID", ENTITY_NAME, "idexists");
        }

        // Attachment handle
        if (institution.getAttachments().size() != 0) {
            Set<Attachment> attachments = institution.getAttachments();
            AttachmentGroup attachmentGroupResult = attachmentService.createAttachmentGroup(Institution.class);
            institution.setAttachmentGroup(attachmentGroupResult);
            attachmentService.saveInstitutionAttachment(institution.getAttachmentGroup(), attachments);
        }
        institution.setAttachments(null);

        Institution result = institutionRepository.save(institution);
        institutionSearchRepository.save(result);

        return ResponseEntity.created(new URI("/api/institutions/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
    }
    /**
     * PUT /institutions : Updates an existing institutions with attachment.
     *
     * @param institution the institutionsv to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated
     *         institutions, or with status 400 (Bad Request) if the institutions is not
     *         valid, or with status 500 (Internal Server Error) if the institutions
     *         couldn't be updated
     * @throws URISyntaxException
     *             if the Location URI syntax is incorrect
     */
    @PutMapping("/institution-with-attachment")
    @Timed
    @Transactional
    public ResponseEntity<Institution> updateInstitutionWithAttachment(@Valid @RequestBody Institution institution) throws Exception {
        log.debug("REST request to update Institution with attachment : {}", institution);
        if (institution.getId() == null) {
            return createInstitutionWithAttachment(institution);
        }

        // Attachment handle
        if (institution.getAttachments().size() != 0) {
            Set<Attachment> attachments = institution.getAttachments().stream()
                .filter(attachment -> ((attachment.getId() == null && !attachment.getRemoveFlag()) || (attachment.getId() != null && attachment.getRemoveFlag()))).collect(Collectors.toSet());
            if (institution.getAttachmentGroup() == null) {
                AttachmentGroup attachmentGroupResult = attachmentService.createAttachmentGroup(Institution.class);
                institution.setAttachmentGroup(attachmentGroupResult);
            }
            attachmentService.saveInstitutionAttachment(institution.getAttachmentGroup(), attachments);
        }
        institution.setAttachments(null);

        Institution result = institutionRepository.save(institution);
        institutionSearchRepository.save(result);
        return ResponseEntity.ok().headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
    }
}
