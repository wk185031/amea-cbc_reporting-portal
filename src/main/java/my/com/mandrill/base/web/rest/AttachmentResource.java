package my.com.mandrill.base.web.rest;

import com.codahale.metrics.annotation.Timed;
import my.com.mandrill.base.domain.Attachment;

import my.com.mandrill.base.repository.AttachmentRepository;
import my.com.mandrill.base.repository.search.AttachmentSearchRepository;
import my.com.mandrill.base.service.AttachmentService;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import io.github.jhipster.web.util.ResponseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.imageio.ImageIO;
import javax.validation.Valid;
import org.apache.commons.io.FileUtils;
import java.awt.*;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import java.util.Base64;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static org.elasticsearch.index.query.QueryBuilders.*;

/**
 * REST controller for managing Attachment.
 */
@RestController
@RequestMapping("/api")
public class AttachmentResource {

    private final Logger log = LoggerFactory.getLogger(AttachmentResource.class);

    private static final String ENTITY_NAME = "attachment";
    private static final String FOLDER_NAME = "attachment";
    private static final String SMALL_SUFFIX = "-small";

    private final AttachmentRepository attachmentRepository;

    private final AttachmentSearchRepository attachmentSearchRepository;
    private final AttachmentService attachmentService;

    public AttachmentResource(AttachmentRepository attachmentRepository, AttachmentSearchRepository attachmentSearchRepository,
                                AttachmentService attachmentService) {
        this.attachmentRepository = attachmentRepository;
        this.attachmentSearchRepository = attachmentSearchRepository;
        this.attachmentService = attachmentService;
    }

    /**
     * POST  /attachments : Create a new attachment.
     *
     * @param attachment the attachment to create
     * @return the ResponseEntity with status 201 (Created) and with body the new attachment, or with status 400 (Bad Request) if the attachment has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/attachments")
    @Timed
    public ResponseEntity<Attachment> createAttachment(@Valid @RequestBody Attachment attachment) throws URISyntaxException {
        log.debug("REST request to save Attachment : {}", attachment);
        if (attachment.getId() != null) {
            throw new BadRequestAlertException("A new attachment cannot already have an ID", ENTITY_NAME, "idexists");
        }
        Attachment result = attachmentRepository.save(attachment);
        attachmentSearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/attachments/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
    }

    /**
     * PUT  /attachments : Updates an existing attachment.
     *
     * @param attachment the attachment to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated attachment,
     * or with status 400 (Bad Request) if the attachment is not valid,
     * or with status 500 (Internal Server Error) if the attachment couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/attachments")
    @Timed
    public ResponseEntity<Attachment> updateAttachment(@Valid @RequestBody Attachment attachment) throws URISyntaxException {
        log.debug("REST request to update Attachment : {}", attachment);
        if (attachment.getId() == null) {
            return createAttachment(attachment);
        }
        Attachment result = attachmentRepository.save(attachment);
        attachmentSearchRepository.save(result);
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, attachment.getId().toString()))
            .body(result);
    }

    /**
     * GET  /attachments : get all the attachments.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of attachments in body
     */
    @GetMapping("/attachments")
    @Timed
    public List<Attachment> getAllAttachments() {
        log.debug("REST request to get all Attachments");
        return attachmentRepository.findAll();
        }

    /**
     * GET  /attachments/:id : get the "id" attachment.
     *
     * @param id the id of the attachment to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the attachment, or with status 404 (Not Found)
     */
    @GetMapping("/attachments/{id}")
    @Timed
    public ResponseEntity<Attachment> getAttachment(@PathVariable Long id) {
        log.debug("REST request to get Attachment : {}", id);
        Attachment attachment = attachmentRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(attachment));
    }

    /**
     * DELETE  /attachments/:id : delete the "id" attachment.
     *
     * @param id the id of the attachment to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/attachments/{id}")
    @Timed
    public ResponseEntity<Void> deleteAttachment(@PathVariable Long id) {
        log.debug("REST request to delete Attachment : {}", id);
        attachmentRepository.delete(id);
        attachmentSearchRepository.delete(id);
        return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
    }

    /**
     * SEARCH  /_search/attachments?query=:query : search for the attachment corresponding
     * to the query.
     *
     * @param query the query of the attachment search
     * @return the result of the search
     */
    @GetMapping("/_search/attachments")
    @Timed
    public List<Attachment> searchAttachments(@RequestParam String query) {
        log.debug("REST request to search Attachments for query {}", query);
        return StreamSupport
            .stream(attachmentSearchRepository.search(queryStringQuery(query)).spliterator(), false)
            .collect(Collectors.toList());
    }

    /**
     * POST  /attachments : Create multiple new attachment.
     *
     * @param attachments the attachment to create
     * @return the ResponseEntity with status 201 (Created) and with body the new attachment, or with status 400 (Bad Request) if the attachment has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/attachments-multiple")
    @Timed
    public ResponseEntity<List<Attachment>> createAttachments(@Valid @RequestBody List<Attachment> attachments) throws URISyntaxException {
        log.debug("REST request to save Attachments : {}", attachments);
        for(Attachment attachment: attachments){
            if (attachment.getId() != null) {
                throw new BadRequestAlertException("A new attachment cannot already have an ID", ENTITY_NAME, "idexists");
            }

            if(attachment.getBlobFile()!=null){
                try {
                    attachment.setName(attachment.getName()+".jpeg");
                    attachmentService.writeImageFiles(attachment);
                } catch (Exception e) {
                    log.error("Error whhile writing the image files", e);
                    return ResponseEntity.badRequest().headers(HeaderUtil.createFailureAlert(ENTITY_NAME, "filename", "Failed to upload")).body(null);
                }
            }
        }
        List<Attachment> result = attachmentRepository.save(attachments);
        attachmentSearchRepository.save(result);
        return ResponseEntity.ok().body(result);
    }

    @GetMapping("/attachments-by-attachment-group/{attachmentGroupId}")
    @Timed
    public ResponseEntity<List<Attachment>> getAttachmentsByAttachmentGroupId(@PathVariable Long attachmentGroupId) {
        log.debug("REST request to get Attachment by Attachment Group Id : {}", attachmentGroupId);
        List<Attachment> attachments = attachmentRepository.findByAttachmentGroupId(attachmentGroupId);
        for(Attachment attachment: attachments){
            String path = attachmentService.getNewFolderPath(attachment) + attachment.getName();
            try {
                byte[] fileContent = FileUtils.readFileToByteArray(new File(path));
                attachment.setBlobFile(Base64.getEncoder().encodeToString(fileContent));
            } catch (IOException e) {
                log.error(e.getMessage());
            }
        }
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(attachments));
    }
}
