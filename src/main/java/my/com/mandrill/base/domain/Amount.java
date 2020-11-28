package my.com.mandrill.base.domain;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.text.DecimalFormat;

import org.apache.commons.lang3.math.NumberUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Amount {

	private final Logger logger = LoggerFactory.getLogger(Amount.class);
	
	private BigDecimal value;

	public Amount(BigDecimal value) {
		this.value = value;
	}

	public BigDecimal getValue() {
		return value;
	}

	public void add(Amount anotherAmount) {
		this.value = this.value.add(anotherAmount.getValue());
	}
	
	public void subtract(Amount anotherAmount) {
		this.value = this.value.subtract(anotherAmount.getValue());
	}
	
	public String format(String format) {
		logger.debug("format: format={}, amount={}", format, this.value);
		DecimalFormat formatter = new DecimalFormat(format);
		return formatter.format(this.value);
	}

	public BigDecimal calculateFee(String rate) {
		logger.debug("calculateFee: rate={}, amount={}", rate, this.value);
		if (rate == null || rate.trim().isEmpty() || !NumberUtils.isParsable(rate)) {
			return BigDecimal.ZERO;
		} else {
			return this.value.multiply(new BigDecimal(rate),
					new MathContext(2, RoundingMode.HALF_UP));
		}
	}

}
