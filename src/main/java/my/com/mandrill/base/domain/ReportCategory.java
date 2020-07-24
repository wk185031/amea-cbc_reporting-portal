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
 * ReportCategory, to support different categories of reports
 */
@ApiModel(description = "ReportCategory, to support different categories of reports")
@Entity
@Table(name = "report_category")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "report_category")
public class ReportCategory extends AbstractAuditingEventEntity implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "rec_id")
	private Long id;

	@NotNull
	@Size(max = 100)
	@Column(name = "rec_name", length = 100, nullable = false)
	private String name;

	@NotNull
	@Size(max = 255)
	@Column(name = "rec_description", length = 255, nullable = false)
	private String description;
	
	@Size(max = 255)
	@Column(name = "rec_branch_flag")
	private String branchFlag;
	
	
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

	public ReportCategory name(String name) {
		this.name = name;
		return this;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public ReportCategory description(String description) {
		this.description = description;
		return this;
	}

	public void setDescription(String description) {
		this.description = description;
	}
	
	public String getBranchFlag() {
		return branchFlag;
	}

	public ReportCategory branchFlag(String branchFlag) {
		this.branchFlag = branchFlag;
		return this;
	}

	public void setBranchFlag(String branchFlag) {
		this.branchFlag = branchFlag;
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
		ReportCategory reportCategory = (ReportCategory) o;
		if (reportCategory.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), reportCategory.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "ReportCategory{" +
        "id=" + getId() +
        ", name='" + getName() + "'" +
        ", description='" + getDescription() + "'" +
        ", branch='" + getBranchFlag() + "'" +
        ", createdBy='" + getCreatedBy() + "'" +
        ", createdDate='" + getCreatedDate() + "'" +
        ", lastModifiedBy='" + getLastModifiedBy() + "'" +
        ", lastModifiedDate='" + getLastModifiedDate() + "'" +
        "}";
	}
}
