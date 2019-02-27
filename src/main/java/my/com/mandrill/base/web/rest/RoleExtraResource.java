package my.com.mandrill.base.web.rest;

import com.codahale.metrics.annotation.Timed;
import my.com.mandrill.base.domain.RoleExtra;

import my.com.mandrill.base.repository.RoleExtraRepository;
import my.com.mandrill.base.repository.search.RoleExtraSearchRepository;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import my.com.mandrill.base.web.rest.util.PaginationUtil;
import io.github.jhipster.web.util.ResponseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.net.URI;
import java.net.URISyntaxException;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static my.com.mandrill.base.service.AppPermissionService.*;
import static org.elasticsearch.index.query.QueryBuilders.*;

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

    public RoleExtraResource(RoleExtraRepository roleExtraRepository, RoleExtraSearchRepository roleExtraSearchRepository) {
        this.roleExtraRepository = roleExtraRepository;
        this.roleExtraSearchRepository = roleExtraSearchRepository;
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
    public ResponseEntity<RoleExtra> createRoleExtra(@Valid @RequestBody RoleExtra roleExtra) throws URISyntaxException {
        log.debug("REST request to save RoleExtra : {}", roleExtra);
        if (roleExtra.getId() != null) {
            throw new BadRequestAlertException("A new roleExtra cannot already have an ID", ENTITY_NAME, "idexists");
        }
        RoleExtra result = roleExtraRepository.save(roleExtra);
        roleExtraSearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/role-extras/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
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
    public ResponseEntity<RoleExtra> updateRoleExtra(@Valid @RequestBody RoleExtra roleExtra) throws URISyntaxException {
        log.debug("REST request to update RoleExtra : {}", roleExtra);
        if (roleExtra.getId() == null) {
            return createRoleExtra(roleExtra);
        }
        RoleExtra result = roleExtraRepository.save(roleExtra);
        roleExtraSearchRepository.save(result);
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, roleExtra.getId().toString()))
            .body(result);
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
    public ResponseEntity<Void> deleteRoleExtra(@PathVariable Long id) {
        log.debug("REST request to delete RoleExtra : {}", id);
        roleExtraRepository.delete(id);
        roleExtraSearchRepository.delete(id);
        return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
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
