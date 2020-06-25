package my.com.mandrill.base.web.rest;

import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.codahale.metrics.annotation.Timed;

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.repository.BranchRepository;

/**
 * REST controller for managing Branch.
 */
@RestController
@RequestMapping("/api")
public class BranchResource {

    private final Logger log = LoggerFactory.getLogger(BranchResource.class);

    private final BranchRepository branchRepository;

    public BranchResource(BranchRepository branchRepository) {
        this.branchRepository = branchRepository;
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

}
