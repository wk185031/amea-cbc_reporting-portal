package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;
import my.com.mandrill.base.web.rest.ReportGenerationResource;

public class DailySummaryRfidChannelPayments extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(DailySummaryRfidChannelPayments.class);
	public static final String SUBSTRING_START_FIRST_PAGE = "START FIRST PAGE";
	public static final String SUBSTRING_END_FIRST_PAGE = "END FIRST PAGE";
	public static final String SUBSTRING_START_SECOND_PAGE = "START SECOND PAGE";
	public static final String SUBSTRING_END_SECOND_PAGE = "END SECOND PAGE";
	public static final String SUBSTRING_START_THIRD_PAGE = "START THIRD PAGE";
	public static final String SUBSTRING_END_THIRD_PAGE = "END THIRD PAGE";
	public static final String SUMMARY_OF_RFID_PAYMENTS_PER_CHANNEL_REPORT = "SUMMARY OF RFID PAYMENTS PER CHANNEL REPORT";
	public static final String File_Name1 = "File Name1";
	private String firstPageBodyQuery = null;
	private String secondPageBodyQuery = null;
	private String thirdPageBodyQuery = null;
	private String firstPageTrailerQuery = null;
	private String secondPageTrailerQuery = null;
	private String thirdPageTrailerQuery = null;
	private int pagination = 0;

	public String getFirstPageBodyQuery() {
		return firstPageBodyQuery;
	}

	public void setFirstPageBodyQuery(String firstPageBodyQuery) {
		this.firstPageBodyQuery = firstPageBodyQuery;
	}

	public String getSecondPageBodyQuery() {
		return secondPageBodyQuery;
	}

	public void setSecondPageBodyQuery(String secondPageBodyQuery) {
		this.secondPageBodyQuery = secondPageBodyQuery;
	}

	public String getThirdPageBodyQuery() {
		return thirdPageBodyQuery;
	}

	public void setThirdPageBodyQuery(String thirdPageBodyQuery) {
		this.thirdPageBodyQuery = thirdPageBodyQuery;
	}

	public String getFirstPageTrailerQuery() {
		return firstPageTrailerQuery;
	}

	public void setFirstPageTrailerQuery(String firstPageTrailerQuery) {
		this.firstPageTrailerQuery = firstPageTrailerQuery;
	}

	public String getSecondPageTrailerQuery() {
		return secondPageTrailerQuery;
	}

	public void setSecondPageTrailerQuery(String secondPageTrailerQuery) {
		this.secondPageTrailerQuery = secondPageTrailerQuery;
	}

	public String getThirdPageTrailerQuery() {
		return thirdPageTrailerQuery;
	}

	public void setThirdPageTrailerQuery(String thirdPageTrailerQuery) {
		this.thirdPageTrailerQuery = thirdPageTrailerQuery;
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			pagination++;
			writeHeader(rgm, pagination);
			firstPageDetails(rgm);

			pagination++;
			writeHeader(rgm, pagination);
			secondPageDetails(rgm);

			pagination++;
			writeThirdHeader(rgm, pagination);
			thirdPageDetails(rgm);

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

	private void firstPageDetails(ReportGenerationMgr rgm) {
		logger.debug("In DailySummaryRfidChannelPayments.firstPageDetails()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		try {
			writeFirstPageBodyHeader(rgm);

			rgm.setBodyQuery(getFirstPageBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					StringBuilder line = new StringBuilder();
					line.append(branchCode).append(";").append(";").append(branchName).append(";");
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						rgm.setBodyQuery(getFirstPageBodyQuery());
						rgm.setTrailerQuery(getFirstPageTrailerQuery());
						preProcessing(rgm, branchCode, terminal, true);
						executeBodyQuery(rgm, location, "firstPage");
					}
				}
			}
			executeTrailerQuery(rgm, "firstPage");
			StringBuilder line = new StringBuilder();
			line.append("*** END OF REPORT ***");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in summaryDetails", e);
		}
	}

	private void secondPageDetails(ReportGenerationMgr rgm) {
		logger.debug("In DailySummaryRfidChannelPayments.secondPageDetails()");
		String branchCode = null;
		try {
			writeSecondPageBodyHeader(rgm);

			rgm.setBodyQuery(getSecondPageBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
			for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				rgm.setBodyQuery(getSecondPageBodyQuery());
				rgm.setTrailerQuery(getSecondPageTrailerQuery());
				preProcessing(rgm, branchCode, null, false);
				executeBodyQuery(rgm, null, "secondPage");
			}
			executeTrailerQuery(rgm, "secondPage");
			StringBuilder line = new StringBuilder();
			line.append("*** END OF REPORT ***");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in summaryDetails", e);
		}
	}

	private void thirdPageDetails(ReportGenerationMgr rgm) {
		logger.debug("In DailySummaryRfidChannelPayments.thirdPageDetails()");
		String branchCode = null;
		try {
			writeThirdPageBodyHeader(rgm);

			rgm.setBodyQuery(getThirdPageBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
			for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				rgm.setBodyQuery(getThirdPageBodyQuery());
				rgm.setTrailerQuery(getThirdPageTrailerQuery());
				preProcessing(rgm, branchCode, null, false);
				executeBodyQuery(rgm, null, "thirdPage");
			}
			executeTrailerQuery(rgm, "thirdPage");
			StringBuilder line = new StringBuilder();
			line.append("*** END OF REPORT ***");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in summaryDetails", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In DailySummaryRfidChannelPayments.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setFirstPageBodyQuery(
					rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(SUBSTRING_START_FIRST_PAGE) + 16,
							rgm.getBodyQuery().indexOf(SUBSTRING_END_FIRST_PAGE)));
			setSecondPageBodyQuery(
					rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(SUBSTRING_START_SECOND_PAGE) + 17,
							rgm.getBodyQuery().indexOf(SUBSTRING_END_SECOND_PAGE)));
			setThirdPageBodyQuery(
					rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(SUBSTRING_START_THIRD_PAGE) + 16,
							rgm.getBodyQuery().indexOf(SUBSTRING_END_THIRD_PAGE)));
		}

		if (rgm.getTrailerQuery() != null) {
			setFirstPageTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(SUBSTRING_START_FIRST_PAGE) + 16,
							rgm.getTrailerQuery().indexOf(SUBSTRING_END_FIRST_PAGE)));
			setSecondPageTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(SUBSTRING_START_SECOND_PAGE) + 17,
							rgm.getTrailerQuery().indexOf(SUBSTRING_END_SECOND_PAGE)));
			setThirdPageTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(SUBSTRING_START_THIRD_PAGE) + 16,
							rgm.getTrailerQuery().indexOf(SUBSTRING_END_THIRD_PAGE)));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal,
			boolean indicator) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In DailySummaryRfidChannelPayments.preProcessing()");
		if (filterByBranchCode != null) {
			if (indicator) {
				ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
						ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
				getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			} else {
				ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
						ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
				getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			}
		}

		if (filterByTerminal != null) {
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(AST.AST_TERMINAL_ID, -4) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}
	@Override
	protected void writeHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In DailySummaryRfidChannelPayments.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(getEol());
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					line.append(String.valueOf(pagination));{
				}
				line.append(field.getDelimiter());
			} else if (ReportGenerationResource.getUserInsId().equalsIgnoreCase("CBS") && 
		              (field.getFieldName().equalsIgnoreCase("Bank Code") || field.getFieldName().equalsIgnoreCase("Bank Name"))){
		          if(field.getFieldName().equalsIgnoreCase("Bank Code")) {
		              line.append("0112");
		              line.append(field.getDelimiter());
		          }else{
		              line.append("CHINA BANK SAVINGS");
		              line.append(field.getDelimiter());
		          }
			} 
			else {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeThirdHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In DailySummaryRfidChannelPayments.writeThirdHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(getEol());
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					line.append(String.valueOf(pagination));{
				}
				line.append(field.getDelimiter());
			} else if (ReportGenerationResource.getUserInsId().equalsIgnoreCase("CBS") && 
		              (field.getFieldName().equalsIgnoreCase("Bank Code") || field.getFieldName().equalsIgnoreCase("Bank Name"))){
		          if(field.getFieldName().equalsIgnoreCase("Bank Code")) {
		              line.append("0112");
		              line.append(field.getDelimiter());
		          }else{
		              line.append("CHINA BANK SAVINGS");
		              line.append(field.getDelimiter());
		          }
			} else if(field.getFieldName().equalsIgnoreCase(File_Name1)) {
				line.append(SUMMARY_OF_RFID_PAYMENTS_PER_CHANNEL_REPORT);
				line.append(field.getDelimiter());
			}
			else {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
	private void writeFirstPageBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In DailySummaryRfidChannelPayments.writeFirstPageBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
			case 21:
			case 22:
			case 24:
			case 26:
			case 27:
			case 29:
			case 31:
			case 32:
			case 34:
			case 36:
			case 37:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			default:
				break;
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeSecondPageBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In DailySummaryRfidChannelPayments.writeSecondPageBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 5:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				break;
			case 7:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(field.getDelimiter());
				break;
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 20:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(field.getDelimiter());
				break;
			case 21:
			case 22:
			case 24:
			case 26:
			case 27:
			case 29:
			case 31:
			case 32:
			case 34:
			case 36:
			case 37:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			default:
				break;
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeThirdPageBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In DailySummaryRfidChannelPayments.writeThirdPageBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 7:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(field.getDelimiter());
				break;
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 14:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(getEol());
				break;
			case 18:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				break;
			case 20:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(field.getDelimiter());
				break;
			case 21:
			case 23:
			case 25:
			case 26:
			case 28:
			case 30:
			case 31:
			case 33:
			case 35:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			default:
				break;
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeFirstPageBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String location)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 38:
			case 39:
			case 40:
			case 41:
			case 42:
			case 43:
			case 44:
			case 45:
			case 46:
			case 47:
			case 48:
			case 49:
			case 50:
			case 51:
				if (!field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
						line.append(location);
					} else {
						line.append(getFieldValue(rgm, field, fieldsMap));
					}
				} else {
					line.append("");
				}
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeSecondPageBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 38:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			case 40:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				line.append(field.getDelimiter());
				break;
			case 41:
			case 42:
			case 43:
			case 44:
			case 45:
			case 46:
			case 47:
			case 48:
			case 49:
			case 50:
			case 51:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeThirdPageBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 38:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			case 40:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				line.append(field.getDelimiter());
				break;
			case 41:
			case 42:
			case 43:
			case 44:
			case 45:
			case 46:
			case 47:
			case 48:
			case 49:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeFirstPageTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In DailySummaryRfidChannelPayments.writeFirstPageTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeSecondPageTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In DailySummaryRfidChannelPayments.writeSecondPageTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeThirdPageTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In DailySummaryRfidChannelPayments.writeThirdPageTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 12:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				line.append(getEol());
				break;
			case 13:
			case 14:
				break;
			default:
				if (field.isEol()) {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void executeBodyQuery(ReportGenerationMgr rgm, String location, String paging) {
		logger.debug("In DailySummaryRfidChannelPayments.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

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
					if (paging.equalsIgnoreCase("firstPage")) {
						writeFirstPageBody(rgm, lineFieldsMap, location);
					} else if (paging.equalsIgnoreCase("secondPage")) {
						writeSecondPageBody(rgm, lineFieldsMap);
					} else {
						writeThirdPageBody(rgm, lineFieldsMap);
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanUpDbResource(ps, rs);
			}
		}
	}

	private void executeTrailerQuery(ReportGenerationMgr rgm, String paging) {
		logger.debug("In DailySummaryRfidChannelPayments.executeTrailerQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = null;
		if ("firstPage".equals(paging)) {
			query = getFirstPageTrailerQuery();
		} else if ("secondPage".equals(paging)) {
			query = getSecondPageTrailerQuery();
		} else if ("thirdPage".equals(paging)) {
			query = getThirdPageTrailerQuery();
		} else {
			return;
		}
		
		if (query != null) {
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
			String txnStart = rgm.getTxnStartDate().format(formatter);
			String txnEnd = rgm.getTxnEndDate().format(formatter);
			String criteria = "TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
					+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
					+ ReportConstants.FORMAT_TXN_DATE + "')";
			query = query.replace('{'+ReportConstants.PARAM_TXN_DATE+'}', criteria);
		}
		
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
					if (paging.equalsIgnoreCase("firstPage")) {
						writeFirstPageTrailer(rgm, lineFieldsMap);
					} else if (paging.equalsIgnoreCase("secondPage")) {
						writeSecondPageTrailer(rgm, lineFieldsMap);
					} else {
						writeThirdPageTrailer(rgm, lineFieldsMap);
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
			} finally {
				rgm.cleanUpDbResource(ps, rs);
			}
		}
	}
}
