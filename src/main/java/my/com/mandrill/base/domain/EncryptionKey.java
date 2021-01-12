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
 * EncryptionKey, to store encryption key
 */
@ApiModel(description = "EncryptionKey, to store encryption key")
@Entity
@Table(name = "encryption_key")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "encryption_key")
public class EncryptionKey implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "eky_id")
	private Long id;

	@NotNull
	@Size(max = 255)
	@Column(name = "eky_class", length = 255, nullable = false)
	private String className;

	@Size(max = 50)
	@Column(name = "eky_check_value", length = 50, nullable = true)
	private String checkValue;

	@Lob
	@Column(name = "eky_key_data", nullable = true)
	private byte[] keyData;

	@NotNull
	@Size(max = 20)
	@Column(name = "eky_category", length = 20, nullable = false)
	private String category;

	@CreatedDate
	@Column(name = "eky_creation_ts", nullable = true)
	private Instant creationTs = Instant.now();

	@Column(name = "eky_crypto_period_elapsed_ts", nullable = true)
	private Instant cryptoPeriodElapsedTs = Instant.now();

	@Column(name = "eky_crypto_period_warn_ts", nullable = true)
	private Instant cryptoPeriodWarnTs = Instant.now();

	@Column(name = "eky_decommission_ts", nullable = true)
	private Instant decommissionTs = Instant.now();

	@LastModifiedDate
	@Column(name = "eky_last_update_ts", nullable = true)
	private Instant lastUpdateTs = Instant.now();

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getClassName() {
		return className;
	}

	public EncryptionKey className(String className) {
		this.className = className;
		return this;
	}

	public void setClassName(String className) {
		this.className = className;
	}

	public String getCheckValue() {
		return checkValue;
	}

	public EncryptionKey checkValue(String checkValue) {
		this.checkValue = checkValue;
		return this;
	}

	public void setCheckValue(String checkValue) {
		this.checkValue = checkValue;
	}

	public byte[] getKeyData() {
		return keyData;
	}

	public EncryptionKey keyData(byte[] keyData) {
		this.keyData = keyData;
		return this;
	}

	public void setKeyData(byte[] keyData) {
		this.keyData = keyData;
	}

	public String getCategory() {
		return category;
	}

	public EncryptionKey category(String category) {
		this.category = category;
		return this;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public Instant getCreationTs() {
		return creationTs;
	}

	public EncryptionKey creationTs(Instant creationTs) {
		this.creationTs = creationTs;
		return this;
	}

	public void setCreationTs(Instant creationTs) {
		this.creationTs = creationTs;
	}

	public Instant getCryptoPeriodElapsedTs() {
		return cryptoPeriodElapsedTs;
	}

	public EncryptionKey cryptoPeriodElapsedTs(Instant cryptoPeriodElapsedTs) {
		this.cryptoPeriodElapsedTs = cryptoPeriodElapsedTs;
		return this;
	}

	public void setCryptoPeriodElapsedTs(Instant cryptoPeriodElapsedTs) {
		this.cryptoPeriodElapsedTs = cryptoPeriodElapsedTs;
	}

	public Instant getCryptoPeriodWarnTs() {
		return cryptoPeriodWarnTs;
	}

	public EncryptionKey cryptoPeriodWarnTs(Instant cryptoPeriodWarnTs) {
		this.cryptoPeriodWarnTs = cryptoPeriodWarnTs;
		return this;
	}

	public void setCryptoPeriodWarnTs(Instant cryptoPeriodWarnTs) {
		this.cryptoPeriodWarnTs = cryptoPeriodWarnTs;
	}

	public Instant getDecommissionTs() {
		return decommissionTs;
	}

	public EncryptionKey decommissionTs(Instant decommissionTs) {
		this.decommissionTs = decommissionTs;
		return this;
	}

	public void setDecommissionTs(Instant decommissionTs) {
		this.decommissionTs = decommissionTs;
	}

	public Instant getLastUpdateTs() {
		return lastUpdateTs;
	}

	public EncryptionKey lastUpdateTs(Instant lastUpdateTs) {
		this.lastUpdateTs = lastUpdateTs;
		return this;
	}

	public void setLastUpdateTs(Instant lastUpdateTs) {
		this.lastUpdateTs = lastUpdateTs;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) {
			return true;
		}
		if (o == null || getClass() != o.getClass()) {
			return false;
		}
		EncryptionKey encryptionKey = (EncryptionKey) o;
		if (encryptionKey.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), encryptionKey.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "EncryptionKey [id=" + id + ", className=" + className + ", checkValue=" + checkValue + ", keyData="
				+ keyData + ", category=" + category + ", creationTs=" + creationTs + ", cryptoPeriodElapsedTs="
				+ cryptoPeriodElapsedTs + ", cryptoPeriodWarnTs=" + cryptoPeriodWarnTs + ", decommissionTs="
				+ decommissionTs + ", lastUpdateTs=" + lastUpdateTs + "]";
	}
}
