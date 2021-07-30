package my.com.mandrill.base.reporting.billingAllocationReportsInterBank;

import java.io.FileOutputStream;
import java.util.List;

import org.springframework.stereotype.Component;

import my.com.mandrill.base.cbc.processor.SimpleReportProcessor;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.writer.CsvWriter;

@Component
public class BillsPaymentEarningsProcessor extends SimpleReportProcessor {

	@Override
	protected String getDelimiter() {
		return CsvWriter.DELIMITER_SEMICOLON;
	}
	
	@Override
	protected void writeBodyData(ReportContext context, List<ReportGenerationFields> bodyFields, FileOutputStream out)
			throws Exception {

		StringBuilder line = new StringBuilder();
		
		ReportGenerationFields termNoField = bodyFields.stream()
				.filter(field -> "TERM NO".equals(field.getFieldName())).findAny().orElse(null);
		boolean isTerminalLevel = true;
		if (termNoField != null && "-".equals(termNoField.getValue())) {
			isTerminalLevel = false;
		}
		for (ReportGenerationFields field : bodyFields) {
			if (field.isGroup()) {
				handleGroupFieldInBody(context, field, line);
			} else {
				String fieldValue = getFormattedFieldValue(field, context);
				if (isTerminalLevel && nonTerminalField(field.getFieldName())) {
					// For branch level data, set the field empty when write terminal row
					line.append("");
				} else if (ReportGenerationFields.TYPE_NUMBER.equals(field.getFieldType())
						|| ReportGenerationFields.TYPE_DECIMAL.equals(field.getFieldType())) {
					line.append("\"" + fieldValue + "\"");
					addToSumField(context, field);
				} else {
					line.append(fieldValue);
				}
				line.append(field.getDelimiter());

				if (field.isEol()) {
					line.append(CsvWriter.EOL);
				}
			}
		}

		csvWriter.writeLine(out, line.toString());
		context.setTotalRecord(context.getTotalRecord() + 1);
	}
	
	private boolean nonTerminalField(String fieldName) {
		return "ACQUIRER VOL".equals(fieldName) || "ACQUIRER FEE".equals(fieldName) || "ISSUER VOL".equals(fieldName) || "ISSUER FEE".equals(fieldName) || "TOTAL VOL".equals(fieldName) || "TOTAL FEE".equals(fieldName);
	}
}
