package my.com.mandrill.base.web.rest;

import com.codahale.metrics.annotation.Timed;
import my.com.mandrill.base.domain.AttachmentGroup;

import my.com.mandrill.base.repository.AttachmentGroupRepository;
import my.com.mandrill.base.repository.search.AttachmentGroupSearchRepository;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import io.github.jhipster.web.util.ResponseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.net.URI;
import java.net.URISyntaxException;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static org.elasticsearch.index.query.QueryBuilders.*;

/**
 * REST controller for managing AttachmentGroup.
 */
@RestController
@RequestMapping("/api")
public class AttachmentGroupResource {

    private final Logger log = LoggerFactory.getLogger(AttachmentGroupResource.class);

    private static final String ENTITY_NAME = "attachmentGroup";

    private final AttachmentGroupRepository attachmentGroupRepository;

    private final AttachmentGroupSearchRepository attachmentGroupSearchRepository;

    public AttachmentGroupResource(AttachmentGroupRepository attachmentGroupRepository, AttachmentGroupSearchRepository attachmentGroupSearchRepository) {
        this.attachmentGroupRepository = attachmentGroupRepository;
        this.attachmentGroupSearchRepository = attachmentGroupSearchRepository;
    }

    /**
     * POST  /attachment-groups : Create a new attachmentGroup.
     *
     * @param attachmentGroup the attachmentGroup to create
     * @return the ResponseEntity with status 201 (Created) and with body the new attachmentGroup, or with status 400 (Bad Request) if the attachmentGroup has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/attachment-groups")
    @Timed
    public ResponseEntity<AttachmentGroup> createAttachmentGroup(@Valid @RequestBody AttachmentGroup attachmentGroup) throws URISyntaxException {
        log.debug("REST request to save AttachmentGroup : {}", attachmentGroup);
        if (attachmentGroup.getId() != null) {
            throw new BadRequestAlertException("A new attachmentGroup cannot already have an ID", ENTITY_NAME, "idexists");
        }
        AttachmentGroup result = attachmentGroupRepository.save(attachmentGroup);
        attachmentGroupSearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/attachment-groups/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
    }

    /**
     * PUT  /attachment-groups : Updates an existing attachmentGroup.
     *
     * @param attachmentGroup the attachmentGroup to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated attachmentGroup,
     * or with status 400 (Bad Request) if the attachmentGroup is not valid,
     * or with status 500 (Internal Server Error) if the attachmentGroup couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/attachment-groups")
    @Timed
    public ResponseEntity<AttachmentGroup> updateAttachmentGroup(@Valid @RequestBody AttachmentGroup attachmentGroup) throws URISyntaxException {
        log.debug("REST request to update AttachmentGroup : {}", attachmentGroup);
        if (attachmentGroup.getId() == null) {
            return createAttachmentGroup(attachmentGroup);
        }
        AttachmentGroup result = attachmentGroupRepository.save(attachmentGroup);
        attachmentGroupSearchRepository.save(result);
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, attachmentGroup.getId().toString()))
            .body(result);
    }

    /**
     * GET  /attachment-groups : get all the attachmentGroups.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of attachmentGroups in body
     */
    @GetMapping("/attachment-groups")
    @Timed
    public List<AttachmentGroup> getAllAttachmentGroups() {
        log.debug("REST request to get all AttachmentGroups");
        return attachmentGroupRepository.findAll();
        }

    /**
     * GET  /attachment-groups/:id : get the "id" attachmentGroup.
     *
     * @param id the id of the attachmentGroup to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the attachmentGroup, or with status 404 (Not Found)
     */
    @GetMapping("/attachment-groups/{id}")
    @Timed
    public ResponseEntity<AttachmentGroup> getAttachmentGroup(@PathVariable Long id) {
        log.debug("REST request to get AttachmentGroup : {}", id);
        AttachmentGroup attachmentGroup = attachmentGroupRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(attachmentGroup));
    }

    /**
     * DELETE  /attachment-groups/:id : delete the "id" attachmentGroup.
     *
     * @param id the id of the attachmentGroup to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/attachment-groups/{id}")
    @Timed
    public ResponseEntity<Void> deleteAttachmentGroup(@PathVariable Long id) {
        log.debug("REST request to delete AttachmentGroup : {}", id);
        attachmentGroupRepository.delete(id);
        attachmentGroupSearchRepository.delete(id);
        return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
    }

    /**
     * SEARCH  /_search/attachment-groups?query=:query : search for the attachmentGroup corresponding
     * to the query.
     *
     * @param query the query of the attachmentGroup search
     * @return the result of the search
     */
    @GetMapping("/_search/attachment-groups")
    @Timed
    public List<AttachmentGroup> searchAttachmentGroups(@RequestParam String query) {
        log.debug("REST request to search AttachmentGroups for query {}", query);
        return StreamSupport
            .stream(attachmentGroupSearchRepository.search(queryStringQuery(query)).spliterator(), false)
            .collect(Collectors.toList());
    }

}
