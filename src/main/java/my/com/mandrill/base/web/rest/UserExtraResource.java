package my.com.mandrill.base.web.rest;

import com.codahale.metrics.annotation.Timed;

import my.com.mandrill.base.domain.Authority;
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
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static my.com.mandrill.base.service.AppPermissionService.*;
import static org.elasticsearch.index.query.QueryBuilders.*;

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

    public UserExtraResource(UserExtraRepository userExtraRepository,
    		UserExtraSearchRepository userExtraSearchRepository,
    		UserRepository userRepository,
    		AuthorityRepository authorityRepository,
    		UserService userService,
    		MailService mailService) {
        this.userExtraRepository = userExtraRepository;
        this.userExtraSearchRepository = userExtraSearchRepository;
        this.userRepository = userRepository;
        this.authorityRepository = authorityRepository;
        this.userService = userService;
        this.mailService = mailService;
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
    public ResponseEntity<UserExtra> createUserExtra(@Valid @RequestBody UserExtra userExtra) throws URISyntaxException {
        log.debug("REST request to save UserExtra : {}", userExtra);
        if (userExtra.getId() != null) {
            throw new BadRequestAlertException("A new userExtra cannot already have an ID", ENTITY_NAME, "idexists");
        }
        
        User pseudoUser = userExtra.getUser();
        
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
        
        Authority userAuthority = authorityRepository.findOne(AuthoritiesConstants.USER);
        Set<Authority> authoritySet = new HashSet<>();
        authoritySet.add(userAuthority);
        
        pseudoUser.setAuthorities(authoritySet);
        User savedUser = userService.createUser(new UserDTO(pseudoUser));
        
        userExtra.setUser(savedUser);
        UserExtra result = userExtraRepository.save(userExtra);
        mailService.sendCreationEmail(savedUser);
        userExtraSearchRepository.save(result);
        return ResponseEntity.created(new URI("/api/user-extras/" + result.getId()))
            .headers(HeaderUtil.createEntityCreationAlert(ENTITY_NAME, result.getId().toString()))
            .body(result);
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
    public ResponseEntity<UserExtra> updateUserExtra(@Valid @RequestBody UserExtra userExtra) throws URISyntaxException {
        log.debug("REST request to update UserExtra : {}", userExtra);
                
        if (userExtra.getId() == null) {
            return createUserExtra(userExtra);
        } else {
        	UserExtra usrExtra = userExtraRepository.findOne(userExtra.getId());
        	userExtra.setCreatedDate(usrExtra.getCreatedDate());
        }
        
        Authority userAuthority = authorityRepository.findOne(AuthoritiesConstants.USER);
        Set<Authority> authoritySet = new HashSet<>();
        authoritySet.add(userAuthority);
        userExtra.getUser().setAuthorities(authoritySet);
        
        userService.updateUser(new UserDTO(userExtra.getUser()));
        UserExtra result = userExtraRepository.save(userExtra);
        userExtraSearchRepository.save(result);
        
        return ResponseEntity.ok()
            .headers(HeaderUtil.createEntityUpdateAlert(ENTITY_NAME, userExtra.getId().toString()))
            .body(result);
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
    public ResponseEntity<Void> deleteUserExtra(@PathVariable Long id) {
        log.debug("REST request to delete UserExtra : {}", id);
        UserExtra userExtra = userExtraRepository.findOneWithEagerRelationships(id);
        
        userExtraRepository.delete(id);
        userExtraSearchRepository.delete(id);
        userService.deleteUser(userExtra.getUser().getLogin());
        
        return ResponseEntity.ok().headers(HeaderUtil.createEntityDeletionAlert(ENTITY_NAME, id.toString())).build();
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
        Page<UserExtra> page = userExtraSearchRepository.search(queryStringQuery(query), pageable);
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
