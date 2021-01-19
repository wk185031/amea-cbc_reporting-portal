package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class AtmDailyTransactionSummary extends CsvReportProcessor {
	private final Logger logger = LoggerFactory.getLogger(AtmDailyTransactionSummary.class);
	private int hours = 0;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		hours = 0;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			for (int i = 0; i <= 23; i++) {
				StringBuilder line = new StringBuilder();
				// preProcessing(rgm);
				writeBodyHeader(rgm);
				executeBodyQuery(rgm);
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
			}
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
//		logger.debug("In AtmDailyTransactionSummary.addPreProcessingFieldsToGlobalMap()");
//		if (rgm.isGenerate() == true) {
//			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
//					ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toString());
//			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
//		} else {
//			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
//					ReportGenerationFields.TYPE_DATE, rgm.getYesterdayDate().toString());
//			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
//		}
//	}

//	private void preProcessing(ReportGenerationMgr rgm)
//			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
//		logger.debug("In AtmDailyTransactionSummary.preProcessing()");
//		String startTime = null;
//		String endTime = null;
//		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01);
//
//		if (hours > 9) {
//			startTime = ReportConstants.START_TIME.replace(ReportConstants.START_TIME,
//					String.valueOf(hours) + ":00:00");
//			endTime = ReportConstants.END_TIME.replace(ReportConstants.END_TIME, String.valueOf(hours) + ":59:59");
//		} else {
//			startTime = ReportConstants.START_TIME.replace(ReportConstants.START_TIME,
//					"0" + String.valueOf(hours) + ":00:00");
//			endTime = ReportConstants.END_TIME.replace(ReportConstants.END_TIME,
//					"0" + String.valueOf(hours) + ":59:59");
//		}
//
//		if (rgm.isGenerate() == true) {
//			String txnStart = rgm.getTxnStartDate().format(formatter).concat(" ").concat(startTime);
//			String txnEnd = rgm.getTxnEndDate().format(formatter).concat(" ").concat(endTime);
//
//			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
//					ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toString());
//			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
//					ReportGenerationFields.TYPE_STRING,
//					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
//							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
//							+ ReportConstants.FORMAT_TXN_DATE + "')");
//
//			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
//			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
//		} else {
//			String txnStart = rgm.getYesterdayDate().format(formatter).concat(" ").concat(startTime);
//			String txnEnd = rgm.getTodayDate().format(formatter).concat(" ").concat(endTime);
//
//			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
//					ReportGenerationFields.TYPE_DATE, rgm.getYesterdayDate().toString());
//			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
//					ReportGenerationFields.TYPE_STRING,
//					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
//							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
//							+ ReportConstants.FORMAT_TXN_DATE + "')");
//
//			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
//			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
//		}
//	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmDailyTransactionSummary.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		String hourValue = null;
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.HOUR)) {
					switch (hours) {
					case 0:
						hourValue = "12 AM";
						break;
					case 1:
						hourValue = "1 AM";
						break;
					case 2:
						hourValue = "2 AM";
						break;
					case 3:
						hourValue = "3 AM";
						break;
					case 4:
						hourValue = "4 AM";
						break;
					case 5:
						hourValue = "5 AM";
						break;
					case 6:
						hourValue = "6 AM";
						break;
					case 7:
						hourValue = "7 AM";
						break;
					case 8:
						hourValue = "8 AM";
						break;
					case 9:
						hourValue = "9 AM";
						break;
					case 10:
						hourValue = "10 AM";
						break;
					case 11:
						hourValue = "11 AM";
						break;
					case 12:
						hourValue = "12 PM";
						break;
					case 13:
						hourValue = "1 PM";
						break;
					case 14:
						hourValue = "2 PM";
						break;
					case 15:
						hourValue = "3 PM";
						break;
					case 16:
						hourValue = "4 PM";
						break;
					case 17:
						hourValue = "5 PM";
						break;
					case 18:
						hourValue = "6 PM";
						break;
					case 19:
						hourValue = "7 PM";
						break;
					case 20:
						hourValue = "8 PM";
						break;
					case 21:
						hourValue = "9 PM";
						break;
					case 22:
						hourValue = "10 PM";
						break;
					case 23:
						hourValue = "11 PM";
						break;
					default:
						break;
					}
					line.append(hourValue);
				} else {
					line.append(getGlobalFieldValue(rgm, field));
				}
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
			}
		}
		hours++;
		rgm.writeLine(line.toString().getBytes());
	}
}
