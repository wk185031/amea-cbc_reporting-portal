package my.com.mandrill.base.reporting.ibftTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
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
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class InterBankFundTransferReportAtm extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(InterBankFundTransferReportAtm.class);
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
		String branchCode = null;
		String branchName = null;
		String bankCode = null;
		String bankName = null;
		String bankMnem = null;
		boolean issuing = false;
		boolean receiving = false;
		double overallSectionTotal = 0.00;
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			separateQuery(rgm);
			preProcessing(rgm);

			overallSectionTotal = 0.00;
			preProcessing(rgm, "acquiring");
			for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
				acquiringDetails(rgm, branchCode, branchName, overallSectionTotal, branchCodeMap, bankCode, formatter);
			}

			TreeSet<String> branchCodesList = new TreeSet<>();

			preProcessing(rgm, "issuing");
			for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> issuingBranchCodeMap : filterByIssuingReceiving(
					rgm).entrySet()) {
				branchCodesList.add(issuingBranchCodeMap.getKey());
			}

			preProcessing(rgm, "receiving");
			for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> receivingBranchCodeMap : filterByIssuingReceiving(
					rgm).entrySet()) {
				branchCodesList.add(receivingBranchCodeMap.getKey());
			}

			for (String branchCodes : branchCodesList) {
				preProcessing(rgm, "issuing");
				for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> issuingBranchCodeMap : filterByIssuingReceiving(
						rgm).entrySet()) {
					if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
						issuing = true;
					}
				}

				preProcessing(rgm, "receiving");
				for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> receivingBranchCodeMap : filterByIssuingReceiving(
						rgm).entrySet()) {
					if (receivingBranchCodeMap.getKey().equals(branchCodes)) {
						receiving = true;
					}
				}

				if (issuing && receiving) {
					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> issuingBranchCodeMap : filterByIssuingReceiving(
							rgm).entrySet()) {
						if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
							for (SortedMap.Entry<String, Map<String, Map<String, String>>> issuingBranchNameMap : issuingBranchCodeMap
									.getValue().entrySet()) {
								issuingDetails(rgm, issuingBranchCodeMap.getKey(), issuingBranchNameMap.getKey(),
										overallSectionTotal, issuingBranchNameMap, bankCode, bankName, bankMnem,
										formatter);

							}
						}
					}
					preProcessing(rgm, "receiving");
					for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> receivingBranchCodeMap : filterByIssuingReceiving(
							rgm).entrySet()) {
						if (receivingBranchCodeMap.getKey().equals(branchCodes)) {
							for (SortedMap.Entry<String, Map<String, Map<String, String>>> receivingBranchNameMap : receivingBranchCodeMap
									.getValue().entrySet()) {
								receivingDetails(rgm, receivingBranchCodeMap.getKey(), receivingBranchNameMap.getKey(),
										overallSectionTotal, receivingBranchNameMap, bankCode, bankName, bankMnem,
										formatter);
							}
						}
					}
				} else if (issuing) {
					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> issuingBranchCodeMap : filterByIssuingReceiving(
							rgm).entrySet()) {
						if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
							for (SortedMap.Entry<String, Map<String, Map<String, String>>> issuingBranchNameMap : issuingBranchCodeMap
									.getValue().entrySet()) {
								issuingDetails(rgm, issuingBranchCodeMap.getKey(), issuingBranchNameMap.getKey(),
										overallSectionTotal, issuingBranchNameMap, bankCode, bankName, bankMnem,
										formatter);

							}
						}
					}
				} else if (receiving) {
					preProcessing(rgm, "receiving");
					for (SortedMap.Entry<String, Map<String, Map<String, Map<String, String>>>> receivingBranchCodeMap : filterByIssuingReceiving(
							rgm).entrySet()) {
						if (receivingBranchCodeMap.getKey().equals(branchCodes)) {
							for (SortedMap.Entry<String, Map<String, Map<String, String>>> receivingBranchNameMap : receivingBranchCodeMap
									.getValue().entrySet()) {
								pagination++;
								writeHeader(rgm, pagination, receivingBranchCodeMap.getKey(),
										receivingBranchNameMap.getKey());
								receivingDetails(rgm, receivingBranchCodeMap.getKey(), receivingBranchNameMap.getKey(),
										overallSectionTotal, receivingBranchNameMap, bankCode, bankName, bankMnem,
										formatter);
							}
						}
					}
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

	private void acquiringDetails(ReportGenerationMgr rgm, String branchCode, String branchName,
			double overallSectionTotal, SortedMap.Entry<String, String> branchCodeMap, String bankCode,
			DecimalFormat formatter) {
		logger.debug("In InterBankFundTransferReportAtm.acquiringDetails()");
		try {
			StringBuilder acquiringLine = new StringBuilder();
			pagination++;
			branchCode = branchCodeMap.getKey();
			branchName = branchCodeMap.getValue();
			writeHeader(rgm, pagination, branchCode, branchName);
			sectionTotal = 0.00;
			preProcessing(rgm, branchCode, bankCode, "acquiring");
			acquiringLine.append("A.").append("THIS BRANCH AS ACQUIRER/ORIGINATING BRANCH").append(";");
			acquiringLine.append(getEol());
			rgm.writeLine(acquiringLine.toString().getBytes());
			writeBodyHeader(rgm);
			rgm.setBodyQuery(getAcquiringBodyQuery());
			executeBodyQuery(rgm);
			acquiringLine = new StringBuilder();
			acquiringLine.append(";").append(";").append(";").append(";").append(";").append(";")
					.append(formatter.format(sectionTotal)).append(";");
			acquiringLine.append(getEol());
			overallSectionTotal = sectionTotal;
			acquiringLine.append(";").append(";").append(";").append(";").append(";").append("SECTION A OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			acquiringLine.append(getEol());
			acquiringLine.append(getEol());
			rgm.writeLine(acquiringLine.toString().getBytes());
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in acquiringDetails", e);
		}
	}

	private void issuingDetails(ReportGenerationMgr rgm, String issuerBranchCode, String issuerBranchName,
			double overallSectionTotal, SortedMap.Entry<String, Map<String, Map<String, String>>> issuingBranchNameMap,
			String bankCode, String bankName, String bankMnem, DecimalFormat formatter) {
		logger.debug("In InterBankFundTransferReportAtm.issuingDetails()");
		try {
			pagination++;
			writeHeader(rgm, pagination, issuerBranchCode, issuerBranchName);
			StringBuilder line = new StringBuilder();
			line.append("B.").append("THIS BRANCH AS ISSUER/TRANSMITTING BRANCH").append(";");
			line.append(getEol());
			line.append("THIS BRANCH IS NOT THE ACQUIRER/ORIGINATING BRANCH").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			overallSectionTotal = 0.00;

			for (SortedMap.Entry<String, Map<String, String>> bankCodeMap : issuingBranchNameMap.getValue()
					.entrySet()) {
				bankCode = bankCodeMap.getKey();
				for (SortedMap.Entry<String, String> bankMnemMap : bankCodeMap.getValue().entrySet()) {
					bankName = bankMnemMap.getKey();
					bankMnem = bankMnemMap.getValue();
					sectionTotal = 0.00;
					preProcessing(rgm, issuerBranchCode, bankCode, "issuing");
					line = new StringBuilder();
					line.append("ACQUIRER BANK - ").append(bankMnem + "  ").append(bankName).append(";");
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

	private void receivingDetails(ReportGenerationMgr rgm, String receivingBranchCode, String receivingBranchName,
			double overallSectionTotal,
			SortedMap.Entry<String, Map<String, Map<String, String>>> receivingBranchNameMap, String bankCode,
			String bankName, String bankMnem, DecimalFormat formatter) {
		logger.debug("In InterBankFundTransferReportAtm.receivingDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("C.").append("THIS BRANCH AS RECEIVING BRANCH").append(";");
			line.append(getEol());
			line.append("THIS BRANCH IS NOT THE ACQUIRER/ORIGINATING BRANCH").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			overallSectionTotal = 0.00;

			for (SortedMap.Entry<String, Map<String, String>> bankCodeMap : receivingBranchNameMap.getValue()
					.entrySet()) {
				bankCode = bankCodeMap.getKey();
				for (SortedMap.Entry<String, String> bankMnemMap : bankCodeMap.getValue().entrySet()) {
					bankName = bankMnemMap.getKey();
					bankMnem = bankMnemMap.getValue();
					sectionTotal = 0.00;
					preProcessing(rgm, receivingBranchCode, bankCode, "receiving");
					line = new StringBuilder();
					line.append("ACQUIRER BANK - ").append(bankMnem + "  ").append(bankName).append(";");
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
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

	private SortedMap<String, String> filterByBranch(ReportGenerationMgr rgm) {
		logger.debug("In InterBankFundTransferReportAtm.filterByBranch()");
		String branchCode = null;
		String branchName = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> criteriaMap = new TreeMap<>();
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
						}
					}
					criteriaMap.put(branchCode, branchName);
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

	private SortedMap<String, Map<String, Map<String, Map<String, String>>>> filterByIssuingReceiving(
			ReportGenerationMgr rgm) {
		logger.debug("In InterBankFundTransferReportAtm.filterByIssuingReceiving()");
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
							if (key.equalsIgnoreCase(ReportConstants.ISSUER_BRANCH_CODE)
									|| key.equalsIgnoreCase(ReportConstants.RECEIVING_BRANCH_CODE)) {
								branchCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.ISSUER_BRANCH_NAME)
									|| key.equalsIgnoreCase(ReportConstants.RECEIVING_BRANCH_NAME)) {
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
						Map<String, Map<String, Map<String, String>>> branchNameMap = new HashMap<>();
						Map<String, Map<String, String>> bankCodeMap = new HashMap<>();
						Map<String, String> locationMap = new HashMap<>();
						locationMap.put(bankName, acqBankMnem);
						bankCodeMap.put(bankCode, locationMap);
						branchNameMap.put(branchName, bankCodeMap);
						criteriaMap.put(branchCode, branchNameMap);
					} else {
						Map<String, Map<String, Map<String, String>>> branchNameMap = criteriaMap.get(branchCode);
						if (branchNameMap.get(branchName) == null) {
							Map<String, Map<String, String>> terminalMap = new HashMap<>();
							Map<String, String> locationMap = new HashMap<>();
							locationMap.put(bankName, acqBankMnem);
							terminalMap.put(bankCode, locationMap);
							branchNameMap.put(branchName, terminalMap);
						} else {
							Map<String, Map<String, String>> bankCodeMap = branchNameMap.get(branchName);
							if (bankCodeMap.get(bankCode) == null) {
								Map<String, String> bankNameMap = new HashMap<>();
								bankNameMap.put(bankName, acqBankMnem);
								bankCodeMap.put(bankCode, bankNameMap);
							} else {
								Map<String, String> bankNameMap = bankCodeMap.get(bankCode);
								bankNameMap.put(bankName, acqBankMnem);
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

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In InterBankFundTransferReportAtm.preProcessing()");
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String indicator) {
		logger.debug("In InterBankFundTransferReportAtm.preProcessing()");
		if (indicator.equalsIgnoreCase("acquiring")) {
			rgm.setBodyQuery(getAcquiringBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		} else if (indicator.equalsIgnoreCase("issuing")) {
			rgm.setBodyQuery(getIssuingBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		} else {
			rgm.setBodyQuery(getReceivingBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByBankCode,
			String filterType) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In InterBankFundTransferReportAtm.preProcessing()");
		if (filterByBranchCode != null && filterType.equalsIgnoreCase("acquiring")) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByBankCode != null) {
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING,
					"LPAD(TXN.TRL_ACQR_INST_ID, 4, '0') = '" + filterByBankCode + "'");
			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
		}

		if (filterByBranchCode != null
				&& (filterType.equalsIgnoreCase("issuing") || filterType.equalsIgnoreCase("receiving"))) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(BRC.BRC_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In InterBankFundTransferReportAtm.separateQuery()");
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

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In InterBankFundTransferReportAtm.writeBodyHeader()");
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
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
				if (getFieldValue(field, fieldsMap, true).indexOf(",") != 0) {
					sectionTotal += Double.parseDouble(getFieldValue(field, fieldsMap, true).replace(",", ""));
				} else {
					sectionTotal += Double.parseDouble(getFieldValue(field, fieldsMap, true));
				}
			}
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
}
