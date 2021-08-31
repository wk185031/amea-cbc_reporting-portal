package my.com.mandrill.base.cbc.processor;

import java.io.FileOutputStream;
import java.text.DecimalFormat;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.processor.BaseReportProcessor;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.writer.CsvWriter;

@Component
public class ReportWithBodyHeaderTrailerProcessor extends BaseReportProcessor {

	@Autowired
	private CsvWriter csvWriter;

	@Override
	protected void handleGroupFieldInBody(ReportContext context, ReportGenerationFields field, StringBuilder bodyLine) {
		// Do nothing. Do not write group field in body
	}

	@Override
	protected void preProcessBodyHeader(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {

		ReportGenerationFields branch = bodyFields.stream()
				.filter(field -> getBranchFieldName().equals(field.getFieldName())).findAny().orElse(null);
		ReportGenerationFields terminal = bodyFields.stream()
				.filter(field -> getTerminalFieldName().equals(field.getFieldName())).findAny().orElse(null);
		if (context.getCurrentBranch() == null || !context.getCurrentBranch().equals(branch.getValue())
				|| context.getCurrentTerminal() == null || !context.getCurrentTerminal().equals(terminal.getValue())) {

			writeBodyTrailer(context, bodyFields, out);
			writeBranchTerminal(context, branch.getValue(), terminal.getValue(), out);
		}
	}

	@Override
	protected void writeBodyHeader(ReportContext context, List<ReportGenerationFields> bodyHeaderFields,
			FileOutputStream out) throws Exception {
		if (context.isWriteBodyHeader()) {
			csvWriter.writeLine(out, CsvWriter.EOL);
			csvWriter.writeLine(out, bodyHeaderFields, null);
			context.setWriteBodyHeader(false);
		}
	}

	@Override
	protected void preProcessBodyData(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		ReportGenerationFields bodyGroupField = bodyFields.stream()
				.filter(field -> field.isGroup() && getBodyGroupFieldName().equals(field.getFieldName())).findAny()
				.orElse(null);

		if (context.isGroupChange(bodyGroupField.getFieldName(), bodyGroupField.getValue())) {
			writeBodyTrailer(context, bodyFields, out);
		}
		writeGroupHeader(context, bodyFields, out);
	}

	protected void writeGroupHeader(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		for (ReportGenerationFields field : bodyFields) {
			if (field.isGroup()) {
				if (!field.getFieldName().equals(getBranchFieldName())
						&& !field.getFieldName().equals(getTerminalFieldName())
						&& context.isGroupChange(field.getFieldName(), field.getValue())) {
					csvWriter.writeLine(out, CsvWriter.EOL);
					csvWriter.writeLine(out, field.getValue());
					csvWriter.writeLine(out, CsvWriter.EOL);
					context.getCurrentGroupMap().put(field.getFieldName(), field.getValue());
				}
			}
		}
	}

	@Override
	protected void writeBodyTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		if (!context.getSubTotal().isEmpty()) {
			StringBuilder subTotalLine = new StringBuilder();

			boolean isFirstColumn = true;
			for (ReportGenerationFields tempField : bodyFields) {
				if (tempField.isGroup()) {
					continue;
				}

				if (isFirstColumn) {
					subTotalLine.append("SUB-TOTAL");
					subTotalLine.append(getDefaultDelimiter());
					isFirstColumn = false;
				} else if (context.getSubTotal().containsKey(tempField.getFieldName())) {
					String formattedAmount = new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT)
							.format(context.getSubTotal().get(tempField.getFieldName()));
					subTotalLine.append("\"" + formattedAmount + "\"");
					subTotalLine.append(getDefaultDelimiter());
				} else {
					subTotalLine.append(getDefaultDelimiter());
				}
			}
			csvWriter.writeLine(out, subTotalLine.toString());
			csvWriter.writeLine(out, CsvWriter.EOL);
			context.getSubTotal().clear();
		}
	}
	
	protected String getDefaultDelimiter() {
		return CsvWriter.DEFAULT_DELIMITER;
	}

	protected String getBranchFieldName() {
		return "BRANCH";
	}

	protected String getTerminalFieldName() {
		return "TERMINAL";
	}

	protected String getBodyGroupFieldName() {
		return "TRANSACTION GROUP";
	}

	private void writeBranchTerminal(ReportContext context, String branch, String terminal, FileOutputStream out)
			throws Exception {

		StringBuilder lineBuilder = new StringBuilder();
		lineBuilder.append(CsvWriter.EOL);
		lineBuilder.append(CsvWriter.EOL);
		lineBuilder.append("BRANCH:   ").append(branch);
		lineBuilder.append(CsvWriter.EOL);
		lineBuilder.append("TERMINAL: ").append(terminal);
		lineBuilder.append(CsvWriter.EOL);
		csvWriter.writeLine(out, lineBuilder.toString());

		context.setCurrentBranch(branch);
		context.setCurrentTerminal(terminal);
		context.setWriteBodyHeader(true);

	}
}
