package my.com.mandrill.base.web.rest;

import my.com.mandrill.base.BaseApp;

import my.com.mandrill.base.domain.RoleExtra;
import my.com.mandrill.base.domain.AppResource;
import my.com.mandrill.base.repository.RoleExtraRepository;
import my.com.mandrill.base.repository.search.RoleExtraSearchRepository;
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
 * Test class for the RoleExtraResource REST controller.
 *
 * @see RoleExtraResource
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = BaseApp.class)
public class RoleExtraResourceIntTest {

    private static final String DEFAULT_NAME = "AAAAAAAAAA";
    private static final String UPDATED_NAME = "BBBBBBBBBB";

    private static final String DEFAULT_DESCRIPTION = "AAAAAAAAAA";
    private static final String UPDATED_DESCRIPTION = "BBBBBBBBBB";

    private static final String DEFAULT_CREATED_BY = "AAAAAAAAAA";
    private static final String UPDATED_CREATED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_CREATED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_CREATED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    private static final String DEFAULT_LAST_MODIFIED_BY = "AAAAAAAAAA";
    private static final String UPDATED_LAST_MODIFIED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_LAST_MODIFIED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_LAST_MODIFIED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    @Autowired
    private RoleExtraRepository roleExtraRepository;

    @Autowired
    private RoleExtraSearchRepository roleExtraSearchRepository;

    @Autowired
    private MappingJackson2HttpMessageConverter jacksonMessageConverter;

    @Autowired
    private PageableHandlerMethodArgumentResolver pageableArgumentResolver;

    @Autowired
    private ExceptionTranslator exceptionTranslator;

    @Autowired
    private EntityManager em;

    private MockMvc restRoleExtraMockMvc;

    private RoleExtra roleExtra;

    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);
        final RoleExtraResource roleExtraResource = new RoleExtraResource(roleExtraRepository, roleExtraSearchRepository);
        this.restRoleExtraMockMvc = MockMvcBuilders.standaloneSetup(roleExtraResource)
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
    public static RoleExtra createEntity(EntityManager em) {
        RoleExtra roleExtra = new RoleExtra()
            .name(DEFAULT_NAME)
            .description(DEFAULT_DESCRIPTION);
        // Add required entity
        AppResource permissions = AppResourceResourceIntTest.createEntity(em);
        em.persist(permissions);
        em.flush();
        roleExtra.getPermissions().add(permissions);
        return roleExtra;
    }

    @Before
    public void initTest() {
        roleExtraSearchRepository.deleteAll();
        roleExtra = createEntity(em);
    }

    @Test
    @Transactional
    public void createRoleExtra() throws Exception {
        int databaseSizeBeforeCreate = roleExtraRepository.findAll().size();

        // Create the RoleExtra
        restRoleExtraMockMvc.perform(post("/api/role-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(roleExtra)))
            .andExpect(status().isCreated());

        // Validate the RoleExtra in the database
        List<RoleExtra> roleExtraList = roleExtraRepository.findAll();
        assertThat(roleExtraList).hasSize(databaseSizeBeforeCreate + 1);
        RoleExtra testRoleExtra = roleExtraList.get(roleExtraList.size() - 1);
        assertThat(testRoleExtra.getName()).isEqualTo(DEFAULT_NAME);
        assertThat(testRoleExtra.getDescription()).isEqualTo(DEFAULT_DESCRIPTION);
        assertThat(testRoleExtra.getCreatedBy()).isEqualTo(DEFAULT_CREATED_BY);
        assertThat(testRoleExtra.getCreatedDate()).isEqualTo(DEFAULT_CREATED_DATE);
        assertThat(testRoleExtra.getLastModifiedBy()).isEqualTo(DEFAULT_LAST_MODIFIED_BY);
        assertThat(testRoleExtra.getLastModifiedDate()).isEqualTo(DEFAULT_LAST_MODIFIED_DATE);

        // Validate the RoleExtra in Elasticsearch
        RoleExtra roleExtraEs = roleExtraSearchRepository.findOne(testRoleExtra.getId());
        assertThat(testRoleExtra.getCreatedDate()).isEqualTo(testRoleExtra.getCreatedDate());
        assertThat(testRoleExtra.getLastModifiedDate()).isEqualTo(testRoleExtra.getLastModifiedDate());
        assertThat(roleExtraEs).isEqualToIgnoringGivenFields(testRoleExtra, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void createRoleExtraWithExistingId() throws Exception {
        int databaseSizeBeforeCreate = roleExtraRepository.findAll().size();

        // Create the RoleExtra with an existing ID
        roleExtra.setId(1L);

        // An entity with an existing ID cannot be created, so this API call must fail
        restRoleExtraMockMvc.perform(post("/api/role-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(roleExtra)))
            .andExpect(status().isBadRequest());

        // Validate the RoleExtra in the database
        List<RoleExtra> roleExtraList = roleExtraRepository.findAll();
        assertThat(roleExtraList).hasSize(databaseSizeBeforeCreate);
    }

    @Test
    @Transactional
    public void checkNameIsRequired() throws Exception {
        int databaseSizeBeforeTest = roleExtraRepository.findAll().size();
        // set the field null
        roleExtra.setName(null);

        // Create the RoleExtra, which fails.

        restRoleExtraMockMvc.perform(post("/api/role-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(roleExtra)))
            .andExpect(status().isBadRequest());

        List<RoleExtra> roleExtraList = roleExtraRepository.findAll();
        assertThat(roleExtraList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkDescriptionIsRequired() throws Exception {
        int databaseSizeBeforeTest = roleExtraRepository.findAll().size();
        // set the field null
        roleExtra.setDescription(null);

        // Create the RoleExtra, which fails.

        restRoleExtraMockMvc.perform(post("/api/role-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(roleExtra)))
            .andExpect(status().isBadRequest());

        List<RoleExtra> roleExtraList = roleExtraRepository.findAll();
        assertThat(roleExtraList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedByIsRequired() throws Exception {
        int databaseSizeBeforeTest = roleExtraRepository.findAll().size();
        // set the field null
        roleExtra.setCreatedBy(null);

        // Create the RoleExtra, which fails.

        restRoleExtraMockMvc.perform(post("/api/role-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(roleExtra)))
            .andExpect(status().isBadRequest());

        List<RoleExtra> roleExtraList = roleExtraRepository.findAll();
        assertThat(roleExtraList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedDateIsRequired() throws Exception {
        int databaseSizeBeforeTest = roleExtraRepository.findAll().size();
        // set the field null
        roleExtra.setCreatedDate(null);

        // Create the RoleExtra, which fails.

        restRoleExtraMockMvc.perform(post("/api/role-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(roleExtra)))
            .andExpect(status().isBadRequest());

        List<RoleExtra> roleExtraList = roleExtraRepository.findAll();
        assertThat(roleExtraList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void getAllRoleExtras() throws Exception {
        // Initialize the database
        roleExtraRepository.saveAndFlush(roleExtra);

        // Get all the roleExtraList
        restRoleExtraMockMvc.perform(get("/api/role-extras?sort=id,desc"))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(roleExtra.getId().intValue())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].description").value(hasItem(DEFAULT_DESCRIPTION.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void getRoleExtra() throws Exception {
        // Initialize the database
        roleExtraRepository.saveAndFlush(roleExtra);

        // Get the roleExtra
        restRoleExtraMockMvc.perform(get("/api/role-extras/{id}", roleExtra.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.id").value(roleExtra.getId().intValue()))
            .andExpect(jsonPath("$.name").value(DEFAULT_NAME.toString()))
            .andExpect(jsonPath("$.description").value(DEFAULT_DESCRIPTION.toString()))
            .andExpect(jsonPath("$.createdBy").value(DEFAULT_CREATED_BY.toString()))
            .andExpect(jsonPath("$.createdDate").value(sameInstant(DEFAULT_CREATED_DATE)))
            .andExpect(jsonPath("$.lastModifiedBy").value(DEFAULT_LAST_MODIFIED_BY.toString()))
            .andExpect(jsonPath("$.lastModifiedDate").value(sameInstant(DEFAULT_LAST_MODIFIED_DATE)));
    }

    @Test
    @Transactional
    public void getNonExistingRoleExtra() throws Exception {
        // Get the roleExtra
        restRoleExtraMockMvc.perform(get("/api/role-extras/{id}", Long.MAX_VALUE))
            .andExpect(status().isNotFound());
    }

    @Test
    @Transactional
    public void updateRoleExtra() throws Exception {
        // Initialize the database
        roleExtraRepository.saveAndFlush(roleExtra);
        roleExtraSearchRepository.save(roleExtra);
        int databaseSizeBeforeUpdate = roleExtraRepository.findAll().size();

        // Update the roleExtra
        RoleExtra updatedRoleExtra = roleExtraRepository.findOne(roleExtra.getId());
        // Disconnect from session so that the updates on updatedRoleExtra are not directly saved in db
        em.detach(updatedRoleExtra);
        updatedRoleExtra
            .name(UPDATED_NAME)
            .description(UPDATED_DESCRIPTION);

        restRoleExtraMockMvc.perform(put("/api/role-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(updatedRoleExtra)))
            .andExpect(status().isOk());

        // Validate the RoleExtra in the database
        List<RoleExtra> roleExtraList = roleExtraRepository.findAll();
        assertThat(roleExtraList).hasSize(databaseSizeBeforeUpdate);
        RoleExtra testRoleExtra = roleExtraList.get(roleExtraList.size() - 1);
        assertThat(testRoleExtra.getName()).isEqualTo(UPDATED_NAME);
        assertThat(testRoleExtra.getDescription()).isEqualTo(UPDATED_DESCRIPTION);
        assertThat(testRoleExtra.getCreatedBy()).isEqualTo(UPDATED_CREATED_BY);
        assertThat(testRoleExtra.getCreatedDate()).isEqualTo(UPDATED_CREATED_DATE);
        assertThat(testRoleExtra.getLastModifiedBy()).isEqualTo(UPDATED_LAST_MODIFIED_BY);
        assertThat(testRoleExtra.getLastModifiedDate()).isEqualTo(UPDATED_LAST_MODIFIED_DATE);

        // Validate the RoleExtra in Elasticsearch
        RoleExtra roleExtraEs = roleExtraSearchRepository.findOne(testRoleExtra.getId());
        assertThat(testRoleExtra.getCreatedDate()).isEqualTo(testRoleExtra.getCreatedDate());
        assertThat(testRoleExtra.getLastModifiedDate()).isEqualTo(testRoleExtra.getLastModifiedDate());
        assertThat(roleExtraEs).isEqualToIgnoringGivenFields(testRoleExtra, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void updateNonExistingRoleExtra() throws Exception {
        int databaseSizeBeforeUpdate = roleExtraRepository.findAll().size();

        // Create the RoleExtra

        // If the entity doesn't have an ID, it will be created instead of just being updated
        restRoleExtraMockMvc.perform(put("/api/role-extras")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(roleExtra)))
            .andExpect(status().isCreated());

        // Validate the RoleExtra in the database
        List<RoleExtra> roleExtraList = roleExtraRepository.findAll();
        assertThat(roleExtraList).hasSize(databaseSizeBeforeUpdate + 1);
    }

    @Test
    @Transactional
    public void deleteRoleExtra() throws Exception {
        // Initialize the database
        roleExtraRepository.saveAndFlush(roleExtra);
        roleExtraSearchRepository.save(roleExtra);
        int databaseSizeBeforeDelete = roleExtraRepository.findAll().size();

        // Get the roleExtra
        restRoleExtraMockMvc.perform(delete("/api/role-extras/{id}", roleExtra.getId())
            .accept(TestUtil.APPLICATION_JSON_UTF8))
            .andExpect(status().isOk());

        // Validate Elasticsearch is empty
        boolean roleExtraExistsInEs = roleExtraSearchRepository.exists(roleExtra.getId());
        assertThat(roleExtraExistsInEs).isFalse();

        // Validate the database is empty
        List<RoleExtra> roleExtraList = roleExtraRepository.findAll();
        assertThat(roleExtraList).hasSize(databaseSizeBeforeDelete - 1);
    }

    @Test
    @Transactional
    public void searchRoleExtra() throws Exception {
        // Initialize the database
        roleExtraRepository.saveAndFlush(roleExtra);
        roleExtraSearchRepository.save(roleExtra);

        // Search the roleExtra
        restRoleExtraMockMvc.perform(get("/api/_search/role-extras?query=id:" + roleExtra.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(roleExtra.getId().intValue())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].description").value(hasItem(DEFAULT_DESCRIPTION.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void equalsVerifier() throws Exception {
        TestUtil.equalsVerifier(RoleExtra.class);
        RoleExtra roleExtra1 = new RoleExtra();
        roleExtra1.setId(1L);
        RoleExtra roleExtra2 = new RoleExtra();
        roleExtra2.setId(roleExtra1.getId());
        assertThat(roleExtra1).isEqualTo(roleExtra2);
        roleExtra2.setId(2L);
        assertThat(roleExtra1).isNotEqualTo(roleExtra2);
        roleExtra1.setId(null);
        assertThat(roleExtra1).isNotEqualTo(roleExtra2);
    }
}
