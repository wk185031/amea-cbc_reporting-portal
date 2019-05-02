package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.time.ZonedDateTime;
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
 * Task, to perform an action
 */
@ApiModel(description = "Task, to perform an action")
@Entity
@Table(name = "task")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "task")
public class Task implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	@NotNull
    @Size(max = 100)
    @Column(name = "name", length = 100, nullable = false)
    private String name;
	
    @Size(max = 1000)
    @Column(name = "description", length = 1000)
    private String description;
    
    @Size(max = 3000)
    @Column(name = "content", length = 3000)
    private String content;
    
    @NotNull
    @Column(name = "sequence", nullable = false)
	private Integer sequence;

	@NotNull
    @Size(max = 100)
    @Column(name = "status", length = 100, nullable = false)
    private String status;

	@NotNull
    @Size(max = 100)
    @Column(name = "type", length = 100, nullable = false)
    private String type;

    @NotNull
    @Column(name = "created_date", nullable = false)
    private ZonedDateTime createdDate;
    
    @NotNull
    @Size(max = 100)
    @Column(name = "created_by", length = 100, nullable = false)
    private String createdBy;
    
    @ManyToOne(optional = false)
    @NotNull
    private TaskGroup taskGroup;

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

    public Task name(String name) {
        this.name = name;
        return this;
    }

    public void setName(String name) {
        this.name = name;
    }
    
    public String getDescription() {
        return description;
    }

    public Task description(String description) {
        this.description = description;
        return this;
    }

    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getStatus() {
        return status;
    }

    public Task status(String status) {
        this.status = status;
        return this;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getContent() {
		return content;
	}
    
    public Task content(String content) {
        this.content = content;
        return this;
    }

	public void setContent(String content) {
		this.content = content;
	}
	
	public Integer getSequence() {
		return sequence;
	}
	
	public Task sequence(Integer sequence) {
        this.sequence = sequence;
        return this;
    }

	public void setSequence(Integer sequence) {
		this.sequence = sequence;
	}
    
    public String getType() {
        return type;
    }

    public Task type(String type) {
        this.type = type;
        return this;
    }

    public void setType(String type) {
        this.type = type;
    }
    
	public String getCreatedBy() {
        return createdBy;
    }

    public Task createdBy(String createdBy) {
        this.createdBy = createdBy;
        return this;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public ZonedDateTime getCreatedDate() {
        return createdDate;
    }

    public Task createdDate(ZonedDateTime createdDate) {
        this.createdDate = createdDate;
        return this;
    }

    public void setCreatedDate(ZonedDateTime createdDate) {
        this.createdDate = createdDate;
    }
    
    public TaskGroup getTaskGroup() {
        return taskGroup;
    }

    public Task taskGroup(TaskGroup taskGroup) {
        this.taskGroup = taskGroup;
        return this;
    }

    public void setTaskGroup(TaskGroup taskGroup) {
        this.taskGroup = taskGroup;
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
		Task Task = (Task) o;
		if (Task.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), Task.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "Task{" +
	            "id=" + getId() +
	            ", name='" + getName() + "'" +
	            ", description='" + getDescription() + "'" +
	            ", status='" + getStatus() + "'" +
	            ", type='" + getType() + "'" +
	            ", createdBy='" + getCreatedBy() + "'" +
	            ", createdDate='" + getCreatedDate() + "'" +
	            "}";
	}
}
