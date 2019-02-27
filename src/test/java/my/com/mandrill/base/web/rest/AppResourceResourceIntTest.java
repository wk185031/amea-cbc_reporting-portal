package my.com.mandrill.base.web.rest;

import my.com.mandrill.base.BaseApp;

import my.com.mandrill.base.domain.AppResource;
import my.com.mandrill.base.repository.AppResourceRepository;
import my.com.mandrill.base.repository.RoleExtraRepository;
import my.com.mandrill.base.repository.search.AppResourceSearchRepository;
import my.com.mandrill.base.service.AppService;
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
 * Test class for the AppResourceResource REST controller.
 *
 * @see AppResourceResource
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = BaseApp.class)
public class AppResourceResourceIntTest {

    private static final String DEFAULT_CODE = "AAAAAAAAAA";
    private static final String UPDATED_CODE = "BBBBBBBBBB";

    private static final String DEFAULT_NAME = "AAAAAAAAAA";
    private static final String UPDATED_NAME = "BBBBBBBBBB";

    private static final String DEFAULT_TYPE = "AAAAAAAAAA";
    private static final String UPDATED_TYPE = "BBBBBBBBBB";

    private static final String DEFAULT_DESCRIPTION = "AAAAAAAAAA";
    private static final String UPDATED_DESCRIPTION = "BBBBBBBBBB";

    private static final Integer DEFAULT_SEQ_NO = 1;
    private static final Integer UPDATED_SEQ_NO = 2;

    private static final Integer DEFAULT_DEPTH = 1;
    private static final Integer UPDATED_DEPTH = 2;

    private static final String DEFAULT_CREATED_BY = "AAAAAAAAAA";
    private static final String UPDATED_CREATED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_CREATED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_CREATED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    private static final String DEFAULT_LAST_MODIFIED_BY = "AAAAAAAAAA";
    private static final String UPDATED_LAST_MODIFIED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_LAST_MODIFIED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_LAST_MODIFIED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    @Autowired
    private AppResourceRepository appResourceRepository;

    @Autowired
    private AppResourceSearchRepository appResourceSearchRepository;

    @Autowired
    private MappingJackson2HttpMessageConverter jacksonMessageConverter;

    @Autowired
    private PageableHandlerMethodArgumentResolver pageableArgumentResolver;

    @Autowired
    private ExceptionTranslator exceptionTranslator;

    @Autowired
    private EntityManager em;

    private MockMvc restAppResourceMockMvc;

    private AppResource appResource;

    private AppService appService;
    private RoleExtraRepository roleExtraRepository;

    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);
        final AppResourceResource appResourceResource = new AppResourceResource(appResourceRepository, appResourceSearchRepository, appService, roleExtraRepository);
        this.restAppResourceMockMvc = MockMvcBuilders.standaloneSetup(appResourceResource)
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
    public static AppResource createEntity(EntityManager em) {
        AppResource appResource = new AppResource()
            .code(DEFAULT_CODE)
            .name(DEFAULT_NAME)
            .type(DEFAULT_TYPE)
            .description(DEFAULT_DESCRIPTION)
            .seqNo(DEFAULT_SEQ_NO)
            .depth(DEFAULT_DEPTH)
            .createdBy(DEFAULT_CREATED_BY)
            .createdDate(DEFAULT_CREATED_DATE)
            .lastModifiedBy(DEFAULT_LAST_MODIFIED_BY)
            .lastModifiedDate(DEFAULT_LAST_MODIFIED_DATE);
        return appResource;
    }

    @Before
    public void initTest() {
        appResourceSearchRepository.deleteAll();
        appResource = createEntity(em);
    }

    @Test
    @Transactional
    public void createAppResource() throws Exception {
        int databaseSizeBeforeCreate = appResourceRepository.findAll().size();

        // Create the AppResource
        restAppResourceMockMvc.perform(post("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isCreated());

        // Validate the AppResource in the database
        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeCreate + 1);
        AppResource testAppResource = appResourceList.get(appResourceList.size() - 1);
        assertThat(testAppResource.getCode()).isEqualTo(DEFAULT_CODE);
        assertThat(testAppResource.getName()).isEqualTo(DEFAULT_NAME);
        assertThat(testAppResource.getType()).isEqualTo(DEFAULT_TYPE);
        assertThat(testAppResource.getDescription()).isEqualTo(DEFAULT_DESCRIPTION);
        assertThat(testAppResource.getSeqNo()).isEqualTo(DEFAULT_SEQ_NO);
        assertThat(testAppResource.getDepth()).isEqualTo(DEFAULT_DEPTH);
        assertThat(testAppResource.getCreatedBy()).isEqualTo(DEFAULT_CREATED_BY);
        assertThat(testAppResource.getCreatedDate()).isEqualTo(DEFAULT_CREATED_DATE);
        assertThat(testAppResource.getLastModifiedBy()).isEqualTo(DEFAULT_LAST_MODIFIED_BY);
        assertThat(testAppResource.getLastModifiedDate()).isEqualTo(DEFAULT_LAST_MODIFIED_DATE);

        // Validate the AppResource in Elasticsearch
        AppResource appResourceEs = appResourceSearchRepository.findOne(testAppResource.getId());
        assertThat(testAppResource.getCreatedDate()).isEqualTo(testAppResource.getCreatedDate());
        assertThat(testAppResource.getLastModifiedDate()).isEqualTo(testAppResource.getLastModifiedDate());
        assertThat(appResourceEs).isEqualToIgnoringGivenFields(testAppResource, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void createAppResourceWithExistingId() throws Exception {
        int databaseSizeBeforeCreate = appResourceRepository.findAll().size();

        // Create the AppResource with an existing ID
        appResource.setId(1L);

        // An entity with an existing ID cannot be created, so this API call must fail
        restAppResourceMockMvc.perform(post("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isBadRequest());

        // Validate the AppResource in the database
        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeCreate);
    }

    @Test
    @Transactional
    public void checkCodeIsRequired() throws Exception {
        int databaseSizeBeforeTest = appResourceRepository.findAll().size();
        // set the field null
        appResource.setCode(null);

        // Create the AppResource, which fails.

        restAppResourceMockMvc.perform(post("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isBadRequest());

        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkNameIsRequired() throws Exception {
        int databaseSizeBeforeTest = appResourceRepository.findAll().size();
        // set the field null
        appResource.setName(null);

        // Create the AppResource, which fails.

        restAppResourceMockMvc.perform(post("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isBadRequest());

        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkTypeIsRequired() throws Exception {
        int databaseSizeBeforeTest = appResourceRepository.findAll().size();
        // set the field null
        appResource.setType(null);

        // Create the AppResource, which fails.

        restAppResourceMockMvc.perform(post("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isBadRequest());

        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkSeqNoIsRequired() throws Exception {
        int databaseSizeBeforeTest = appResourceRepository.findAll().size();
        // set the field null
        appResource.setSeqNo(null);

        // Create the AppResource, which fails.

        restAppResourceMockMvc.perform(post("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isBadRequest());

        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkDepthIsRequired() throws Exception {
        int databaseSizeBeforeTest = appResourceRepository.findAll().size();
        // set the field null
        appResource.setDepth(null);

        // Create the AppResource, which fails.

        restAppResourceMockMvc.perform(post("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isBadRequest());

        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedByIsRequired() throws Exception {
        int databaseSizeBeforeTest = appResourceRepository.findAll().size();
        // set the field null
        appResource.setCreatedBy(null);

        // Create the AppResource, which fails.

        restAppResourceMockMvc.perform(post("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isBadRequest());

        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedDateIsRequired() throws Exception {
        int databaseSizeBeforeTest = appResourceRepository.findAll().size();
        // set the field null
        appResource.setCreatedDate(null);

        // Create the AppResource, which fails.

        restAppResourceMockMvc.perform(post("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isBadRequest());

        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void getAllAppResources() throws Exception {
        // Initialize the database
        appResourceRepository.saveAndFlush(appResource);

        // Get all the appResourceList
        restAppResourceMockMvc.perform(get("/api/app-resources?sort=id,desc"))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(appResource.getId().intValue())))
            .andExpect(jsonPath("$.[*].code").value(hasItem(DEFAULT_CODE.toString())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].type").value(hasItem(DEFAULT_TYPE.toString())))
            .andExpect(jsonPath("$.[*].description").value(hasItem(DEFAULT_DESCRIPTION.toString())))
            .andExpect(jsonPath("$.[*].seqNo").value(hasItem(DEFAULT_SEQ_NO)))
            .andExpect(jsonPath("$.[*].depth").value(hasItem(DEFAULT_DEPTH)))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void getAppResource() throws Exception {
        // Initialize the database
        appResourceRepository.saveAndFlush(appResource);

        // Get the appResource
        restAppResourceMockMvc.perform(get("/api/app-resources/{id}", appResource.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.id").value(appResource.getId().intValue()))
            .andExpect(jsonPath("$.code").value(DEFAULT_CODE.toString()))
            .andExpect(jsonPath("$.name").value(DEFAULT_NAME.toString()))
            .andExpect(jsonPath("$.type").value(DEFAULT_TYPE.toString()))
            .andExpect(jsonPath("$.description").value(DEFAULT_DESCRIPTION.toString()))
            .andExpect(jsonPath("$.seqNo").value(DEFAULT_SEQ_NO))
            .andExpect(jsonPath("$.depth").value(DEFAULT_DEPTH))
            .andExpect(jsonPath("$.createdBy").value(DEFAULT_CREATED_BY.toString()))
            .andExpect(jsonPath("$.createdDate").value(sameInstant(DEFAULT_CREATED_DATE)))
            .andExpect(jsonPath("$.lastModifiedBy").value(DEFAULT_LAST_MODIFIED_BY.toString()))
            .andExpect(jsonPath("$.lastModifiedDate").value(sameInstant(DEFAULT_LAST_MODIFIED_DATE)));
    }

    @Test
    @Transactional
    public void getNonExistingAppResource() throws Exception {
        // Get the appResource
        restAppResourceMockMvc.perform(get("/api/app-resources/{id}", Long.MAX_VALUE))
            .andExpect(status().isNotFound());
    }

    @Test
    @Transactional
    public void updateAppResource() throws Exception {
        // Initialize the database
        appResourceRepository.saveAndFlush(appResource);
        appResourceSearchRepository.save(appResource);
        int databaseSizeBeforeUpdate = appResourceRepository.findAll().size();

        // Update the appResource
        AppResource updatedAppResource = appResourceRepository.findOne(appResource.getId());
        // Disconnect from session so that the updates on updatedAppResource are not directly saved in db
        em.detach(updatedAppResource);
        updatedAppResource
            .code(UPDATED_CODE)
            .name(UPDATED_NAME)
            .type(UPDATED_TYPE)
            .description(UPDATED_DESCRIPTION)
            .seqNo(UPDATED_SEQ_NO)
            .depth(UPDATED_DEPTH)
            .createdBy(UPDATED_CREATED_BY)
            .createdDate(UPDATED_CREATED_DATE)
            .lastModifiedBy(UPDATED_LAST_MODIFIED_BY)
            .lastModifiedDate(UPDATED_LAST_MODIFIED_DATE);

        restAppResourceMockMvc.perform(put("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(updatedAppResource)))
            .andExpect(status().isOk());

        // Validate the AppResource in the database
        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeUpdate);
        AppResource testAppResource = appResourceList.get(appResourceList.size() - 1);
        assertThat(testAppResource.getCode()).isEqualTo(UPDATED_CODE);
        assertThat(testAppResource.getName()).isEqualTo(UPDATED_NAME);
        assertThat(testAppResource.getType()).isEqualTo(UPDATED_TYPE);
        assertThat(testAppResource.getDescription()).isEqualTo(UPDATED_DESCRIPTION);
        assertThat(testAppResource.getSeqNo()).isEqualTo(UPDATED_SEQ_NO);
        assertThat(testAppResource.getDepth()).isEqualTo(UPDATED_DEPTH);
        assertThat(testAppResource.getCreatedBy()).isEqualTo(UPDATED_CREATED_BY);
        assertThat(testAppResource.getCreatedDate()).isEqualTo(UPDATED_CREATED_DATE);
        assertThat(testAppResource.getLastModifiedBy()).isEqualTo(UPDATED_LAST_MODIFIED_BY);
        assertThat(testAppResource.getLastModifiedDate()).isEqualTo(UPDATED_LAST_MODIFIED_DATE);

        // Validate the AppResource in Elasticsearch
        AppResource appResourceEs = appResourceSearchRepository.findOne(testAppResource.getId());
        assertThat(testAppResource.getCreatedDate()).isEqualTo(testAppResource.getCreatedDate());
        assertThat(testAppResource.getLastModifiedDate()).isEqualTo(testAppResource.getLastModifiedDate());
        assertThat(appResourceEs).isEqualToIgnoringGivenFields(testAppResource, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void updateNonExistingAppResource() throws Exception {
        int databaseSizeBeforeUpdate = appResourceRepository.findAll().size();

        // Create the AppResource

        // If the entity doesn't have an ID, it will be created instead of just being updated
        restAppResourceMockMvc.perform(put("/api/app-resources")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(appResource)))
            .andExpect(status().isCreated());

        // Validate the AppResource in the database
        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeUpdate + 1);
    }

    @Test
    @Transactional
    public void deleteAppResource() throws Exception {
        // Initialize the database
        appResourceRepository.saveAndFlush(appResource);
        appResourceSearchRepository.save(appResource);
        int databaseSizeBeforeDelete = appResourceRepository.findAll().size();

        // Get the appResource
        restAppResourceMockMvc.perform(delete("/api/app-resources/{id}", appResource.getId())
            .accept(TestUtil.APPLICATION_JSON_UTF8))
            .andExpect(status().isOk());

        // Validate Elasticsearch is empty
        boolean appResourceExistsInEs = appResourceSearchRepository.exists(appResource.getId());
        assertThat(appResourceExistsInEs).isFalse();

        // Validate the database is empty
        List<AppResource> appResourceList = appResourceRepository.findAll();
        assertThat(appResourceList).hasSize(databaseSizeBeforeDelete - 1);
    }

    @Test
    @Transactional
    public void searchAppResource() throws Exception {
        // Initialize the database
        appResourceRepository.saveAndFlush(appResource);
        appResourceSearchRepository.save(appResource);

        // Search the appResource
        restAppResourceMockMvc.perform(get("/api/_search/app-resources?query=id:" + appResource.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(appResource.getId().intValue())))
            .andExpect(jsonPath("$.[*].code").value(hasItem(DEFAULT_CODE.toString())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].type").value(hasItem(DEFAULT_TYPE.toString())))
            .andExpect(jsonPath("$.[*].description").value(hasItem(DEFAULT_DESCRIPTION.toString())))
            .andExpect(jsonPath("$.[*].seqNo").value(hasItem(DEFAULT_SEQ_NO)))
            .andExpect(jsonPath("$.[*].depth").value(hasItem(DEFAULT_DEPTH)))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void equalsVerifier() throws Exception {
        TestUtil.equalsVerifier(AppResource.class);
        AppResource appResource1 = new AppResource();
        appResource1.setId(1L);
        AppResource appResource2 = new AppResource();
        appResource2.setId(appResource1.getId());
        assertThat(appResource1).isEqualTo(appResource2);
        appResource2.setId(2L);
        assertThat(appResource1).isNotEqualTo(appResource2);
        appResource1.setId(null);
        assertThat(appResource1).isNotEqualTo(appResource2);
    }
}
