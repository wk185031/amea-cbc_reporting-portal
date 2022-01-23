package my.com.mandrill.base.reporting.billingAllocationReportsInterBank;

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

public class IbftTransactionFees extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(IbftTransactionFees.class);
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
	private double transmittingIncome = 0.00;
	private double acquiringIncome = 0.00;
	private double receivingIncome = 0.00;
	private double totalBilling = 0.00;
	private double overallTransmittingExpense = 0.00;
	private double overallTransmittingIncome = 0.00;
	private double overallAcquiringIncome = 0.00;
	private double overallReceivingIncome = 0.00;
	private double overallTotalBilling = 0.00;
	private int overallTransmittingCount = 0;
	private int overallAcquiringCount = 0;
	private int overallReceivingCount = 0;	
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
		String toAccountNumber = "";
		String branchName = "";
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);

			// 1. get all branch codes having ibft acquiring/issuing (transmitting)/receiving
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

			// 2. iterate the list of branch codes, for each branch check if the branch has record for acquiring/issuing/receiving, set true flag if it has
			for (String branchCode : branchCodesList) {
				preProcessing(rgm, "acquiring");
				for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
					if (branchCodeMap.getKey().equals(branchCode)) {
						acquiring = true;
					}
				}

				preProcessing(rgm, "issuing");
				for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
					if (branchCodeMap.getKey().equals(branchCode)) {
						issuing = true;
					}
				}

				addReceivingBranchCode(branchCode);
				preProcessing(rgm, "receiving");
				for (SortedMap.Entry<String, Set<String>> receivingBranchCodeMap : filterForReceivingBranchCode(rgm)
						.entrySet()) {
					if (receivingBranchCodeMap.getKey().equals(branchCode)) {
						toAccountList = receivingBranchCodeMap.getValue();
						receiving = true;
					}
				}
				
				transmittingCount = 0;
				transmittingExpense = 0.00;
				transmittingIncome = 0.00;
				acquiringCount = 0;	
				acquiringIncome = 0.00;
				receivingCount = 0;
				receivingIncome = 0.00;

				// 3. depend on the flag, accumulate each total/calculation accordingly to populate to report's column
				if (acquiring) {
					preProcessing(rgm, "acquiring");
					for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
						if (branchCodeMap.getKey().equals(branchCode)) {
							ReportGenerationFields branchCodeValue = new ReportGenerationFields(
									ReportConstants.PARAM_BRANCH_CODE, ReportGenerationFields.TYPE_STRING,
									"ABR.ABR_CODE = '" + branchCode + "'");
							getGlobalFileFieldsMap().put(branchCodeValue.getFieldName(), branchCodeValue);
							setAcquiringBranchCode(branchCodeMap.getKey());
							rgm.setBodyQuery(getAcquiringBodyQuery());
							executeBodyQuery(rgm, branchCode, toAccountList);
						}
					}
				}

				if (issuing) {
					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
						if (branchCodeMap.getKey().equals(branchCode)) {
							ReportGenerationFields branchCodeValue = new ReportGenerationFields(
									ReportConstants.PARAM_BRANCH_CODE, ReportGenerationFields.TYPE_STRING,
									"BRC.BRC_CODE = '" + branchCode + "'");
							getGlobalFileFieldsMap().put(branchCodeValue.getFieldName(), branchCodeValue);
							setIssuingBranchCode(branchCodeMap.getKey());
							rgm.setBodyQuery(getIssuingBodyQuery());
							executeBodyQuery(rgm, branchCode, toAccountList);
						}
					}
				}

				if (receiving) {
					addReceivingBranchCode(branchCode);
					preProcessing(rgm, "receiving");
					for (SortedMap.Entry<String, Set<String>> branchCodeMap : filterForReceivingBranchCode(rgm)
							.entrySet()) {
						if (branchCodeMap.getKey().equals(branchCode)) {
							toAccountNumber = "";
							toAccountList = branchCodeMap.getValue();
							int i = 0;
							for (Iterator<String> it = toAccountList.iterator(); it.hasNext();) {
								String toAccountNo = it.next();
								
								if (toAccountNo != null && !toAccountNo.trim().isEmpty()) {
									if (i > 0) {
										toAccountNumber += ",";
									}
									toAccountNumber += "'" + toAccountNo + "'";
									i++;
								}
								
							}
							
							if(toAccountNumber == "") {
								toAccountNumber = "'0'";
							}
							
							ReportGenerationFields toAccountNo = new ReportGenerationFields(
									ReportConstants.PARAM_TO_ACCOUNT, ReportGenerationFields.TYPE_STRING,
									"TXN.TRL_ACCOUNT_2_ACN_ID IN (" + toAccountNumber + ")");
							getGlobalFileFieldsMap().put(toAccountNo.getFieldName(), toAccountNo);
							rgm.setBodyQuery(getReceivingBodyQuery());
							executeBodyQuery(rgm, branchCode, toAccountList);
						}
					}
				}
				
				totalBilling = transmittingExpense - transmittingIncome - acquiringIncome - receivingIncome;
				overallTransmittingCount += transmittingCount;
				overallAcquiringCount += acquiringCount;
				overallReceivingCount += receivingCount;
				overallTransmittingExpense += transmittingExpense;
				overallTransmittingIncome += transmittingIncome;
				overallAcquiringIncome += acquiringIncome;
				overallReceivingIncome += receivingIncome;
					
				// 4. write to body after we have combine acquiring/issuing (transmitting)/receiving count/amount for each branch
				HashMap<String, ReportGenerationFields> fieldsMap = new HashMap<>();
				branchName = getBranchName(rgm, branchCode);
				fieldsMap.put("BRANCH CODE", new ReportGenerationFields("BRANCH CODE", "STRING", branchCode));
				fieldsMap.put("BRANCH NAME", new ReportGenerationFields("BRANCH CODE", "STRING", branchName));
				fieldsMap.put("TRANSMITTING COUNT", new ReportGenerationFields("TRANSMITTING COUNT", "STRING", String.valueOf(transmittingCount)));
				fieldsMap.put("TRANSMITTING EXPENSE", new ReportGenerationFields("TRANSMITTING EXPENSE", "STRING", String.valueOf(transmittingExpense)));
				fieldsMap.put("TRANSMITTING INCOME", new ReportGenerationFields("TRANSMITTING INCOME", "STRING", String.valueOf(transmittingIncome)));
				fieldsMap.put("ACQUIRER COUNT", new ReportGenerationFields("ACQUIRER COUNT", "STRING", String.valueOf(acquiringCount)));
				fieldsMap.put("ACQUIRER INCOME", new ReportGenerationFields("ACQUIRER INCOME", "STRING", String.valueOf(acquiringIncome)));
				fieldsMap.put("RECEIVING COUNT", new ReportGenerationFields("RECEIVING COUNT", "STRING", String.valueOf(receivingCount)));
				fieldsMap.put("RECEIVING INCOME", new ReportGenerationFields("RECEIVING INCOME", "STRING", String.valueOf(receivingIncome)));
				fieldsMap.put("TOTAL BILLING", new ReportGenerationFields("TOTAL BILLING", "STRING", String.valueOf(totalBilling)));
				writeBody(rgm, fieldsMap);
			}

			overallTotalBilling = overallTransmittingExpense - overallTransmittingIncome - overallAcquiringIncome - overallReceivingIncome;
			writeTrailer(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
			
			// reset to original body query otherwise monthly report generation will break
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
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
		logger.debug("In IbftTransactionFees.separateQuery()");
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
		logger.debug("In IbftTransactionFees.preProcessing()");
		if (indicator.equalsIgnoreCase("acquiring")) {
			rgm.setBodyQuery(getAcquiringBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("ABR.ABR_NAME \"BRANCH NAME\",", "ABR.ABR_NAME \"BRANCH NAME\"")
					.replace("0 \"TRANSMITTING COUNT\",", "").replace("0 \"TRANSMITTING EXPENSE\",", "")
					.replace("0 \"TRANSMITTING INCOME\",", "").replace("COUNT(TXN.TRL_ID) \"ACQUIRER COUNT\",", "")
					.replace("COUNT(TXN.TRL_ID) * 6.00 \"ACQUIRER INCOME\",", "").replace("0 \"RECEIVING COUNT\",", "")
					.replace("0 \"RECEIVING INCOME\"", ""));
		} else if (indicator.equalsIgnoreCase("issuing")) {
			rgm.setBodyQuery(getIssuingBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("BRC.BRC_NAME \"BRANCH NAME\",", "BRC.BRC_NAME \"BRANCH NAME\"")
					.replace("COUNT(TXN.TRL_ID) \"TRANSMITTING COUNT\",", "")
					.replace("COUNT(TXN.TRL_ID) * 25.00 \"TRANSMITTING EXPENSE\",", "")
					.replace("COUNT(TXN.TRL_ID) * 7.00 \"TRANSMITTING INCOME\",", "")
					.replace("0 \"ACQUIRER COUNT\",", "").replace("0 \"ACQUIRER INCOME\",", "")
					.replace("0 \"RECEIVING COUNT\",", "").replace("0 \"RECEIVING INCOME\"", ""));
		} else {
			rgm.setBodyQuery(getReceivingBodyQuery().replace("0 \"TRANSMITTING COUNT\",", "")
					.replace("0 \"TRANSMITTING EXPENSE\",", "").replace("0 \"TRANSMITTING INCOME\",", "")
					.replace("0 \"ACQUIRER COUNT\",", "").replace("0 \"ACQUIRER INCOME\",", "")
					.replace("COUNT(TXN.TRL_ID) \"RECEIVING COUNT\",", "")
					.replace("COUNT(TXN.TRL_ID) * 7.00 \"RECEIVING INCOME\"", ""));
		}
	}

	private void addReceivingBranchCode(String filterByBranchCode) {
		logger.debug("In IbftTransactionFees.addReceivingBranchCode()");
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
		logger.debug("In IbftTransactionFees.writeBodyHeader()");
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

	private void writeTrailer(ReportGenerationMgr rgm)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In IbftTransactionFees.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TRANSMITTING_COUNT:
				line.append(overallTransmittingCount);
				line.append(field.getDelimiter());
				break;
			case ReportConstants.TRANSMITTING_EXPENSE:
				line.append(formatter.format(overallTransmittingExpense));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.TRANSMITTING_INCOME:
				line.append(formatter.format(overallTransmittingIncome));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.ACQUIRER_COUNT:
				line.append(overallAcquiringCount);
				line.append(field.getDelimiter());
				break;
			case ReportConstants.ACQUIRER_INCOME:
				line.append(formatter.format(overallAcquiringIncome));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.RECEIVING_COUNT:
				line.append(overallReceivingCount);
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
		logger.debug("In IbftTransactionFees.filterForReceivingBranchCode()");
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
				ps = rgm.getConnection().prepareStatement(query);
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
				rgm.cleanAllDbResource(ps, rs);
			}
		}
		return branchCodeMap;
	}

	private void executeBodyQuery(ReportGenerationMgr rgm, String branchCode, Set<String> toAccountNo) {
		logger.debug("In IbftTransactionFees.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
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
					transmittingCount += Integer.parseInt(lineFieldsMap.get("TRANSMITTING COUNT").getValue());
					transmittingExpense += Double.parseDouble(lineFieldsMap.get("TRANSMITTING EXPENSE").getValue());
					transmittingIncome += Double.parseDouble(lineFieldsMap.get("TRANSMITTING INCOME").getValue());
					acquiringCount += Integer.parseInt(lineFieldsMap.get("ACQUIRER COUNT").getValue());
					acquiringIncome += Double.parseDouble(lineFieldsMap.get("ACQUIRER INCOME").getValue());
					receivingCount += Integer.parseInt(lineFieldsMap.get("RECEIVING COUNT").getValue());
					receivingIncome +=  Double.parseDouble(lineFieldsMap.get("RECEIVING INCOME").getValue());
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}
	
	private String getBranchName(ReportGenerationMgr rgm, String branchCode) {
		logger.debug("In IbftTransactionFees.getBranchName()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = "select brc.brc_name from branch brc where brc.brc_code = '" + branchCode + "'";
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.getConnection().prepareStatement(query);
			rs = ps.executeQuery();

			while (rs.next()) {
				return rs.getString(1);
			}
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Error trying to execute the body query", e);
		} finally {
			rgm.cleanAllDbResource(ps, rs);
		}
		return "0";
	}
}