package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.time.ZonedDateTime;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.springframework.data.elasticsearch.annotations.Document;

import io.swagger.annotations.ApiModel;

/**
 * TaskGroup, to group various tasks together
 */
@ApiModel(description = "TaskGroup, to group various tasks together")
@Entity
@Table(name = "task_group")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "task_group")
public class TaskGroup implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@NotNull
    @Size(max = 100)
    @Column(name = "name", length = 100, nullable = false, unique = true)
    private String name;
	
    @Size(max = 1000)
    @Column(name = "description", length = 1000)
    private String description;
	
	@NotNull
    @Size(max = 100)
    @Column(name = "status", length = 100, nullable = false)
    private String status;	

    @NotNull
    @Column(name = "created_date", nullable = false)
    private ZonedDateTime createdDate;

	@NotNull
    @Size(max = 100)
    @Column(name = "created_by", length = 100, nullable = false)
    private String createdBy;
    
    @OneToOne(optional = false)
    @NotNull
    private Job job;

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

    public TaskGroup name(String name) {
        this.name = name;
        return this;
    }

    public void setName(String name) {
        this.name = name;
    }
    
    public String getDescription() {
        return description;
    }

    public TaskGroup description(String description) {
        this.description = description;
        return this;
    }

    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getStatus() {
        return status;
    }

    public TaskGroup status(String status) {
        this.status = status;
        return this;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
	public String getCreatedBy() {
        return createdBy;
    }

    public TaskGroup createdBy(String createdBy) {
        this.createdBy = createdBy;
        return this;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public ZonedDateTime getCreatedDate() {
        return createdDate;
    }

    public TaskGroup createdDate(ZonedDateTime createdDate) {
        this.createdDate = createdDate;
        return this;
    }

    public void setCreatedDate(ZonedDateTime createdDate) {
        this.createdDate = createdDate;
    }
    
    public Job getJob() {
		return job;
	}
    
    public TaskGroup job(Job job) {
        this.job = job;
        return this;
    }

	public void setJob(Job job) {
		this.job = job;
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
		TaskGroup taskGroup = (TaskGroup) o;
		if (taskGroup.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), taskGroup.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "TaskGroup{" +
	            "id=" + getId() +
	            ", name='" + getName() + "'" +
	            ", description='" + getDescription() + "'" +
	            ", status='" + getStatus() + "'" +
	            ", job='" + getJob() + "'" +
	            ", createdBy='" + getCreatedBy() + "'" +
	            ", createdDate='" + getCreatedDate() + "'" +
	            "}";
	}
}
