package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.SortedMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class AtmDowntime extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(AtmDowntime.class);
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
			String terminal = null;
			String cause = null;
			
			rgm.fileOutputStream = new FileOutputStream(file);
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			preProcess(rgm);
			separateQuery(rgm);
			addAtmDownTimeReportPreProcessingFieldsToGlobalMap(rgm);
			writeBodyHeader(rgm);
			
			List<String> causeListing = new ArrayList<>();
			for (SortedMap.Entry<String, String> causeMap : filterCriteriaByCause(rgm).entrySet()) {
				cause = causeMap.getKey();
				causeListing.add(cause);
			}
			
			for (SortedMap.Entry<String, String> terminalMap : filterCriteriaByTerminal(rgm).entrySet()) {
				terminal = terminalMap.getKey();
			    for (int listCause = 0; listCause < causeListing.size(); listCause++) {
					preProcess(rgm, terminal, causeListing.get(listCause));
					rgm.setTrailerQuery(getCauseTrailerQuery());
					executeBodyQuery(rgm);
					executeCauseTrailerQuery(rgm);
			    }
			    rgm.setTrailerQuery(getTerminalTrailerQuery());
				StringBuilder line = new StringBuilder();
			    line.append(",,,,,").append(terminal).append(" ");
				rgm.writeLine(line.toString().getBytes());
				executeTerminalTrailerQuery(rgm);
			}
			
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
			
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in generating CSV file", e);
		} finally {
			
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			
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
		logger.debug("In AtmDowntime.preProcess()");
		
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery()
					.replace("{" + ReportConstants.PARAM_FROM_DATE + "}",
							rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern("yyyyMMdd HH:mm:ss")))
					.replace("{" + ReportConstants.PARAM_TO_DATE + "}",
							rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern("yyyyMMdd HH:mm:ss")))
					.replace("AND {" + ReportConstants.PARAM_DOWN_REASON + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}
	}
	
	private void preProcess(ReportGenerationMgr rgm, String filterByTerminal, String filterByCause) 
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmDowntime.preProcess()");
		
		if (rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			
			if (filterByTerminal != null) {
				ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
						ReportGenerationFields.TYPE_STRING, "AST.AST_TERMINAL_ID = '" + filterByTerminal + "'");
				getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
			}
			
			if (filterByCause != null) {
				ReportGenerationFields cause = new ReportGenerationFields(ReportConstants.PARAM_DOWN_REASON,
						ReportGenerationFields.TYPE_STRING, "CASE WHEN TRIM(ATD.ATD_DOWN_REASON) = 'Comms Event' THEN 'Host'\r\n"
								+ "          WHEN TRIM(ATD.ATD_DOWN_REASON) = 'In supervisor mode' THEN 'Replenish'\r\n"
								+ "          WHEN TRIM(ATD.ATD_DOWN_REASON) = 'Power fail' THEN 'PF'\r\n"
								+ "          WHEN TRIM(ATD.ATD_DOWN_REASON) IN ('Card reader faulty', 'Cash dispenser faulty', 'Encryptor faulty') THEN 'HW'\r\n"
								+ "          WHEN TRIM(ATD.ATD_DOWN_REASON) = 'Cash dispenser faulty' THEN 'OOC'\r\n"
								+ "          WHEN TRIM(ATD.ATD_DOWN_REASON) = 'Cash availability status change' THEN 'Cash'\r\n"
								//+ "          WHEN TRIM(ATD.ATD_DOWN_REASON) IN ('Operator request', 'Exiting supervisor mode') THEN 'Other' "
								+ " END = '" + filterByCause + "'");
				getGlobalFileFieldsMap().put(cause.getFieldName(), cause);
			}
		}
	}
	
	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In AtmDowntime.separateQuery()");
		
		if (rgm.getTrailerQuery() != null) {
			setCauseTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_STARTING)));
			setTerminalTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_STARTING),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_STARTING, ""));
		}
	}

	@Override
	protected String getAtmDownTimeStartDateRangeFieldName() {
		return "ATD.ATD_START_TIMESTAMP";
	}
	
	@Override
	protected String getAtmDownTimeEndDateRangeFieldName() {
		return "ATD.ATD_END_TIMESTAMP";
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			line.append(getFieldValue(rgm, field, fieldsMap));
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
	
	private void executeCauseTrailerQuery(ReportGenerationMgr rgm) {
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
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
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeCauseTrailer(rgm, lineFieldsMap);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}
	
	private void executeTerminalTrailerQuery(ReportGenerationMgr rgm) {
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
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
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeTerminalTrailer(rgm, lineFieldsMap);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}
	
	private void writeCauseTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		String total = null;
		line.append(",,,,,,").append("Sub Total");
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.CAUSE_TERMINAL_TOTAL)) {
					total = getFieldValue(rgm, field, fieldsMap);
					line.append(",").append(total);
				}
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
	
	private void writeTerminalTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		String total = null;
		line.append(",").append("Total Downtime");
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.CAUSE_TERMINAL_TOTAL)) {
					total = getFieldValue(rgm, field, fieldsMap);
					line.append(",").append(total);
				}
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}
