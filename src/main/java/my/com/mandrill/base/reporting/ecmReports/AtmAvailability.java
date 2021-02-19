package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
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

public class AtmAvailability extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(AtmAvailability.class);
	String terminal = null;
	private int terminalCount = 0;
	double availablePercentage = 0.00;
	double totalPercentage = 0.00;
	int totalMeetStandard = 0;

	public String getTerminal() {
		return terminal;
	}

	public void setTerminal(String terminal) {
		this.terminal = terminal;
	}

	public double getAvailablePercentage() {
		return availablePercentage;
	}

	public void setAvailablePercentage(double availablePercentage) {
		this.availablePercentage = availablePercentage;
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
        DecimalFormat formatter = new DecimalFormat("##0.00");
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcess(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			StringBuilder line = new StringBuilder();
			line.append(ReportConstants.SEPARATOR).append(ReportConstants.SEPARATOR).append(ReportConstants.SEPARATOR)
					.append(ReportConstants.SEPARATOR).append(formatter.format(totalPercentage) + "%")
					.append(ReportConstants.SEPARATOR).append(ReportConstants.SEPARATOR).append(totalMeetStandard);
			line.append(getEol());

			double averagePercentage = totalPercentage / terminalCount;
			String passedNotPassed = averagePercentage > 95 ? "PASSED" : "NOT PASSED";
			double percentageMeetStandard = new BigDecimal(totalMeetStandard)
					.divide(new BigDecimal(terminalCount), 2, RoundingMode.HALF_UP).multiply(new BigDecimal(100))
					.doubleValue();

			line.append(ReportConstants.SEPARATOR).append(ReportConstants.SEPARATOR).append(ReportConstants.SEPARATOR)
					.append("ATM Average Performance").append(ReportConstants.SEPARATOR)
					.append(formatter.format(averagePercentage) + "%").append(ReportConstants.SEPARATOR)
					.append(passedNotPassed).append(ReportConstants.SEPARATOR).append("ATMs Meeting Std")
					.append(ReportConstants.SEPARATOR).append(formatter.format(percentageMeetStandard) + "%");
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

	private void preProcess(ReportGenerationMgr rgm) {
		long totalSeconds = ChronoUnit.SECONDS.between(rgm.getTxnStartDate(), rgm.getTxnEndDate());
		logger.debug("endDate:{}, startDate:{}, totalSeconds:{}", rgm.getTxnEndDate(), rgm.getTxnStartDate(), totalSeconds);
		rgm.setBodyQuery(
				rgm.getBodyQuery().replace("{" + ReportConstants.PARAM_TOTAL_DAY + "}", String.valueOf(totalSeconds))
				.replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern("yyyyMMdd HH:mm:ss")) + "'"));
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}
	
	@Override
	protected String getTransactionDateRangeFieldName() {
		return "ATD.ATD_START_TIMESTAMP";
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
		//double targetHour = 24 * noOfDaysInMonth;
		
		double available = 0.00;
		//double unavailable = 0.00;
		
		for (ReportGenerationFields field : fields) {
			
			switch (field.getFieldName()) {
			case ReportConstants.TERMINAL:
				terminalCount++;
				setTerminal(getFieldValue(field, fieldsMap));
				line.append("\t" + getFieldValue(rgm, field, fieldsMap));
				break;
			case ReportConstants.AVAILABLE:
				String availableValue = getFieldValue(rgm, field, fieldsMap);
				available = Double.valueOf(availableValue);
				line.append(availableValue);
				totalPercentage += available;
				break;
//			case ReportConstants.UNAVAILABLE:
//				String unavailableValue = getFieldValue(rgm, field, fieldsMap);
//				line.append(unavailableValue);
//				unavailable = Double.valueOf(unavailableValue);
//				break;
			case ReportConstants.STANDARD:
				//String standardValue = getFieldValue(rgm, field, fieldsMap);
				String standardValue = available > 95 ? "1" : "0";
				line.append(standardValue);
				totalMeetStandard += "1".equals(standardValue) ? 1 : 0;
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
