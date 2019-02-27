package my.com.mandrill.base.web.rest;

import my.com.mandrill.base.BaseApp;

import my.com.mandrill.base.domain.AttachmentGroup;
import my.com.mandrill.base.repository.AttachmentGroupRepository;
import my.com.mandrill.base.repository.search.AttachmentGroupSearchRepository;
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
import java.time.temporal.ChronoUnit;
import java.util.List;

import static my.com.mandrill.base.web.rest.TestUtil.createFormattingConversionService;
import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Test class for the AttachmentGroupResource REST controller.
 *
 * @see AttachmentGroupResource
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = BaseApp.class)
public class AttachmentGroupResourceIntTest {

    private static final String DEFAULT_ENTITY = "AAAAAAAAAA";
    private static final String UPDATED_ENTITY = "BBBBBBBBBB";

    private static final String DEFAULT_CREATED_BY = "AAAAAAAAAA";
    private static final String UPDATED_CREATED_BY = "BBBBBBBBBB";

    private static final Instant DEFAULT_CREATED_DATE = Instant.ofEpochMilli(0L);
    private static final Instant UPDATED_CREATED_DATE = Instant.now().truncatedTo(ChronoUnit.MILLIS);

    private static final String DEFAULT_LAST_MODIFIED_BY = "AAAAAAAAAA";
    private static final String UPDATED_LAST_MODIFIED_BY = "BBBBBBBBBB";

    private static final Instant DEFAULT_LAST_MODIFIED_DATE = Instant.ofEpochMilli(0L);
    private static final Instant UPDATED_LAST_MODIFIED_DATE = Instant.now().truncatedTo(ChronoUnit.MILLIS);

    @Autowired
    private AttachmentGroupRepository attachmentGroupRepository;

    @Autowired
    private AttachmentGroupSearchRepository attachmentGroupSearchRepository;

    @Autowired
    private MappingJackson2HttpMessageConverter jacksonMessageConverter;

    @Autowired
    private PageableHandlerMethodArgumentResolver pageableArgumentResolver;

    @Autowired
    private ExceptionTranslator exceptionTranslator;

    @Autowired
    private EntityManager em;

    private MockMvc restAttachmentGroupMockMvc;

    private AttachmentGroup attachmentGroup;

    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);
        final AttachmentGroupResource attachmentGroupResource = new AttachmentGroupResource(attachmentGroupRepository, attachmentGroupSearchRepository);
        this.restAttachmentGroupMockMvc = MockMvcBuilders.standaloneSetup(attachmentGroupResource)
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
    public static AttachmentGroup createEntity(EntityManager em) {
        AttachmentGroup attachmentGroup = new AttachmentGroup()
            .entity(DEFAULT_ENTITY)
            .createdBy(DEFAULT_CREATED_BY)
            .createdDate(DEFAULT_CREATED_DATE)
            .lastModifiedBy(DEFAULT_LAST_MODIFIED_BY)
            .lastModifiedDate(DEFAULT_LAST_MODIFIED_DATE);
        return attachmentGroup;
    }

    @Before
    public void initTest() {
        attachmentGroupSearchRepository.deleteAll();
        attachmentGroup = createEntity(em);
    }

    @Test
    @Transactional
    public void createAttachmentGroup() throws Exception {
        int databaseSizeBeforeCreate = attachmentGroupRepository.findAll().size();

        // Create the AttachmentGroup
        restAttachmentGroupMockMvc.perform(post("/api/attachment-groups")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(attachmentGroup)))
            .andExpect(status().isCreated());

        // Validate the AttachmentGroup in the database
        List<AttachmentGroup> attachmentGroupList = attachmentGroupRepository.findAll();
        assertThat(attachmentGroupList).hasSize(databaseSizeBeforeCreate + 1);
        AttachmentGroup testAttachmentGroup = attachmentGroupList.get(attachmentGroupList.size() - 1);
        assertThat(testAttachmentGroup.getEntity()).isEqualTo(DEFAULT_ENTITY);
        assertThat(testAttachmentGroup.getCreatedBy()).isEqualTo(DEFAULT_CREATED_BY);
        assertThat(testAttachmentGroup.getCreatedDate()).isEqualTo(DEFAULT_CREATED_DATE);
        assertThat(testAttachmentGroup.getLastModifiedBy()).isEqualTo(DEFAULT_LAST_MODIFIED_BY);
        assertThat(testAttachmentGroup.getLastModifiedDate()).isEqualTo(DEFAULT_LAST_MODIFIED_DATE);

        // Validate the AttachmentGroup in Elasticsearch
        AttachmentGroup attachmentGroupEs = attachmentGroupSearchRepository.findOne(testAttachmentGroup.getId());
        assertThat(attachmentGroupEs).isEqualToIgnoringGivenFields(testAttachmentGroup);
    }

    @Test
    @Transactional
    public void createAttachmentGroupWithExistingId() throws Exception {
        int databaseSizeBeforeCreate = attachmentGroupRepository.findAll().size();

        // Create the AttachmentGroup with an existing ID
        attachmentGroup.setId(1L);

        // An entity with an existing ID cannot be created, so this API call must fail
        restAttachmentGroupMockMvc.perform(post("/api/attachment-groups")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(attachmentGroup)))
            .andExpect(status().isBadRequest());

        // Validate the AttachmentGroup in the database
        List<AttachmentGroup> attachmentGroupList = attachmentGroupRepository.findAll();
        assertThat(attachmentGroupList).hasSize(databaseSizeBeforeCreate);
    }

    @Test
    @Transactional
    public void checkEntityIsRequired() throws Exception {
        int databaseSizeBeforeTest = attachmentGroupRepository.findAll().size();
        // set the field null
        attachmentGroup.setEntity(null);

        // Create the AttachmentGroup, which fails.

        restAttachmentGroupMockMvc.perform(post("/api/attachment-groups")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(attachmentGroup)))
            .andExpect(status().isBadRequest());

        List<AttachmentGroup> attachmentGroupList = attachmentGroupRepository.findAll();
        assertThat(attachmentGroupList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedByIsRequired() throws Exception {
        int databaseSizeBeforeTest = attachmentGroupRepository.findAll().size();
        // set the field null
        attachmentGroup.setCreatedBy(null);

        // Create the AttachmentGroup, which fails.

        restAttachmentGroupMockMvc.perform(post("/api/attachment-groups")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(attachmentGroup)))
            .andExpect(status().isBadRequest());

        List<AttachmentGroup> attachmentGroupList = attachmentGroupRepository.findAll();
        assertThat(attachmentGroupList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void checkCreatedDateIsRequired() throws Exception {
        int databaseSizeBeforeTest = attachmentGroupRepository.findAll().size();
        // set the field null
        attachmentGroup.setCreatedDate(null);

        // Create the AttachmentGroup, which fails.

        restAttachmentGroupMockMvc.perform(post("/api/attachment-groups")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(attachmentGroup)))
            .andExpect(status().isBadRequest());

        List<AttachmentGroup> attachmentGroupList = attachmentGroupRepository.findAll();
        assertThat(attachmentGroupList).hasSize(databaseSizeBeforeTest);
    }

    @Test
    @Transactional
    public void getAllAttachmentGroups() throws Exception {
        // Initialize the database
        attachmentGroupRepository.saveAndFlush(attachmentGroup);

        // Get all the attachmentGroupList
        restAttachmentGroupMockMvc.perform(get("/api/attachment-groups?sort=id,desc"))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(attachmentGroup.getId().intValue())))
            .andExpect(jsonPath("$.[*].entity").value(hasItem(DEFAULT_ENTITY.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(DEFAULT_CREATED_DATE.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(DEFAULT_LAST_MODIFIED_DATE.toString())));
    }

    @Test
    @Transactional
    public void getAttachmentGroup() throws Exception {
        // Initialize the database
        attachmentGroupRepository.saveAndFlush(attachmentGroup);

        // Get the attachmentGroup
        restAttachmentGroupMockMvc.perform(get("/api/attachment-groups/{id}", attachmentGroup.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.id").value(attachmentGroup.getId().intValue()))
            .andExpect(jsonPath("$.entity").value(DEFAULT_ENTITY.toString()))
            .andExpect(jsonPath("$.createdBy").value(DEFAULT_CREATED_BY.toString()))
            .andExpect(jsonPath("$.createdDate").value(DEFAULT_CREATED_DATE.toString()))
            .andExpect(jsonPath("$.lastModifiedBy").value(DEFAULT_LAST_MODIFIED_BY.toString()))
            .andExpect(jsonPath("$.lastModifiedDate").value(DEFAULT_LAST_MODIFIED_DATE.toString()));
    }

    @Test
    @Transactional
    public void getNonExistingAttachmentGroup() throws Exception {
        // Get the attachmentGroup
        restAttachmentGroupMockMvc.perform(get("/api/attachment-groups/{id}", Long.MAX_VALUE))
            .andExpect(status().isNotFound());
    }

    @Test
    @Transactional
    public void updateAttachmentGroup() throws Exception {
        // Initialize the database
        attachmentGroupRepository.saveAndFlush(attachmentGroup);
        attachmentGroupSearchRepository.save(attachmentGroup);
        int databaseSizeBeforeUpdate = attachmentGroupRepository.findAll().size();

        // Update the attachmentGroup
        AttachmentGroup updatedAttachmentGroup = attachmentGroupRepository.findOne(attachmentGroup.getId());
        // Disconnect from session so that the updates on updatedAttachmentGroup are not directly saved in db
        em.detach(updatedAttachmentGroup);
        updatedAttachmentGroup
            .entity(UPDATED_ENTITY)
            .createdBy(UPDATED_CREATED_BY)
            .createdDate(UPDATED_CREATED_DATE)
            .lastModifiedBy(UPDATED_LAST_MODIFIED_BY)
            .lastModifiedDate(UPDATED_LAST_MODIFIED_DATE);

        restAttachmentGroupMockMvc.perform(put("/api/attachment-groups")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(updatedAttachmentGroup)))
            .andExpect(status().isOk());

        // Validate the AttachmentGroup in the database
        List<AttachmentGroup> attachmentGroupList = attachmentGroupRepository.findAll();
        assertThat(attachmentGroupList).hasSize(databaseSizeBeforeUpdate);
        AttachmentGroup testAttachmentGroup = attachmentGroupList.get(attachmentGroupList.size() - 1);
        assertThat(testAttachmentGroup.getEntity()).isEqualTo(UPDATED_ENTITY);
        assertThat(testAttachmentGroup.getCreatedBy()).isEqualTo(UPDATED_CREATED_BY);
        assertThat(testAttachmentGroup.getCreatedDate()).isEqualTo(UPDATED_CREATED_DATE);
        assertThat(testAttachmentGroup.getLastModifiedBy()).isEqualTo(UPDATED_LAST_MODIFIED_BY);
        assertThat(testAttachmentGroup.getLastModifiedDate()).isEqualTo(UPDATED_LAST_MODIFIED_DATE);

        // Validate the AttachmentGroup in Elasticsearch
        AttachmentGroup attachmentGroupEs = attachmentGroupSearchRepository.findOne(testAttachmentGroup.getId());
        assertThat(attachmentGroupEs).isEqualToIgnoringGivenFields(testAttachmentGroup);
    }

    @Test
    @Transactional
    public void updateNonExistingAttachmentGroup() throws Exception {
        int databaseSizeBeforeUpdate = attachmentGroupRepository.findAll().size();

        // Create the AttachmentGroup

        // If the entity doesn't have an ID, it will be created instead of just being updated
        restAttachmentGroupMockMvc.perform(put("/api/attachment-groups")
            .contentType(TestUtil.APPLICATION_JSON_UTF8)
            .content(TestUtil.convertObjectToJsonBytes(attachmentGroup)))
            .andExpect(status().isCreated());

        // Validate the AttachmentGroup in the database
        List<AttachmentGroup> attachmentGroupList = attachmentGroupRepository.findAll();
        assertThat(attachmentGroupList).hasSize(databaseSizeBeforeUpdate + 1);
    }

    @Test
    @Transactional
    public void deleteAttachmentGroup() throws Exception {
        // Initialize the database
        attachmentGroupRepository.saveAndFlush(attachmentGroup);
        attachmentGroupSearchRepository.save(attachmentGroup);
        int databaseSizeBeforeDelete = attachmentGroupRepository.findAll().size();

        // Get the attachmentGroup
        restAttachmentGroupMockMvc.perform(delete("/api/attachment-groups/{id}", attachmentGroup.getId())
            .accept(TestUtil.APPLICATION_JSON_UTF8))
            .andExpect(status().isOk());

        // Validate Elasticsearch is empty
        boolean attachmentGroupExistsInEs = attachmentGroupSearchRepository.exists(attachmentGroup.getId());
        assertThat(attachmentGroupExistsInEs).isFalse();

        // Validate the database is empty
        List<AttachmentGroup> attachmentGroupList = attachmentGroupRepository.findAll();
        assertThat(attachmentGroupList).hasSize(databaseSizeBeforeDelete - 1);
    }

    @Test
    @Transactional
    public void searchAttachmentGroup() throws Exception {
        // Initialize the database
        attachmentGroupRepository.saveAndFlush(attachmentGroup);
        attachmentGroupSearchRepository.save(attachmentGroup);

        // Search the attachmentGroup
        restAttachmentGroupMockMvc.perform(get("/api/_search/attachment-groups?query=id:" + attachmentGroup.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andExpect(jsonPath("$.[*].id").value(hasItem(attachmentGroup.getId().intValue())))
            .andExpect(jsonPath("$.[*].entity").value(hasItem(DEFAULT_ENTITY.toString())))
            .andExpect(jsonPath("$.[*].createdBy").value(hasItem(DEFAULT_CREATED_BY.toString())))
            .andExpect(jsonPath("$.[*].createdDate").value(hasItem(DEFAULT_CREATED_DATE.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedBy").value(hasItem(DEFAULT_LAST_MODIFIED_BY.toString())))
            .andExpect(jsonPath("$.[*].lastModifiedDate").value(hasItem(DEFAULT_LAST_MODIFIED_DATE.toString())));
    }

    @Test
    @Transactional
    public void equalsVerifier() throws Exception {
        TestUtil.equalsVerifier(AttachmentGroup.class);
        AttachmentGroup attachmentGroup1 = new AttachmentGroup();
        attachmentGroup1.setId(1L);
        AttachmentGroup attachmentGroup2 = new AttachmentGroup();
        attachmentGroup2.setId(attachmentGroup1.getId());
        assertThat(attachmentGroup1).isEqualTo(attachmentGroup2);
        attachmentGroup2.setId(2L);
        assertThat(attachmentGroup1).isNotEqualTo(attachmentGroup2);
        attachmentGroup1.setId(null);
        assertThat(attachmentGroup1).isNotEqualTo(attachmentGroup2);
    }
}
