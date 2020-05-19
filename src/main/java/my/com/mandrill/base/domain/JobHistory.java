package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.Date;
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

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.InstantDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.InstantSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.ZonedDateTimeSerializer;

import io.swagger.annotations.ApiModel;

/**
 * JobHistory, to store history of job execution
 */
@ApiModel(description = "JobHistory, to store history of job execution")
@Entity
@Table(name = "job_history")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "job_history")
public class JobHistory implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;
	
	@ManyToOne(optional = false)
    @NotNull
    private Job job;
	
	@NotNull
    @Size(max = 100)
    @Column(name = "status", length = 100, nullable = false)
    private String status;

	@NotNull
    @Column(name = "created_date", nullable = false)
    private Instant createdDate;
    
    @NotNull
    @Size(max = 100)
    @Column(name = "created_by", length = 100, nullable = false)
    private String createdBy;

	// jhipster-needle-entity-add-field - JHipster will add fields here, do not
	// remove
    public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}
	
    public Job getJob() {
		return job;
	}
    
    public JobHistory job(Job job) {
        this.job = job;
        return this;
    }

	public void setJob(Job job) {
		this.job = job;
	}

	public String getStatus() {
        return status;
    }

    public JobHistory status(String status) {
        this.status = status;
        return this;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
	public String getCreatedBy() {
        return createdBy;
    }

    public JobHistory createdBy(String createdBy) {
        this.createdBy = createdBy;
        return this;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public Instant getCreatedDate() {
        return createdDate;
    }

    public JobHistory createdDate(Instant createdDate) {
        this.createdDate = createdDate;
        return this;
    }

    public void setCreatedDate(Instant createdDate) {
        this.createdDate = createdDate;
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
		JobHistory jobHistory = (JobHistory) o;
		if (jobHistory.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), jobHistory.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "JobHistory{" +
				", id='" + getId() + "'" +
				", job='" + getJob() + "'" +
	            ", status='" + getStatus() + "'" +
	            ", createdBy='" + getCreatedBy() + "'" +
	            ", createdDate='" + getCreatedDate() + "'" +
	            "}";
	}
}
