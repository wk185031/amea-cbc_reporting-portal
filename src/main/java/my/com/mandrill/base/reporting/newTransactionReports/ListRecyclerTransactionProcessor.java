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
	protected void writeBodyData(ReportContext context, List<ReportGenerationFields> bodyFields, FileOutputStream out)
			throws Exception {

		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : bodyFields) {
			if (field.isGroup()) {
				handleGroupFieldInBody(context, field, line);
			} else {
				String fieldValue = getFormattedFieldValue(field, context);
				if ("TO ACC NO".equals(field.getFieldName())) {
					ReportGenerationFields subscriber = bodyFields.stream().filter(f -> "SUBSCRIBER NO".equals(f.getFieldName())).findFirst().orElse(null);
					if (subscriber != null && subscriber.getValue() != null && !subscriber.getValue().trim().isEmpty()) {
						fieldValue = getFormattedFieldValue(subscriber, context);
					}
				} else if ("SUBSCRIBER NO".equals(field.getFieldName())) {
					// Do not print the subscriber no column
					continue;
				}

				if (ReportGenerationFields.TYPE_NUMBER.equals(field.getFieldType())
						|| ReportGenerationFields.TYPE_DECIMAL.equals(field.getFieldType())) {
					if ("TRANS AMOUNT".equals(field.getFieldName()) && fieldValue.startsWith("-")) {
						line.append("\"" + fieldValue.substring(1) + "\"");					
					} else {
						line.append("\"" + fieldValue + "\"");
					}
					
					ReportGenerationFields responseCode = bodyFields.stream().filter(f -> "REMARKS".equals(f.getFieldName())).findFirst().orElse(null);
					if (responseCode != null ) {
						if (responseCode.getValue().startsWith("0")) {
							addToSumField(context, field);
						} else {
							ReportGenerationFields f = new ReportGenerationFields();
							f.setFieldName(field.getFieldName());
							f.setSumAmount(true);
							f.setValue("0");
							addToSumField(context, f);
						}
					} else {
						addToSumField(context, field);
					}
					
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

		if (!context.getOverallTotal().isEmpty() && transactionGroup.getValue() != null
				&& context.getCurrentGroupMap().containsKey("TRANSACTION GROUP")
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

			if (context.getCurrentGroupMap() != null && context.getCurrentGroupMap().containsKey("TRANSACTION GROUP")
					&& context.getCurrentGroupMap().get("TRANSACTION GROUP").contains("CASH DEPOSIT")) {
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
	protected void writeReportTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) {
		// write last line of Overall-Total
		BigDecimal overallTotal = BigDecimal.ZERO;
		if (context.getOverallTotal() != null && context.getOverallTotal().containsKey(OVERALL_TOTAL_FIELD_NAME)) {
			overallTotal = context.getOverallTotal().get(OVERALL_TOTAL_FIELD_NAME);
		}
		String formattedAmount = new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT)
				.format(overallTotal.doubleValue());
		StringBuilder s = new StringBuilder();
		s.append(CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER
				+ CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER
				+ CsvWriter.DEFAULT_DELIMITER + CsvWriter.DEFAULT_DELIMITER);
		if (context.getCurrentGroupMap() != null && context.getCurrentGroupMap().containsKey("TRANSACTION GROUP")
				&& context.getCurrentGroupMap().get("TRANSACTION GROUP").contains("CASH DEPOSIT")) {
			s.append("OVER-ALL TOTAL CREDITS:").append(CsvWriter.DEFAULT_DELIMITER);
		} else {
			s.append("OVER-ALL TOTAL DEBITS:").append(CsvWriter.DEFAULT_DELIMITER);
		}
		s.append("\"" + formattedAmount + "\"");
		s.append(CsvWriter.EOL);
		try {
			csvWriter.writeLine(out, s.toString());
		} catch (Exception e) {
			logger.warn("Failed to write line: {}", e);
		}

		context.getOverallTotal().clear();
	}

	@Override
	protected String getBodyGroupFieldName() {
		return "TRANSACTION TYPE";
	}

}
