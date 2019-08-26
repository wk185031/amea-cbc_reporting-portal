package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.time.Instant;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.elasticsearch.annotations.Document;

import io.swagger.annotations.ApiModel;

/**
 * SecureKey, to store secure key
 */
@ApiModel(description = "SecureKey, to store secure key")
@Entity
@Table(name = "secure_key")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "secure_key")
public class SecureKey implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "seck_id")
	private Long id;

	@NotNull
	@Size(max = 40)
	@Column(name = "seck_name", length = 40, nullable = false)
	private String name;

	@NotNull
	@Size(max = 20)
	@Column(name = "seck_category", length = 20, nullable = false)
	private String category;

	@Lob
	@Column(name = "seck_data", nullable = true)
	private byte[] data;

	@Lob
	@Column(name = "seck_access", nullable = true)
	private byte[] access;

	@Column(name = "seck_crypto_period_warn_ts", nullable = true)
	private Instant cryptoPeriodWarnTs = Instant.now();

	@Column(name = "seck_crypto_period_elapsed_ts", nullable = true)
	private Instant cryptoPeriodElapsedTs = Instant.now();

	@LastModifiedDate
	@Column(name = "seck_last_update_ts", nullable = true)
	private Instant lastUpdateTs = Instant.now();

	@CreatedDate
	@Column(name = "seck_creation_ts", nullable = true)
	private Instant creationTs = Instant.now();

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public SecureKey name(String name) {
		this.name = name;
		return this;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCategory() {
		return category;
	}

	public SecureKey category(String category) {
		this.category = category;
		return this;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public byte[] getData() {
		return data;
	}

	public SecureKey data(byte[] data) {
		this.data = data;
		return this;
	}

	public void setData(byte[] data) {
		this.data = data;
	}

	public byte[] getAccess() {
		return access;
	}

	public SecureKey access(byte[] access) {
		this.access = access;
		return this;
	}

	public void setAccess(byte[] access) {
		this.access = access;
	}

	public Instant getCryptoPeriodWarnTs() {
		return cryptoPeriodWarnTs;
	}

	public SecureKey cryptoPeriodWarnTs(Instant cryptoPeriodWarnTs) {
		this.cryptoPeriodWarnTs = cryptoPeriodWarnTs;
		return this;
	}

	public void setCryptoPeriodWarnTs(Instant cryptoPeriodWarnTs) {
		this.cryptoPeriodWarnTs = cryptoPeriodWarnTs;
	}

	public Instant getCryptoPeriodElapsedTs() {
		return cryptoPeriodElapsedTs;
	}

	public SecureKey cryptoPeriodElapsedTs(Instant cryptoPeriodElapsedTs) {
		this.cryptoPeriodElapsedTs = cryptoPeriodElapsedTs;
		return this;
	}

	public void setCryptoPeriodElapsedTs(Instant cryptoPeriodElapsedTs) {
		this.cryptoPeriodElapsedTs = cryptoPeriodElapsedTs;
	}

	public Instant getLastUpdateTs() {
		return lastUpdateTs;
	}

	public SecureKey lastUpdateTs(Instant lastUpdateTs) {
		this.lastUpdateTs = lastUpdateTs;
		return this;
	}

	public void setLastUpdateTs(Instant lastUpdateTs) {
		this.lastUpdateTs = lastUpdateTs;
	}

	public Instant getCreatedTs() {
		return creationTs;
	}

	public SecureKey creationTs(Instant creationTs) {
		this.creationTs = creationTs;
		return this;
	}

	public void setCreatedTs(Instant creationTs) {
		this.creationTs = creationTs;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) {
			return true;
		}
		if (o == null || getClass() != o.getClass()) {
			return false;
		}
		SecureKey securityKey = (SecureKey) o;
		if (securityKey.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), securityKey.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "SecureKey [id=" + id + ", name=" + name + ", category=" + category + ", data=" + data + ", access="
				+ access + ", cryptoPeriodWarnTs=" + cryptoPeriodWarnTs + ", cryptoPeriodElapsedTs="
				+ cryptoPeriodElapsedTs + ", lastUpdateTs=" + lastUpdateTs + ", creationTs=" + creationTs + "]";
	}
}
