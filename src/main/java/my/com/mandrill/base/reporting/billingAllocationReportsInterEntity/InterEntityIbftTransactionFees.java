package my.com.mandrill.base.reporting.billingAllocationReportsInterEntity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.TreeSet;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class InterEntityIbftTransactionFees extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(InterEntityIbftTransactionFees.class);
	public static final String SUBSTRING_START_ACQUIRING = "START ACQUIRING";
	public static final String SUBSTRING_END_ACQUIRING = "END ACQUIRING";
	public static final String SUBSTRING_START_ISSUING = "START ISSUING";
	public static final String SUBSTRING_END_ISSUING = "END ISSUING";
	public static final String SUBSTRING_START_RECEIVING = "START RECEIVING";
	public static final String SUBSTRING_END_RECEIVING = "END RECEIVING";
	private int transmittingCount = 0;
	private int acquiringCount = 0;
	private int receivingCount = 0;
	private double transmittingExpense = 0.00;
	private double acquiringIncome = 0.00;
	private double receivingIncome = 0.00;
	private double totalBilling = 0.00;
	private double overallTransmittingExpense = 0.00;
	private double overallAcquiringIncome = 0.00;
	private double overallReceivingIncome = 0.00;
	private double overallTotalBilling = 0.00;
	private String acquiringBranchCode = null;
	private String issuingBranchCode = null;

	public String getAcquiringBranchCode() {
		return acquiringBranchCode;
	}

	public void setAcquiringBranchCode(String acquiringBranchCode) {
		this.acquiringBranchCode = acquiringBranchCode;
	}

	public String getIssuingBranchCode() {
		return issuingBranchCode;
	}

	public void setIssuingBranchCode(String issuingBranchCode) {
		this.issuingBranchCode = issuingBranchCode;
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		boolean acquiring = false;
		boolean issuing = false;
		boolean receiving = false;
		TreeSet<String> branchCodesList = new TreeSet<>();
		Set<String> toAccountList = new TreeSet<>();
		String toAccountNumber = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);

			preProcessing(rgm, "acquiring");
			for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
				branchCodesList.add(branchCodeMap.getKey());
			}

			preProcessing(rgm, "issuing");
			for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
				branchCodesList.add(branchCodeMap.getKey());
			}

			for (SortedMap.Entry<String, Set<String>> receivingBranchCodeMap : filterForReceivingBranchCode(rgm)
					.entrySet()) {
				branchCodesList.add(receivingBranchCodeMap.getKey());
			}

			for (String branchCodes : branchCodesList) {
				preProcessing(rgm, "acquiring");
				for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
					if (branchCodeMap.getKey().equals(branchCodes)) {
						acquiring = true;
					}
				}

				preProcessing(rgm, "issuing");
				for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
					if (branchCodeMap.getKey().equals(branchCodes)) {
						issuing = true;
					}
				}

				addReceivingBranchCode(branchCodes);
				preProcessing(rgm, "receiving");
				for (SortedMap.Entry<String, Set<String>> receivingBranchCodeMap : filterForReceivingBranchCode(rgm)
						.entrySet()) {
					if (receivingBranchCodeMap.getKey().equals(branchCodes)) {
						toAccountList = receivingBranchCodeMap.getValue();
						receiving = true;
					}
				}

				if (acquiring) {
					preProcessing(rgm, "acquiring");
					for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
						if (branchCodeMap.getKey().equals(branchCodes)) {
							transmittingExpense = 0.00;
							acquiringIncome = 0.00;
							receivingIncome = 0.00;
							ReportGenerationFields branchCode = new ReportGenerationFields(
									ReportConstants.PARAM_BRANCH_CODE, ReportGenerationFields.TYPE_STRING,
									"ABR.ABR_CODE = '" + branchCodes + "'");
							getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
							setAcquiringBranchCode(branchCodeMap.getKey());
							rgm.setBodyQuery(getAcquiringBodyQuery());
							executeBodyQuery(rgm, branchCodes, toAccountList);
						}
					}
				}

				if (issuing) {
					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
						if (branchCodeMap.getKey().equals(branchCodes)
								&& !branchCodeMap.getKey().equals(getAcquiringBranchCode())) {
							transmittingExpense = 0.00;
							acquiringIncome = 0.00;
							receivingIncome = 0.00;
							ReportGenerationFields branchCode = new ReportGenerationFields(
									ReportConstants.PARAM_BRANCH_CODE, ReportGenerationFields.TYPE_STRING,
									"BRC.BRC_CODE = '" + branchCodes + "'");
							getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
							setIssuingBranchCode(branchCodeMap.getKey());
							rgm.setBodyQuery(getIssuingBodyQuery());
							executeBodyQuery(rgm, branchCodes, toAccountList);
						}
					}
				}

				if (receiving) {
					addReceivingBranchCode(branchCodes);
					preProcessing(rgm, "receiving");
					for (SortedMap.Entry<String, Set<String>> branchCodeMap : filterForReceivingBranchCode(rgm)
							.entrySet()) {
						if (branchCodeMap.getKey().equals(branchCodes)
								&& !branchCodeMap.getKey().equals(getAcquiringBranchCode())
								&& !branchCodeMap.getKey().equals(getIssuingBranchCode())) {
							toAccountList = branchCodeMap.getValue();
							transmittingExpense = 0.00;
							acquiringIncome = 0.00;
							receivingIncome = 0.00;
							for (Iterator<String> it = toAccountList.iterator(); it.hasNext();) {
								String toAccountNo = it.next();
								if (it.hasNext()) {
									toAccountNumber += "'" + toAccountNo + "',";
								} else {
									toAccountNumber += "'" + toAccountNo + "'";
								}
							}
							ReportGenerationFields toAccountNo = new ReportGenerationFields(
									ReportConstants.PARAM_TO_ACCOUNT, ReportGenerationFields.TYPE_STRING,
									"TXN.TRL_ACCOUNT_2_ACN_ID IN (" + toAccountNumber + ")");
							getGlobalFileFieldsMap().put(toAccountNo.getFieldName(), toAccountNo);
							rgm.setBodyQuery(getReceivingBodyQuery());
							executeBodyQuery(rgm, branchCodes, toAccountList);
						}
					}
				}

			}

			writeTrailer(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
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

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In InterEntityIbftTransactionFees.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setAcquiringBodyQuery(
					rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(SUBSTRING_START_ACQUIRING) + 15,
							rgm.getBodyQuery().indexOf(SUBSTRING_END_ACQUIRING)));
			setIssuingBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(SUBSTRING_START_ISSUING) + 13,
					rgm.getBodyQuery().indexOf(SUBSTRING_END_ISSUING)));
			setReceivingBodyQuery(
					rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(SUBSTRING_START_RECEIVING) + 15,
							rgm.getBodyQuery().indexOf(SUBSTRING_END_RECEIVING)));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String indicator) {
		logger.debug("In InterEntityIbftTransactionFees.preProcessing()");
		if (indicator.equalsIgnoreCase("acquiring")) {
			rgm.setBodyQuery(getAcquiringBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("ABR.ABR_NAME \"BRANCH NAME\",", "ABR.ABR_NAME \"BRANCH NAME\"")
					.replace("0 \"TRANSMITTING COUNT\",", "").replace("0 \"TRANSMITTING EXPENSE\",", "")
					.replace("COUNT(TXN.TRL_ID) \"ACQUIRER COUNT\",", "")
					.replace("COUNT(TXN.TRL_ID) * 5.00 \"ACQUIRER INCOME\",", "").replace("0 \"RECEIVING COUNT\",", "")
					.replace("0 \"RECEIVING INCOME\"", ""));
		} else if (indicator.equalsIgnoreCase("issuing")) {
			rgm.setBodyQuery(getIssuingBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("BRC.BRC_NAME \"BRANCH NAME\",", "BRC.BRC_NAME \"BRANCH NAME\"")
					.replace("COUNT(TXN.TRL_ID) \"TRANSMITTING COUNT\",", "")
					.replace("COUNT(TXN.TRL_ID) * 5.00 \"TRANSMITTING EXPENSE\",", "")
					.replace("0 \"ACQUIRER COUNT\",", "").replace("0 \"ACQUIRER INCOME\",", "")
					.replace("0 \"RECEIVING COUNT\",", "").replace("0 \"RECEIVING INCOME\"", ""));
		} else {
			rgm.setBodyQuery(getReceivingBodyQuery().replace("0 \"TRANSMITTING COUNT\",", "")
					.replace("0 \"TRANSMITTING EXPENSE\",", "").replace("0 \"ACQUIRER COUNT\",", "")
					.replace("0 \"ACQUIRER INCOME\",", "").replace("COUNT(TXN.TRL_ID) \"RECEIVING COUNT\",", "")
					.replace("COUNT(TXN.TRL_ID) * 5.00 \"RECEIVING INCOME\"", ""));
		}
	}

	private void addReceivingBranchCode(String filterByBranchCode) {
		logger.debug("In InterEntityIbftTransactionFees.addReceivingBranchCode()");
		ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_RECEIVING_BRANCH_CODE,
				ReportGenerationFields.TYPE_STRING, "'" + filterByBranchCode + "'");
		ReportGenerationFields branchName = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_NAME,
				ReportGenerationFields.TYPE_STRING,
				"(SELECT BRC_NAME FROM BRANCH WHERE BRC_CODE = '" + filterByBranchCode + "')");
		getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		getGlobalFileFieldsMap().put(branchName.getFieldName(), branchName);
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In InterEntityIbftTransactionFees.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
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

	private void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String filterByBranchCode, Set<String> filterByToAccountNo)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		String toAccountNumber = "";
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TRANSMITTING_COUNT:
				if (filterByBranchCode != null) {
					ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
							ReportGenerationFields.TYPE_STRING, "BRC.BRC_CODE = '" + filterByBranchCode + "'");
					getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
				}

				rgm.setBodyQuery(getIssuingBodyQuery());
				fieldsMap.get(field.getFieldName())
						.setValue(executeQuery(rgm, ReportConstants.TRANSMITTING_COUNT, null));
				line.append(getFieldValue(rgm, field, fieldsMap));
				transmittingCount += Integer.parseInt(getFieldValue(field, fieldsMap));
				break;
			case ReportConstants.TRANSMITTING_EXPENSE:
				fieldsMap.get(field.getFieldName())
						.setValue(executeQuery(rgm, null, ReportConstants.TRANSMITTING_EXPENSE));
				line.append(getFieldValue(rgm, field, fieldsMap));

				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					transmittingExpense += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					transmittingExpense += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				overallTransmittingExpense += transmittingExpense;
				break;
			case ReportConstants.ACQUIRER_COUNT:
				if (filterByBranchCode != null) {
					ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
							ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
					getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
				}

				rgm.setBodyQuery(getAcquiringBodyQuery());
				fieldsMap.get(field.getFieldName()).setValue(executeQuery(rgm, ReportConstants.ACQUIRER_COUNT, null));
				line.append(getFieldValue(rgm, field, fieldsMap));
				acquiringCount += Integer.parseInt(getFieldValue(field, fieldsMap));
				break;
			case ReportConstants.ACQUIRER_INCOME:
				fieldsMap.get(field.getFieldName()).setValue(executeQuery(rgm, null, ReportConstants.ACQUIRER_INCOME));
				line.append(getFieldValue(rgm, field, fieldsMap));

				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					acquiringIncome += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					acquiringIncome += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				overallAcquiringIncome += acquiringIncome;
				break;
			case ReportConstants.RECEIVING_COUNT:
				if (filterByToAccountNo != null) {
					for (Iterator<String> it = filterByToAccountNo.iterator(); it.hasNext();) {
						String toAccountNo = it.next();
						if (it.hasNext()) {
							toAccountNumber += "'" + toAccountNo + "',";
						} else {
							toAccountNumber += "'" + toAccountNo + "'";
						}
					}
					ReportGenerationFields toAccountNo = new ReportGenerationFields(ReportConstants.PARAM_TO_ACCOUNT,
							ReportGenerationFields.TYPE_STRING,
							"TXN.TRL_ACCOUNT_2_ACN_ID IN (" + toAccountNumber + ")");
					getGlobalFileFieldsMap().put(toAccountNo.getFieldName(), toAccountNo);
				}

				rgm.setBodyQuery(getReceivingBodyQuery());
				rgm.setBodyQuery(getBodyQuery(rgm).replace("TXN.TRL_ACCOUNT_2_ACN_ID \"TO ACCOUNT NO\",", "")
						.replace("TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,", "")
						.replace(getBodyQuery(rgm).substring(getBodyQuery(rgm).indexOf("(SELECT BRC_NAME"),
								getBodyQuery(rgm).indexOf("\"BRANCH NAME\",")), "")
						.replace("\"BRANCH NAME\",", "")
						.replace(getBodyQuery(rgm).substring(getBodyQuery(rgm).indexOf("GROUP BY")), ""));
				fieldsMap.get(field.getFieldName()).setValue(executeQuery(rgm, ReportConstants.RECEIVING_COUNT, null));
				line.append(getFieldValue(rgm, field, fieldsMap));
				receivingCount += Integer.parseInt(getFieldValue(field, fieldsMap));
				break;
			case ReportConstants.RECEIVING_INCOME:
				fieldsMap.get(field.getFieldName()).setValue(executeQuery(rgm, null, ReportConstants.RECEIVING_INCOME));
				line.append(getFieldValue(rgm, field, fieldsMap));

				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					receivingIncome += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					receivingIncome += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				overallReceivingIncome += receivingIncome;
				break;
			case ReportConstants.TOTAL_BILLING:
				totalBilling = transmittingExpense + acquiringIncome + receivingIncome;
				overallTotalBilling += totalBilling;
				line.append(formatter.format(totalBilling));
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

	private void writeTrailer(ReportGenerationMgr rgm)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In IbftTransactionFees.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TRANSMITTING_COUNT:
				line.append(transmittingCount);
				line.append(field.getDelimiter());
				break;
			case ReportConstants.TRANSMITTING_EXPENSE:
				line.append(formatter.format(overallTransmittingExpense));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.ACQUIRER_COUNT:
				line.append(acquiringCount);
				line.append(field.getDelimiter());
				break;
			case ReportConstants.ACQUIRER_INCOME:
				line.append(formatter.format(overallAcquiringIncome));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.RECEIVING_COUNT:
				line.append(receivingCount);
				line.append(field.getDelimiter());
				break;
			case ReportConstants.RECEIVING_INCOME:
				line.append(formatter.format(overallReceivingIncome));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.TOTAL_BILLING:
				line.append(formatter.format(overallTotalBilling));
				line.append(field.getDelimiter());
				break;
			default:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				break;
			}

		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private SortedMap<String, Set<String>> filterForReceivingBranchCode(ReportGenerationMgr rgm) {
		logger.debug("In InterEntityIbftTransactionFees.filterForReceivingBranchCode()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Set<String>> branchCodeMap = new TreeMap<>();
		rgm.setBodyQuery(getReceivingBodyQuery()
				.replace("{" + ReportConstants.PARAM_RECEIVING_BRANCH_CODE + "}" + " \"BRANCH CODE\",", "")
				.replace("{" + ReportConstants.PARAM_BRANCH_NAME + "}" + " \"BRANCH NAME\",", "")
				.replace("AND {" + ReportConstants.PARAM_TO_ACCOUNT + "}", ""));
		String query = getBodyQuery(rgm);
		String toAccountNo = null;
		String toAccountNoEkyId = null;
		String branchCode = null;
		logger.info("Query for filter for receiving branch code: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.TO_ACCOUNT_NO)) {
								toAccountNo = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.TO_ACCOUNT_NO_EKY_ID)) {
								toAccountNoEkyId = result.toString();
							}
						}
					}
					branchCode = getBranchCode(toAccountNo, toAccountNoEkyId);
					if (branchCodeMap.get(branchCode) == null) {
						Set<String> toAccountNoList = new HashSet<>();
						toAccountNoList.add(toAccountNo);
						branchCodeMap.put(branchCode, toAccountNoList);
					} else {
						Set<String> toAccountNoList = branchCodeMap.get(branchCode);
						toAccountNoList.add(toAccountNo);
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the receiving branch code", e);
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
		return branchCodeMap;
	}

	private void executeBodyQuery(ReportGenerationMgr rgm, String branchCode, Set<String> toAccountNo) {
		logger.debug("In InterEntityIbftTransactionFees.executeBodyQuery()");
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
					writeBody(rgm, lineFieldsMap, branchCode, toAccountNo);
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

	private String executeQuery(ReportGenerationMgr rgm, String count, String total) {
		logger.debug("In InterEntityIbftTransactionFees.executeQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = getBodyQuery(rgm);
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.connection.prepareStatement(query);
			rs = ps.executeQuery();

			while (rs.next()) {
				if (count != null) {
					return rs.getObject(count).toString();
				}
				if (total != null) {
					return rs.getObject(total).toString();
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
		return "0";
	}
}