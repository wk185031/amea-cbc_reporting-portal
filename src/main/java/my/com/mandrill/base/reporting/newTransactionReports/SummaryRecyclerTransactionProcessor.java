package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.cbc.processor.BranchReportWithBodyHeaderTrailerProcessor;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.writer.CsvWriter;

@Component
public class SummaryRecyclerTransactionProcessor extends BranchReportWithBodyHeaderTrailerProcessor {

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
			FileOutputStream outMaster, FileOutputStream outBranch) throws Exception {
		super.writeBodyTrailer(context, bodyFields, outMaster, outBranch);

		ReportGenerationFields branch = bodyFields.stream()
				.filter(field -> getBranchFieldName().equals(field.getFieldName())).findAny().orElse(null);
		ReportGenerationFields terminal = bodyFields.stream()
				.filter(field -> getTerminalFieldName().equals(field.getFieldName())).findAny().orElse(null);
		if ((context.getCurrentBranch() != null && !context.getCurrentBranch().equals(branch.getValue()))
				|| (context.getCurrentTerminal() != null && !context.getCurrentTerminal().equals(terminal.getValue()))) {
			StringBuilder s = new StringBuilder();
			s.append(CsvWriter.DELIMITER_SEMICOLON + CsvWriter.DELIMITER_SEMICOLON + CsvWriter.DELIMITER_SEMICOLON
					+ CsvWriter.DELIMITER_SEMICOLON + CsvWriter.DELIMITER_SEMICOLON + CsvWriter.DELIMITER_SEMICOLON
					+ CsvWriter.DELIMITER_SEMICOLON);
			BigDecimal overallTotal = context.getOverallTotal().get(overallTotalFieldName);
			String formattedAmount = "0.00";
			if (overallTotal != null) {
				formattedAmount = new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT)
						.format(context.getOverallTotal().get(overallTotalFieldName).doubleValue());
			}

			s.append("\"" + formattedAmount + "\"");
			csvWriter.writeLine(outMaster, s.toString() + " \r\n");
			csvWriter.writeLine(outBranch, s.toString() + " \r\n");
			context.getOverallTotal().clear();
		}
	}

	@Override
	protected String getDefaultDelimiter() {
		return CsvWriter.DELIMITER_SEMICOLON;
	}
	
	

}
