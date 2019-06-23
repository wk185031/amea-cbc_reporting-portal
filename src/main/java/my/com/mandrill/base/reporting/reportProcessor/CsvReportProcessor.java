package my.com.mandrill.base.reporting.reportProcessor;

import java.io.File;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class CsvReportProcessor extends GeneralReportProcess implements ICsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(CsvReportProcessor.class);
	private String acquiringBodyQuery = null;
	private String issuingBodyQuery = null;
	private String receivingBodyQuery = null;
	private String ibftBodyQuery = null;
	private String summaryBodyQuery = null;
	private String ibftTrailerQuery = null;
	private String summaryTrailerQuery = null;
	private String criteriaQuery = null;

	public String getAcquiringBodyQuery() {
		return acquiringBodyQuery;
	}

	public void setAcquiringBodyQuery(String acquiringBodyQuery) {
		this.acquiringBodyQuery = acquiringBodyQuery;
	}

	public String getIssuingBodyQuery() {
		return issuingBodyQuery;
	}

	public void setIssuingBodyQuery(String issuingBodyQuery) {
		this.issuingBodyQuery = issuingBodyQuery;
	}

	public String getReceivingBodyQuery() {
		return receivingBodyQuery;
	}

	public void setReceivingBodyQuery(String receivingBodyQuery) {
		this.receivingBodyQuery = receivingBodyQuery;
	}

	public String getIbftBodyQuery() {
		return ibftBodyQuery;
	}

	public void setIbftBodyQuery(String ibftBodyQuery) {
		this.ibftBodyQuery = ibftBodyQuery;
	}

	public String getSummaryBodyQuery() {
		return summaryBodyQuery;
	}

	public void setSummaryBodyQuery(String summaryBodyQuery) {
		this.summaryBodyQuery = summaryBodyQuery;
	}

	public String getIbftTrailerQuery() {
		return ibftTrailerQuery;
	}

	public void setIbftTrailerQuery(String ibftTrailerQuery) {
		this.ibftTrailerQuery = ibftTrailerQuery;
	}

	public String getSummaryTrailerQuery() {
		return summaryTrailerQuery;
	}

	public void setSummaryTrailerQuery(String summaryTrailerQuery) {
		this.summaryTrailerQuery = summaryTrailerQuery;
	}

	public String getCriteriaQuery() {
		return criteriaQuery;
	}

	public void setCriteriaQuery(String criteriaQuery) {
		this.criteriaQuery = criteriaQuery;
	}

	@Override
	public void processCsvRecord(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.processCsvRecord()");
		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);

		try {
			if (rgm.isGenerate() == true) {
				txnDate = df.format(rgm.getFileDate());
			} else {
				txnDate = df.format(rgm.getYesterdayDate());
			}

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}
					file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate
							+ ReportConstants.CSV_FORMAT);
					execute(rgm, file);
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception("Errors when generating" + rgm.getFileNamePrefix() + "_" + txnDate
						+ ReportConstants.CSV_FORMAT);
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.CSV_FORMAT,
					e);
		}
	}

	protected void execute(ReportGenerationMgr rgm, File file) {
		// To be overriden
	}

	protected SortedMap<String, Map<String, Set<String>>> filterByCriteriaTxn(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterByCriteriaTxn()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, Set<String>>> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter criteria: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when getting result", e);
							continue;
						}
						if (result != null) {
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
								branchCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								branchName = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.TERMINAL)) {
								terminal = result.toString();
							}
						}
					}
					if (criteriaMap.get(branchCode) == null) {
						Map<String, Set<String>> tmpCriteriaMap = new HashMap<>();
						Set<String> terminalList = new HashSet<>();
						terminalList.add(terminal);
						tmpCriteriaMap.put(branchName, terminalList);
						criteriaMap.put(branchCode, tmpCriteriaMap);
					} else {
						Map<String, Set<String>> tmpCriteriaMap = criteriaMap.get(branchCode);
						if (tmpCriteriaMap.get(branchName) == null) {
							Set<String> terminalList = new HashSet<>();
							terminalList.add(terminal);
							tmpCriteriaMap.put(branchName, terminalList);
						} else {
							Set<String> terminalList = tmpCriteriaMap.get(branchName);
							terminalList.add(terminal);
						}
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the criteria", e);
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
		return criteriaMap;
	}

	protected SortedMap<String, Map<String, Map<String, Set<String>>>> filterByCriteria(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterByCriteria()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, Map<String, Set<String>>>> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter criteria: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when getting result", e);
							continue;
						}
						if (result != null) {
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
								branchCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								branchName = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.TERMINAL)) {
								terminal = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.LOCATION)) {
								location = result.toString();
							}
						}
					}
					if (criteriaMap.get(branchCode) == null) {
						Map<String, Map<String, Set<String>>> branchNameMap = new HashMap<>();
						Map<String, Set<String>> terminalMap = new HashMap<>();
						Set<String> locationList = new HashSet<>();
						locationList.add(location);
						terminalMap.put(terminal, locationList);
						branchNameMap.put(branchName, terminalMap);
						criteriaMap.put(branchCode, branchNameMap);
					} else {
						Map<String, Map<String, Set<String>>> branchNameMap = criteriaMap.get(branchCode);
						if (branchNameMap.get(branchName) == null) {
							Map<String, Set<String>> terminalMap = new HashMap<>();
							Set<String> locationList = new HashSet<>();
							locationList.add(location);
							terminalMap.put(terminal, locationList);
							branchNameMap.put(branchName, terminalMap);
						} else {
							Map<String, Set<String>> terminalMap = branchNameMap.get(branchName);
							if (terminalMap.get(terminal) == null) {
								Set<String> locationList = new HashSet<>();
								locationList.add(location);
								terminalMap.put(terminal, locationList);
							} else {
								Set<String> locationList = terminalMap.get(terminal);
								locationList.add(location);
							}
						}
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the criteria", e);
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
		return criteriaMap;
	}

	protected SortedMap<String, Map<String, Map<String, Map<String, String>>>> filterByCriteriaCashCard(
			ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterByCriteriaCashCard()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		String cardProduct = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, Map<String, Map<String, String>>>> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter criteria for cash card: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when getting result", e);
							continue;
						}
						if (result != null) {
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
								branchCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								branchName = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.TERMINAL)) {
								terminal = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.LOCATION)) {
								location = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.CARD_PRODUCT)) {
								cardProduct = result.toString();
							}
						}
					}
					if (criteriaMap.get(branchCode) == null) {
						Map<String, Map<String, Map<String, String>>> branchNameMap = new HashMap<>();
						Map<String, Map<String, String>> terminalMap = new HashMap<>();
						Map<String, String> locationMap = new HashMap<>();
						locationMap.put(location, cardProduct);
						terminalMap.put(terminal, locationMap);
						branchNameMap.put(branchName, terminalMap);
						criteriaMap.put(branchCode, branchNameMap);
					} else {
						Map<String, Map<String, Map<String, String>>> branchNameMap = criteriaMap.get(branchCode);
						if (branchNameMap.get(branchName) == null) {
							Map<String, Map<String, String>> terminalMap = new HashMap<>();
							Map<String, String> locationMap = new HashMap<>();
							locationMap.put(location, cardProduct);
							terminalMap.put(terminal, locationMap);
							branchNameMap.put(branchName, terminalMap);
						} else {
							Map<String, Map<String, String>> terminalMap = branchNameMap.get(branchName);
							if (terminalMap.get(terminal) == null) {
								Map<String, String> locationMap = new HashMap<>();
								locationMap.put(location, cardProduct);
								terminalMap.put(terminal, locationMap);
							} else {
								Map<String, String> locationList = terminalMap.get(terminal);
								locationList.put(location, cardProduct);
							}
						}
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the criteria", e);
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
		return criteriaMap;
	}

	protected void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CsvReportProcessor.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (getGlobalFieldValue(field, true) == null) {
					line.append("");
				} else {
					line.append(getGlobalFieldValue(field, true));
				}
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					line.append("");
				} else {
					line.append(getGlobalFieldValue(field, true));
				}
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In CsvReportProcessor.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					line.append(String.valueOf(pagination));
				} else if (getGlobalFieldValue(field, true) == null) {
					line.append("");
				} else {
					line.append(getGlobalFieldValue(field, true));
				}
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					line.append("");
				} else {
					line.append(getGlobalFieldValue(field, true));
				}
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeHeader(ReportGenerationMgr rgm, int pagination, String branchCode, String branchName)
			throws IOException, JSONException {
		logger.debug("In CsvReportProcessor.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					line.append(String.valueOf(pagination));
				} else if (getGlobalFieldValue(field, true) == null) {
					line.append("");
				} else {
					line.append(getGlobalFieldValue(field, true));
				}
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					line.append(branchCode);
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
					line.append(branchName);
				} else if (getGlobalFieldValue(field, true) == null) {
					line.append("");
				} else {
					line.append(getGlobalFieldValue(field, true));
				}
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CsvReportProcessor.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			line.append(field.getFieldName());
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
				line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
			} else if (getFieldValue(field, fieldsMap, true) == null) {
				line.append("");
			} else {
				line.append(getFieldValue(field, fieldsMap, true));
			}
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String branchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		// To be overriden
	}

	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String txnQualifier, String voidCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.ATM_CARD_NUMBER:
				if (getFieldValue(field, fieldsMap, true).length() <= 19) {
					line.append(
							String.format("%1$" + 19 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0'));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
				break;
			case ReportConstants.SEQ_NUMBER:
			case ReportConstants.TRACE_NUMBER:
				if (getFieldValue(field, fieldsMap, true).length() <= 6) {
					line.append(
							String.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0'));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
				break;
			case ReportConstants.FROM_ACCOUNT_NO:
			case ReportConstants.TO_ACCOUNT_NO:
				if (getFieldValue(field, fieldsMap, true).length() <= 16) {
					line.append(
							String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0'));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
				break;
			case ReportConstants.AMOUNT:
				if (!voidCode.equals("0")) {
					line.append("");
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
				break;
			case ReportConstants.VOID_CODE:
				if (getFieldValue(field, fieldsMap, true).length() <= 3) {
					line.append(
							String.format("%1$" + 3 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0'));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
				break;
			case ReportConstants.COMMENT:
				if (!getFieldValue(field, fieldsMap, true).equalsIgnoreCase(ReportConstants.APPROVED)) {
					line.append(getFieldValue(field, fieldsMap, true));
				} else if (txnQualifier.equals("R")
						&& getFieldValue(field, fieldsMap, true).equalsIgnoreCase(ReportConstants.APPROVED)) {
					line.append(ReportConstants.FULL_REVERSAL);
				} else {
					line.append("");
				}
				line.append(field.getDelimiter());
				break;
			default:
				if (getFieldValue(field, fieldsMap, true) == null) {
					line.append("");
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In CsvReportProcessor.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					line.append(getEol());
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					line.append("");
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
					line.append(field.getDelimiter());
					line.append(getEol());
				}
			} else {
				if (getFieldValue(field, fieldsMap, true) == null) {
					line.append("");
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
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
					writeBody(rgm, lineFieldsMap);
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

	protected void executeBodyQuery(ReportGenerationMgr rgm, String branchCode) {
		logger.debug("In CsvReportProcessor.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
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
					writeBody(rgm, lineFieldsMap, branchCode);
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

	protected void executeTrailerQuery(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.executeTrailerQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
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
					writeTrailer(rgm, lineFieldsMap);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
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
}
