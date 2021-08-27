package my.com.mandrill.base.reporting.reportProcessor;

import java.io.File;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

import my.com.mandrill.base.processor.IReportOutputFileName;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.web.rest.ReportGenerationResource;

public class CsvReportProcessor extends GeneralReportProcess implements ICsvReportProcessor, IReportOutputFileName {

	private final Logger logger = LoggerFactory.getLogger(CsvReportProcessor.class);
	private String acquiringBodyQuery = null;
	private String issuingBodyQuery = null;
	private String receivingBodyQuery = null;
	private String txnBodyQuery = null;
	private String summaryBodyQuery = null;
	private String summaryDetailBodyQuery = null;
	private String txnTrailerQuery = null;
	private String summaryTrailerQuery = null;
	private String criteriaQuery = null;
	private String causeTrailerQuery = null;
	private String terminalTrailerQuery = null;
	private String onusBodyQuery = null;
	private String interEntityBodyQuery = null;
	private String onusTrailerQuery = null;
	private String interEntityTrailerQuery = null;

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

	public String getTxnBodyQuery() {
		return txnBodyQuery;
	}

	public void setTxnBodyQuery(String txnBodyQuery) {
		this.txnBodyQuery = txnBodyQuery;
	}

	public String getSummaryBodyQuery() {
		return summaryBodyQuery;
	}

	public void setSummaryBodyQuery(String summaryBodyQuery) {
		this.summaryBodyQuery = summaryBodyQuery;
	}

	public String getSummaryDetailBodyQuery() {
		return summaryDetailBodyQuery;
	}

	public void setSummaryDetailBodyQuery(String summaryDetailBodyQuery) {
		this.summaryDetailBodyQuery = summaryDetailBodyQuery;
	}

	public String getTxnTrailerQuery() {
		return txnTrailerQuery;
	}

	public void setTxnTrailerQuery(String txnTrailerQuery) {
		this.txnTrailerQuery = txnTrailerQuery;
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

	public String getCauseTrailerQuery() {
		return causeTrailerQuery;
	}

	public void setCauseTrailerQuery(String causeTrailerQuery) {
		this.causeTrailerQuery = causeTrailerQuery;
	}

	public String getTerminalTrailerQuery() {
		return terminalTrailerQuery;
	}

	public void setTerminalTrailerQuery(String terminalTrailerQuery) {
		this.terminalTrailerQuery = terminalTrailerQuery;
	}

	public String getOnusBodyQuery() {
		return onusBodyQuery;
	}

	public void setOnusBodyQuery(String onusBodyQuery) {
		this.onusBodyQuery = onusBodyQuery;
	}

	public String getInterEntityBodyQuery() {
		return interEntityBodyQuery;
	}

	public void setInterEntityBodyQuery(String interEntityBodyQuery) {
		this.interEntityBodyQuery = interEntityBodyQuery;
	}

	public String getOnusTrailerQuery() {
		return onusTrailerQuery;
	}

	public void setOnusTrailerQuery(String onusTrailerQuery) {
		this.onusTrailerQuery = onusTrailerQuery;
	}

	public String getInterEntityTrailerQuery() {
		return interEntityTrailerQuery;
	}

	public void setInterEntityTrailerQuery(String interEntityTrailerQuery) {
		this.interEntityTrailerQuery = interEntityTrailerQuery;
	}

	public Logger getLogger() {
		return logger;
	}

	@Override
	public void processCsvRecord(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.processCsvRecord()");
		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();
		this.setEncryptionService(rgm.getEncryptionService());
		String fileName = "";

		try {
            fileName = generateDateRangeOutputFileName(rgm.getFileNamePrefix(),
                rgm.getTxnStartDate(),
                rgm.getReportTxnEndDate(),
                ReportConstants.CSV_FORMAT);

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}

					file = new File(rgm.getFileLocation() + fileName);
					execute(rgm, file);
					logger.debug("Write file to : {}", file.getAbsolutePath());
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception("Errors when generating " + fileName);
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + fileName, e);
		}
	}

	protected void execute(ReportGenerationMgr rgm, File file) {
		// To be overriden
	}

	protected SortedMap<String, String> filterByBranch(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterByBranch()");
		String branchCode = null;
		String branchName = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> branchMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter branch: {}", query);

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
								if (branchCode == null) {
									branchCode = branchName;
								}
							}
						}
					}
					branchMap.put(branchCode, branchName);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the branch", e);
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
		return branchMap;
	}

	protected SortedMap<String, Set<String>> filterCriteriaByBranchTerminal(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterCriteriaByBranchTerminal()");
		String branchCode = null;
		String terminal = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Set<String>> criteriaMap = new TreeMap<>();
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
							if (key.equalsIgnoreCase(ReportConstants.TERMINAL)) {
								terminal = result.toString();
							}
						}
					}
					if (criteriaMap.get(branchCode) == null) {
						Set<String> terminalList = new HashSet<>();
						terminalList.add(terminal);
						criteriaMap.put(branchCode, terminalList);
					} else {
						Set<String> terminalList = criteriaMap.get(branchCode);
						terminalList.add(terminal);
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

	protected SortedMap<String, Map<String, TreeMap<String, String>>> filterCriteriaByBranch(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterCriteriaByBranch()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, TreeMap<String, String>>> criteriaMap = new TreeMap<>();
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

					if (branchCode != null) {
						if (criteriaMap.get(branchCode) == null) {
							Map<String, TreeMap<String, String>> branchNameMap = new TreeMap<>();
							TreeMap<String, String> terminalMap = new TreeMap<>();
							terminalMap.put(terminal, location);
							branchNameMap.put(branchName, terminalMap);
							criteriaMap.put(branchCode, branchNameMap);
						} else {
							Map<String, TreeMap<String, String>> branchNameMap = criteriaMap.get(branchCode);
							if (branchNameMap.get(branchName) == null) {
								TreeMap<String, String> terminalMap = new TreeMap<>();
								terminalMap.put(terminal, location);
								branchNameMap.put(branchName, terminalMap);
							} else {
								TreeMap<String, String> terminalMap = branchNameMap.get(branchName);
								terminalMap.put(terminal, location);
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

	protected SortedMap<String, Map<String, TreeMap<String, Map<String, String>>>> filterCriteriaForCashCard(
			ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterCriteriaForCashCard()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		String cardProduct = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, TreeMap<String, Map<String, String>>>> criteriaMap = new TreeMap<>();
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
						Map<String, TreeMap<String, Map<String, String>>> branchNameMap = new TreeMap<>();
						TreeMap<String, Map<String, String>> terminalMap = new TreeMap<>();
						Map<String, String> locationMap = new TreeMap<>();
						locationMap.put(location, cardProduct);
						terminalMap.put(terminal, locationMap);
						branchNameMap.put(branchName, terminalMap);
						criteriaMap.put(branchCode, branchNameMap);
					} else {
						Map<String, TreeMap<String, Map<String, String>>> branchNameMap = criteriaMap.get(branchCode);
						if (branchNameMap.get(branchName) == null) {
							TreeMap<String, Map<String, String>> terminalMap = new TreeMap<>();
							Map<String, String> locationMap = new TreeMap<>();
							locationMap.put(location, cardProduct);
							terminalMap.put(terminal, locationMap);
							branchNameMap.put(branchName, terminalMap);
						} else {
							Map<String, Map<String, String>> terminalMap = branchNameMap.get(branchName);
							if (terminalMap.get(terminal) == null) {
								Map<String, String> locationMap = new TreeMap<>();
								locationMap.put(location, cardProduct);
								terminalMap.put(terminal, locationMap);
							} else {
								Map<String, String> locationMap = terminalMap.get(terminal);
								locationMap.put(location, cardProduct);
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

	protected SortedMap<String, String> filterCriteriaByBank(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterCriteriaByBank()");
		String bankCode = null;
		String bankName = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter bank code: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.BANK_CODE)) {
								bankCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BANK_NAME)) {
								bankName = result.toString();
							}
						}
					}
					criteriaMap.put(bankCode, bankName);
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

	protected SortedMap<String, TreeMap<String, Map<String, TreeMap<String, String>>>> filterByChannelBranch(
			ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterByChannelBranch()");
		String channel = null;
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, TreeMap<String, Map<String, TreeMap<String, String>>>> criteriaMap = new TreeMap<>();
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
							if (key.equalsIgnoreCase(ReportConstants.CHANNEL)) {
								channel = result.toString();
							}
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
					if (criteriaMap.get(channel) == null) {
						TreeMap<String, Map<String, TreeMap<String, String>>> branchCodeMap = new TreeMap<>();
						Map<String, TreeMap<String, String>> branchNameMap = new TreeMap<>();
						TreeMap<String, String> terminalMap = new TreeMap<>();
						terminalMap.put(terminal, location);
						branchNameMap.put(branchName, terminalMap);
						branchCodeMap.put(branchCode, branchNameMap);
						criteriaMap.put(channel, branchCodeMap);
					} else {
						TreeMap<String, Map<String, TreeMap<String, String>>> branchCodeMap = criteriaMap.get(channel);
						if (branchCodeMap.get(branchCode) == null) {
							Map<String, TreeMap<String, String>> branchNameMap = new TreeMap<>();
							TreeMap<String, String> terminalMap = new TreeMap<>();
							terminalMap.put(terminal, location);
							branchNameMap.put(branchName, terminalMap);
							branchCodeMap.put(branchCode, branchNameMap);
						} else {
							Map<String, TreeMap<String, String>> branchNameMap = branchCodeMap.get(branchCode);
							if (branchNameMap.get(branchName) == null) {
								TreeMap<String, String> terminalMap = new TreeMap<>();
								terminalMap.put(terminal, location);
								branchNameMap.put(branchName, terminalMap);
							} else {
								TreeMap<String, String> terminalMap = branchNameMap.get(branchName);
								terminalMap.put(terminal, location);
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

	protected SortedMap<String, String> filterCriteriaByTerminal(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterCriteriaByTerminal()");
		String terminal = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> terminalMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter bank code: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.TERMINAL)) {
								terminal = result.toString();
							}
						}
					}
					terminalMap.put(terminal, "");
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
		return terminalMap;
	}

	protected SortedMap<String, String> filterCriteriaByCause(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.filterCriteriaByCause()");
		String cause = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> causeMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter bank code: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.CAUSE)) {
								cause = result.toString();
							}
						}
					}
					causeMap.put(cause, "");
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
		return causeMap;
	}

	protected void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CsvReportProcessor.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(getEol());
			} else if (ReportGenerationResource.getUserInsId().equalsIgnoreCase("CBS") && 
		              (field.getFieldName().equalsIgnoreCase("Bank Code") || field.getFieldName().equalsIgnoreCase("Bank Name"))){
		          if(field.getFieldName().equalsIgnoreCase("Bank Code")) {
		              line.append("0112");
		              line.append(field.getDelimiter());
		          }else{
		              line.append("CHINA BANK SAVINGS");
		              line.append(field.getDelimiter());
		          }
			} else {
				line.append(getGlobalFieldValue(rgm, field));
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
				} else {
					line.append(getGlobalFieldValue(rgm, field));
				}
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					line.append(branchCode);
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
					line.append(branchName);
				} else {
					line.append(getGlobalFieldValue(rgm, field));
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
			if(field.isEol()) {
				line.append("\"" + getFieldValue(rgm, field, null) + "\"");
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				line.append("\"" + getFieldValue(rgm, field, null) + "\"");
				line.append(field.getDelimiter());
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			line.append("\""+ getFieldValue(rgm, field, fieldsMap) + "\"");
			line.append(field.getDelimiter());
			if (field.isEol()) {
				line.append(getEol());
			}
		}
		//line.append(getEol());
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
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			switch (field.getFieldName()) {
			case ReportConstants.COMMENT:
				if (!getFieldValue(rgm, field, fieldsMap).equalsIgnoreCase(ReportConstants.APPROVED)) {
					line.append(getFieldValue(rgm, field, fieldsMap));
				} else if (txnQualifier.equals("R")
						&& getFieldValue(rgm, field, fieldsMap).equalsIgnoreCase(ReportConstants.APPROVED)) {
					line.append(ReportConstants.FULL_REVERSAL);
				} else {
					line.append("");
				}
				line.append(field.getDelimiter());
				break;
			default:
				line.append("\"" + getFieldValue(rgm, field, fieldsMap) + "\"");
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
				} else {
					line.append("\"" + getFieldValue(rgm, field, fieldsMap) + "\"");
					line.append(field.getDelimiter());
					line.append(getEol());
				}
			} else {
				line.append("\"" + getFieldValue(rgm, field, fieldsMap) + "\"");
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
	
	protected boolean executeBodyQueryWithHasRecord (ReportGenerationMgr rgm) {
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
				
				if (rs.next()) {
					do {
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
					} while (rs.next());
					return true;
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
		return false;
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
	
	protected int executeBodyQueryWithCount(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

		int i = 0;
		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				while (rs.next()) {
					i++;
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
		return i;
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
