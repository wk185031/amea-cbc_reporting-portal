package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.cbc.processor.ReportWithBodyHeaderTrailerProcessor;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.writer.CsvWriter;

@Component
public class SummaryRecyclerTransactionProcessor extends ReportWithBodyHeaderTrailerProcessor {

	@Autowired
	private CsvWriter csvWriter;
	
	private final static String overallTotalFieldName = "NET-TOTAL";

	@Override
	protected void addToSumField(ReportContext context, ReportGenerationFields field) {
		super.addToSumField(context, field);

		if (!context.getOverallTotal().containsKey(overallTotalFieldName)) {
			context.getOverallTotal().put(overallTotalFieldName, BigDecimal.ZERO);
		}

		if ("TOTAL DISPENSED".equals(field.getFieldName()) && field.getValue() != null && !field.getValue().isEmpty()) {
			context.getOverallTotal().put(overallTotalFieldName,
					context.getOverallTotal().get(overallTotalFieldName).subtract(new BigDecimal(field.getValue())));
		} else if ("TOTAL DEPOSIT".equals(field.getFieldName()) && field.getValue() != null
				&& !field.getValue().isEmpty()) {
			context.getOverallTotal().put(overallTotalFieldName,
					context.getOverallTotal().get(overallTotalFieldName).add(new BigDecimal(field.getValue())));
		}
	}

	@Override
	protected void writeBodyTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		super.writeBodyTrailer(context, bodyFields, out);

		ReportGenerationFields branch = bodyFields.stream()
				.filter(field -> getBranchFieldName().equals(field.getFieldName())).findAny().orElse(null);
		ReportGenerationFields terminal = bodyFields.stream()
				.filter(field -> getTerminalFieldName().equals(field.getFieldName())).findAny().orElse(null);
		if ((context.getCurrentBranch() != null && !context.getCurrentBranch().equals(branch.getValue()))
				|| (context.getCurrentTerminal() != null && !context.getCurrentTerminal().equals(terminal.getValue()))) {
			StringBuilder s = new StringBuilder();
			s.append(CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER
					+ CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER
					+ CsvWriter.DEFAULT_DELIMITER);
			BigDecimal overallTotal = context.getOverallTotal().get(overallTotalFieldName);
			String formattedAmount = "0.00";
			if (overallTotal != null) {
				formattedAmount = new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT)
						.format(context.getOverallTotal().get(overallTotalFieldName).doubleValue());
			}

			s.append("\"" + formattedAmount + "\"");
			csvWriter.writeLine(out, s.toString());
			context.getOverallTotal().clear();
		}
	}

}
