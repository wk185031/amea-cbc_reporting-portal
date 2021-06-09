package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class AtmDailyTransactionSummary extends CsvReportProcessor {
	private final Logger logger = LoggerFactory.getLogger(AtmDailyTransactionSummary.class);
	private List <String> terminalIdList = new ArrayList<String>();
	public static final String DELIMITER = ";";

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);
			retrieveTerminalId(rgm);
			
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			
			for(int i=0; i< terminalIdList.size(); i++) {
				for(int counter = 0; counter < 24; counter++) {
					preProcessingTime(rgm, counter, terminalIdList.get(i));
					executeBodyQuery(rgm, counter, terminalIdList.get(i));
				}
			}
			
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
	
	private void preProcessingTime(ReportGenerationMgr rgm, int counter, String terminalId)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		LocalDateTime txnStart = rgm.getTxnStartDate();
		
		LocalDateTime replacedStart = txnStart.withHour(counter);
		LocalDateTime replacedEnd;
		
		if(counter == 23) {
			replacedEnd = txnStart.plusDays(1).withHour(0);
		}else {
			replacedEnd = txnStart.withHour(counter+1);
		}
		
		String replacedStartStr = replacedStart.format(formatter);
		String replacedEndStr = replacedEnd.format(formatter);
		
		rgm.setBodyQuery(rgm.getTmpBodyQuery());
		
		if (rgm.getBodyQuery() != null) {
			
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_TXN_TIME + "}", 
					"AND TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + replacedStartStr + "', '" + ReportConstants.FORMAT_TXN_DATE 
					+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + replacedEndStr + "','" + ReportConstants.FORMAT_TXN_DATE + "')"));
			
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", "AND AST.AST_TERMINAL_ID = '" + terminalId + "'"));
			
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
			line.append("").append(";");
			line.append(hourValue).append(";");
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
	
	protected void retrieveTerminalId(ReportGenerationMgr rgm) {

		ResultSet rs = null;
		PreparedStatement ps = null;

		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);

		String query = "SELECT DISTINCT AST.AST_TERMINAL_ID AS TERMINAL " + "FROM TRANSACTION_LOG TXN "
				+ " JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID "
				+ "WHERE TXN.TRL_TQU_ID = 'F' " + " AND NVL(TXN.TRL_POST_COMPLETION_CODE, ' ') != 'R' "
				+ " AND TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
				+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE
				+ "') ORDER BY TERMINAL ";

		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
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
	
	protected void executeBodyQuery(ReportGenerationMgr rgm, int counter, String terminalId) throws IOException {

		ResultSet rs = null;
		PreparedStatement ps = null;

		String query = getBodyQuery(rgm);
		StringBuilder line = new StringBuilder();
		
		if(counter == 0) {
			line.append(terminalId).append(DELIMITER);
		}
		
		int rejectedCount = 0;
		int approvedCount = 0;
		int totalCount = 0;
		long amount = 0;

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();

				while (rs.next()) {

					try {
						rejectedCount = rs.getInt("REJECTED COUNT");
						approvedCount = rs.getInt("APPROVED COUNT");
						totalCount = rs.getInt("TOTAL COUNT");
						amount = rs.getLong("AMOUNT");
						
					} catch (SQLException e) {
						rgm.errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}
				}
			}
			catch (Exception e) {
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
		
		line.append(rejectedCount).append(DELIMITER);
		line.append(approvedCount).append(DELIMITER);
		line.append(totalCount).append(DELIMITER);
		line.append(amount).append(DELIMITER);
		
		if(counter == 23) {
			line.append(System.getProperty("line.separator"));
		}
		
		rgm.writeLine(line.toString().getBytes());
	}
}
	

