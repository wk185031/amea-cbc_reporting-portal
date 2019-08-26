package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.time.Instant;
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
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.elasticsearch.annotations.Document;

import io.swagger.annotations.ApiModel;

/**
 * SecurityParameters, to store security parameters
 */
@ApiModel(description = "SecurityParameters, to store security parameters")
@Entity
@Table(name = "security_parameters")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "security_parameters")
public class SecurityParameters implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "secp_id")
	private Long id;

	@NotNull
	@Size(max = 40)
	@Column(name = "secp_name", length = 40, nullable = false)
	private String name;

	@NotNull
	@Size(max = 20)
	@Column(name = "secp_category", length = 20, nullable = false)
	private String category;

	@Size(max = 20)
	@Column(name = "secp_status", length = 20, nullable = true)
	private String status;

	@NotNull
	@Size(max = 19)
	@Column(name = "secp_current_eky_id", length = 19, nullable = false)
	private Long currentEkyId;

	@NotNull
	@Size(max = 20)
	@Column(name = "secp_database_format", length = 20, nullable = false)
	private String databaseFormat;

	@NotNull
	@Size(max = 20)
	@Column(name = "secp_log_format", length = 20, nullable = false)
	private String logFormat;

	@NotNull
	@Size(max = 20)
	@Column(name = "secp_screen_format", length = 20, nullable = false)
	private String screenFormat;

	@NotNull
	@Size(max = 1)
	@Column(name = "secp_log_track_data", length = 1, nullable = false)
	private String logTrackData;

	@NotNull
	@Size(max = 1)
	@Column(name = "secp_mask_char", length = 1, nullable = false)
	private String maskChar;

	@NotNull
	@Size(max = 255)
	@Column(name = "secp_mask_class", length = 255, nullable = false)
	private String maskClass;

	@NotNull
	@Size(max = 255)
	@Column(name = "secp_internal_encrypt_class", length = 255, nullable = false)
	private String internalEncryptClass;

	@NotNull
	@Size(max = 255)
	@Column(name = "secp_key_encrypt_class", length = 255, nullable = false)
	private String keyEncryptClass;

	@NotNull
	@Size(max = 255)
	@Column(name = "secp_hash_class", length = 255, nullable = false)
	private String hashClass;

	@NotNull
	@Size(max = 20)
	@Column(name = "secp_validation_fail_action", length = 20, nullable = false)
	private String validationFailAction;

	@NotNull
	@Size(max = 1)
	@Column(name = "secp_monitor_crypto_period", length = 1, nullable = false)
	private String monitorCryptoPeriod;

	@Size(max = 10)
	@Column(name = "secp_crypto_period_warn_days", length = 10, nullable = true)
	private Long cryptoPeriodWarnDays;

	@Size(max = 10)
	@Column(name = "secp_crypto_period_days", length = 10, nullable = true)
	private Long cryptoPeriodDays;

	@NotNull
	@Size(max = 255)
	@Column(name = "secp_default_encrypt_class", length = 255, nullable = false)
	private String defaultEncryptClass;

	@NotNull
	@Size(max = 19)
	@Column(name = "secp_fallback_eky_id", length = 19, nullable = false)
	private Long fallbackEkyId;

	@LastModifiedDate
	@Column(name = "secp_last_update_ts", nullable = true)
	private Instant lastUpdateTs = Instant.now();

	@NotNull
	@Size(max = 255)
	@Column(name = "secp_mac_class", length = 255, nullable = false)
	private String macClass;

	@NotNull
	@Size(max = 50)
	@Column(name = "secp_last_update_user", length = 50, nullable = false)
	private String lastUpdateUser;

	@NotNull
	@Size(max = 128)
	@Column(name = "secp_mac", length = 128, nullable = false)
	private String mac;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public SecurityParameters name(String name) {
		this.name = name;
		return this;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCategory() {
		return category;
	}

	public SecurityParameters category(String category) {
		this.category = category;
		return this;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getStatus() {
		return status;
	}

	public SecurityParameters status(String status) {
		this.status = status;
		return this;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Long getCurrentEkyId() {
		return currentEkyId;
	}

	public SecurityParameters currentEkyId(Long currentEkyId) {
		this.currentEkyId = currentEkyId;
		return this;
	}

	public void setCurrentEkyId(Long currentEkyId) {
		this.currentEkyId = currentEkyId;
	}

	public String getDatabaseFormat() {
		return databaseFormat;
	}

	public SecurityParameters databaseFormat(String databaseFormat) {
		this.databaseFormat = databaseFormat;
		return this;
	}

	public void setDatabaseFormat(String databaseFormat) {
		this.databaseFormat = databaseFormat;
	}

	public String getLogFormat() {
		return logFormat;
	}

	public SecurityParameters logFormat(String logFormat) {
		this.logFormat = logFormat;
		return this;
	}

	public void setLogFormat(String logFormat) {
		this.logFormat = logFormat;
	}

	public String getScreenFormat() {
		return screenFormat;
	}

	public SecurityParameters screenFormat(String screenFormat) {
		this.screenFormat = screenFormat;
		return this;
	}

	public void setScreenFormat(String screenFormat) {
		this.screenFormat = screenFormat;
	}

	public String getLogTrackData() {
		return logTrackData;
	}

	public SecurityParameters logTrackData(String logTrackData) {
		this.logTrackData = logTrackData;
		return this;
	}

	public void setLogTrackData(String logTrackData) {
		this.logTrackData = logTrackData;
	}

	public String getMaskChar() {
		return maskChar;
	}

	public SecurityParameters maskChar(String maskChar) {
		this.maskChar = maskChar;
		return this;
	}

	public void setMaskChar(String maskChar) {
		this.maskChar = maskChar;
	}

	public String getMaskClass() {
		return maskClass;
	}

	public SecurityParameters maskClass(String maskClass) {
		this.maskClass = maskClass;
		return this;
	}

	public void setMaskClass(String maskClass) {
		this.maskClass = maskClass;
	}

	public String getInternalEncryptClass() {
		return internalEncryptClass;
	}

	public SecurityParameters internalEncryptClass(String internalEncryptClass) {
		this.internalEncryptClass = internalEncryptClass;
		return this;
	}

	public void setInternalEncryptClass(String internalEncryptClass) {
		this.internalEncryptClass = internalEncryptClass;
	}

	public String getKeyEncryptClass() {
		return keyEncryptClass;
	}

	public SecurityParameters keyEncryptClass(String keyEncryptClass) {
		this.keyEncryptClass = keyEncryptClass;
		return this;
	}

	public void setKeyEncryptClass(String keyEncryptClass) {
		this.keyEncryptClass = keyEncryptClass;
	}

	public String getHashClass() {
		return hashClass;
	}

	public SecurityParameters hashClass(String hashClass) {
		this.hashClass = hashClass;
		return this;
	}

	public void setHashClass(String hashClass) {
		this.hashClass = hashClass;
	}

	public String getValidationFailAction() {
		return validationFailAction;
	}

	public SecurityParameters validationFailAction(String validationFailAction) {
		this.validationFailAction = validationFailAction;
		return this;
	}

	public void setValidationFailAction(String validationFailAction) {
		this.validationFailAction = validationFailAction;
	}

	public String getMonitorCryptoPeriod() {
		return monitorCryptoPeriod;
	}

	public SecurityParameters monitorCryptoPeriod(String monitorCryptoPeriod) {
		this.monitorCryptoPeriod = monitorCryptoPeriod;
		return this;
	}

	public void setMonitorCryptoPeriod(String monitorCryptoPeriod) {
		this.monitorCryptoPeriod = monitorCryptoPeriod;
	}

	public Long getCryptoPeriodWarnDays() {
		return cryptoPeriodWarnDays;
	}

	public SecurityParameters cryptoPeriodWarnDays(Long cryptoPeriodWarnDays) {
		this.cryptoPeriodWarnDays = cryptoPeriodWarnDays;
		return this;
	}

	public void setCryptoPeriodWarnDays(Long cryptoPeriodWarnDays) {
		this.cryptoPeriodWarnDays = cryptoPeriodWarnDays;
	}

	public Long getCryptoPeriodDays() {
		return cryptoPeriodDays;
	}

	public SecurityParameters cryptoPeriodDays(Long cryptoPeriodDays) {
		this.cryptoPeriodDays = cryptoPeriodDays;
		return this;
	}

	public void setCryptoPeriodDays(Long cryptoPeriodDays) {
		this.cryptoPeriodDays = cryptoPeriodDays;
	}

	public String getDefaultEncryptClass() {
		return defaultEncryptClass;
	}

	public SecurityParameters defaultEncryptClass(String defaultEncryptClass) {
		this.defaultEncryptClass = defaultEncryptClass;
		return this;
	}

	public void setDefaultEncryptClass(String defaultEncryptClass) {
		this.defaultEncryptClass = defaultEncryptClass;
	}

	public Long getFallbackEkyId() {
		return fallbackEkyId;
	}

	public SecurityParameters fallbackEkyId(Long fallbackEkyId) {
		this.fallbackEkyId = fallbackEkyId;
		return this;
	}

	public void setFallbackEkyId(Long fallbackEkyId) {
		this.fallbackEkyId = fallbackEkyId;
	}

	public Instant getLastUpdateTs() {
		return lastUpdateTs;
	}

	public SecurityParameters lastUpdateTs(Instant lastUpdateTs) {
		this.lastUpdateTs = lastUpdateTs;
		return this;
	}

	public void setLastUpdateTs(Instant lastUpdateTs) {
		this.lastUpdateTs = lastUpdateTs;
	}

	public String getMacClass() {
		return macClass;
	}

	public SecurityParameters macClass(String macClass) {
		this.macClass = macClass;
		return this;
	}

	public void setMacClass(String macClass) {
		this.macClass = macClass;
	}

	public String getLastUpdateUser() {
		return lastUpdateUser;
	}

	public SecurityParameters lastUpdateUser(String lastUpdateUser) {
		this.lastUpdateUser = lastUpdateUser;
		return this;
	}

	public void setLastUpdateUser(String lastUpdateUser) {
		this.lastUpdateUser = lastUpdateUser;
	}

	public String getMac() {
		return mac;
	}

	public SecurityParameters mac(String mac) {
		this.mac = mac;
		return this;
	}

	public void setMac(String mac) {
		this.mac = mac;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) {
			return true;
		}
		if (o == null || getClass() != o.getClass()) {
			return false;
		}
		SecurityParameters securityparameters = (SecurityParameters) o;
		if (securityparameters.getId() == null || getId() == null) {
			return false;
		}
		return Objects.equals(getId(), securityparameters.getId());
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(getId());
	}

	@Override
	public String toString() {
		return "SecurityParameters [id=" + id + ", name=" + name + ", category=" + category + ", status=" + status
				+ ", currentEkyId=" + currentEkyId + ", databaseFormat=" + databaseFormat + ", logFormat=" + logFormat
				+ ", screenFormat=" + screenFormat + ", logTrackData=" + logTrackData + ", maskChar=" + maskChar
				+ ", maskClass=" + maskClass + ", internalEncryptClass=" + internalEncryptClass + ", keyEncryptClass="
				+ keyEncryptClass + ", hashClass=" + hashClass + ", validationFailAction=" + validationFailAction
				+ ", monitorCryptoPeriod=" + monitorCryptoPeriod + ", cryptoPeriodWarnDays=" + cryptoPeriodWarnDays
				+ ", cryptoPeriodDays=" + cryptoPeriodDays + ", defaultEncryptClass=" + defaultEncryptClass
				+ ", fallbackEkyId=" + fallbackEkyId + ", macClass=" + macClass + ", lastUpdateUser=" + lastUpdateUser
				+ ", mac=" + mac + "]";
	}
}
