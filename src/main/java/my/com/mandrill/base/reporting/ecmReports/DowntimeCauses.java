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

public class DowntimeCauses extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(DowntimeCauses.class);
	private long hour = 0L;
	private long minute = 0L;
	private long second = 0L;
	private long totalHour = 0L;
	private long totalMinute = 0L;
	private long totalSecond = 0L;
	private double totalPercentage = 0.00;

	public long getHour() {
		return hour;
	}

	public void setHour(long hour) {
		this.hour = hour;
	}

	public long getMinute() {
		return minute;
	}

	public void setMinute(long minute) {
		this.minute = minute;
	}

	public long getSecond() {
		return second;
	}

	public void setSecond(long second) {
		this.second = second;
	}

	public long getTotalHour() {
		return totalHour;
	}

	public void setTotalHour(long totalHour) {
		this.totalHour = totalHour;
	}

	public long getTotalMinute() {
		return totalMinute;
	}

	public void setTotalMinute(long totalMinute) {
		this.totalMinute = totalMinute;
	}

	public long getTotalSecond() {
		return totalSecond;
	}

	public void setTotalSecond(long totalSecond) {
		this.totalSecond = totalSecond;
	}

	public double getTotalPercentage() {
		return totalPercentage;
	}

	public void setTotalPercentage(double totalPercentage) {
		this.totalPercentage = totalPercentage;
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
			line.append(";").append(totalSecond).append(";").append(totalHour + ":" + totalMinute).append(";")
					.append(formatter.format(totalPercentage) + "%").append(";");
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
//		logger.debug("In DowntimeCauses.addPreProcessingFieldsToGlobalMap()");
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
//	}

	@Override
	protected String getTransactionDateRangeFieldName() {
		return "ASH.ASH_TIMESTAMP";
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In DowntimeCauses.writeBodyHeader()");
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
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.SECOND:
				ZonedDateTime second = ZonedDateTime.ofInstant(
						Instant.ofEpochMilli(Long.parseLong(fieldsMap.get(field.getFieldName()).getValue())),
						ZoneId.systemDefault());
				setSecond(second.getSecond());
				line.append(second.getSecond());
				totalSecond += getSecond();
				break;
			case ReportConstants.HOUR:
				ZonedDateTime hour = ZonedDateTime.ofInstant(
						Instant.ofEpochMilli(Long.parseLong(fieldsMap.get(field.getFieldName()).getValue())),
						ZoneId.systemDefault());
				setHour(hour.getHour());
				setMinute(hour.getMinute());
				line.append(getHour() + ":" + getMinute());
				totalHour += getHour();
				totalMinute += getMinute();
				break;
			case ReportConstants.PERCENTAGE:
				fieldsMap.get(field.getFieldName()).setValue(String.valueOf(getSecond() / getHour()));
				line.append(getFieldValue(rgm, field, fieldsMap) + "%");
				totalPercentage += (getSecond() / getHour());
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
