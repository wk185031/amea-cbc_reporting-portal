package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class AtmHostDowntime extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(AtmHostDowntime.class);
	private long timeUp = 0L;
	private long timeDown = 0L;

	public long getTimeUp() {
		return timeUp;
	}

	public void setTimeUp(long timeUp) {
		this.timeUp = timeUp;
	}

	public long getTimeDown() {
		return timeDown;
	}

	public void setTimeDown(long timeDown) {
		this.timeDown = timeDown;
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
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
//		logger.debug("In AtmHostDowntime.addPreProcessingFieldsToGlobalMap()");
//		if (rgm.isGenerate() == true) {
//			String txnStart = rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
//					.concat(" ").concat(ReportConstants.START_TIME);
//			String txnEnd = rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
//					.concat(" ").concat(ReportConstants.END_TIME);
//			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
//					ReportGenerationFields.TYPE_STRING,
//					"ASH.ASH_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
//							+ "') AND ASH.ASH_TIMESTAMP < TO_DATE('" + txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE
//							+ "')");
//			ReportGenerationFields fromDateValue = new ReportGenerationFields(ReportConstants.FROM_DATE,
//					ReportGenerationFields.TYPE_DATE, rgm.getTxnStartDate().toString());
//			ReportGenerationFields toDateValue = new ReportGenerationFields(ReportConstants.TO_DATE,
//					ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toString());
//
//			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
//			getGlobalFileFieldsMap().put(fromDateValue.getFieldName(), fromDateValue);
//			getGlobalFileFieldsMap().put(toDateValue.getFieldName(), toDateValue);
//		} else {
//			String txnStart = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
//					.concat(" ").concat(ReportConstants.START_TIME);
//			String txnEnd = rgm.getTodayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
//					.concat(ReportConstants.END_TIME);
//			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
//					ReportGenerationFields.TYPE_STRING,
//					"ASH.ASH_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
//							+ "') AND ASH.ASH_TIMESTAMP < TO_DATE('" + txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE
//							+ "')");
//			ReportGenerationFields fromDateValue = new ReportGenerationFields(ReportConstants.FROM_DATE,
//					ReportGenerationFields.TYPE_DATE, rgm.getYesterdayDate().toString());
//			ReportGenerationFields toDateValue = new ReportGenerationFields(ReportConstants.TO_DATE,
//					ReportGenerationFields.TYPE_DATE, rgm.getTodayDate().toString());
//
//			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
//			getGlobalFileFieldsMap().put(fromDateValue.getFieldName(), fromDateValue);
//			getGlobalFileFieldsMap().put(toDateValue.getFieldName(), toDateValue);
//		}
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
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TIME_UP:
				if (getFieldValue(field, fieldsMap) == null || getFieldValue(field, fieldsMap).isEmpty()) {
					setTimeUp(0L);
				} else {
					setTimeUp(Long.parseLong(fieldsMap.get(field.getFieldName()).getValue()));
				}
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			case ReportConstants.TIME_DOWN:
				if (getFieldValue(field, fieldsMap) == null || getFieldValue(field, fieldsMap).isEmpty()) {
					setTimeDown(0L);
				} else {
					setTimeDown(Long.parseLong(fieldsMap.get(field.getFieldName()).getValue()));
				}
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			case ReportConstants.TOTAL_DOWN_TIME:
				if (getTimeDown() == 0L || getTimeUp() == 0L) {
					line.append("");
				} else {
					ZonedDateTime timeDown = ZonedDateTime.ofInstant(Instant.ofEpochMilli(getTimeDown()),
							ZoneId.systemDefault());
					ZonedDateTime timeUp = ZonedDateTime.ofInstant(Instant.ofEpochMilli(getTimeUp()),
							ZoneId.systemDefault());
					ZonedDateTime zonedDateTime = ZonedDateTime.from(timeDown);

					Long days = zonedDateTime.until(timeUp, ChronoUnit.DAYS);
					zonedDateTime = zonedDateTime.plusDays(days);

					Long hours = zonedDateTime.until(timeUp, ChronoUnit.HOURS);
					zonedDateTime = zonedDateTime.plusHours(hours);

					Long minutes = zonedDateTime.until(timeUp, ChronoUnit.MINUTES);
					zonedDateTime = zonedDateTime.plusMinutes(minutes);
					
					String hoursStr = hours < 10 ? "0"+ hours.toString() : hours.toString();
					String minutesStr = minutes < 10 ? "0"+ minutes.toString() : minutes.toString();

					line.append(days + " day/s " + hoursStr + ":" + minutesStr);
				}
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
