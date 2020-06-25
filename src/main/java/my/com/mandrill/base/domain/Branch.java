package my.com.mandrill.base.domain;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

import javax.persistence.*;
import javax.validation.constraints.*;

import org.springframework.data.elasticsearch.annotations.Document;
import java.io.Serializable;
import java.time.ZonedDateTime;
import java.util.Objects;

/**
 * A Branch.
 */
@Entity
@Table(name = "atm_branches")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "atm_branches")
public class Branch implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "abr_id")
    private Long id;

    @NotNull
    @Size(max = 50)
    @Column(name = "abr_name", length = 50, nullable = false)
    private String abr_name;

    @NotNull
    @Size(max = 50)
    @Column(name = "abr_contact", length = 50, nullable = false)
    private String abr_contact;
    
    @NotNull
    @Size(max = 50)
    @Column(name = "abr_alo_location_id", length = 50, nullable = false)
    private String abr_alo_location_id;

    @NotNull
    @Size(max = 8)
    @Column(name = "abr_code", length = 8, nullable = true)
    private String abr_code;
    
    @Column(name = "abr_last_update_ts")
    private ZonedDateTime abr_last_update_ts;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getAbr_name() {
		return abr_name;
	}

	public void setAbr_name(String abr_name) {
		this.abr_name = abr_name;
	}

	public String getAbr_contact() {
		return abr_contact;
	}

	public void setAbr_contact(String abr_contact) {
		this.abr_contact = abr_contact;
	}

	public String getAbr_alo_location_id() {
		return abr_alo_location_id;
	}

	public void setAbr_alo_allocation_id(String abr_alo_location_id) {
		this.abr_alo_location_id = abr_alo_location_id;
	}

	public String getAbr_code() {
		return abr_code;
	}

	public void setAbr_code(String abr_code) {
		this.abr_code = abr_code;
	}

	public ZonedDateTime getAbr_last_update_ts() {
		return abr_last_update_ts;
	}

	public void setAbr_last_update_ts(ZonedDateTime abr_last_update_ts) {
		this.abr_last_update_ts = abr_last_update_ts;
	}

	@Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Branch branch = (Branch) o;
        if (branch.getId() == null || getId() == null) {
            return false;
        }
        return Objects.equals(getId(), branch.getId());
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(getId());
    }

    @Override
    public String toString() {
        return "Branch{" +
            "id=" + getId() +
            ", abr_name='" + getAbr_name() + "'" +
            ", abr_contact='" + getAbr_contact() + "'" +
            ", abr_alo_allocation_id='" + getAbr_alo_location_id() + "'" +
            ", abr_code='" + getAbr_code() + "'" +
            "}";
    }
}
