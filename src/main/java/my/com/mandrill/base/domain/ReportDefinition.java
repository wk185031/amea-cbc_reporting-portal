package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
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

	@Size(max = 1000)
	@Column(name = "red_header_fields", length = 1000)
	private String headerFields;

	@Size(max = 1000)
	@Column(name = "red_body_fields", length = 1000)
	private String bodyFields;

	@Size(max = 1000)
	@Column(name = "red_trailer_fields", length = 1000)
	private String trailerFields;

	@Size(max = 2000)
	@Column(name = "red_query", length = 2000)
	private String query;

	@ManyToOne(optional = false)
	@NotNull
	private ReportCategory red;

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

	public String getQuery() {
		return query;
	}

	public ReportDefinition query(String query) {
		this.query = query;
		return this;
	}

	public void setQuery(String query) {
		this.query = query;
	}

	public ReportCategory getReportCategory() {
		return red;
	}

	public ReportDefinition reportCategory(ReportCategory red) {
		this.red = red;
		return this;
	}

	public void setReportCategory(ReportCategory red) {
		this.red = red;
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
		return "ReportDefinition{" + 
				"id=" + getId() + 
				", name='" + getName() + "'" + 
				", description='" + getDescription() + "'" + 
				", fileNamePrefix='" + getFileNamePrefix() + "'" + 
				", fileFormat='" + getFileFormat() + "'" + 
				", fileLocation='" + getFileLocation() + "'" + 
				", processingClass='" + getProcessingClass() + "'" + 
				", headerFields='" + getHeaderFields() + "'" + 
				", bodyFields='" + getBodyFields() + "'" + 
				", trailerFields='" + getTrailerFields() + "'" + 
				", query='" + getQuery() + "'" + 
				", createdBy='" + getCreatedBy() + "'" + 
				", createdDate='" + getCreatedDate() + "'" + 
				", lastModifiedBy='" + getLastModifiedBy() + "'" + 
				", lastModifiedDate='" + getLastModifiedDate() + "'" + 
				"}";
	}
}
