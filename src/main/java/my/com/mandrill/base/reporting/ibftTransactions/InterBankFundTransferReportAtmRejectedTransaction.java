package my.com.mandrill.base.reporting.ibftTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
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

public class InterBankFundTransferReportAtmRejectedTransaction extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(InterBankFundTransferReportAtmRejectedTransaction.class);
	public static final String SUBSTRING_START_ACQUIRING = "START ACQUIRING";
	public static final String SUBSTRING_END_ACQUIRING = "END ACQUIRING";
	public static final String SUBSTRING_START_ISSUING = "START ISSUING";
	public static final String SUBSTRING_END_ISSUING = "END ISSUING";
	public static final String SUBSTRING_START_RECEIVING = "START RECEIVING";
	public static final String SUBSTRING_END_RECEIVING = "END RECEIVING";
	private int pagination = 0;
	private double sectionTotal = 0.00;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		boolean acquiring = false;
		boolean issuing = false;
		boolean receiving = false;
		double overallSectionTotal = 0.00;
		TreeSet<String> branchCodesList = new TreeSet<>();
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);

			preProcessing(rgm, "acquiring");
			for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
				branchCodesList.add(branchCodeMap.getKey());
			}

			preProcessing(rgm, "issuing");
			for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> issuingBranchCodeMap : filterByIssuing(
					rgm).entrySet()) {
				branchCodesList.add(issuingBranchCodeMap.getKey());
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
				for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> issuingBranchCodeMap : filterByIssuing(
						rgm).entrySet()) {
					if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
						issuing = true;
					}
				}

				addReceivingBranchCode(branchCodes);
				preProcessing(rgm, "receiving");
				for (SortedMap.Entry<String, Set<String>> receivingBranchCodeMap : filterForReceivingBranchCode(rgm)
						.entrySet()) {
					if (receivingBranchCodeMap.getKey().equals(branchCodes)) {
						receiving = true;
					}
				}

				if (acquiring && issuing && receiving) {
					preProcessing(rgm, "acquiring");
					for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
						if (branchCodeMap.getKey().equals(branchCodes)) {
							acquiringDetails(rgm, branchCodeMap.getKey(), branchCodeMap.getValue(), overallSectionTotal,
									branchCodeMap, formatter);
						}
					}
					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> issuingBranchCodeMap : filterByIssuing(
							rgm).entrySet()) {
						if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
							for (SortedMap.Entry<String, Map<String, Map<String, String>>> issuingBranchNameMap : issuingBranchCodeMap
									.getValue().entrySet()) {
								issuingDetails(rgm, issuingBranchCodeMap.getKey(), overallSectionTotal,
										issuingBranchNameMap, formatter);

							}
						}
					}
					preProcessing(rgm, "receiving");
					for (SortedMap.Entry<String, Set<String>> receivingBranchCodeMap : filterForReceivingBranchCode(rgm)
							.entrySet()) {
						if (receivingBranchCodeMap.getKey().equals(branchCodes)) {
							receivingDetails(rgm, receivingBranchCodeMap.getKey(), overallSectionTotal,
									receivingBranchCodeMap, formatter);
						}
					}
				} else if (acquiring) {
					preProcessing(rgm, "acquiring");
					for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
						if (branchCodeMap.getKey().equals(branchCodes)) {
							acquiringDetails(rgm, branchCodeMap.getKey(), branchCodeMap.getValue(), overallSectionTotal,
									branchCodeMap, formatter);
						}
					}
				} else if (issuing) {
					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> issuingBranchCodeMap : filterByIssuing(
							rgm).entrySet()) {
						if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
							for (SortedMap.Entry<String, Map<String, Map<String, String>>> issuingBranchNameMap : issuingBranchCodeMap
									.getValue().entrySet()) {
								pagination++;
								writeHeader(rgm, pagination, issuingBranchCodeMap.getKey(),
										issuingBranchNameMap.getKey());
								issuingDetails(rgm, issuingBranchCodeMap.getKey(), overallSectionTotal,
										issuingBranchNameMap, formatter);

							}
						}
					}
				} else if (receiving) {
					preProcessing(rgm, "receiving");
					for (SortedMap.Entry<String, Set<String>> receivingBranchCodeMap : filterForReceivingBranchCode(rgm)
							.entrySet()) {
						if (receivingBranchCodeMap.getKey().equals(branchCodes)) {
							pagination++;
							writeHeader(rgm, pagination, receivingBranchCodeMap.getKey(),
									receivingBranchCodeMap.getKey());
							receivingDetails(rgm, receivingBranchCodeMap.getKey(), overallSectionTotal,
									receivingBranchCodeMap, formatter);
						}
					}
				}
			}

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

	private void acquiringDetails(ReportGenerationMgr rgm, String branchCode, String branchName,
			double overallSectionTotal, SortedMap.Entry<String, String> branchCodeMap, DecimalFormat formatter) {
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.acquiringDetails()");
		try {
			pagination++;
			branchCode = branchCodeMap.getKey();
			branchName = branchCodeMap.getValue();
			writeHeader(rgm, pagination, branchCode, branchName);
			sectionTotal = 0.00;
			preProcessing(rgm, branchCode, null, null, "acquiring");
			StringBuilder line = new StringBuilder();
			line.append("A.").append("THIS BRANCH AS ACQUIRER/ORIGINATING BRANCH").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			rgm.setBodyQuery(getAcquiringBodyQuery());
			executeBodyQuery(rgm);
			line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append(";")
					.append(formatter.format(sectionTotal)).append(";");
			line.append(getEol());
			overallSectionTotal = sectionTotal;
			line.append(";").append(";").append(";").append(";").append(";").append("SECTION A OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in acquiringDetails", e);
		}
	}

	private void issuingDetails(ReportGenerationMgr rgm, String issuerBranchCode, double overallSectionTotal,
			SortedMap.Entry<String, Map<String, Map<String, String>>> issuingBranchNameMap, DecimalFormat formatter) {
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.issuingDetails()");
		String bankCode = null;
		String bankName = null;
		String bankMnem = null;
		try {
			StringBuilder line = new StringBuilder();
			line.append("B.").append("THIS BRANCH AS ISSUER/TRANSMITTING BRANCH").append(";");
			line.append(getEol());
			line.append("THIS BRANCH IS NOT THE ACQUIRER/ORIGINATING BRANCH").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			overallSectionTotal = 0.00;

			for (SortedMap.Entry<String, Map<String, String>> acqBankMnemMap : issuingBranchNameMap.getValue()
					.entrySet()) {
				bankMnem = acqBankMnemMap.getKey();
				for (SortedMap.Entry<String, String> bankNameMap : acqBankMnemMap.getValue().entrySet()) {
					bankName = bankNameMap.getKey();
					bankCode = bankNameMap.getValue();
					sectionTotal = 0.00;
					preProcessing(rgm, issuerBranchCode, bankCode, null, "issuing");
					line = new StringBuilder();
					line.append("ACQUIRER BANK - ").append(";").append(bankMnem + "  ").append(";").append(bankName)
							.append(";");
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
					writeBodyHeader(rgm);
					rgm.setBodyQuery(getIssuingBodyQuery());
					executeBodyQuery(rgm);
					line = new StringBuilder();
					line.append(";").append(";").append(";").append(";").append(";").append(";")
							.append(formatter.format(sectionTotal)).append(";");
					line.append(getEol());
					overallSectionTotal += sectionTotal;
					rgm.writeLine(line.toString().getBytes());
				}
			}
			line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append("SECTION B OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in issuingDetails", e);
		}
	}

	private void receivingDetails(ReportGenerationMgr rgm, String receivingBranchCode, double overallSectionTotal,
			SortedMap.Entry<String, Set<String>> receivingBranchCodeMap, DecimalFormat formatter) {
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.receivingDetails()");
		String bankCode = null;
		String bankName = null;
		String bankMnem = null;
		try {
			StringBuilder line = new StringBuilder();
			line.append("C.").append("THIS BRANCH AS RECEIVING BRANCH").append(";");
			line.append(getEol());
			line.append("THIS BRANCH IS NOT THE ACQUIRER/ORIGINATING BRANCH").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			overallSectionTotal = 0.00;
			preProcessing(rgm, receivingBranchCode, bankCode, receivingBranchCodeMap.getValue(), "receiving");
			rgm.setBodyQuery(getReceivingBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", ""));
			for (SortedMap.Entry<String, Map<String, String>> acqBankMnemMap : filterByReceiving(rgm).entrySet()) {
				bankMnem = acqBankMnemMap.getKey();
				for (SortedMap.Entry<String, String> bankNameMap : acqBankMnemMap.getValue().entrySet()) {
					sectionTotal = 0.00;
					bankName = bankNameMap.getKey();
					bankCode = bankNameMap.getValue();
					line = new StringBuilder();
					line.append("ACQUIRER BANK - ").append(";").append(bankMnem + "  ").append(";").append(bankName)
							.append(";");
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
					preProcessing(rgm, receivingBranchCode, bankCode, receivingBranchCodeMap.getValue(), "receiving");
					writeBodyHeader(rgm);
					rgm.setBodyQuery(getReceivingBodyQuery());
					executeBodyQuery(rgm);
					line = new StringBuilder();
					line.append(";").append(";").append(";").append(";").append(";").append(";")
							.append(formatter.format(sectionTotal)).append(";");
					line.append(getEol());
					overallSectionTotal += sectionTotal;
					rgm.writeLine(line.toString().getBytes());
				}
			}
			line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append("SECTION C OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in receivingDetails", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.separateQuery()");
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
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.preProcessing()");
		if (indicator.equalsIgnoreCase("acquiring")) {
			rgm.setBodyQuery(getAcquiringBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		} else if (indicator.equalsIgnoreCase("issuing")) {
			rgm.setBodyQuery(getIssuingBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		} else {
			rgm.setBodyQuery(getReceivingBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TO_ACCOUNT + "}", ""));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByBankCode,
			Set<String> filterByToAccountNo, String filterType)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.preProcessing()");
		String toAccountNumber = "";
		if (filterByBankCode != null) {
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING,
					"LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = LPAD('" + filterByBankCode + "', 10, '0')");
			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
		}

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
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ACCOUNT_2_ACN_ID IN (" + toAccountNumber + ")");
			getGlobalFileFieldsMap().put(toAccountNo.getFieldName(), toAccountNo);
		}

		if (filterByBranchCode != null) {
			if (filterType.equalsIgnoreCase("acquiring")) {
				ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
						ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
				getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			} else if (filterType.equalsIgnoreCase("issuing")) {
				ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
						ReportGenerationFields.TYPE_STRING, "BRC.BRC_CODE = '" + filterByBranchCode + "'");
				getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			} else {
				ReportGenerationFields branchCode = new ReportGenerationFields(
						ReportConstants.PARAM_RECEIVING_BRANCH_CODE, ReportGenerationFields.TYPE_STRING,
						"'" + filterByBranchCode + "'");
				getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			}
		}
	}

	private void addReceivingBranchCode(String filterByBranchCode) {
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.addReceivingBranchCode()");
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
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(field.getFieldName());
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				line.append(field.getFieldName());
				line.append(field.getDelimiter());
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					sectionTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					sectionTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}
			line.append(getFieldValue(rgm, field, fieldsMap));
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private SortedMap<String, Map<String, Map<String, Map<String, String>>>> filterByIssuing(ReportGenerationMgr rgm) {
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.filterByIssuing()");
		String branchCode = null;
		String branchName = null;
		String bankCode = null;
		String bankName = null;
		String acqBankMnem = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, Map<String, Map<String, String>>>> criteriaMap = new TreeMap<>();
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
							if (key.equalsIgnoreCase(ReportConstants.ISSUER_BRANCH_CODE)) {
								branchCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.ISSUER_BRANCH_NAME)) {
								branchName = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BANK_CODE)) {
								bankCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BANK_NAME)) {
								bankName = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.ACQUIRER_BANK_MNEM)) {
								acqBankMnem = result.toString();
							}
						}
					}
					if (criteriaMap.get(branchCode) == null) {
						Map<String, Map<String, Map<String, String>>> branchNameMap = new TreeMap<>();
						Map<String, Map<String, String>> acqBankMnemMap = new TreeMap<>();
						Map<String, String> bankNameMap = new TreeMap<>();
						bankNameMap.put(bankName, bankCode);
						acqBankMnemMap.put(acqBankMnem, bankNameMap);
						branchNameMap.put(branchName, acqBankMnemMap);
						criteriaMap.put(branchCode, branchNameMap);
					} else {
						Map<String, Map<String, Map<String, String>>> branchNameMap = criteriaMap.get(branchCode);
						if (branchNameMap.get(branchName) == null) {
							Map<String, Map<String, String>> acqBankMnemMap = new TreeMap<>();
							Map<String, String> bankNameMap = new TreeMap<>();
							bankNameMap.put(bankName, bankCode);
							acqBankMnemMap.put(acqBankMnem, bankNameMap);
							branchNameMap.put(branchName, acqBankMnemMap);
						} else {
							Map<String, Map<String, String>> acqBankMnemMap = branchNameMap.get(branchName);
							if (acqBankMnemMap.get(bankCode) == null) {
								Map<String, String> bankNameMap = new TreeMap<>();
								bankNameMap.put(bankName, bankCode);
								acqBankMnemMap.put(acqBankMnem, bankNameMap);
							} else {
								Map<String, String> bankNameMap = acqBankMnemMap.get(bankCode);
								bankNameMap.put(bankName, bankCode);
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

	private SortedMap<String, Map<String, String>> filterByReceiving(ReportGenerationMgr rgm) {
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.filterByReceiving()");
		String bankCode = null;
		String bankName = null;
		String acqBankMnem = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, String>> criteriaMap = new TreeMap<>();
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
							if (key.equalsIgnoreCase(ReportConstants.BANK_CODE)) {
								bankCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BANK_NAME)) {
								bankName = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.ACQUIRER_BANK_MNEM)) {
								acqBankMnem = result.toString();
							}
						}
					}
					if (criteriaMap.get(acqBankMnem) == null) {
						Map<String, String> bankNameMap = new TreeMap<>();
						bankNameMap.put(bankName, bankCode);
						criteriaMap.put(acqBankMnem, bankNameMap);
					} else {
						Map<String, String> bankNameMap = criteriaMap.get(acqBankMnem);
						if (bankNameMap.get(acqBankMnem) == null) {
							Map<String, String> bankCodeMap = new TreeMap<>();
							bankCodeMap.put(bankName, bankCode);
						} else {
							Map<String, String> bankCodeMap = criteriaMap.get(acqBankMnem);
							bankCodeMap.put(bankName, bankCode);
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

	private SortedMap<String, Set<String>> filterForReceivingBranchCode(ReportGenerationMgr rgm) {
		logger.debug("In InterBankFundTransferReportAtmRejectedTransaction.filterForReceivingBranchCode()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Set<String>> branchCodeMap = new TreeMap<>();
		rgm.setBodyQuery(getReceivingBodyQuery()
				.replace("{" + ReportConstants.PARAM_RECEIVING_BRANCH_CODE + "}" + " \"RECEIVING BRANCH CODE\",", "")
				.replace("{" + ReportConstants.PARAM_BRANCH_NAME + "}" + " \"RECEIVING BRANCH NAME\",", "")
				.replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", "")
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
}
