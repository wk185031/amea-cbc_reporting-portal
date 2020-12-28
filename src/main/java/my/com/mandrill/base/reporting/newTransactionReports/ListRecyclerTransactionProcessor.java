package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.cbc.processor.ReportWithBodyHeaderTrailerProcessor;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.writer.CsvWriter;

@Component
public class ListRecyclerTransactionProcessor extends ReportWithBodyHeaderTrailerProcessor {

	private final Logger logger = LoggerFactory.getLogger(ListRecyclerTransactionProcessor.class);

	@Autowired
	private CsvWriter csvWriter;
	
	private final static String OVERALL_TOTAL_FIELD_NAME = "OVERALL-TOTAL";

	private final static String SUB_TOTAL_FIELD_NAME = "TRANS AMOUNT";

	@Override
	protected void addToSumField(ReportContext context, ReportGenerationFields field) {
		if (!field.isSumAmount()) {
			return;
		}

		super.addToSumField(context, field);

		if (!context.getOverallTotal().containsKey(OVERALL_TOTAL_FIELD_NAME)) {
			context.getOverallTotal().put(OVERALL_TOTAL_FIELD_NAME, BigDecimal.ZERO);
		}

		context.getOverallTotal().put(OVERALL_TOTAL_FIELD_NAME,
				context.getOverallTotal().get(OVERALL_TOTAL_FIELD_NAME).add(new BigDecimal(field.getValue())));
	}

	@Override
	protected void writeBodyTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {

		if (!context.getSubTotal().isEmpty() && context.getSubTotal().containsKey(SUB_TOTAL_FIELD_NAME)) {
			StringBuilder s = new StringBuilder();
			s.append(CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER
					+ CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER
					+ CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER);
			s.append("TOTAL:").append(CsvWriter.DEFAULT_DELIMITER);
			String formattedAmount = new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT)
					.format(context.getSubTotal().get("TRANS AMOUNT").doubleValue());
			s.append("\"" + formattedAmount + "\"");

			csvWriter.writeLine(out, s.toString());
			csvWriter.writeLine(out, CsvWriter.EOL);
			context.getSubTotal().clear();
		}

		ReportGenerationFields transactionGroup = bodyFields.stream()
				.filter(field -> "TRANSACTION GROUP".equals(field.getFieldName())).findAny().orElse(null);
		
		if (!context.getOverallTotal().isEmpty() && transactionGroup.getValue() != null && context.getCurrentGroupMap().containsKey("TRANSACTION GROUP")
				&& !transactionGroup.getValue().equals(context.getCurrentGroupMap().get("TRANSACTION GROUP"))) {
			StringBuilder s = new StringBuilder();
			s.append(CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER
					+ CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER
					+ CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER);
			BigDecimal overallTotal = BigDecimal.ZERO;
			if (context.getOverallTotal() != null && context.getOverallTotal().containsKey(OVERALL_TOTAL_FIELD_NAME)) {
				overallTotal = context.getOverallTotal().get(OVERALL_TOTAL_FIELD_NAME);
			}
			String formattedAmount = new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT)
					.format(overallTotal.doubleValue());
			
			if (context.getCurrentGroupMap().get("TRANSACTION GROUP").contains("CASH DEPOSIT")) {
				s.append("OVER-ALL TOTAL CREDITS:").append(CsvWriter.DEFAULT_DELIMITER);
			} else {
				s.append("OVER-ALL TOTAL DEBITS:").append(CsvWriter.DEFAULT_DELIMITER);
			}

			s.append("\"" + formattedAmount + "\"");
			s.append(CsvWriter.EOL);
			csvWriter.writeLine(out, s.toString());	
			context.getOverallTotal().clear();
		}
	}

	@Override
	protected String getBodyGroupFieldName() {
		return "TRANSACTION TYPE";
	}

}
