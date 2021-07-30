package my.com.mandrill.base.cbc.processor;

import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.processor.BaseReportProcessor;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.writer.CsvWriter;

@Component
public class SimpleReportProcessor extends BaseReportProcessor {

	@Autowired
	protected CsvWriter csvWriter;

	@Override
	protected void preProcessBodyHeader(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		// Do nothing
	}

	@Override
	protected void preProcessBodyData(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		// Do nothing
	}

	@Override
	protected void handleGroupFieldInBody(ReportContext context, ReportGenerationFields field, StringBuilder bodyLine) {

		if (!context.getCurrentGroupMap().containsKey(field.getFieldName())) {
			bodyLine.append(field.getValue()).append(getDelimiter());
			context.getCurrentGroupMap().put(field.getFieldName(), field.getValue());
		} else if (!context.getCurrentGroupMap().get(field.getFieldName()).equals(field.getValue())) {
			bodyLine.append(field.getValue()).append(getDelimiter());
			context.getCurrentGroupMap().put(field.getFieldName(), field.getValue());
		} else {
			bodyLine.append(getDelimiter());
		}
	}

	@Override
	protected void writeBodyTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		StringBuilder line = new StringBuilder();
		boolean labelWritten = false;
		for (ReportGenerationFields field : bodyFields) {
			if (field.isSumAmount() && context.getSubTotal().containsKey(field.getFieldName())) {

				if (!labelWritten) {
					// Write the total label before the first subtotal column
					line = new StringBuilder(line.toString().substring(1));
					line.append("OVER-ALL TOTAL");
					line.append(getDelimiter());
					labelWritten = true;
				}

				BigDecimal amount = context.getSubTotal().get(field.getFieldName());
				String formattedAmount = null;

				if (ReportGenerationFields.TYPE_DECIMAL.equals(field.getFieldType())) {
					formattedAmount = new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT)
							.format(amount.doubleValue());
				} else {
					formattedAmount = amount.toString();
				}
				line.append("\"" + formattedAmount + "\"");
			}
			line.append(getDelimiter());
		}
		line.append(CsvWriter.EOL);
		csvWriter.writeLine(out, line.toString());
	}
	
	protected String getDelimiter() {
		return CsvWriter.DEFAULT_DELIMITER;
	}

}
