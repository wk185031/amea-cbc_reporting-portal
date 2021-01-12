package my.com.mandrill.base.domain;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.springframework.data.elasticsearch.annotations.Document;

import io.swagger.annotations.ApiModel;

@ApiModel(description = "Card_Custom, additional fields required for Card")
@Entity
@Table(name = "card_custom")
@Document(indexName = "card_custom")
public class CardCustom {

	@Id
	@Column(name = "crd_id")
	private Long cardId;
	
	@NotNull
	@Size(max = 100)
	@Column(name = "crd_branch_code")
	private String cardBranchCode;

	public Long getCardId() {
		return cardId;
	}

	public void setCardId(Long cardId) {
		this.cardId = cardId;
	}

	public String getCardBranchCode() {
		return cardBranchCode;
	}

	public void setCardBranchCode(String cardBranchCode) {
		this.cardBranchCode = cardBranchCode;
	}
}
