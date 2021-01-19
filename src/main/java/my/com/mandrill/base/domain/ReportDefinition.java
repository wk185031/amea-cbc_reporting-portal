package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.time.ZonedDateTime;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.springframework.data.elasticsearch.annotations.Document;

import io.swagger.annotations.ApiModel;

/**
 * ReportDefinition, to support different reports
 */
@ApiModel(description = "ReportDefinition, to support different reports")
@Entity
@Table(name = "report_definition")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "report_definition")
public class ReportDefinition extends AbstractAuditingEventEntity implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "red_id")
	private Long id;

	@NotNull
	@Size(max = 100)
	@Column(name = "red_name", length = 100, nullable = false)
	private String name;

	@NotNull
	@Size(max = 255)
	@Column(name = "red_description", length = 255, nullable = false)
	private String description;

	@NotNull
	@Size(max = 100)
	@Column(name = "red_file_name_prefix", length = 100, nullable = false)
	private String fileNamePrefix;

	@NotNull
	@Size(max = 15)
	@Column(name = "red_file_format", length = 15, nullable = false)
	private String fileFormat;

	@Size(max = 255)
	@Column(name = "red_file_location", length = 255)
	private String fileLocation;

	@Size(max = 255)
	@Column(name = "red_processing_class", length = 255)
	private String processingClass;

	@NotNull
	@Size(max = 30)
	@Column(name = "red_frequency", length = 30, nullable = false)
	private String frequency;

	@Size(max = 300)
	@Column(name = "red_generated_path_csv", length = 300)
	private String generatedPathCsv;

	@Size(max = 300)
	@Column(name = "red_generated_path_txt", length = 300)
	private String generatedPathTxt;

	@Size(max = 300)
	@Column(name = "red_generated_path_pdf", length = 300)
	private String generatedPathPdf;

	@Size(max = 200)
	@Column(name = "red_generated_filename_csv", length = 200)
	private String generatedFileNameCsv;

	@Size(max = 200)
	@Column(name = "red_generated_filename_txt", length = 200)
	private String generatedFileNameTxt;

	@Size(max = 200)
	@Column(name = "red_generated_filename_pdf", length = 200)
	private String generatedFileNamePdf;

	@Column(name = "red_header_fields")
	private String headerFields;

	@Column(name = "red_body_fields")
	private String bodyFields;

	@Column(name = "red_trailer_fields")
	private String trailerFields;

	@Column(name = "red_body_query")
	private String bodyQuery;

	@Column(name = "red_trailer_query")
	private String trailerQuery;

	@Column(name = "red_branch_flag")
	private String branchFlag;
	
	@Column(name = "red_daily_schedule_time")
	private ZonedDateTime scheduleTime;
	
	@Column(name = "red_ins_id")
	private Long institutionId;
	
	@ManyToOne(optional = false)
	@NotNull
	@JoinColumn(name="red_rec_id", nullable=false)
	private ReportCategory category;

	// jhipster-needle-entity-add-field - JHipster will add fields here, do not
	// remove
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public ReportDefinition name(String name) {
		this.name = name;
		return this;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public ReportDefinition description(String description) {
		this.description = description;
		return this;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getFileNamePrefix() {
		return fileNamePrefix;
	}

	public ReportDefinition fileNamePrefix(String fileNamePrefix) {
		this.fileNamePrefix = fileNamePrefix;
		return this;
	}

	public void setFileNamePrefix(String fileNamePrefix) {
		this.fileNamePrefix = fileNamePrefix;
	}

	public String getFileFormat() {
		return fileFormat;
	}

	public ReportDefinition fileFormat(String fileFormat) {
		this.fileFormat = fileFormat;
		return this;
	}

	public void setFileFormat(String fileFormat) {
		this.fileFormat = fileFormat;
	}

	public String getFileLocation() {
		return fileLocation;
	}

	public ReportDefinition fileLocation(String fileLocation) {
		this.fileLocation = fileLocation;
		return this;
	}

	public void setFileLocation(String fileLocation) {
		this.fileLocation = fileLocation;
	}

	public String getProcessingClass() {
		return processingClass;
	}

	public ReportDefinition processingClass(String processingClass) {
		this.processingClass = processingClass;
		return this;
	}

	public void setProcessingClass(String processingClass) {
		this.processingClass = processingClass;
	}

	public String getFrequency() {
		return frequency;
	}

	public ReportDefinition frequency(String frequency) {
		this.frequency = frequency;
		return this;
	}

	public void setFrequency(String frequency) {
		this.frequency = frequency;
	}

	public String getGeneratedPathCsv() {
		return generatedPathCsv;
	}

	public ReportDefinition generatedPathCsv(String generatedPathCsv) {
		this.generatedPathCsv = generatedPathCsv;
		return this;
	}

	public void setGeneratedPathCsv(String generatedPathCsv) {
		this.generatedPathCsv = generatedPathCsv;
	}

	public String getGeneratedPathTxt() {
		return generatedPathTxt;
	}

	public ReportDefinition generatedPathTxt(String generatedPathTxt) {
		this.generatedPathTxt = generatedPathTxt;
		return this;
	}

	public void setGeneratedPathTxt(String generatedPathTxt) {
		this.generatedPathTxt = generatedPathTxt;
	}

	public String getGeneratedPathPdf() {
		return generatedPathPdf;
	}

	public ReportDefinition generatedPathPdf(String generatedPathPdf) {
		this.generatedPathPdf = generatedPathPdf;
		return this;
	}

	public void setGeneratedPathPdf(String generatedPathPdf) {
		this.generatedPathPdf = generatedPathPdf;
	}

	public String getGeneratedFileNameCsv() {
		return generatedFileNameCsv;
	}

	public ReportDefinition generatedFileNameCsv(String generatedFileNameCsv) {
		this.generatedFileNameCsv = generatedFileNameCsv;
		return this;
	}

	public void setGeneratedFileNameCsv(String generatedFileNameCsv) {
		this.generatedFileNameCsv = generatedFileNameCsv;
	}

	public String getGeneratedFileNameTxt() {
		return generatedFileNameTxt;
	}

	public ReportDefinition generatedFileNameTxt(String generatedFileNameTxt) {
		this.generatedFileNameTxt = generatedFileNameTxt;
		return this;
	}

	public void setGeneratedFileNameTxt(String generatedFileNameTxt) {
		this.generatedFileNameTxt = generatedFileNameTxt;
	}

	public String getGeneratedFileNamePdf() {
		return generatedFileNamePdf;
	}

	public ReportDefinition generatedFileNamePdf(String generatedFileNamePdf) {
		this.generatedFileNamePdf = generatedFileNamePdf;
		return this;
	}

	public void setGeneratedFileNamePdf(String generatedFileNamePdf) {
		this.generatedFileNamePdf = generatedFileNamePdf;
	}

	public String getHeaderFields() {
		return headerFields;
	}

	public ReportDefinition headerFields(String headerFields) {
		this.headerFields = headerFields;
		return this;
	}

	public void setHeaderFields(String headerFields) {
		this.headerFields = headerFields;
	}

	public String getBodyFields() {
		return bodyFields;
	}

	public ReportDefinition bodyFields(String bodyFields) {
		this.bodyFields = bodyFields;
		return this;
	}

	public void setBodyFields(String bodyFields) {
		this.bodyFields = bodyFields;
	}

	public String getTrailerFields() {
		return trailerFields;
	}

	public ReportDefinition trailerFields(String trailerFields) {
		this.trailerFields = trailerFields;
		return this;
	}

	public void setTrailerFields(String trailerFields) {
		this.trailerFields = trailerFields;
	}

	public String getBodyQuery() {
		return bodyQuery;
	}

	public ReportDefinition bodyQuery(String bodyQuery) {
		this.bodyQuery = bodyQuery;
		return this;
	}

	public void setBodyQuery(String bodyQuery) {
		this.bodyQuery = bodyQuery;
	}

	public String getTrailerQuery() {
		return trailerQuery;
	}

	public ReportDefinition trailerQuery(String trailerQuery) {
		this.trailerQuery = trailerQuery;
		return this;
	}

	public void setTrailerQuery(String trailerQuery) {
		this.trailerQuery = trailerQuery;
	}

	public ReportCategory getReportCategory() {
		return category;
	}

	public ReportDefinition reportCategory(ReportCategory category) {
		this.category = category;
		return this;
	}

	public void setReportCategory(ReportCategory category) {
		this.category = category;
	}
	
	public String getBranchFlag() {
		return branchFlag;
	}

	public ReportDefinition branchFlag(String branchFlag) {
		this.branchFlag = branchFlag;
		return this;
	}

	public void setBranchFlag(String branchFlag) {
		this.branchFlag = branchFlag;
	}
	
	public ZonedDateTime getScheduleTime() {
		return scheduleTime;
	}

	public ReportDefinition scheduleTime(ZonedDateTime scheduleTime) {
		this.scheduleTime = scheduleTime;
		return this;
	}

	public void setScheduleTime(ZonedDateTime scheduleTime) {
		this.scheduleTime = scheduleTime;
	}
	
	public Long getInstitutionId() {
		return this.institutionId;
	}

	public ReportDefinition institutionId(Long institutionId) {
		this.institutionId = institutionId;
		return this;
	}

	public void setInstitutionId(Long institutionId) {
		this.institutionId = institutionId;
	}
	
	// jhipster-needle-entity-add-getters-setters - JHipster will add getters and
	// setters here, do not remove
	@Override
	public boolean equals(Object o) {
		if (this == o) {
			return true;
		}
		if (o == null || getClass() != o.getClass()) {
			return false;
		}
		ReportDefinition reportDefinition = (ReportDefinition) o;
		if (reportDefinition.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), reportDefinition.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "ReportDefinition [id=" + id + ", name=" + name + ", description=" + description + ", fileNamePrefix="
				+ fileNamePrefix + ", fileFormat=" + fileFormat + ", fileLocation=" + fileLocation
				+ ", processingClass=" + processingClass + ", frequency=" + frequency + ", category=" + category.getName() 
				+ ", branchFlag=" + branchFlag + ", scheduleTime=" + scheduleTime + ", instutionId=" + institutionId + "]";
	}
}
