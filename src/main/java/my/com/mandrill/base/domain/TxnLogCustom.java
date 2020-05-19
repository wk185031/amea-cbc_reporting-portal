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

	private static final String BILL_PAYMENT_TSC_CODE = "50";
	
	
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
}
