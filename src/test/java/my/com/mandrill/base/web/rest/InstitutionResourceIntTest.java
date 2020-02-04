package my.com.mandrill.base.web.rest;

import my.com.mandrill.base.BaseApp;

import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.repository.InstitutionRepository;
import my.com.mandrill.base.repository.search.InstitutionSearchRepository;
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
 * Test class for the InstitutionResource REST controller.
 *
 * @see InstitutionResource
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = BaseApp.class)
public class InstitutionResourceIntTest {

    private static final String DEFAULT_NAME = "AAAAAAAAAA";
    private static final String UPDATED_NAME = "BBBBBBBBBB";

    private static final String DEFAULT_TYPE = "AAAAAAAAAA";
    private static final String UPDATED_TYPE = "BBBBBBBBBB";

    private static final String DEFAULT_BUSINESS_REG_NO = "AAAAAAAAAA";
    private static final String UPDATED_BUSINESS_REG_NO = "BBBBBBBBBB";

    private static final String DEFAULT_INDUSTRY = "AAAAAAAAAA";
    private static final String UPDATED_INDUSTRY = "BBBBBBBBBB";

    private static final String DEFAULT_ADDRESS = "AAAAAAAAAA";
    private static final String UPDATED_ADDRESS = "BBBBBBBBBB";

    private static final String DEFAULT_PHONE = "AAAAAAAAAA";
    private static final String UPDATED_PHONE = "BBBBBBBBBB";

    private static final String DEFAULT_FAX = "AAAAAAAAAA";
    private static final String UPDATED_FAX = "BBBBBBBBBB";

    private static final String DEFAULT_EMAIL = "AAAAAAAAAA";
    private static final String UPDATED_EMAIL = "BBBBBBBBBB";

    private static final String DEFAULT_WEBSITE = "AAAAAAAAAA";
    private static final String UPDATED_WEBSITE = "BBBBBBBBBB";

    private static final String DEFAULT_CREATED_BY = "AAAAAAAAAA";
    private static final String UPDATED_CREATED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_CREATED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_CREATED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    private static final String DEFAULT_LAST_MODIFIED_BY = "AAAAAAAAAA";
    private static final String UPDATED_LAST_MODIFIED_BY = "BBBBBBBBBB";

    private static final ZonedDateTime DEFAULT_LAST_MODIFIED_DATE = ZonedDateTime.ofInstant(Instant.ofEpochMilli(0L), ZoneOffset.UTC);
    private static final ZonedDateTime UPDATED_LAST_MODIFIED_DATE = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

    @Autowired
    private InstitutionRepository institutionRepository;

    @Autowired
    private InstitutionSearchRepository institutionSearchRepository;

    @Autowired
    private MappingJackson2HttpMessageConverter jacksonMessageConverter;

    @Autowired
    private PageableHandlerMethodArgumentResolver pageableArgumentResolver;

    @Autowired
    private ExceptionTranslator exceptionTranslator;

    @Autowired
    private EntityManager em;

    private MockMvc restInstitutionMockMvc;

    private Institution institution;

    private AppService appService;

    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);
        final InstitutionResource institutionResource = new InstitutionResource(institutionRepository, institutionSearchRepository, appService, null);
        this.restInstitutionMockMvc = MockMvcBuilders.standaloneSetup(institutionResource)
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
    public static Institution createEntity(EntityManager em) {
        Institution institution = new Institution()
            .name(DEFAULT_NAME)
            .type(DEFAULT_TYPE)
            .businessRegNo(DEFAULT_BUSINESS_REG_NO)
            .industry(DEFAULT_INDUSTRY)
            .address(DEFAULT_ADDRESS)
            .phone(DEFAULT_PHONE)
            .fax(DEFAULT_FAX)
            .email(DEFAULT_EMAIL)
            .website(DEFAULT_WEBSITE);
        return institution;
    }

    @Before
    public void initTest() {
        institutionSearchRepository.deleteAll();
        institution = createEntity(em);
    }

    @Test
    @Transactional
    public void createInstitution() throws Exception {
        int databaseSizeBeforeCreate = institutionRepository.findAll().size();

        // Create the Institution
        restInstitutionMockMvc.perform(post("/api/institutions")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(institution)))
            .andExpect(status().isCreated());

        // Validate the Institution in the database
        List<Institution> institutionList = institutionRepository.findAll();
        assertThat(institutionList).hasSize(databaseSizeBeforeCreate + 1);
        Institution testInstitution = institutionList.get(institutionList.size() - 1);
        assertThat(testInstitution.getName()).isEqualTo(DEFAULT_NAME);
        assertThat(testInstitution.getType()).isEqualTo(DEFAULT_TYPE);
        assertThat(testInstitution.getBusinessRegNo()).isEqualTo(DEFAULT_BUSINESS_REG_NO);
        assertThat(testInstitution.getIndustry()).isEqualTo(DEFAULT_INDUSTRY);
        assertThat(testInstitution.getAddress()).isEqualTo(DEFAULT_ADDRESS);
        assertThat(testInstitution.getPhone()).isEqualTo(DEFAULT_PHONE);
        assertThat(testInstitution.getFax()).isEqualTo(DEFAULT_FAX);
        assertThat(testInstitution.getEmail()).isEqualTo(DEFAULT_EMAIL);
        assertThat(testInstitution.getWebsite()).isEqualTo(DEFAULT_WEBSITE);
        assertThat(testInstitution.getCreatedBy()).isEqualTo(DEFAULT_CREATED_BY);
        assertThat(testInstitution.getCreatedDate()).isEqualTo(DEFAULT_CREATED_DATE);
        assertThat(testInstitution.getLastModifiedBy()).isEqualTo(DEFAULT_LAST_MODIFIED_BY);
        assertThat(testInstitution.getLastModifiedDate()).isEqualTo(DEFAULT_LAST_MODIFIED_DATE);

        // Validate the Institution in Elasticsearch
        Institution institutionEs = institutionSearchRepository.findOne(testInstitution.getId());
        assertThat(testInstitution.getCreatedDate()).isEqualTo(testInstitution.getCreatedDate());
        assertThat(testInstitution.getLastModifiedDate()).isEqualTo(testInstitution.getLastModifiedDate());
        assertThat(institutionEs).isEqualToIgnoringGivenFields(testInstitution, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void createInstitutionWithExistingId() throws Exception {
        int databaseSizeBeforeCreate = institutionRepository.findAll().size();

        // Create the Institution with an existing ID
        institution.setId(1L);

        // An entity with an existing ID cannot be created, so this API call must fail
        restInstitutionMockMvc.perform(post("/api/institutions")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(institution)))
            .andExpect(status().isBadRequest());

        // Validate the Institution in the database
        List<Institution> institutionList = institutionRepository.findAll();
        assertThat(institutionList).hasSize(databaseSizeBeforeCreate);
    }

    @Test
    @Transactional
    public void checkNameIsRequired() throws Exception {
        int databaseSizeBeforeTest = institutionRepository.findAll().size();
        // set the field null
        institution.setName(null);

        // Create the Institution, which fails.

        restInstitutionMockMvc.perform(post("/api/institutions")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(institution)))
            .andExpect(status().isBadRequest());

        List<Institution> institutionList = institutionRepository.findAll();
        assertThat(institutionList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedByIsRequired() throws Exception {
        int databaseSizeBeforeTest = institutionRepository.findAll().size();
        // set the field null
        institution.setCreatedBy(null);

        // Create the Institution, which fails.

        restInstitutionMockMvc.perform(post("/api/institutions")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(institution)))
            .andExpect(status().isBadRequest());

        List<Institution> institutionList = institutionRepository.findAll();
        assertThat(institutionList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedDateIsRequired() throws Exception {
        int databaseSizeBeforeTest = institutionRepository.findAll().size();
        // set the field null
        institution.setCreatedDate(null);

        // Create the Institution, which fails.

        restInstitutionMockMvc.perform(post("/api/institutions")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(institution)))
            .andExpect(status().isBadRequest());

        List<Institution> institutionList = institutionRepository.findAll();
        assertThat(institutionList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void getAllInstitutions() throws Exception {
        // Initialize the database
        institutionRepository.saveAndFlush(institution);

        // Get all the institutionList
        restInstitutionMockMvc.perform(get("/api/institutions?sort=id,desc"))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(institution.getId().intValue())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].type").value(hasItem(DEFAULT_TYPE.toString())))
            .andExpect(jsonPath("$.[*].businessRegNo").value(hasItem(DEFAULT_BUSINESS_REG_NO.toString())))
            .andExpect(jsonPath("$.[*].industry").value(hasItem(DEFAULT_INDUSTRY.toString())))
            .andExpect(jsonPath("$.[*].address").value(hasItem(DEFAULT_ADDRESS.toString())))
            .andExpect(jsonPath("$.[*].phone").value(hasItem(DEFAULT_PHONE.toString())))
            .andExpect(jsonPath("$.[*].fax").value(hasItem(DEFAULT_FAX.toString())))
            .andExpect(jsonPath("$.[*].email").value(hasItem(DEFAULT_EMAIL.toString())))
            .andExpect(jsonPath("$.[*].website").value(hasItem(DEFAULT_WEBSITE.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void getInstitution() throws Exception {
        // Initialize the database
        institutionRepository.saveAndFlush(institution);

        // Get the institution
        restInstitutionMockMvc.perform(get("/api/institutions/{id}", institution.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.id").value(institution.getId().intValue()))
            .andExpect(jsonPath("$.name").value(DEFAULT_NAME.toString()))
            .andExpect(jsonPath("$.type").value(DEFAULT_TYPE.toString()))
            .andExpect(jsonPath("$.businessRegNo").value(DEFAULT_BUSINESS_REG_NO.toString()))
            .andExpect(jsonPath("$.industry").value(DEFAULT_INDUSTRY.toString()))
            .andExpect(jsonPath("$.address").value(DEFAULT_ADDRESS.toString()))
            .andExpect(jsonPath("$.phone").value(DEFAULT_PHONE.toString()))
            .andExpect(jsonPath("$.fax").value(DEFAULT_FAX.toString()))
            .andExpect(jsonPath("$.email").value(DEFAULT_EMAIL.toString()))
            .andExpect(jsonPath("$.website").value(DEFAULT_WEBSITE.toString()))
            .andExpect(jsonPath("$.createdBy").value(DEFAULT_CREATED_BY.toString()))
            .andExpect(jsonPath("$.createdDate").value(sameInstant(DEFAULT_CREATED_DATE)))
            .andExpect(jsonPath("$.lastModifiedBy").value(DEFAULT_LAST_MODIFIED_BY.toString()))
            .andExpect(jsonPath("$.lastModifiedDate").value(sameInstant(DEFAULT_LAST_MODIFIED_DATE)));
    }

    @Test
    @Transactional
    public void getNonExistingInstitution() throws Exception {
        // Get the institution
        restInstitutionMockMvc.perform(get("/api/institutions/{id}", Long.MAX_VALUE))
            .andExpect(status().isNotFound());
    }

    @Test
    @Transactional
    public void updateInstitution() throws Exception {
        // Initialize the database
        institutionRepository.saveAndFlush(institution);
        institutionSearchRepository.save(institution);
        int databaseSizeBeforeUpdate = institutionRepository.findAll().size();

        // Update the institution
        Institution updatedInstitution = institutionRepository.findOne(institution.getId());
        // Disconnect from session so that the updates on updatedInstitution are not directly saved in db
        em.detach(updatedInstitution);
        updatedInstitution
            .name(UPDATED_NAME)
            .type(UPDATED_TYPE)
            .businessRegNo(UPDATED_BUSINESS_REG_NO)
            .industry(UPDATED_INDUSTRY)
            .address(UPDATED_ADDRESS)
            .phone(UPDATED_PHONE)
            .fax(UPDATED_FAX)
            .email(UPDATED_EMAIL)
            .website(UPDATED_WEBSITE);

        restInstitutionMockMvc.perform(put("/api/institutions")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(updatedInstitution)))
            .andExpect(status().isOk());

        // Validate the Institution in the database
        List<Institution> institutionList = institutionRepository.findAll();
        assertThat(institutionList).hasSize(databaseSizeBeforeUpdate);
        Institution testInstitution = institutionList.get(institutionList.size() - 1);
        assertThat(testInstitution.getName()).isEqualTo(UPDATED_NAME);
        assertThat(testInstitution.getType()).isEqualTo(UPDATED_TYPE);
        assertThat(testInstitution.getBusinessRegNo()).isEqualTo(UPDATED_BUSINESS_REG_NO);
        assertThat(testInstitution.getIndustry()).isEqualTo(UPDATED_INDUSTRY);
        assertThat(testInstitution.getAddress()).isEqualTo(UPDATED_ADDRESS);
        assertThat(testInstitution.getPhone()).isEqualTo(UPDATED_PHONE);
        assertThat(testInstitution.getFax()).isEqualTo(UPDATED_FAX);
        assertThat(testInstitution.getEmail()).isEqualTo(UPDATED_EMAIL);
        assertThat(testInstitution.getWebsite()).isEqualTo(UPDATED_WEBSITE);
        assertThat(testInstitution.getCreatedBy()).isEqualTo(UPDATED_CREATED_BY);
        assertThat(testInstitution.getCreatedDate()).isEqualTo(UPDATED_CREATED_DATE);
        assertThat(testInstitution.getLastModifiedBy()).isEqualTo(UPDATED_LAST_MODIFIED_BY);
        assertThat(testInstitution.getLastModifiedDate()).isEqualTo(UPDATED_LAST_MODIFIED_DATE);

        // Validate the Institution in Elasticsearch
        Institution institutionEs = institutionSearchRepository.findOne(testInstitution.getId());
        assertThat(testInstitution.getCreatedDate()).isEqualTo(testInstitution.getCreatedDate());
        assertThat(testInstitution.getLastModifiedDate()).isEqualTo(testInstitution.getLastModifiedDate());
        assertThat(institutionEs).isEqualToIgnoringGivenFields(testInstitution, "createdDate", "lastModifiedDate");
    }

    @Test
    @Transactional
    public void updateNonExistingInstitution() throws Exception {
        int databaseSizeBeforeUpdate = institutionRepository.findAll().size();

        // Create the Institution

        // If the entity doesn't have an ID, it will be created instead of just being updated
        restInstitutionMockMvc.perform(put("/api/institutions")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(institution)))
            .andExpect(status().isCreated());

        // Validate the Institution in the database
        List<Institution> institutionList = institutionRepository.findAll();
        assertThat(institutionList).hasSize(databaseSizeBeforeUpdate + 1);
    }

    @Test
    @Transactional
    public void deleteInstitution() throws Exception {
        // Initialize the database
        institutionRepository.saveAndFlush(institution);
        institutionSearchRepository.save(institution);
        int databaseSizeBeforeDelete = institutionRepository.findAll().size();

        // Get the institution
        restInstitutionMockMvc.perform(delete("/api/institutions/{id}", institution.getId())
            .accept(TestUtil.APPLICATION_JSON_UTF8))
            .andExpect(status().isOk());

        // Validate Elasticsearch is empty
        boolean institutionExistsInEs = institutionSearchRepository.exists(institution.getId());
        assertThat(institutionExistsInEs).isFalse();

        // Validate the database is empty
        List<Institution> institutionList = institutionRepository.findAll();
        assertThat(institutionList).hasSize(databaseSizeBeforeDelete - 1);
    }

    @Test
    @Transactional
    public void searchInstitution() throws Exception {
        // Initialize the database
        institutionRepository.saveAndFlush(institution);
        institutionSearchRepository.save(institution);

        // Search the institution
        restInstitutionMockMvc.perform(get("/api/_search/institutions?query=id:" + institution.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(institution.getId().intValue())))
            .andExpect(jsonPath("$.[*].name").value(hasItem(DEFAULT_NAME.toString())))
            .andExpect(jsonPath("$.[*].type").value(hasItem(DEFAULT_TYPE.toString())))
            .andExpect(jsonPath("$.[*].businessRegNo").value(hasItem(DEFAULT_BUSINESS_REG_NO.toString())))
            .andExpect(jsonPath("$.[*].industry").value(hasItem(DEFAULT_INDUSTRY.toString())))
            .andExpect(jsonPath("$.[*].address").value(hasItem(DEFAULT_ADDRESS.toString())))
            .andExpect(jsonPath("$.[*].phone").value(hasItem(DEFAULT_PHONE.toString())))
            .andExpect(jsonPath("$.[*].fax").value(hasItem(DEFAULT_FAX.toString())))
            .andExpect(jsonPath("$.[*].email").value(hasItem(DEFAULT_EMAIL.toString())))
            .andExpect(jsonPath("$.[*].website").value(hasItem(DEFAULT_WEBSITE.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(sameInstant(DEFAULT_CREATED_DATE))))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(sameInstant(DEFAULT_LAST_MODIFIED_DATE))));
    }

    @Test
    @Transactional
    public void equalsVerifier() throws Exception {
        TestUtil.equalsVerifier(Institution.class);
        Institution institution1 = new Institution();
        institution1.setId(1L);
        Institution institution2 = new Institution();
        institution2.setId(institution1.getId());
        assertThat(institution1).isEqualTo(institution2);
        institution2.setId(2L);
        assertThat(institution1).isNotEqualTo(institution2);
        institution1.setId(null);
        assertThat(institution1).isNotEqualTo(institution2);
    }
}
