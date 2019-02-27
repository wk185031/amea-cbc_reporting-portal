package my.com.mandrill.base.web.rest;

import com.codahale.metrics.annotation.Timed;
import my.com.mandrill.base.domain.AppResource;
import my.com.mandrill.base.domain.AppResourceDto;
import my.com.mandrill.base.domain.RoleExtra;
import my.com.mandrill.base.repository.AppResourceRepository;
import my.com.mandrill.base.repository.RoleExtraRepository;
import my.com.mandrill.base.repository.search.AppResourceSearchRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.service.AppService;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import io.github.jhipster.web.util.ResponseUtil;

import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static org.elasticsearch.index.query.QueryBuilders.*;
import static my.com.mandrill.base.service.AppPermissionService.*;

/**
 * REST controller for managing AppResource.
 */
@RestController
@RequestMapping("/api")
public class AppResourceResource {

    private final Logger log = LoggerFactory.getLogger(AppResourceResource.class);

    private static final String ENTITY_NAME = "appResource";

    private final AppResourceRepository appResourceRepository;

    private final AppResourceSearchRepository appResourceSearchRepository;

    private final RoleExtraRepository roleExtraRepository;
    
    private final AppService appService;
    
    public AppResourceResource(
    		AppResourceRepository appResourceRepository, 
    		AppResourceSearchRepository appResourceSearchRepository,
    		AppService appService,
    		RoleExtraRepository roleExtraRepository) {
        this.appResourceRepository = appResourceRepository;
        this.appResourceSearchRepository = appResourceSearchRepository;
        this.appService = appService;
        this.roleExtraRepository = roleExtraRepository;
    }

    /**
     * POST  /app-resources : Create a new appResource.
     *
     * @param appResource the appResource to create
     * @return the ResponseEntity with status 201 (Created) and with body the new appResource, or with status 400 (Bad Request) if the appResource has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/app-resources")
    @Timed
    public ResponseEntity<AppResource> createAppResource(@Valid @RequestBody AppResource appResource) throws URISyntaxException {
        log.debug("REST request to save AppResource : {}", appResource);
        if (appResource.getId() != null) {
            throw new BadRequestAlertException("A new appResource cannot already have an ID", ENTITY_NAME, "idexists");
        }
        AppResource result = appResourceRepository.save(appResource);
        appResourceSearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/app-resources/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
    }

    /**
     * PUT  /app-resources : Updates an existing appResource.
     *
     * @param appResource the appResource to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated appResource,
     * or with status 400 (Bad Request) if the appResource is not valid,
     * or with status 500 (Internal Server Error) if the appResource couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/app-resources")
    @Timed
    public ResponseEntity<AppResource> updateAppResource(@Valid @RequestBody AppResource appResource) throws URISyntaxException {
        log.debug("REST request to update AppResource : {}", appResource);
        if (appResource.getId() == null) {
            return createAppResource(appResource);
        }
        AppResource result = appResourceRepository.save(appResource);
        appResourceSearchRepository.save(result);
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, appResource.getId().toString()))
            .body(result);
    }

    /**
     * GET  /app-resources : get all the appResources.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of appResources in body
     */
    @GetMapping("/app-resources")
    @Timed
    public List<AppResource> getAllAppResources() {
        log.debug("REST request to get all AppResources");
        return appResourceRepository.findAll();
        }

    /**
     * GET  /app-resources/:id : get the "id" appResource.
     *
     * @param id the id of the appResource to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the appResource, or with status 404 (Not Found)
     */
    @GetMapping("/app-resources/{id}")
    @Timed
    public ResponseEntity<AppResource> getAppResource(@PathVariable Long id) {
        log.debug("REST request to get AppResource : {}", id);
        AppResource appResource = appResourceRepository.findOne(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(appResource));
    }

    /**
     * DELETE  /app-resources/:id : delete the "id" appResource.
     *
     * @param id the id of the appResource to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/app-resources/{id}")
    @Timed
    public ResponseEntity<Void> deleteAppResource(@PathVariable Long id) {
        log.debug("REST request to delete AppResource : {}", id);
        appResourceRepository.delete(id);
        appResourceSearchRepository.delete(id);
        return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
    }

    /**
     * SEARCH  /_search/app-resources?query=:query : search for the appResource corresponding
     * to the query.
     *
     * @param query the query of the appResource search
     * @return the result of the search
     */
    @GetMapping("/_search/app-resources")
    @Timed
    public List<AppResource> searchAppResources(@RequestParam String query) {
        log.debug("REST request to search AppResources for query {}", query);
        return StreamSupport
            .stream(appResourceSearchRepository.search(queryStringQuery(query)).spliterator(), false)
            .collect(Collectors.toList());
    }
    
    /**
     * GET  /app-resources-for-user : get all the permissions associated with the current user.
     *
     * @return the ResponseEntity with status 200 (OK) and the list of permissions in body
     */
    @GetMapping("/app-resources-for-user")
    @Timed
    public List<AppResource> getPermissionsForUser() {
        log.debug("REST request to get AppResources for user");
        Optional<String> user = SecurityUtils.getCurrentUserLogin();
        if (!user.isPresent()) {
        	log.info("User is not logged in");
        	return null;
        }
        String username = user.get();
        
        List<AppResource> permissions = new ArrayList<>();
        if (username != null) {
            permissions.addAll(appService.getPermissionsForUser(username));
        }
        return permissions;
    }

    @GetMapping("/app-resources/permission/{id}")
    @Timed
    public ResponseEntity<String> getPermission(@PathVariable Long id){
    	log.debug("REST request to get All AppResources by user extra {} ", id);
    	List<AppResource> all = appResourceRepository.findAll();
        List<AppResource> parents = all.stream().filter((resource) -> resource.getParent() == null).collect(Collectors.toList());
        List<AppResourceDto> permissions = new ArrayList<>();
        RoleExtra roleExtra = roleExtraRepository.findOne(id);
        Set<AppResource> permissionsAllowed = null;
        permissionsAllowed = (id.intValue() != 0) ? roleExtra.getPermissions(): new HashSet<>();
        for(AppResource parent: parents){
        	AppResourceDto resource = new AppResourceDto(parent, permissionsAllowed);
        	resource.setChildren(this.generateAppResource(parent.getId(), permissionsAllowed));
        	if (permissionsAllowed.contains(parent)) {
        		resource.setChecked(true);
        	} else {
        		resource.setChecked(false);
        	}
        	permissions.add(resource);
        }
        
        //Advanced checking
        for(AppResourceDto permission: permissions){
        	if(permission.getChildren() != null && permission.getChecked()){
        		this.assignIndeterminate(permission);
        	}
        }
        //Advanced checking
        
        //Set checked and indeterminate to false
        if(id.intValue() == 0){
        	for(AppResourceDto permission: permissions){
        		setAllCheckToFalse(permission);
        	}
        }
        JSONArray jsonStructures = new JSONArray();
        for(AppResourceDto permission : permissions){
            jsonStructures.put(new JSONObject(permission));
        }
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(jsonStructures.toString()));
    }
    
    public void setAllCheckToFalse(AppResourceDto ar){
		List<AppResourceDto> childs = ar.getChildren();
		if(childs != null){
			for(AppResourceDto child: childs){
				setAllCheckToFalse(child);
	    	}
		}
		ar.setChecked(false);
		ar.setIndeterminate(false);
    }
    
    public List<AppResourceDto> generateAppResource(Long id, Set<AppResource> permissionsAllowed){
    	List<AppResource> roots = appResourceRepository.findAllByParentId(id);
    	List<AppResourceDto> resource = new ArrayList<>();
    	for(AppResource ar: roots){
    		AppResourceDto arDTO = new AppResourceDto(ar, permissionsAllowed);
    		buildTree(arDTO, permissionsAllowed);
    		resource.add(arDTO);
    	}
    	return resource;
    }
    
    public boolean buildTree(AppResourceDto ar, Set<AppResource> permissionsAllowed){
        if(ar == null){
        	return true;
        }
        else{
        	List<AppResource> childs = appResourceRepository.findAllByParentId(ar.getId());
        	if(childs == null){
        		buildTree(null, null);
        	}
        	else{
        		log.info(ar.getName()+" . childs -> "+childs.size());
        		for(AppResource ch: childs){
        			AppResourceDto child = new AppResourceDto(ch, permissionsAllowed);
        			buildTree(child, permissionsAllowed);
        			ar.addChildren(child);
        		}
        	}
        }
        return false;
    }
    
    public boolean assignIndeterminate(AppResourceDto ar){
    	boolean containTrue = false;
    	boolean containFalse = false;
    	boolean containIndeterminate = false;
    	boolean indeterminate = false;
    	if(ar.getChildren() == null){
    		return ar.getChecked();
    	}
    	else{
    		List<AppResourceDto> childs = ar.getChildren();
    		for(AppResourceDto child: childs){
    			if(this.assignIndeterminate(child)){
    				if(child.getIndeterminate()){
    					containIndeterminate = true;
    				}
    				containTrue = true;
    			}
    			else{
    				containFalse = true;
    			}
    		}
    		//Mean every item checked
    		if(containTrue && containFalse){
    			indeterminate = true;
    		}
    		if(containTrue && !containFalse){
    			indeterminate = false;
    		}
    		if(!containTrue && containFalse){
    			indeterminate = false;
    		}
    		
    		if(containIndeterminate){
    			indeterminate = true;
    		}
    		ar.setIndeterminate(indeterminate);
    	}
    	//if the children not checked return checked;
    	//if the children checked, need to check is it having indeterminate
    	//if children having indeterminate set the parent indeterminate to true; 
    	//return the not indeterminate can assign the parent to indeterminate true
    	return ar.getChecked();
    }
}
