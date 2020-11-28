package my.com.mandrill.base.domain.builder;

import java.math.BigDecimal;
import java.text.DecimalFormat;

import org.apache.commons.lang3.math.NumberUtils;

import my.com.mandrill.base.domain.Amount;

public class AmountBuilder {

	private BigDecimal amount;

	public AmountBuilder(BigDecimal amount) {
		this.amount = amount;
	}

	public AmountBuilder(String amount) {
		if (amount == null || amount.trim().isEmpty()) {
			this.amount = BigDecimal.ZERO;
		} else {
			if (amount.contains(",")) {
				amount = amount.replace(",", "");
			}

			if (!NumberUtils.isParsable(amount)) {
				throw new IllegalArgumentException("Amount " + amount + " is not valid.");
			}
			this.amount = new BigDecimal(amount);
		}
	}

	public Amount build() {
		return new Amount(amount);
	}

	public Amount buildFromRaw() {
		if (amount.compareTo(BigDecimal.ZERO) > 0) {
			return new Amount(amount.movePointLeft(2).setScale(2));
		} else {
			return new Amount(amount);
		}
	}

}
