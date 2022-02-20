package my.com.mandrill.base.web.rest;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.CREATE;
import static my.com.mandrill.base.service.AppPermissionService.DELETE;
import static my.com.mandrill.base.service.AppPermissionService.DOT;
import static my.com.mandrill.base.service.AppPermissionService.OPER;
import static my.com.mandrill.base.service.AppPermissionService.READ;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_USER_ROLE;
import static my.com.mandrill.base.service.AppPermissionService.UPDATE;
import static org.elasticsearch.index.query.QueryBuilders.queryStringQuery;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Optional;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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
import my.com.mandrill.base.domain.RoleExtra;
import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.repository.RoleExtraRepository;
import my.com.mandrill.base.repository.search.RoleExtraSearchRepository;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import my.com.mandrill.base.web.rest.util.PaginationUtil;

/**
 * REST controller for managing RoleExtra.
 */
@RestController
@RequestMapping("/api")
public class RoleExtraResource {

    private final Logger log = LoggerFactory.getLogger(RoleExtraResource.class);

    private static final String ENTITY_NAME = "roleExtra";

    private final RoleExtraRepository roleExtraRepository;

    private final RoleExtraSearchRepository roleExtraSearchRepository;
    
    private final AuditActionService auditActionService;

    public RoleExtraResource(RoleExtraRepository roleExtraRepository, RoleExtraSearchRepository roleExtraSearchRepository,
    		AuditActionService auditActionService) {
        this.roleExtraRepository = roleExtraRepository;
        this.roleExtraSearchRepository = roleExtraSearchRepository;
        this.auditActionService = auditActionService;
    }

    /**
     * POST  /role-extras : Create a new roleExtra.
     *
     * @param roleExtra the roleExtra to create
     * @return the ResponseEntity with status 201 (Created) and with body the new roleExtra, or with status 400 (Bad Request) if the roleExtra has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/role-extras")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER_ROLE+DOT+CREATE+"')")
    public ResponseEntity<RoleExtra> createRoleExtra(@Valid @RequestBody RoleExtra roleExtra, HttpServletRequest request) throws URISyntaxException {
        log.debug("REST request to save RoleExtra : {}", roleExtra);
        if (roleExtra.getId() != null) {
            throw new BadRequestAlertException("A new roleExtra cannot already have an ID", ENTITY_NAME, "idexists");
        }

		try {
			RoleExtra result = roleExtraRepository.save(roleExtra);
			roleExtraSearchRepository.save(result);
			auditActionService.addSuccessEvent(AuditActionType.ROLE_CREATE, result.getName(), request);
			return ResponseEntity.created(new URI("/api/role-extras/" + result.getId()))
					.headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString())).body(result);
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.ROLE_CREATE, roleExtra.getName(), e, request);
			throw e;
		}
    }

    /**
     * PUT  /role-extras : Updates an existing roleExtra.
     *
     * @param roleExtra the roleExtra to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated roleExtra,
     * or with status 400 (Bad Request) if the roleExtra is not valid,
     * or with status 500 (Internal Server Error) if the roleExtra couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/role-extras")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER_ROLE+DOT+UPDATE+"')")
    public ResponseEntity<RoleExtra> updateRoleExtra(@Valid @RequestBody RoleExtra roleExtra, HttpServletRequest request) throws URISyntaxException {
        log.debug("REST request to update RoleExtra : {}", roleExtra);
        if (roleExtra.getId() == null) {
            return createRoleExtra(roleExtra, request);
        }
        
        RoleExtra old = org.apache.commons.lang3.SerializationUtils
				.clone(roleExtraRepository.findOne(roleExtra.getId()));
        
		try {
			RoleExtra result = roleExtraRepository.save(roleExtra);
			roleExtraSearchRepository.save(result);
			auditActionService.addSuccessEvent(AuditActionType.ROLE_UPDATE, old, result, request);
			return ResponseEntity.ok()
					.headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, roleExtra.getId().toString()))
					.body(result);
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.ROLE_UPDATE, roleExtra.getName(), e, request);
			throw e;
		}
    }


    /**
     * GET  /role-extras : get all the roleExtras.
     *
     * @param pageable the pagination information
     * @return the ResponseEntity with status 200 (OK) and the list of roleExtras in body
     */
    @GetMapping("/role-extras-pagination")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER_ROLE+DOT+READ+"')")
    public ResponseEntity<List<RoleExtra>> getAllRoleExtrasPagination(Pageable pageable) {
        log.debug("REST request to get a page of RoleExtras");
        Page<RoleExtra> page = roleExtraRepository.findAll(pageable);
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/role-extras");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }
    
    @GetMapping("/role-extras")
    @Timed
    public List<RoleExtra> getAllRoleExtras() {
        log.debug("REST request to get All RoleExtras");
        List<RoleExtra> roleExtra = roleExtraRepository.findAll();
        //Todo filter with institution
        return roleExtra;
    }

    /**
     * GET  /role-extras/:id : get the "id" roleExtra.
     *
     * @param id the id of the roleExtra to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the roleExtra, or with status 404 (Not Found)
     */
    @GetMapping("/role-extras/{id}")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER_ROLE+DOT+READ+"')")
    public ResponseEntity<RoleExtra> getRoleExtra(@PathVariable Long id) {
        log.debug("REST request to get RoleExtra : {}", id);
        RoleExtra roleExtra = roleExtraRepository.findOneWithEagerRelationships(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(roleExtra));
    }

    /**
     * DELETE  /role-extras/:id : delete the "id" roleExtra.
     *
     * @param id the id of the roleExtra to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/role-extras/{id}")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER_ROLE+DOT+DELETE+"')")
    public ResponseEntity<Void> deleteRoleExtra(@PathVariable Long id, HttpServletRequest request) {
        log.debug("REST request to delete RoleExtra : {}", id);
        
        RoleExtra old = roleExtraRepository.findOne(id);
		try {
			roleExtraRepository.delete(id);
			roleExtraSearchRepository.delete(id);
			auditActionService.addSuccessEvent(AuditActionType.ROLE_DELETE, old.getName(), request);
			return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString()))
					.build();
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.ROLE_DELETE, old != null ? old.getName() : id.toString(), e, request);
			throw e;
		}
    }

    /**
     * SEARCH  /_search/role-extras?query=:query : search for the roleExtra corresponding
     * to the query.
     *
     * @param query the query of the roleExtra search
     * @param pageable the pagination information
     * @return the result of the search
     */
    @GetMapping("/_search/role-extras")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER_ROLE+DOT+READ+"')")
    public ResponseEntity<List<RoleExtra>> searchRoleExtras(@RequestParam String query, Pageable pageable) {
        log.debug("REST request to search for a page of RoleExtras for query {}", query);
        Page<RoleExtra> page = roleExtraSearchRepository.search(queryStringQuery(query), pageable);
        HttpHeaders headers = PaginationUtil.generateSearchPaginationHttpHeaders(query, page, "/api/_search/role-extras");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }

}
