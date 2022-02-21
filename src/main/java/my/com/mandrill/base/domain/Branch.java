package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.time.ZonedDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.springframework.data.elasticsearch.annotations.Document;

/**
 * A Branch.
 */
@Entity
@Table(name = "branch")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "branch")
public class Branch implements Serializable, Comparable<Branch> {

    private static final long serialVersionUID = 1L;

//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    @Column(name = "abr_id")
//    private Long id;

    @NotNull
    @Size(max = 50)
    @Column(name = "brc_name", length = 50, nullable = false)
    private String abr_name;

//    @NotNull
//    @Size(max = 50)
//    @Column(name = "abr_contact", length = 50, nullable = false)
//    private String abr_contact;
//    
//    @NotNull
//    @Size(max = 50)
//    @Column(name = "abr_alo_location_id", length = 50, nullable = false)
//    private String abr_alo_location_id;

    @Id
    @NotNull
    @Size(max = 8)
    @Column(name = "brc_code", length = 8, nullable = false)
    private String id;
    
    @Column(name = "brc_last_update_ts")
    private ZonedDateTime abr_last_update_ts;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getAbr_name() {
		return abr_name;
	}

	public void setAbr_name(String abr_name) {
		this.abr_name = abr_name;
	}

//	public String getAbr_contact() {
//		return abr_contact;
//	}
//
//	public void setAbr_contact(String abr_contact) {
//		this.abr_contact = abr_contact;
//	}
//
//	public String getAbr_alo_location_id() {
//		return abr_alo_location_id;
//	}
//
//	public void setAbr_alo_allocation_id(String abr_alo_location_id) {
//		this.abr_alo_location_id = abr_alo_location_id;
//	}

	public String getAbr_code() {
		return id;
	}

	public void setAbr_code(String abr_code) {
		this.id = abr_code;
	}

	public ZonedDateTime getAbr_last_update_ts() {
		return abr_last_update_ts;
	}

	public void setAbr_last_update_ts(ZonedDateTime abr_last_update_ts) {
		this.abr_last_update_ts = abr_last_update_ts;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((abr_name == null) ? 0 : abr_name.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Branch other = (Branch) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (abr_name == null) {
			if (other.abr_name != null)
				return false;
		} else if (!abr_name.equals(other.abr_name))
			return false;
		return true;
	}

	@Override
	public int compareTo(Branch o) {
		return this.abr_name.compareTo(o.getAbr_name());
	}

}
