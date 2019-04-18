package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.time.Instant;
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
 * ReportGeneration, to generate different reports manually
 */
@ApiModel(description = "ReportGeneration, to generate different reports manually")
@Entity
@Table(name = "report_generation")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "report_generation")
public class ReportGeneration extends AbstractAuditingEventEntity implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "rge_id")
	private Long id;

	@NotNull
	@Size(max = 10)
	@Column(name = "rge_file_date", length = 10, nullable = false)
	private String fileDate;

	@NotNull
	@Column(name = "rge_txn_start_time", nullable = false)
	private Instant txnStartTime;

	@NotNull
	@Column(name = "rge_txn_end_time", nullable = false)
	private Instant txnEndTime;

	@Size(max = 1)
	@Column(name = "rge_gen_instant", length = 1)
	private String genInstant;

	@Size(max = 1)
	@Column(name = "rge_gen_specific", length = 1)
	private String genSpecific;

	@Column(name = "rge_gen_specific_time")
	private Instant genSpecificTime;

	@ManyToOne(optional = false)
	@NotNull
	private ReportDefinition rge;

	// jhipster-needle-entity-add-field - JHipster will add fields here, do not
	// remove
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getFileDate() {
		return fileDate;
	}
	
	public ReportGeneration fileDate(String fileDate) {
		this.fileDate = fileDate;
		return this;
	}

	public void setFileDate(String fileDate) {
		this.fileDate = fileDate;
	}

	public Instant getTxnStartTime() {
		return txnStartTime;
	}
	
	public ReportGeneration txnStartTime(Instant txnStartTime) {
		this.txnStartTime = txnStartTime;
		return this;
	}

	public void setTxnStartTime(Instant txnStartTime) {
		this.txnStartTime = txnStartTime;
	}

	public Instant getTxnEndTime() {
		return txnEndTime;
	}

	public ReportGeneration txnEndTime(Instant txnEndTime) {
		this.txnEndTime = txnEndTime;
		return this;
	}
	
	public void setTxnEndTime(Instant txnEndTime) {
		this.txnEndTime = txnEndTime;
	}

	public String getGenInstant() {
		return genInstant;
	}
	
	public ReportGeneration genInstant(String genInstant) {
		this.genInstant = genInstant;
		return this;
	}

	public void setGenInstant(String genInstant) {
		this.genInstant = genInstant;
	}

	public String getGenSpecific() {
		return genSpecific;
	}
	
	public ReportGeneration genSpecific(String genSpecific) {
		this.genSpecific = genSpecific;
		return this;
	}

	public void setGenSpecific(String genSpecific) {
		this.genSpecific = genSpecific;
	}

	public Instant getGenSpecificTime() {
		return genSpecificTime;
	}
	
	public ReportGeneration genSpecificTime(Instant genSpecificTime) {
		this.genSpecificTime = genSpecificTime;
		return this;
	}

	public void setGenSpecificTime(Instant genSpecificTime) {
		this.genSpecificTime = genSpecificTime;
	}

	public ReportDefinition getReportDefinition() {
		return rge;
	}

	public ReportGeneration reportDefinition(ReportDefinition rge) {
		this.rge = rge;
		return this;
	}

	public void setReportDefinition(ReportDefinition rge) {
		this.rge = rge;
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
		ReportGeneration reportGeneration = (ReportGeneration) o;
		if (reportGeneration.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), reportGeneration.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "ReportDefinition{" +
	            "id=" + getId() +
	            ", fileDate='" + getFileDate() + "'" +
	            ", txnStartTime='" + getTxnStartTime() + "'" +
	            ", txnEndTime='" + getTxnEndTime() + "'" +
	            ", genInstant='" + getGenInstant() + "'" +
	            ", genSpecific='" + getGenSpecific() + "'" +
	            ", genSpecificTime='" + getGenSpecificTime() + "'" +
	            ", createdBy='" + getCreatedBy() + "'" +
	            ", createdDate='" + getCreatedDate() + "'" +
	            ", lastModifiedBy='" + getLastModifiedBy() + "'" +
	            ", lastModifiedDate='" + getLastModifiedDate() + "'" +
	            "}";
	}
}
