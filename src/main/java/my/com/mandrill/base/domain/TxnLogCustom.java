package my.com.mandrill.base.domain;

import java.sql.ResultSet;
import java.sql.SQLException;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.springframework.data.elasticsearch.annotations.Document;

import io.swagger.annotations.ApiModel;

@ApiModel(description = "Transaction_Log_Custom, additional fields required for Transaction_Log")
@Entity
@Table(name = "transaction_log_custom")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@Document(indexName = "transaction_log_custom")
public class TxnLogCustom {
	
	@Id
	@Column(name = "trl_id")
	private Long trlId;

	@NotNull
	@Size(max = 20)
	@Column(name = "trl_biller_code", length = 20)
	private String billerCode;

	@NotNull
	@Size(max = 20)
	@Column(name = "trl_card_bin", length = 20)
	private String cardBin;

	@NotNull
	@Size(max = 20)
	@Column(name = "trl_origin_channel", length = 20)
	private String originChannel;
	
	@Column(name = "trl_card_branch", length = 10)
	private String cardBranch;
	
	@Column(name = "trl_card_product_type", length = 10)
	private String cardProductType;

	public Long getTrlId() {
		return trlId;
	}

	public void setTrlId(Long trlId) {
		this.trlId = trlId;
	}

	public String getBillerCode() {
		return billerCode;
	}

	public void setBillerCode(String billerCode) {
		this.billerCode = billerCode;
	}

	public String getCardBin() {
		return cardBin;
	}

	public void setCardBin(String cardBin) {
		this.cardBin = cardBin;
	}

	public String getOriginChannel() {
		return originChannel;
	}

	public void setOriginChannel(String originChannel) {
		this.originChannel = originChannel;
	}

	public String getCardBranch() {
		return cardBranch;
	}

	public void setCardBranch(String cardBranch) {
		this.cardBranch = cardBranch;
	}

	public String getCardProductType() {
		return cardProductType;
	}

	public void setCardProductType(String cardProductType) {
		this.cardProductType = cardProductType;
	}
	
}
