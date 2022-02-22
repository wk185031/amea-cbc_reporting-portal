package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.sql.Timestamp;
import java.time.ZonedDateTime;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.springframework.data.elasticsearch.annotations.Document;

@Entity
@Table(name = "password_history")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "password_history")
public class PasswordHistory implements Serializable {

	private static final long serialVersionUID = 1L;
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;
	
	@NotNull
    @Size(max = 60)
    @Column(name = "password_hash", length = 60, nullable = false)
    private String passwordHash;
	
	@Column(name = "password_change_ts")
    private Timestamp passwordChangeTs;
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}
	
	public String getPasswordHash() {
		return passwordHash;
	}

	public void setPasswordHash(String passwordHash) {
		this.passwordHash = passwordHash;
	}
	
	public Timestamp getPasswordChangeTs() {
		return passwordChangeTs;
	}

	public void setPasswordChangeTs(Timestamp passwordChangeTs) {
		this.passwordChangeTs = passwordChangeTs;
	}
	
	@Override
	public boolean equals(Object o) {
		if (this == o) {
			return true;
		}
		if (o == null || getClass() != o.getClass()) {
			return false;
		}
		PasswordHistory passwordHistory = (PasswordHistory) o;
		if (passwordHistory.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), passwordHistory.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "PasswordHistory{" +
				", id='" + getId() + "'" +
				", passwordHash='" + getPasswordHash() + "'" +
	            ", passwordChangeTs='" + getPasswordChangeTs() + "'" +
	            "}";
	}
	
	
}
