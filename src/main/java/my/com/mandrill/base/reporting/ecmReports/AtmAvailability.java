package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
		//DecimalFormat formatter = new DecimalFormat("#,##0.00");
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
		long totalDay = ChronoUnit.DAYS.between(rgm.getTxnEndDate().toLocalDate(), rgm.getTxnStartDate().toLocalDate());
		rgm.setBodyQuery(
				rgm.getBodyQuery().replace("{" + ReportConstants.PARAM_TOTAL_DAY + "}", String.valueOf(totalDay + 1L)));
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

//	@Override
//	protected void addReportPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
//		logger.debug("In AtmAvailability.addPreProcessingFieldsToGlobalMap()");
//		if (rgm.isGenerate() == true) {
//			String txnStart = rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
//					.concat(" ").concat(ReportConstants.START_TIME);
//			String txnEnd = rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
//					.concat(" ").concat(ReportConstants.END_TIME);
//			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
//					ReportGenerationFields.TYPE_STRING,
//					"ATD.ATD_START_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
//							+ "') AND ATD.ATD_START_TIMESTAMP < TO_DATE('" + txnEnd + "','"
//							+ ReportConstants.FORMAT_TXN_DATE + "')");
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
//					"ATD.ATD_START_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
//							+ "') AND ATD.ATD_START_TIMESTAMP < TO_DATE('" + txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE
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
		double targetHour = 24 * noOfDaysInMonth;

		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TERMINAL:
				terminalCount++;
				setTerminal(getFieldValue(field, fieldsMap));
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			case ReportConstants.AVAILABLE:
//				DecimalFormat availableFormatter = new DecimalFormat("#,##0.00");
//				setCriteriaQuery(
//						"SELECT ASH.ASH_TIMESTAMP FROM ATM_STATIONS AST JOIN ATM_STATUS_HISTORY ASH ON AST.AST_ID = ASH.ASH_AST_ID WHERE ASH.ASH_COMM_STATUS = 'Up' AND ASH.ASH_SERVICE_STATE_REASON IN ('Comms Event', 'In supervisor mode', 'Power fail', 'Card reader faulty', 'Cash dispenser faulty', 'Encryptor faulty', 'Cash dispenser faulty', 'Cash availability status change', 'Operator request') AND SUBSTR(AST.AST_TERMINAL_ID, -4) = '"
//								+ getTerminal() + "'");
//				ZonedDateTime availableOutageHour = ZonedDateTime
//						.ofInstant(Instant.ofEpochMilli(Long.parseLong(executeQuery(rgm))), ZoneId.systemDefault());
//				double available = ((targetHour - availableOutageHour.getHour()) / targetHour) * 100;
//				line.append(availableFormatter.format(available) + "%");
//				setAvailablePercentage(available);
				String value = getFieldValue(rgm, field, fieldsMap);
				line.append(value);
				totalPercentage += Double.valueOf(value);
				break;
//			case ReportConstants.UNAVAILABLE:
//				DecimalFormat unavailableFormatter = new DecimalFormat("#,##0.00");
//				setCriteriaQuery(
//						"SELECT ASH.ASH_TIMESTAMP FROM ATM_STATIONS AST JOIN ATM_STATUS_HISTORY ASH ON AST.AST_ID = ASH.ASH_AST_ID WHERE ASH.ASH_COMM_STATUS = 'Down' AND ASH.ASH_SERVICE_STATE_REASON IN ('Comms Event', 'In supervisor mode', 'Power fail', 'Card reader faulty', 'Cash dispenser faulty', 'Encryptor faulty', 'Cash dispenser faulty', 'Cash availability status change', 'Operator request') AND SUBSTR(AST.AST_TERMINAL_ID, -4) = '"
//								+ getTerminal() + "'");
//				ZonedDateTime unavailableOutageHour = ZonedDateTime
//						.ofInstant(Instant.ofEpochMilli(Long.parseLong(executeQuery(rgm))), ZoneId.systemDefault());
//				double unavailable = ((targetHour - unavailableOutageHour.getHour()) / targetHour) * 100;
//				line.append(unavailableFormatter.format(unavailable) + "%");
//				break;
			case ReportConstants.STANDARD:
				String standardValue = getFieldValue(rgm, field, fieldsMap);
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

	private String executeQuery(ReportGenerationMgr rgm) {
		logger.debug("In AtmAvailability.executeQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = getCriteriaQuery();
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.connection.prepareStatement(query);
			rs = ps.executeQuery();

			while (rs.next()) {
				Object result = rs.getObject("ASH_TIMESTAMP");
				return Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime());
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
		return "";
	}
}
