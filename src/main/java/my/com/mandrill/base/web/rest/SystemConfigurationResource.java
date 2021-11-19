package my.com.mandrill.base.web.rest;

import com.codahale.metrics.annotation.Timed;

import my.com.mandrill.base.config.audit.AuditActionService;
import my.com.mandrill.base.config.audit.AuditActionType;
import my.com.mandrill.base.domain.SystemConfiguration;

import my.com.mandrill.base.repository.SystemConfigurationRepository;
import my.com.mandrill.base.repository.search.SystemConfigurationSearchRepository;
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
 * REST controller for managing SystemConfiguration.
 */
@RestController
@RequestMapping("/api")
public class SystemConfigurationResource {

    private final Logger log = LoggerFactory.getLogger(SystemConfigurationResource.class);

    private static final String ENTITY_NAME = "systemConfiguration";

    private final SystemConfigurationRepository systemConfigurationRepository;

    private final SystemConfigurationSearchRepository systemConfigurationSearchRepository;
    
    private final AuditActionService auditActionService;

    public SystemConfigurationResource(SystemConfigurationRepository systemConfigurationRepository, SystemConfigurationSearchRepository systemConfigurationSearchRepository,
    		AuditActionService auditActionService) {
        this.systemConfigurationRepository = systemConfigurationRepository;
        this.systemConfigurationSearchRepository = systemConfigurationSearchRepository;
        this.auditActionService = auditActionService;
    }

    /**
     * POST  /system-configurations : Create a new systemConfiguration.
     *
     * @param systemConfiguration the systemConfiguration to create
     * @return the ResponseEntity with status 201 (Created) and with body the new systemConfiguration, or with status 400 (Bad Request) if the systemConfiguration has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/system-configurations")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_SYSTEM_CONFIGURATION+DOT+CREATE+"')")
    public ResponseEntity<SystemConfiguration> createSystemConfiguration(@Valid @RequestBody SystemConfiguration systemConfiguration) throws URISyntaxException {
        log.debug("REST request to save SystemConfiguration : {}", systemConfiguration);
		if (systemConfiguration.getId() != null) {
			throw new BadRequestAlertException("A new systemConfiguration cannot already have an ID", ENTITY_NAME,
					"idexists");
		}
		try {
			SystemConfiguration result = systemConfigurationRepository.save(systemConfiguration);
			systemConfigurationSearchRepository.save(result);
			auditActionService.addSuccessEvent(AuditActionType.SYSTEM_CONFIGURATION_CREATE,
					systemConfiguration.getName());
			return ResponseEntity.created(new URI("/api/system-configurations/" + result.getId()))
					.headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString())).body(result);
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.SYSTEM_CONFIGURATION_CREATE,
					systemConfiguration.getName(), e);
			throw e;
		}
    }

    /**
     * PUT  /system-configurations : Updates an existing systemConfiguration.
     *
     * @param systemConfiguration the systemConfiguration to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated systemConfiguration,
     * or with status 400 (Bad Request) if the systemConfiguration is not valid,
     * or with status 500 (Internal Server Error) if the systemConfiguration couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/system-configurations")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_SYSTEM_CONFIGURATION+DOT+UPDATE+"')")
    public ResponseEntity<SystemConfiguration> updateSystemConfiguration(@Valid @RequestBody SystemConfiguration systemConfiguration) throws URISyntaxException {
        log.debug("REST request to update SystemConfiguration : {}", systemConfiguration);
        if (systemConfiguration.getId() == null) {
            return createSystemConfiguration(systemConfiguration);
        }
		try {
			SystemConfiguration result = systemConfigurationRepository.save(systemConfiguration);
			systemConfigurationSearchRepository.save(result);
			auditActionService.addSuccessEvent(AuditActionType.SYSTEM_CONFIGURATION_UPDATE,
					systemConfiguration.getName());
			return ResponseEntity.ok()
					.headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, systemConfiguration.getId().toString()))
					.body(result);
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.SYSTEM_CONFIGURATION_UPDATE,
					systemConfiguration.getName(), e);
			throw e;
		}
    }

    /**
     * GET  /system-configurations : get all the systemConfigurations.
     *
     * @param pageable the pagination information
     * @return the ResponseEntity with status 200 (OK) and the list of systemConfigurations in body
     */
    @GetMapping("/system-configurations")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_SYSTEM_CONFIGURATION+DOT+READ+"')")
    public ResponseEntity<List<SystemConfiguration>> getAllSystemConfigurations(Pageable pageable) {
        log.debug("REST request to get a page of SystemConfigurations");
        Page<SystemConfiguration> page = systemConfigurationRepository.findAll(pageable);
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/system-configurations");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }

    /**
     * GET  /system-configurations/:id : get the "id" systemConfiguration.
     *
     * @param id the id of the systemConfiguration to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the systemConfiguration, or with status 404 (Not Found)
     */
    @GetMapping("/system-configurations/{id}")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_SYSTEM_CONFIGURATION+DOT+READ+"')")
    public ResponseEntity<SystemConfiguration> getSystemConfiguration(@PathVariable Long id) {
        log.debug("REST request to get SystemConfiguration : {}", id);
        SystemConfiguration systemConfiguration = systemConfigurationRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(systemConfiguration));
    }

    /**
     * DELETE  /system-configurations/:id : delete the "id" systemConfiguration.
     *
     * @param id the id of the systemConfiguration to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/system-configurations/{id}")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_SYSTEM_CONFIGURATION+DOT+DELETE+"')")
    public ResponseEntity<Void> deleteSystemConfiguration(@PathVariable Long id) {
        log.debug("REST request to delete SystemConfiguration : {}", id);
		try {
			systemConfigurationRepository.delete(id);
			systemConfigurationSearchRepository.delete(id);
			auditActionService.addSuccessEvent(AuditActionType.SYSTEM_CONFIGURATION_DELETE,
					id.toString());
			return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString()))
					.build();
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.SYSTEM_CONFIGURATION_DELETE,
					id.toString(), e);
			throw e;
		}
    }

    /**
     * SEARCH  /_search/system-configurations?query=:query : search for the systemConfiguration corresponding
     * to the query.
     *
     * @param query the query of the systemConfiguration search
     * @param pageable the pagination information
     * @return the result of the search
     */
    @GetMapping("/_search/system-configurations")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_SYSTEM_CONFIGURATION+DOT+READ+"')")
    public ResponseEntity<List<SystemConfiguration>> searchSystemConfigurations(@RequestParam String query, Pageable pageable) {
        log.debug("REST request to search for a page of SystemConfigurations for query {}", query);
        Page<SystemConfiguration> page = systemConfigurationSearchRepository.search(queryStringQuery(query), pageable);
        HttpHeaders headers = PaginationUtil.generateSearchPaginationHttpHeaders(query, page, "/api/_search/system-configurations");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }
    
    @GetMapping("/system-configurations-by-name/{name}")
    @Timed
    public ResponseEntity<SystemConfiguration> getSystemConfiguration(@PathVariable String name) {
        log.debug("REST request to get SystemConfiguration by Name : {}", name);
        SystemConfiguration systemConfiguration = systemConfigurationRepository.findByName(name);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(systemConfiguration));
    }


}
