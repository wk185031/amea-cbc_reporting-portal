package my.com.mandrill.base.reporting.bartsFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.TreeSet;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class Bnob extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(Bnob.class);
	private boolean branchDetails = false;

	@Override
	public void processTxtRecord(ReportGenerationMgr rgm) {
		logger.debug("In Bnob.processTxtRecord()");
		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();

		try {
			if (rgm.isGenerate() == true) {
				txnDate = rgm.getFileDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_04));
			} else {
				txnDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_04));
			}

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}
					file = new File(
							rgm.getFileLocation() + rgm.getFileNamePrefix() + txnDate + ReportConstants.TXT_FORMAT);
					execute(rgm, file);
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception(
						"Errors when generating " + rgm.getFileNamePrefix() + txnDate + ReportConstants.TXT_FORMAT);
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + txnDate + ReportConstants.TXT_FORMAT, e);
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String branchCode = null;
		String branchName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			rgm.setBodyQuery(getCriteriaQuery());
			for (SortedMap.Entry<String, Map<String, TreeSet<String>>> branchCodeMap : filterByBranches(rgm)
					.entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeSet<String>> branchNameMap : branchCodeMap.getValue().entrySet()) {
					branchDetails = true;
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, null);
					rgm.setBodyQuery(getBranchDetailBodyQuery());
					executeBodyQuery(rgm);
					for (String terminal : branchNameMap.getValue()) {
						branchDetails = false;
						preProcessing(rgm, branchCode, terminal);
						rgm.setBodyQuery(rgm.getFixBodyQuery());
						executeBodyQuery(rgm);
					}
				}
			}
			executeTrailerQuery(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in generating TXT file", e);
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

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In Bnob.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setBranchDetailBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", "")
					.replace("SUBSTR(AST.AST_TERMINAL_ID, -4) \"TERMINAL\",", "").replace("\"TERMINAL\",", "")
					.replace("\"TERMINAL\" ASC", "").replace("\"BRANCH CODE\" ASC,", "\"BRANCH CODE\" ASC")
					.replace(
							rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf("GROUP BY"),
									rgm.getBodyQuery().indexOf("ORDER BY")),
							"GROUP BY \"BRANCH CODE\", \"BRANCH NAME\" ")
					.replace("\"BRANCH NAME\" ASC,", "\"BRANCH NAME\" ASC"));
			setCriteriaQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In Bnob.preProcessing()");
		if (filterByBranchCode != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null) {
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(AST.AST_TERMINAL_ID, -4) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (branchDetails) {
				switch (field.getFieldName()) {
				case ReportConstants.TERMINAL:
				case ReportConstants.AR_PER_TERMINAL:
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					break;
				case ReportConstants.ITEMS:
					line.append("0000");
					break;
				default:
					line.append(getFieldValue(rgm, field, fieldsMap));
					break;
				}
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.TERMINAL:
				case ReportConstants.AR_PER_TERMINAL:
					line.append(getFieldValue(rgm, field, fieldsMap));
					break;
				case ReportConstants.ITEMS:
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap))
							.replace(' ', '0'));
					break;
				default:
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					break;
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In Bnob.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		String total = null;
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(getEol());
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
					total = getFieldValue(rgm, field, fieldsMap);
				}
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
					line.append(total);
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private SortedMap<String, Map<String, TreeSet<String>>> filterByBranches(ReportGenerationMgr rgm) {
		logger.debug("In Bnob.filterByBranches()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, TreeSet<String>>> criteriaMap = new TreeMap<>();
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
						Map<String, TreeSet<String>> branchNameMap = new HashMap<>();
						TreeSet<String> terminalList = new TreeSet<>();
						terminalList.add(terminal);
						branchNameMap.put(branchName, terminalList);
						criteriaMap.put(branchCode, branchNameMap);
					} else {
						Map<String, TreeSet<String>> branchNameMap = criteriaMap.get(branchCode);
						if (branchNameMap.get(branchName) == null) {
							TreeSet<String> terminalList = new TreeSet<>();
							terminalList.add(terminal);
							branchNameMap.put(branchName, terminalList);
						} else {
							TreeSet<String> terminalList = branchNameMap.get(branchName);
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
}
