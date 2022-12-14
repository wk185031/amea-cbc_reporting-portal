package my.com.mandrill.base.web.rest;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.CREATE;
import static my.com.mandrill.base.service.AppPermissionService.DELETE;
import static my.com.mandrill.base.service.AppPermissionService.DOT;
import static my.com.mandrill.base.service.AppPermissionService.OPER;
import static my.com.mandrill.base.service.AppPermissionService.READ;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_USER;
import static my.com.mandrill.base.service.AppPermissionService.UPDATE;
import static org.elasticsearch.index.query.QueryBuilders.queryStringQuery;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.function.Predicate;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.CacheManager;
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
import my.com.mandrill.base.domain.Authority;
import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.domain.User;
import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.repository.AuthorityRepository;
import my.com.mandrill.base.repository.UserExtraRepository;
import my.com.mandrill.base.repository.UserRepository;
import my.com.mandrill.base.repository.search.UserExtraSearchRepository;
import my.com.mandrill.base.security.AuthoritiesConstants;
import my.com.mandrill.base.service.MailService;
import my.com.mandrill.base.service.UserService;
import my.com.mandrill.base.service.dto.UserDTO;
import my.com.mandrill.base.web.rest.errors.BadRequestAlertException;
import my.com.mandrill.base.web.rest.util.HeaderUtil;
import my.com.mandrill.base.web.rest.util.PaginationUtil;


/**
 * REST controller for managing UserExtra.
 */
@RestController
@RequestMapping("/api")
public class UserExtraResource {

    private final Logger log = LoggerFactory.getLogger(UserExtraResource.class);

    private static final String ENTITY_NAME = "userExtra";

    private final UserExtraRepository userExtraRepository;

    private final UserExtraSearchRepository userExtraSearchRepository;
    
    private final UserRepository userRepository;
    
    private final AuthorityRepository authorityRepository;
    
    private final UserService userService;
    
    private final MailService mailService;
    
    private final AuditActionService auditActionService;
    
    private final CacheManager cacheManager;

    public UserExtraResource(UserExtraRepository userExtraRepository,
    		UserExtraSearchRepository userExtraSearchRepository,
    		UserRepository userRepository,
    		AuthorityRepository authorityRepository,
    		UserService userService,
    		MailService mailService,
    		AuditActionService auditActionService,
    		CacheManager cacheManager) {
        this.userExtraRepository = userExtraRepository;
        this.userExtraSearchRepository = userExtraSearchRepository;
        this.userRepository = userRepository;
        this.authorityRepository = authorityRepository;
        this.userService = userService;
        this.mailService = mailService;
        this.auditActionService = auditActionService;
        this.cacheManager = cacheManager;
    }

    /**
     * POST  /user-extras : Create a new userExtra.
     *
     * @param userExtra the userExtra to create
     * @return the ResponseEntity with status 201 (Created) and with body the new userExtra, or with status 400 (Bad Request) if the userExtra has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/user-extras")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER+DOT+CREATE+"')")
    public ResponseEntity<UserExtra> createUserExtra(@Valid @RequestBody UserExtra userExtra, HttpServletRequest request) throws URISyntaxException {
        log.debug("REST request to save UserExtra : {}", userExtra);
        if (userExtra.getId() != null) {
            throw new BadRequestAlertException("A new userExtra cannot already have an ID", ENTITY_NAME, "idexists");
        }
        
        User pseudoUser = userExtra.getUser();
		try {

			if (userRepository.findOneByLogin(pseudoUser.getLogin().toLowerCase()).isPresent()) {
				return ResponseEntity.badRequest()
						.headers(HeaderUtil.createFailureAlert(ENTITY_NAME, "userexists", "Login already in use"))
						.body(null);
			}

			if (userRepository.findOneByEmailIgnoreCase(pseudoUser.getEmail()).isPresent()) {
				return ResponseEntity.badRequest()
						.headers(HeaderUtil.createFailureAlert(ENTITY_NAME, "emailexists", "Email already in use"))
						.body(null);
			}
			
			for (Iterator<Branch> i = userExtra.getBranches().iterator(); i.hasNext();) {
				Branch b = i.next();
				if (b.getAbr_code() == null || b.getAbr_code().trim().isEmpty()) {
					i.remove();
				}
			}

			Authority userAuthority = authorityRepository.findOne(AuthoritiesConstants.USER);
			Set<Authority> authoritySet = new HashSet<>();
			authoritySet.add(userAuthority);

			pseudoUser.setAuthorities(authoritySet);
			User savedUser = userService.createUser(new UserDTO(pseudoUser));

			userExtra.setUser(savedUser);
			UserExtra result = userExtraRepository.save(userExtra);
			mailService.sendCreationEmail(savedUser);
			userExtraSearchRepository.save(result);
			auditActionService.addSuccessEvent(AuditActionType.USER_CREATE, userExtra.getName(), request);
			return ResponseEntity.created(new URI("/api/user-extras/" + result.getId()))
					.headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString())).body(result);
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.USER_CREATE, userExtra.getName(), e, request);
			throw e;
		}
    }

    /**
     * PUT  /user-extras : Updates an existing userExtra.
     *
     * @param userExtra the userExtra to update
     * @return the ResponseEntity with status 200 (OK) and with body the updated userExtra,
     * or with status 400 (Bad Request) if the userExtra is not valid,
     * or with status 500 (Internal Server Error) if the userExtra couldn't be updated
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PutMapping("/user-extras")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER+DOT+UPDATE+"')")
    public ResponseEntity<UserExtra> updateUserExtra(@Valid @RequestBody UserExtra userExtra, HttpServletRequest request) throws URISyntaxException {
        log.debug("REST request to update UserExtra : {}", userExtra);
                
        if (userExtra.getId() == null) {
            return createUserExtra(userExtra, request);
        } else {
        	UserExtra usrExtra = userExtraRepository.findOne(userExtra.getId());
        	userExtra.setCreatedDate(usrExtra.getCreatedDate());
        }

        UserExtra oldClone = org.apache.commons.lang3.SerializationUtils
				.clone(userExtraRepository.findOne(userExtra.getId()));
        User user = userRepository.findOne(userExtra.getUser().getId());
        
		try {

			Authority userAuthority = authorityRepository.findOne(AuthoritiesConstants.USER);
			Set<Authority> authoritySet = new HashSet<>();
			authoritySet.add(userAuthority);
			userExtra.getUser().setAuthorities(authoritySet);
			
			Predicate<Branch> isAllBranchFilter = item -> item.getAbr_code() == null || item.getAbr_code().isEmpty();	
			userExtra.getBranches().removeIf(isAllBranchFilter);
						
			user.setEmail(userExtra.getUser().getEmail());
			user.setActivated(userExtra.getUser().getActivated());
			userRepository.save(user);
			UserExtra result = userExtraRepository.save(userExtra);
			userExtraSearchRepository.save(result);
			cacheManager.getCache(UserRepository.USERS_BY_LOGIN_CACHE).evict(user.getLogin());
			cacheManager.getCache(UserRepository.USERS_BY_EMAIL_CACHE).evict(user.getEmail());
			auditActionService.addSuccessEvent(AuditActionType.USER_UPDATE, oldClone, result, request);

			return ResponseEntity.ok()
					.headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, userExtra.getId().toString()))
					.body(result);
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.USER_UPDATE, userExtra.getName(), e, request);
			throw e;
		}
    }

    /**
     * GET  /user-extras : get all the userExtras.
     *
     * @param pageable the pagination information
     * @return the ResponseEntity with status 200 (OK) and the list of userExtras in body
     */
    @GetMapping("/user-extras-pagination")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER+DOT+READ+"')")
    public ResponseEntity<List<UserExtra>> getAllUserExtrasPagination(Pageable pageable) {
        log.debug("REST request to get a page of UserExtras");
        Page<UserExtra> page = userExtraRepository.findAll(pageable);
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/user-extras");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }
    
    @GetMapping("/user-extras")
    @Timed
    public List<UserExtra> getAllUserExtras() {
        log.debug("REST request to get All UserExtras");
        List<UserExtra> userExtras = userExtraRepository.findAll();
        //Todo filter with institution
        return userExtras;
    }

    /**
     * GET  /user-extras/:id : get the "id" userExtra.
     *
     * @param id the id of the userExtra to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the userExtra, or with status 404 (Not Found)
     */
    @GetMapping("/user-extras/{id}")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER+DOT+READ+"')")
    public ResponseEntity<UserExtra> getUserExtra(@PathVariable Long id) {
        log.debug("REST request to get UserExtra : {}", id);
        UserExtra userExtra = userExtraRepository.findOneWithEagerRelationships(id);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(userExtra));
    }

    /**
     * DELETE  /user-extras/:id : delete the "id" userExtra.
     *
     * @param id the id of the userExtra to delete
     * @return the ResponseEntity with status 200 (OK)
     */
    @DeleteMapping("/user-extras/{id}")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER+DOT+DELETE+"')")
	public ResponseEntity<Void> deleteUserExtra(@PathVariable Long id, HttpServletRequest request) {
		log.debug("REST request to delete UserExtra : {}", id);
		UserExtra userExtra = userExtraRepository.findOneWithEagerRelationships(id);

		try {
			userExtraRepository.delete(id);
			userExtraSearchRepository.delete(id);
			userService.deleteUser(userExtra.getUser().getLogin());
			auditActionService.addSuccessEvent(AuditActionType.USER_DELETE, userExtra.getName(), request);
			return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString()))
					.build();
		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.USER_DELETE, userExtra != null ? userExtra.getName() : id.toString(), e, request);
			throw e;
		}
	}

    /**
     * SEARCH  /_search/user-extras?query=:query : search for the userExtra corresponding
     * to the query.
     *
     * @param query the query of the userExtra search
     * @param pageable the pagination information
     * @return the result of the search
     */
    @GetMapping("/_search/user-extras")
    @Timed
    @PreAuthorize("@AppPermissionService.hasPermission('"+OPER+COLON+RESOURCE_USER+DOT+READ+"')")
    public ResponseEntity<List<UserExtra>> searchUserExtras(@RequestParam String query, Pageable pageable) {
        log.debug("REST request to search for a page of UserExtras for query {}", query);
        
        Page<UserExtra> page = userExtraRepository.findByUserLoginContaining(query, pageable);

        HttpHeaders headers = PaginationUtil.generateSearchPaginationHttpHeaders(query, page, "/api/_search/user-extras");
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }
    
    @GetMapping("/{institutionId}/user-extras-by-roles/{rolesName}")
    @Timed
    public ResponseEntity<List<UserExtra>> getUserExtrasByRoles(@PathVariable String rolesName, @PathVariable Long institutionId) {
        log.debug("REST request to get UserExtras by Roles: {}, institution Id: {}", rolesName, institutionId);
        final List<UserExtra> userExtra = new ArrayList<>();
        userExtra.addAll(userExtraRepository.findByRolesAndInstituionId(rolesName, institutionId));
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(userExtra));
    }
   
    @GetMapping("/user-extras-by-user/{userId}")
    @Timed
    public ResponseEntity<UserExtra> getUserExtrasByUser(@PathVariable Long userId) {
        log.debug("REST request to get UserExtras by User: {}", userId);
        UserExtra userExtra = userExtraRepository.findByUser(userId);
        return ResponseUtil.wrapOrNotFound(Optional.ofNullable(userExtra));
    }
}
