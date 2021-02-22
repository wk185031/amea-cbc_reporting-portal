package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class BancNetAtmAvailability extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(BancNetAtmAvailability.class);
	private int terminalCount = 0;
	private int targetHour = 0;
	private int outageHour = 0;
	private double totalPercentage = 0.00;

	public int getTargetHour() {
		return targetHour;
	}

	public void setTargetHour(int targetHour) {
		this.targetHour = targetHour;
	}

	public int getOutageHour() {
		return outageHour;
	}

	public void setOutageHour(int outageHour) {
		this.outageHour = outageHour;
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			StringBuilder line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append(";").append("AVERAGE").append(";")
					.append(formatter.format(totalPercentage / terminalCount) + "%").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
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

//	@Override
//	protected void addReportPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
//		logger.debug("In BancNetAtmAvailability.addPreProcessingFieldsToGlobalMap()");
//
//		String txnStart = rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01));
//		String txnEnd = rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01));
//		ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
//				ReportGenerationFields.TYPE_STRING,
//				"ASH.ASH_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
//						+ "') AND ASH.ASH_TIMESTAMP < TO_DATE('" + txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE
//						+ "')");
//		ReportGenerationFields fromDateValue = new ReportGenerationFields(ReportConstants.FROM_DATE,
//				ReportGenerationFields.TYPE_DATE, rgm.getTxnStartDate().toLocalDate().toString());
//		ReportGenerationFields toDateValue = new ReportGenerationFields(ReportConstants.TO_DATE,
//				ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toLocalDate().toString());
//
//		getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
//		getGlobalFileFieldsMap().put(fromDateValue.getFieldName(), fromDateValue);
//		getGlobalFileFieldsMap().put(toDateValue.getFieldName(), toDateValue);
//
//	}

	@Override
	protected String getTransactionDateRangeFieldName() {
		return "ASH.ASH_TIMESTAMP";
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		
		int noOfDaysInMonth = 0;
		if (rgm.getTxnStartDate() != null) {
			noOfDaysInMonth = rgm.getTxnStartDate().toLocalDate().lengthOfMonth();
		} else if (rgm.getYesterdayDate() != null) {
			noOfDaysInMonth = rgm.getYesterdayDate().lengthOfMonth();
		}
		
		int targetHour = (24 * noOfDaysInMonth) - 1;
		int targetMinute = 1 * noOfDaysInMonth;
		
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TERMINAL:
				terminalCount++;
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			case ReportConstants.HOUR:
				line.append(targetHour);
				setTargetHour(targetHour);
				break;
			case ReportConstants.MINUTE:
				line.append(targetMinute);
				break;
			case ReportConstants.OUTAGE_HOUR:
				line.append(fieldsMap.get(field.getFieldName()).getValue());
				setOutageHour(Integer.parseInt(fieldsMap.get(field.getFieldName()).getValue()));
				break;
			case ReportConstants.PERCENTAGE:
				DecimalFormat formatter = new DecimalFormat("#,##0.00");
				double percentage = ((Double.valueOf(getTargetHour() - getOutageHour()) / getTargetHour())) * 100;
				line.append(formatter.format(percentage) + "%");
				totalPercentage += percentage;
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			}
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}
