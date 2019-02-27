package my.com.mandrill.base.web.rest;

import my.com.mandrill.base.BaseApp;

import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.domain.User;
import my.com.mandrill.base.domain.RoleExtra;
import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.repository.AuthorityRepository;
import my.com.mandrill.base.repository.UserExtraRepository;
import my.com.mandrill.base.repository.UserRepository;
import my.com.mandrill.base.repository.search.UserExtraSearchRepository;
import my.com.mandrill.base.service.MailService;
import my.com.mandrill.base.service.UserService;
import my.com.mandrill.base.web.rest.errors.ExceptionTranslator;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.web.PageableHandlerMethodArgumentResolver;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import java.time.Instant;
import java.time.ZonedDateTime;
import java.time.ZoneOffset;
import java.time.ZoneId;
import java.util.List;

import static my.com.mandrill.base.web.rest.TestUtil.sameInstant;
import static my.com.mandrill.base.web.rest.TestUtil.createFormattingConversionService;
import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Test class for the UserExtraResource REST controller.
 *
 * @see UserExtraResource
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = BaseApp.class)
public class UserExtraResourceIntTest {

    private static final String DEFAULT_NAME = "AAAAAAAAAA";
    private static final String UPDATED_NAME = "BBBBBBBBBB";

    private static final String DEFAULT_DESIGNATION = "AAAAAAAAAA";
    private static final String UPDATED_DESIGNATION = "BBBBBBBBBB";

    private static final String DEFAULT_CONTACT_MOBILE = "AAAAAAAAAA";
    private static final String UPDATED_CONTACT_MOBILE = "BBBBBBBBBB";

    private static final String DEFAULT_CONTACT_WORK = "AAAAAAAAAA";
    private static final String UPDATED_CONTACT_WORK = "BBBBBBBBBB";

    private static final String DEFAULT_CONTACT_OTHER = "AAAAAAAAAA";
    private static final String UPDATED_CONTACT_OTHER = "BBBBBBBBBB";

    private static final String DEFAULT_CREATED_BY = "AAAAAAAAAA";
    private static final String UPDATED_CREATED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_CREATED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_CREATED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    private static final String DEFAULT_LAST_MODIFIED_BY = "AAAAAAAAAA";
    private static final String UPDATED_LAST_MODIFIED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_LAST_MODIFIED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_LAST_MODIFIED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    @Autowired
    private UserExtraRepository userExtraRepository;

    @Autowired
    private UserExtraSearchRepository userExtraSearchRepository;

    @Autowired
    private MappingJackson2HttpMessageConverter jacksonMessageConverter;

    @Autowired
    private PageableHandlerMethodArgumentResolver pageableArgumentResolver;

    @Autowired
    private ExceptionTranslator exceptionTranslator;

    @Autowired
    private EntityManager em;

    private MockMvc restUserExtraMockMvc;

    private UserExtra userExtra;

    private UserRepository userRepository;
    private AuthorityRepository authorityRepository;
    private UserService userService;
    private MailService mailService;
    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);
        final UserExtraResource userExtraResource = new UserExtraResource(userExtraRepository, userExtraSearchRepository,
                                                                            userRepository, authorityRepository,
                                                                            userService, mailService);
        this.restUserExtraMockMvc = MockMvcBuilders.standaloneSetup(userExtraResource)
            .setCustomArgumentResolvers(pageableArgumentResolver)
            .setControllerAdvice(exceptionTranslator)
            .setConversionService(createFormattingConversionService())
            .setMessageConverters(jacksonMessageConverter).build();
    }

    /**
     * Create an entity for this test.
     *
     * This is a static method, as tests for other entities might also need it,
     * if they test an entity which requires the current entity.
     */
    public static UserExtra createEntity(EntityManager em) {
        UserExtra userExtra = new UserExtra()
            .name(DEFAULT_NAME)
            .designation(DEFAULT_DESIGNATION)
            .contactMobile(DEFAULT_CONTACT_MOBILE)
            .contactWork(DEFAULT_CONTACT_WORK)
            .contactOther(DEFAULT_CONTACT_OTHER);
        // Add required entity
        User user = UserResourceIntTest.createEntity(em);
        em.persist(user);
        em.flush();
        userExtra.setUser(user);
        // Add required entity
        RoleExtra roles = RoleExtraResourceIntTest.createEntity(em);
        em.persist(roles);
        em.flush();
        userExtra.getRoles().add(roles);
        // Add required entity
        Institution institutions = InstitutionResourceIntTest.createEntity(em);
        em.persist(institutions);
        em.flush();
        userExtra.getInstitutions().add(institutions);
        return userExtra;
    }

    @Before
    public void initTest() {
        userExtraSearchRepository.deleteAll();
        userExtra = createEntity(em);
    }

    @Test
    @Transactional
    public void createUserExtra() throws Exception {
        int databaseSizeBeforeCreate = userExtraRepository.findAll().size();

        // Create the UserExtra
        restUserExtraMockMvc.perform(post("/api/user-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(userExtra)))
            .andExpect(status().isCreated());

        // Validate the UserExtra in the database
        List<UserExtra> userExtraList = userExtraRepository.findAll();
        assertThat(userExtraList).hasSize(databaseSizeBeforeCreate + 1);
        UserExtra testUserExtra = userExtraList.get(userExtraList.size() - 1);
        assertThat(testUserExtra.getName()).isEqualTo(DEFAULT_NAME);
        assertThat(testUserExtra.getDesignation()).isEqualTo(DEFAULT_DESIGNATION);
        assertThat(testUserExtra.getContactMobile()).isEqualTo(DEFAULT_CONTACT_MOBILE);
        assertThat(testUserExtra.getContactWork()).isEqualTo(DEFAULT_CONTACT_WORK);
        assertThat(testUserExtra.getContactOther()).isEqualTo(DEFAULT_CONTACT_OTHER);
        assertThat(testUserExtra.getCreatedBy()).isEqualTo(DEFAULT_CREATED_BY);
        assertThat(testUserExtra.getCreatedDate()).isEqualTo(DEFAULT_CREATED_DATE);
        assertThat(testUserExtra.getLastModifiedBy()).isEqualTo(DEFAULT_LAST_MODIFIED_BY);
        assertThat(testUserExtra.getLastModifiedDate()).isEqualTo(DEFAULT_LAST_MODIFIED_DATE);

        // Validate the UserExtra in Elasticsearch
        UserExtra userExtraEs = userExtraSearchRepository.findOne(testUserExtra.getId());
        assertThat(testUserExtra.getCreatedDate()).isEqualTo(testUserExtra.getCreatedDate());
        assertThat(testUserExtra.getLastModifiedDate()).isEqualTo(testUserExtra.getLastModifiedDate());
        assertThat(userExtraEs).isEqualToIgnoringGivenFields(testUserExtra, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void createUserExtraWithExistingId() throws Exception {
        int databaseSizeBeforeCreate = userExtraRepository.findAll().size();

        // Create the UserExtra with an existing ID
        userExtra.setId(1L);

        // An entity with an existing ID cannot be created, so this API call must fail
        restUserExtraMockMvc.perform(post("/api/user-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(userExtra)))
            .andExpect(status().isBadRequest());

        // Validate the UserExtra in the database
        List<UserExtra> userExtraList = userExtraRepository.findAll();
        assertThat(userExtraList).hasSize(databaseSizeBeforeCreate);
    }

    @Test
    @Transactional
    public void checkNameIsRequired() throws Exception {
        int databaseSizeBeforeTest = userExtraRepository.findAll().size();
        // set the field null
        userExtra.setName(null);

        // Create the UserExtra, which fails.

        restUserExtraMockMvc.perform(post("/api/user-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(userExtra)))
            .andExpect(status().isBadRequest());

        List<UserExtra> userExtraList = userExtraRepository.findAll();
        assertThat(userExtraList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedByIsRequired() throws Exception {
        int databaseSizeBeforeTest = userExtraRepository.findAll().size();
        // set the field null
        userExtra.setCreatedBy(null);

        // Create the UserExtra, which fails.

        restUserExtraMockMvc.perform(post("/api/user-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(userExtra)))
            .andExpect(status().isBadRequest());

        List<UserExtra> userExtraList = userExtraRepository.findAll();
        assertThat(userExtraList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedDateIsRequired() throws Exception {
        int databaseSizeBeforeTest = userExtraRepository.findAll().size();
        // set the field null
        userExtra.setCreatedDate(null);

        // Create the UserExtra, which fails.

        restUserExtraMockMvc.perform(post("/api/user-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(userExtra)))
            .andExpect(status().isBadRequest());

        List<UserExtra> userExtraList = userExtraRepository.findAll();
        assertThat(userExtraList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void getAllUserExtras() throws Exception {
        // Initialize the database
        userExtraRepository.saveAndFlush(userExtra);

        // Get all the userExtraList
        restUserExtraMockMvc.perform(get("/api/user-extras?sort=id,desc"))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(userExtra.getId().intValue())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].designation").value(hasItem(DEFAULT_DESIGNATION.toString())))
            .andExpect(jsonPath("$.[*].contactMobile").value(hasItem(DEFAULT_CONTACT_MOBILE.toString())))
            .andExpect(jsonPath("$.[*].contactWork").value(hasItem(DEFAULT_CONTACT_WORK.toString())))
            .andExpect(jsonPath("$.[*].contactOther").value(hasItem(DEFAULT_CONTACT_OTHER.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void getUserExtra() throws Exception {
        // Initialize the database
        userExtraRepository.saveAndFlush(userExtra);

        // Get the userExtra
        restUserExtraMockMvc.perform(get("/api/user-extras/{id}", userExtra.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.id").value(userExtra.getId().intValue()))
            .andExpect(jsonPath("$.name").value(DEFAULT_NAME.toString()))
            .andExpect(jsonPath("$.designation").value(DEFAULT_DESIGNATION.toString()))
            .andExpect(jsonPath("$.contactMobile").value(DEFAULT_CONTACT_MOBILE.toString()))
            .andExpect(jsonPath("$.contactWork").value(DEFAULT_CONTACT_WORK.toString()))
            .andExpect(jsonPath("$.contactOther").value(DEFAULT_CONTACT_OTHER.toString()))
            .andExpect(jsonPath("$.createdBy").value(DEFAULT_CREATED_BY.toString()))
            .andExpect(jsonPath("$.createdDate").value(sameInstant(DEFAULT_CREATED_DATE)))
            .andExpect(jsonPath("$.lastModifiedBy").value(DEFAULT_LAST_MODIFIED_BY.toString()))
            .andExpect(jsonPath("$.lastModifiedDate").value(sameInstant(DEFAULT_LAST_MODIFIED_DATE)));
    }

    @Test
    @Transactional
    public void getNonExistingUserExtra() throws Exception {
        // Get the userExtra
        restUserExtraMockMvc.perform(get("/api/user-extras/{id}", Long.MAX_VALUE))
            .andExpect(status().isNotFound());
    }

    @Test
    @Transactional
    public void updateUserExtra() throws Exception {
        // Initialize the database
        userExtraRepository.saveAndFlush(userExtra);
        userExtraSearchRepository.save(userExtra);
        int databaseSizeBeforeUpdate = userExtraRepository.findAll().size();

        // Update the userExtra
        UserExtra updatedUserExtra = userExtraRepository.findOne(userExtra.getId());
        // Disconnect from session so that the updates on updatedUserExtra are not directly saved in db
        em.detach(updatedUserExtra);
        updatedUserExtra
            .name(UPDATED_NAME)
            .designation(UPDATED_DESIGNATION)
            .contactMobile(UPDATED_CONTACT_MOBILE)
            .contactWork(UPDATED_CONTACT_WORK)
            .contactOther(UPDATED_CONTACT_OTHER);

        restUserExtraMockMvc.perform(put("/api/user-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(updatedUserExtra)))
            .andExpect(status().isOk());

        // Validate the UserExtra in the database
        List<UserExtra> userExtraList = userExtraRepository.findAll();
        assertThat(userExtraList).hasSize(databaseSizeBeforeUpdate);
        UserExtra testUserExtra = userExtraList.get(userExtraList.size() - 1);
        assertThat(testUserExtra.getName()).isEqualTo(UPDATED_NAME);
        assertThat(testUserExtra.getDesignation()).isEqualTo(UPDATED_DESIGNATION);
        assertThat(testUserExtra.getContactMobile()).isEqualTo(UPDATED_CONTACT_MOBILE);
        assertThat(testUserExtra.getContactWork()).isEqualTo(UPDATED_CONTACT_WORK);
        assertThat(testUserExtra.getContactOther()).isEqualTo(UPDATED_CONTACT_OTHER);
        assertThat(testUserExtra.getCreatedBy()).isEqualTo(UPDATED_CREATED_BY);
        assertThat(testUserExtra.getCreatedDate()).isEqualTo(UPDATED_CREATED_DATE);
        assertThat(testUserExtra.getLastModifiedBy()).isEqualTo(UPDATED_LAST_MODIFIED_BY);
        assertThat(testUserExtra.getLastModifiedDate()).isEqualTo(UPDATED_LAST_MODIFIED_DATE);

        // Validate the UserExtra in Elasticsearch
        UserExtra userExtraEs = userExtraSearchRepository.findOne(testUserExtra.getId());
        assertThat(testUserExtra.getCreatedDate()).isEqualTo(testUserExtra.getCreatedDate());
        assertThat(testUserExtra.getLastModifiedDate()).isEqualTo(testUserExtra.getLastModifiedDate());
        assertThat(userExtraEs).isEqualToIgnoringGivenFields(testUserExtra, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void updateNonExistingUserExtra() throws Exception {
        int databaseSizeBeforeUpdate = userExtraRepository.findAll().size();

        // Create the UserExtra

        // If the entity doesn't have an ID, it will be created instead of just being updated
        restUserExtraMockMvc.perform(put("/api/user-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(userExtra)))
            .andExpect(status().isCreated());

        // Validate the UserExtra in the database
        List<UserExtra> userExtraList = userExtraRepository.findAll();
        assertThat(userExtraList).hasSize(databaseSizeBeforeUpdate + 1);
    }

    @Test
    @Transactional
    public void deleteUserExtra() throws Exception {
        // Initialize the database
        userExtraRepository.saveAndFlush(userExtra);
        userExtraSearchRepository.save(userExtra);
        int databaseSizeBeforeDelete = userExtraRepository.findAll().size();

        // Get the userExtra
        restUserExtraMockMvc.perform(delete("/api/user-extras/{id}", userExtra.getId())
            .accept(TestUtil.APPLICATION_JSON_UTF8))
            .andExpect(status().isOk());

        // Validate Elasticsearch is empty
        boolean userExtraExistsInEs = userExtraSearchRepository.exists(userExtra.getId());
        assertThat(userExtraExistsInEs).isFalse();

        // Validate the database is empty
        List<UserExtra> userExtraList = userExtraRepository.findAll();
        assertThat(userExtraList).hasSize(databaseSizeBeforeDelete - 1);
    }

    @Test
    @Transactional
    public void searchUserExtra() throws Exception {
        // Initialize the database
        userExtraRepository.saveAndFlush(userExtra);
        userExtraSearchRepository.save(userExtra);

        // Search the userExtra
        restUserExtraMockMvc.perform(get("/api/_search/user-extras?query=id:" + userExtra.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(userExtra.getId().intValue())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].designation").value(hasItem(DEFAULT_DESIGNATION.toString())))
            .andExpect(jsonPath("$.[*].contactMobile").value(hasItem(DEFAULT_CONTACT_MOBILE.toString())))
            .andExpect(jsonPath("$.[*].contactWork").value(hasItem(DEFAULT_CONTACT_WORK.toString())))
            .andExpect(jsonPath("$.[*].contactOther").value(hasItem(DEFAULT_CONTACT_OTHER.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void equalsVerifier() throws Exception {
        TestUtil.equalsVerifier(UserExtra.class);
        UserExtra userExtra1 = new UserExtra();
        userExtra1.setId(1L);
        UserExtra userExtra2 = new UserExtra();
        userExtra2.setId(userExtra1.getId());
        assertThat(userExtra1).isEqualTo(userExtra2);
        userExtra2.setId(2L);
        assertThat(userExtra1).isNotEqualTo(userExtra2);
        userExtra1.setId(null);
        assertThat(userExtra1).isNotEqualTo(userExtra2);
    }
}
