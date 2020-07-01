package my.com.mandrill.base.web.rest;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.DOT;
import static my.com.mandrill.base.service.AppPermissionService.OPER;
import static my.com.mandrill.base.service.AppPermissionService.READ;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_BRANCH;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_USER_ROLE;
import static org.elasticsearch.index.query.QueryBuilders.queryStringQuery;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.codahale.metrics.annotation.Timed;

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.repository.BranchRepository;
import my.com.mandrill.base.repository.search.BranchSearchRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.service.AppService;
import my.com.mandrill.base.web.rest.util.PaginationUtil;

/**
 * REST controller for managing Branch.
 */
@RestController
@RequestMapping("/api")
public class BranchResource {

    private final Logger log = LoggerFactory.getLogger(BranchResource.class);

    private final BranchRepository branchRepository;

    private final BranchSearchRepository branchSearchRepository;
    
    private final AppService appService;

    public BranchResource(BranchRepository branchRepository, 
    		BranchSearchRepository branchSearchRepository, 
    		AppService appService) {
        this.branchRepository = branchRepository;
        this.branchSearchRepository = branchSearchRepository;
        this.appService = appService;
    }

    /**
     * GET  /branches : get all the branches.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of branches in body
     */
    @GetMapping("/branches")
    @Timed
    public List<Branch> getAllBranches() {
        log.debug("REST request to get all Branches");
        return branchRepository.findAll();
        }

    /**
     * GET  /branches/:id : get the "id" branch.
     *
     * @param id the id of the branch to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the branch, or with status 404 (Not Found)
     */
    @GetMapping("/branches/{id}")
    @Timed
    public ResponseEntity<Branch> getBranch(@PathVariable Long id) {
        log.debug("REST request to get Branch : {}", id);
        Branch branch = branchRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(branch));
    }
    
    @GetMapping("/branches-pagination")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_BRANCH+DOT+READ+"')")
    public ResponseEntity<List<Branch>> getAllBranchesPagination(Pageable pageable) {
        log.debug("REST request to get a page of Branches");
        Page<Branch> page = branchRepository.findAll(pageable);
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/branches");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }
    
    @GetMapping("/_search/branches")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_BRANCH+DOT+READ+"')")
    public ResponseEntity<List<Branch>> searchBranches(@RequestParam String query, Pageable pageable) {
        log.debug("REST request to search for a page of Branches for query {}", query);
        Page<Branch> page = branchSearchRepository.search(queryStringQuery(query), pageable);
        HttpHeaders headers = PaginationUtil.generateSearchPaginationHttpHeaders(query, page, "/api/_search/branches");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }
    
    @GetMapping("/branches-for-user")
    @Timed
    public List<Branch> getBranchForUser() {
        log.debug("REST request to get Branches for user");
        String username = SecurityUtils.getCurrentUserLogin().orElse("");
        List<Branch> companyBranches = new ArrayList<>();
        if (username != null) {
        	companyBranches.addAll(appService.getAllBranchWithChildsOfUser(username));
        }
        return companyBranches;
    }
}
