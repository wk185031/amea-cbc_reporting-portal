package my.com.mandrill.base.web.rest;

import my.com.mandrill.base.BaseApp;

import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.repository.SystemConfigurationRepository;
import my.com.mandrill.base.repository.search.SystemConfigurationSearchRepository;
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
 * Test class for the SystemConfigurationResource REST controller.
 *
 * @see SystemConfigurationResource
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = BaseApp.class)
public class SystemConfigurationResourceIntTest {

    private static final String DEFAULT_NAME = "AAAAAAAAAA";
    private static final String UPDATED_NAME = "BBBBBBBBBB";

    private static final String DEFAULT_DESCRIPTION = "AAAAAAAAAA";
    private static final String UPDATED_DESCRIPTION = "BBBBBBBBBB";

    private static final String DEFAULT_CONFIG = "AAAAAAAAAA";
    private static final String UPDATED_CONFIG = "BBBBBBBBBB";

    private static final String DEFAULT_CREATED_BY = "AAAAAAAAAA";
    private static final String UPDATED_CREATED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_CREATED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_CREATED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    private static final String DEFAULT_LAST_MODIFIED_BY = "AAAAAAAAAA";
    private static final String UPDATED_LAST_MODIFIED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_LAST_MODIFIED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_LAST_MODIFIED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    @Autowired
    private SystemConfigurationRepository systemConfigurationRepository;

    @Autowired
    private SystemConfigurationSearchRepository systemConfigurationSearchRepository;

    @Autowired
    private MappingJackson2HttpMessageConverter jacksonMessageConverter;

    @Autowired
    private PageableHandlerMethodArgumentResolver pageableArgumentResolver;

    @Autowired
    private ExceptionTranslator exceptionTranslator;

    @Autowired
    private EntityManager em;

    private MockMvc restSystemConfigurationMockMvc;

    private SystemConfiguration systemConfiguration;

    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);
        final SystemConfigurationResource systemConfigurationResource = new SystemConfigurationResource(systemConfigurationRepository, systemConfigurationSearchRepository);
        this.restSystemConfigurationMockMvc = MockMvcBuilders.standaloneSetup(systemConfigurationResource)
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
    public static SystemConfiguration createEntity(EntityManager em) {
        SystemConfiguration systemConfiguration = new SystemConfiguration()
            .name(DEFAULT_NAME)
            .description(DEFAULT_DESCRIPTION)
            .config(DEFAULT_CONFIG);
        return systemConfiguration;
    }

    @Before
    public void initTest() {
        systemConfigurationSearchRepository.deleteAll();
        systemConfiguration = createEntity(em);
    }

    @Test
    @Transactional
    public void createSystemConfiguration() throws Exception {
        int databaseSizeBeforeCreate = systemConfigurationRepository.findAll().size();

        // Create the SystemConfiguration
        restSystemConfigurationMockMvc.perform(post("/api/system-configurations")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(systemConfiguration)))
            .andExpect(status().isCreated());

        // Validate the SystemConfiguration in the database
        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeCreate + 1);
        SystemConfiguration testSystemConfiguration = systemConfigurationList.get(systemConfigurationList.size() - 1);
        assertThat(testSystemConfiguration.getName()).isEqualTo(DEFAULT_NAME);
        assertThat(testSystemConfiguration.getDescription()).isEqualTo(DEFAULT_DESCRIPTION);
        assertThat(testSystemConfiguration.getConfig()).isEqualTo(DEFAULT_CONFIG);
        assertThat(testSystemConfiguration.getCreatedBy()).isEqualTo(DEFAULT_CREATED_BY);
        assertThat(testSystemConfiguration.getCreatedDate()).isEqualTo(DEFAULT_CREATED_DATE);
        assertThat(testSystemConfiguration.getLastModifiedBy()).isEqualTo(DEFAULT_LAST_MODIFIED_BY);
        assertThat(testSystemConfiguration.getLastModifiedDate()).isEqualTo(DEFAULT_LAST_MODIFIED_DATE);

        // Validate the SystemConfiguration in Elasticsearch
        SystemConfiguration systemConfigurationEs = systemConfigurationSearchRepository.findOne(testSystemConfiguration.getId());
        assertThat(testSystemConfiguration.getCreatedDate()).isEqualTo(testSystemConfiguration.getCreatedDate());
        assertThat(testSystemConfiguration.getLastModifiedDate()).isEqualTo(testSystemConfiguration.getLastModifiedDate());
        assertThat(systemConfigurationEs).isEqualToIgnoringGivenFields(testSystemConfiguration, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void createSystemConfigurationWithExistingId() throws Exception {
        int databaseSizeBeforeCreate = systemConfigurationRepository.findAll().size();

        // Create the SystemConfiguration with an existing ID
        systemConfiguration.setId(1L);

        // An entity with an existing ID cannot be created, so this API call must fail
        restSystemConfigurationMockMvc.perform(post("/api/system-configurations")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(systemConfiguration)))
            .andExpect(status().isBadRequest());

        // Validate the SystemConfiguration in the database
        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeCreate);
    }

    @Test
    @Transactional
    public void checkNameIsRequired() throws Exception {
        int databaseSizeBeforeTest = systemConfigurationRepository.findAll().size();
        // set the field null
        systemConfiguration.setName(null);

        // Create the SystemConfiguration, which fails.

        restSystemConfigurationMockMvc.perform(post("/api/system-configurations")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(systemConfiguration)))
            .andExpect(status().isBadRequest());

        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkDescriptionIsRequired() throws Exception {
        int databaseSizeBeforeTest = systemConfigurationRepository.findAll().size();
        // set the field null
        systemConfiguration.setDescription(null);

        // Create the SystemConfiguration, which fails.

        restSystemConfigurationMockMvc.perform(post("/api/system-configurations")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(systemConfiguration)))
            .andExpect(status().isBadRequest());

        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkConfigIsRequired() throws Exception {
        int databaseSizeBeforeTest = systemConfigurationRepository.findAll().size();
        // set the field null
        systemConfiguration.setConfig(null);

        // Create the SystemConfiguration, which fails.

        restSystemConfigurationMockMvc.perform(post("/api/system-configurations")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(systemConfiguration)))
            .andExpect(status().isBadRequest());

        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedByIsRequired() throws Exception {
        int databaseSizeBeforeTest = systemConfigurationRepository.findAll().size();
        // set the field null
        systemConfiguration.setCreatedBy(null);

        // Create the SystemConfiguration, which fails.

        restSystemConfigurationMockMvc.perform(post("/api/system-configurations")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(systemConfiguration)))
            .andExpect(status().isBadRequest());

        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedDateIsRequired() throws Exception {
        int databaseSizeBeforeTest = systemConfigurationRepository.findAll().size();
        // set the field null
        systemConfiguration.setCreatedDate(null);

        // Create the SystemConfiguration, which fails.

        restSystemConfigurationMockMvc.perform(post("/api/system-configurations")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(systemConfiguration)))
            .andExpect(status().isBadRequest());

        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void getAllSystemConfigurations() throws Exception {
        // Initialize the database
        systemConfigurationRepository.saveAndFlush(systemConfiguration);

        // Get all the systemConfigurationList
        restSystemConfigurationMockMvc.perform(get("/api/system-configurations?sort=id,desc"))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(systemConfiguration.getId().intValue())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].description").value(hasItem(DEFAULT_DESCRIPTION.toString())))
            .andExpect(jsonPath("$.[*].config").value(hasItem(DEFAULT_CONFIG.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void getSystemConfiguration() throws Exception {
        // Initialize the database
        systemConfigurationRepository.saveAndFlush(systemConfiguration);

        // Get the systemConfiguration
        restSystemConfigurationMockMvc.perform(get("/api/system-configurations/{id}", systemConfiguration.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.id").value(systemConfiguration.getId().intValue()))
            .andExpect(jsonPath("$.name").value(DEFAULT_NAME.toString()))
            .andExpect(jsonPath("$.description").value(DEFAULT_DESCRIPTION.toString()))
            .andExpect(jsonPath("$.config").value(DEFAULT_CONFIG.toString()))
            .andExpect(jsonPath("$.createdBy").value(DEFAULT_CREATED_BY.toString()))
            .andExpect(jsonPath("$.createdDate").value(sameInstant(DEFAULT_CREATED_DATE)))
            .andExpect(jsonPath("$.lastModifiedBy").value(DEFAULT_LAST_MODIFIED_BY.toString()))
            .andExpect(jsonPath("$.lastModifiedDate").value(sameInstant(DEFAULT_LAST_MODIFIED_DATE)));
    }

    @Test
    @Transactional
    public void getNonExistingSystemConfiguration() throws Exception {
        // Get the systemConfiguration
        restSystemConfigurationMockMvc.perform(get("/api/system-configurations/{id}", Long.MAX_VALUE))
            .andExpect(status().isNotFound());
    }

    @Test
    @Transactional
    public void updateSystemConfiguration() throws Exception {
        // Initialize the database
        systemConfigurationRepository.saveAndFlush(systemConfiguration);
        systemConfigurationSearchRepository.save(systemConfiguration);
        int databaseSizeBeforeUpdate = systemConfigurationRepository.findAll().size();

        // Update the systemConfiguration
        SystemConfiguration updatedSystemConfiguration = systemConfigurationRepository.findOne(systemConfiguration.getId());
        // Disconnect from session so that the updates on updatedSystemConfiguration are not directly saved in db
        em.detach(updatedSystemConfiguration);
        updatedSystemConfiguration
            .name(UPDATED_NAME)
            .description(UPDATED_DESCRIPTION)
            .config(UPDATED_CONFIG);

        restSystemConfigurationMockMvc.perform(put("/api/system-configurations")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(updatedSystemConfiguration)))
            .andExpect(status().isOk());

        // Validate the SystemConfiguration in the database
        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeUpdate);
        SystemConfiguration testSystemConfiguration = systemConfigurationList.get(systemConfigurationList.size() - 1);
        assertThat(testSystemConfiguration.getName()).isEqualTo(UPDATED_NAME);
        assertThat(testSystemConfiguration.getDescription()).isEqualTo(UPDATED_DESCRIPTION);
        assertThat(testSystemConfiguration.getConfig()).isEqualTo(UPDATED_CONFIG);
        assertThat(testSystemConfiguration.getCreatedBy()).isEqualTo(UPDATED_CREATED_BY);
        assertThat(testSystemConfiguration.getCreatedDate()).isEqualTo(UPDATED_CREATED_DATE);
        assertThat(testSystemConfiguration.getLastModifiedBy()).isEqualTo(UPDATED_LAST_MODIFIED_BY);
        assertThat(testSystemConfiguration.getLastModifiedDate()).isEqualTo(UPDATED_LAST_MODIFIED_DATE);

        // Validate the SystemConfiguration in Elasticsearch
        SystemConfiguration systemConfigurationEs = systemConfigurationSearchRepository.findOne(testSystemConfiguration.getId());
        assertThat(testSystemConfiguration.getCreatedDate()).isEqualTo(testSystemConfiguration.getCreatedDate());
        assertThat(testSystemConfiguration.getLastModifiedDate()).isEqualTo(testSystemConfiguration.getLastModifiedDate());
        assertThat(systemConfigurationEs).isEqualToIgnoringGivenFields(testSystemConfiguration, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void updateNonExistingSystemConfiguration() throws Exception {
        int databaseSizeBeforeUpdate = systemConfigurationRepository.findAll().size();

        // Create the SystemConfiguration

        // If the entity doesn't have an ID, it will be created instead of just being updated
        restSystemConfigurationMockMvc.perform(put("/api/system-configurations")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(systemConfiguration)))
            .andExpect(status().isCreated());

        // Validate the SystemConfiguration in the database
        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeUpdate + 1);
    }

    @Test
    @Transactional
    public void deleteSystemConfiguration() throws Exception {
        // Initialize the database
        systemConfigurationRepository.saveAndFlush(systemConfiguration);
        systemConfigurationSearchRepository.save(systemConfiguration);
        int databaseSizeBeforeDelete = systemConfigurationRepository.findAll().size();

        // Get the systemConfiguration
        restSystemConfigurationMockMvc.perform(delete("/api/system-configurations/{id}", systemConfiguration.getId())
            .accept(TestUtil.APPLICATION_JSON_UTF8))
            .andExpect(status().isOk());

        // Validate Elasticsearch is empty
        boolean systemConfigurationExistsInEs = systemConfigurationSearchRepository.exists(systemConfiguration.getId());
        assertThat(systemConfigurationExistsInEs).isFalse();

        // Validate the database is empty
        List<SystemConfiguration> systemConfigurationList = systemConfigurationRepository.findAll();
        assertThat(systemConfigurationList).hasSize(databaseSizeBeforeDelete - 1);
    }

    @Test
    @Transactional
    public void searchSystemConfiguration() throws Exception {
        // Initialize the database
        systemConfigurationRepository.saveAndFlush(systemConfiguration);
        systemConfigurationSearchRepository.save(systemConfiguration);

        // Search the systemConfiguration
        restSystemConfigurationMockMvc.perform(get("/api/_search/system-configurations?query=id:" + systemConfiguration.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(systemConfiguration.getId().intValue())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].description").value(hasItem(DEFAULT_DESCRIPTION.toString())))
            .andExpect(jsonPath("$.[*].config").value(hasItem(DEFAULT_CONFIG.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void equalsVerifier() throws Exception {
        TestUtil.equalsVerifier(SystemConfiguration.class);
        SystemConfiguration systemConfiguration1 = new SystemConfiguration();
        systemConfiguration1.setId(1L);
        SystemConfiguration systemConfiguration2 = new SystemConfiguration();
        systemConfiguration2.setId(systemConfiguration1.getId());
        assertThat(systemConfiguration1).isEqualTo(systemConfiguration2);
        systemConfiguration2.setId(2L);
        assertThat(systemConfiguration1).isNotEqualTo(systemConfiguration2);
        systemConfiguration1.setId(null);
        assertThat(systemConfiguration1).isNotEqualTo(systemConfiguration2);
    }
}
