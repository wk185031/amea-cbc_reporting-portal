package my.com.mandrill.base.domain;

import java.io.Serializable;
import java.math.BigInteger;
import java.time.Instant;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.springframework.data.elasticsearch.annotations.Document;

import io.swagger.annotations.ApiModel;

@ApiModel(description = "DcmsUserActivity, store user activity from DCMS")
@Entity
@Table(name = "DCMS_USER_ACTIVITY")
@Document(indexName = "dcms_user_activity")
public class DcmsUserActivity implements Serializable {

	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private Long id;

	private String function;

	private BigInteger cardId;

	private BigInteger institutionId;

	private boolean isCashCard;

	private String description;

	private String createdBy;

	private Instant createdDate;

	private Integer cardKeyRotationNumber;

	private String cardNumberEnc;

	private String customerCifNumber;

	@Transient
	private String auditLog;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getFunction() {
		return function;
	}

	public void setFunction(String function) {
		this.function = function;
	}

	public BigInteger getCardId() {
		return cardId;
	}

	public void setCardId(BigInteger cardId) {
		this.cardId = cardId;
	}

	public boolean isCashCard() {
		return isCashCard;
	}

	public void setCashCard(boolean isCashCard) {
		this.isCashCard = isCashCard;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(String createdBy) {
		this.createdBy = createdBy;
	}

	public Instant getCreatedDate() {
		return createdDate;
	}

	public void setCreatedDate(Instant createdDate) {
		this.createdDate = createdDate;
	}

	public BigInteger getInstitutionId() {
		return institutionId;
	}

	public void setInstitutionId(BigInteger institutionId) {
		this.institutionId = institutionId;
	}

	public String getAuditLog() {
		return auditLog;
	}

	public void setAuditLog(String auditLog) {
		this.auditLog = auditLog;
	}

	public Integer getCardKeyRotationNumber() {
		return cardKeyRotationNumber;
	}

	public void setCardKeyRotationNumber(Integer keyRotationNumber) {
		this.cardKeyRotationNumber = keyRotationNumber;
	}

	public String getCardNumberEnc() {
		return cardNumberEnc;
	}

	public void setCardNumberEnc(String cardNumberEnc) {
		this.cardNumberEnc = cardNumberEnc;
	}

	public String getCustomerCifNumber() {
		return customerCifNumber;
	}

	public void setCustomerCifNumber(String customerCifNumber) {
		this.customerCifNumber = customerCifNumber;
	}

}
