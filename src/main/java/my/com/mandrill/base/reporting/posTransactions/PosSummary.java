package my.com.mandrill.base.reporting.posTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class PosSummary extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(PosSummary.class);
	private int pagination = 0;
	private int txnCount = 0;
	private double total = 0.00;
	private double totalCommission = 0.00;
	private double totalNetSettAmt = 0.00;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination++;
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			writeTotal(rgm, txnCount, total, totalCommission, totalNetSettAmt);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in generating CSV file", e);
		} finally {
			try {
				if (rgm.fileOutputStream != null) {
					rgm.fileOutputStream.close();
					rgm.exit();
				}
			} catch (IOException e) {
				rgm.errors++;
				logger.error("Error in closing fileOutputStream", e);
			}
		}
	}

	private void writeTotal(ReportGenerationMgr rgm, int txnCount, double total, double totalCommission,
			double totalNetSettAmt) throws IOException {
		logger.debug("In PosSummary.writeTotal()");
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		StringBuilder line = new StringBuilder();
		line.append(";").append("GRAND TOTAL : ").append(";").append(String.format("%,d", txnCount)).append(";")
				.append(formatter.format(total)).append(";").append(";").append(formatter.format(totalCommission))
				.append(";").append(formatter.format(totalNetSettAmt)).append(";");
		line.append(getEol());
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In PosSummary.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String customData)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		double txnAmt = 0.00;
		double commission = 0.00;
		double netSettAmt = 0.00;

		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					txnAmt = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
					total += txnAmt;
				} else {
					txnAmt = Double.parseDouble(getFieldValue(field, fieldsMap));
					total += txnAmt;
				}
				if (field.getValue().startsWith("-")) {
					fieldsMap.get(field.getFieldName()).setValue(field.getValue().substring(1));
				}
				
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.TRAN_MNEM)) {
				ReportGenerationFields txnCountField = fields.stream()
						.filter(tempField -> ReportConstants.TRAN_COUNT.equals(tempField.getFieldName())).findAny().orElse(null);
				if ("POS".contentEquals(getFieldValue(field, fieldsMap))) {		
					txnCount += Integer.parseInt(getFieldValue(txnCountField, fieldsMap).replace(",", ""));
				} else {
					txnCount -= Integer.parseInt(getFieldValue(txnCountField, fieldsMap).replace(",", ""));
				}
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.POS_COMMISSION_AMOUNT)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					commission = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
					totalCommission += commission;
				} else {
					commission = Double.parseDouble(getFieldValue(field, fieldsMap));
					totalCommission += commission;
				}
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.POS_NET_SETT_AMT)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					netSettAmt = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
					totalNetSettAmt += netSettAmt;
				} else {
					netSettAmt = Double.parseDouble(getFieldValue(field, fieldsMap));
					totalNetSettAmt += netSettAmt;
				}
			}
			line.append(getFieldValue(rgm, field, fieldsMap));
			line.append(field.getDelimiter());
		}

		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In PosSummary.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String customData = null;
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);

				while (rs.next()) {
					new StringBuffer();
					lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when trying to write a line", e);
							continue;
						}
						if (result != null) {
							if (result instanceof Date) {
								field.setValue(Long.toString(((Date) result).getTime()));
							} else if (result instanceof oracle.sql.TIMESTAMP) {
								field.setValue(
										Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
							} else if (result instanceof oracle.sql.DATE) {
								field.setValue(Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
							} else if (key.equalsIgnoreCase(ReportConstants.CUSTOM_DATA)) {
								customData = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap, customData);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				try {
					ps.close();
					rs.close();
				} catch (SQLException e) {
					rgm.errors++;
					logger.error("Error closing DB resources", e);
				}
			}
		}

	}
}
