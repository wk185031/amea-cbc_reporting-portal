package my.com.mandrill.base.reporting.interEntityAtmWithdrawalTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.IbftReportProcessor;

public class InterEntityAtmWithdrawalAcquirerBank extends IbftReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(InterEntityAtmWithdrawalAcquirerBank.class);
	private int pagination = 0;
	private int totalCount = 0;
	private double grandTotal = 0.00;
	private boolean branchDetails = false;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			separateQuery(rgm);

			pagination++;
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm, pagination);
			processingDetails(rgm);

			pagination++;
			addReportPreProcessingFieldsToGlobalMap(rgm);
			processingSummaryDetails(rgm, pagination);

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

	private void processingDetails(ReportGenerationMgr rgm) {
		logger.debug("In InterEntityAtmWithdrawalAcquirerBank.processingDetails()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		try {
			rgm.setBodyQuery(getCriteriaQuery());
			for (SortedMap.Entry<String, Map<String, Map<String, Set<String>>>> branchCodeMap : filterByCriteria(rgm)
					.entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, Map<String, Set<String>>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					for (SortedMap.Entry<String, Set<String>> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						for (String locationMap : terminalMap.getValue()) {
							location = locationMap;
							StringBuilder line = new StringBuilder();
							line.append("BRANCH: ").append(";").append(branchCode + " ").append(";")
									.append(branchName + " ").append(";");
							line.append(getEol());
							line.append("TERM: ").append(";").append(terminal + " ").append(";").append(location + " ")
									.append(";");
							line.append(getEol());
							rgm.writeLine(line.toString().getBytes());
							writeBodyHeader(rgm);
							rgm.setBodyQuery(getIbftBodyQuery());
							rgm.setTrailerQuery(getIbftTrailerQuery());
							preProcessing(rgm, branchCode, terminal);
							executeBodyQuery(rgm, false, branchName, location);
							executeTrailerQuery(rgm, false);
						}
					}
				}
			}
			DecimalFormat formatter = new DecimalFormat("#,##0.00");
			StringBuilder line = new StringBuilder();
			line.append(";").append(";").append("GRAND TOTAL : ").append(";").append(totalCount).append(";")
					.append("AMOUNT : ").append(";").append(formatter.format(grandTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in processingDetails", e);
		}
	}

	private void processingSummaryDetails(ReportGenerationMgr rgm, int pagination) {
		logger.debug("In InterEntityAtmWithdrawalAcquirerBank.processingSummaryDetails()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		try {
			writeSummaryHeader(rgm, pagination);
			writeSummaryBodyHeader(rgm);

			rgm.setBodyQuery(getCriteriaQuery());
			for (SortedMap.Entry<String, Map<String, Map<String, Set<String>>>> branchCodeMap : filterByCriteria(rgm)
					.entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, Map<String, Set<String>>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchDetails = true;
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, terminal);
					rgm.setBodyQuery(getSummaryDetailBodyQuery());
					executeBodyQuery(rgm, true, branchName, location);
					for (SortedMap.Entry<String, Set<String>> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						for (String locationList : terminalMap.getValue()) {
							branchDetails = false;
							location = locationList;
							rgm.setBodyQuery(getSummaryBodyQuery());
							preProcessing(rgm, branchCode, terminal);
							executeBodyQuery(rgm, true, branchName, location);
						}
					}
				}
			}
			rgm.setTrailerQuery(getSummaryTrailerQuery());
			executeTrailerQuery(rgm, true);
			StringBuilder line = new StringBuilder();
			line.append("*** END OF REPORT ***");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in processingSummaryDetails", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In InterEntityAtmWithdrawalAcquirerBank.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setIbftBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setSummaryDetailBodyQuery(getSummaryBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", "")
					.replace("AST.AST_TERMINAL_ID \"TERMINAL\",", "").replace("\"TERMINAL\",", "")
					.replace("\"TERMINAL\" ASC", "")
					.replace(
							getSummaryBodyQuery().substring(getSummaryBodyQuery().indexOf("GROUP BY"),
									getSummaryBodyQuery().indexOf("ORDER BY")),
							"GROUP BY \"BRANCH CODE\", \"BRANCH NAME\" ")
					.replace("\"BRANCH NAME\" ASC,", "\"BRANCH NAME\" ASC"));
			setCriteriaQuery(getIbftBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}

		if (rgm.getTrailerQuery() != null) {
			setIbftTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In InterEntityAtmWithdrawalAcquirerBank.preProcessing()");
		if (filterByBranchCode != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null) {
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "TRIM(AST.AST_TERMINAL_ID) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In InterEntityAtmWithdrawalAcquirerBank.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
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

	private void writeSummaryBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In InterEntityAtmWithdrawalAcquirerBank.writeSummaryBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
			case 24:
			case 25:
			case 26:
			case 27:
			case 28:
			case 29:
			case 30:
			case 31:
			case 32:
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

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String txnQualifier, String voidCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
				switch (field.getFieldName()) {
				case ReportConstants.DR_AMOUNT:
				case ReportConstants.CR_AMOUNT:
					if (!voidCode.equals("0")) {
						line.append("");
					} else {
						line.append(getFieldValue(rgm, field, fieldsMap));
					}
					line.append(field.getDelimiter());
					break;
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
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
					break;
				}
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writeSummaryBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String branchName, String location)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 33:
			case 34:
			case 35:
			case 36:
			case 37:
			case 38:
			case 39:
				if (branchDetails) {
					if (!field.getFieldName().equalsIgnoreCase(ReportConstants.TERMINAL)
							&& !field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
						if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
							line.append(branchName);
						} else {
							line.append(getFieldValue(rgm, field, fieldsMap));
						}
						line.append(field.getDelimiter());
					} else {
						line.append("");
						line.append(field.getDelimiter());
					}
				} else {
					if (!field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)
							&& !field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
						if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
							line.append(location);
						} else {
							line.append(getFieldValue(rgm, field, fieldsMap));
						}
						line.append(field.getDelimiter());
					} else {
						line.append("");
						line.append(field.getDelimiter());
					}
				}
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In InterEntityAtmWithdrawalAcquirerBank.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
				break;
			default:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL)) {
						if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
							grandTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
						} else {
							grandTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
						}
					}
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_TRAN)) {
						if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
							totalCount += Integer.parseInt(getFieldValue(field, fieldsMap).replace(",", ""));
						} else {
							totalCount += Integer.parseInt(getFieldValue(field, fieldsMap));
						}
					}
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeSummaryTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In InterEntityAtmWithdrawalAcquirerBank.writeSummaryTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		String total = null;
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
				if (field.isEol()) {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
						total = getFieldValue(field, fieldsMap);
					}
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
						line.append(total);
					} else {
						line.append(getFieldValue(rgm, field, fieldsMap));
					}
					line.append(field.getDelimiter());
				}
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void executeBodyQuery(ReportGenerationMgr rgm, boolean summary, String branchName, String location) {
		logger.debug("In AtmWithdrawalAcquirerBank.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String txnQualifier = null;
		String voidCode = null;
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
							} else if (key.equalsIgnoreCase(ReportConstants.TXN_QUALIFIER)) {
								txnQualifier = result.toString();
								field.setValue(result.toString());
							} else if (key.equalsIgnoreCase(ReportConstants.VOID_CODE)) {
								voidCode = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					if (summary) {
						writeSummaryBody(rgm, lineFieldsMap, branchName, location);
					} else {
						writeBody(rgm, lineFieldsMap, txnQualifier, voidCode);
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
}
