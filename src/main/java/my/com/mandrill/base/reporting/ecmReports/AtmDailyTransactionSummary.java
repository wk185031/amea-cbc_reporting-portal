package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;
import my.com.mandrill.base.web.rest.ReportGenerationResource;

public class AtmDailyTransactionSummary extends CsvReportProcessor {
	private final Logger logger = LoggerFactory.getLogger(AtmDailyTransactionSummary.class);
	private List<String> terminalIdList = new ArrayList<String>();
	public static final String DELIMITER = ";";
	private static final DecimalFormat AMOUNT_FORMATTER = new DecimalFormat(
			ReportGenerationFields.DEFAULT_DECIMAL_FORMAT);
	private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
	private ArrayList<String> TRAILER_QUERY;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);
			retrieveTerminalId(rgm);

			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			
			TRAILER_QUERY = new ArrayList<String>();

			for (int i = 0; i < terminalIdList.size(); i++) {
				for (int counter = 0; counter < 24; counter++) {
					preProcessingTime(rgm, counter, terminalIdList.get(i));
					executeBodyQuery(rgm, counter, terminalIdList.get(i));
				}
			}

			writeTrailer(rgm);

			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
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
	
	protected void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmDailyTransactionSummary writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		
		LocalDateTime txnStartDateTime = rgm.getTxnStartDate();
		LocalDateTime txnEndDateTime = rgm.getTxnEndDate();
		long noOfDaysBetween = ChronoUnit.DAYS.between(txnStartDateTime, txnEndDateTime);
		
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.FILE_NAME) && noOfDaysBetween > 1) {
				line.append(ReportConstants.ATM_MONTHLY_TRANSACTION_SUMMARY_REPORT_HEADER);
				line.append(field.getDelimiter());
			} else if (field.isEol()) {
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

	private void preProcessingTime(ReportGenerationMgr rgm, int counter, String terminalId)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {

		String txnStart = rgm.getTxnStartDate().format(FORMATTER);
		String txnEnd = rgm.getTxnEndDate().format(FORMATTER);
		
		LocalTime startTime = LocalTime.of(counter, 0, 0);
		LocalTime endTime;

		StringBuilder endTimeQuery = new StringBuilder("");

		if (counter == 23) {
			endTime = LocalTime.of(counter, 59, 59);
			endTimeQuery.append("' AND TO_CHAR(TXN.TRL_SYSTEM_TIMESTAMP, 'HH24:MI:SS') <= '" + endTime + "'");
		} else {
			endTime = LocalTime.of(counter + 1, 0, 0);
			endTimeQuery.append("' AND TO_CHAR(TXN.TRL_SYSTEM_TIMESTAMP, 'HH24:MI:SS') < '" + endTime + "'");
		}

		rgm.setBodyQuery(rgm.getTmpBodyQuery());

		if (rgm.getBodyQuery() != null) {

			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_TXN_TIME + "}",
					"AND TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')"
							+ " AND TO_CHAR(TXN.TRL_SYSTEM_TIMESTAMP, 'HH24:MI:SS') >= '" + startTime + endTimeQuery));

			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}",
					"AND AST.AST_TERMINAL_ID = '" + terminalId + "'"));

			TRAILER_QUERY.add(rgm.getTrailerQuery().replace("AND {" + ReportConstants.PARAM_TXN_TIME + "}",
					"AND TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')"
							+ " AND TO_CHAR(TXN.TRL_SYSTEM_TIMESTAMP, 'HH24:MI:SS') >= '" + startTime + endTimeQuery));

		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmDailyTransactionSummary.writeBodyHeader()");
		StringBuilder line = new StringBuilder();
		String hourValue = null;

		line.append("TIME").append(DELIMITER);
		for (int i = 0; i < 24; i++) {
			switch (i) {
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
			line.append(hourValue).append(";");
			line.append("").append(";");
			line.append("").append(";");
			line.append("").append(";");
		}

		line.append(System.getProperty("line.separator"));

		line.append("Terminal").append(DELIMITER);

		for (int i = 0; i < 24; i++) {
			line.append("REJECTED").append(DELIMITER).append("APPROVED").append(DELIMITER).append("TOTAL")
					.append(DELIMITER).append("AMOUNT").append(DELIMITER);
		}

		line.append(System.getProperty("line.separator"));

		rgm.writeLine(line.toString().getBytes());

	}

	private void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmDailyTransactionSummary.writeTrailer()");

		for (int counter = 0; counter < 24; counter++) {
			executeTrailerQuery(rgm, counter);
		}
		
	}

	private void retrieveTerminalId(ReportGenerationMgr rgm) {

		ResultSet rs = null;
		PreparedStatement ps = null;

		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);
		
		String query = "SELECT DISTINCT AST.AST_TERMINAL_ID AS TERMINAL " + "FROM TRANSACTION_LOG TXN "
				+ " JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID "
				+ " JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID "
				+ "WHERE TXN.TRL_TQU_ID = 'F' " + " AND NVL(TXN.TRL_POST_COMPLETION_CODE, ' ') != 'R' "
				+ " AND DEO.DEO_NAME = '" + rgm.getInstitution() + "'"
				+ " AND TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
				+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE
				+ "') ORDER BY TERMINAL ";

		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
				rs = ps.executeQuery();

				while (rs.next()) {
					try {
						terminalIdList.add(rs.getString("TERMINAL"));
					} catch (SQLException e) {
						rgm.errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}

				}

			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}

	private void executeBodyQuery(ReportGenerationMgr rgm, int counter, String terminalId) throws IOException {

		ResultSet rs = null;
		PreparedStatement ps = null;

		String query = getBodyQuery(rgm);
		StringBuilder line = new StringBuilder();

		if (counter == 0) {
			line.append(terminalId).append(DELIMITER);
		}

		int rejectedCount = 0;
		int approvedCount = 0;
		int totalCount = 0;
		double amount = 0;

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
				rs = ps.executeQuery();

				while (rs.next()) {

					try {
						rejectedCount = rs.getInt("REJECTED COUNT");
						approvedCount = rs.getInt("APPROVED COUNT");
						totalCount = rs.getInt("TOTAL COUNT");
						amount = rs.getDouble("AMOUNT");

					} catch (SQLException e) {
						rgm.errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}

		line.append(rejectedCount).append(DELIMITER);
		line.append(approvedCount).append(DELIMITER);
		line.append(totalCount).append(DELIMITER);
		line.append(AMOUNT_FORMATTER.format(amount)).append(DELIMITER);

		if (counter == 23) {
			line.append(System.getProperty("line.separator"));
		}

		rgm.writeLine(line.toString().getBytes());
	}

	private void executeTrailerQuery(ReportGenerationMgr rgm, int counter) throws IOException {

		ResultSet rs = null;
		PreparedStatement ps = null;

		String query = TRAILER_QUERY.size() > 0 ? TRAILER_QUERY.get(counter) : null;
		StringBuilder line = new StringBuilder();
		
		if (counter == 0) {
			line.append("Grand AMOUNT").append(DELIMITER);
		}

		int rejectedCount = 0;
		int approvedCount = 0;
		int totalCount = 0;
		double amount = 0;

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
				rs = ps.executeQuery();

				while (rs.next()) {

					try {
						rejectedCount = rs.getInt("REJECTED COUNT");
						approvedCount = rs.getInt("APPROVED COUNT");
						totalCount = rs.getInt("TOTAL COUNT");
						amount = rs.getDouble("AMOUNT");

					} catch (SQLException e) {
						rgm.errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}

		line.append(rejectedCount).append(DELIMITER);
		line.append(approvedCount).append(DELIMITER);
		line.append(totalCount).append(DELIMITER);
		line.append(AMOUNT_FORMATTER.format(amount)).append(DELIMITER);

		rgm.writeLine(line.toString().getBytes());
	}
}
