package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.MovingCashReportProcessor;
import my.com.mandrill.base.service.util.CriteriaParamsUtil;

public class AtmListCardlessWithdrawal extends MovingCashReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(AtmListCardlessWithdrawal.class);
	private int pagination = 0;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			separateQuery(rgm);
			processEmergencyCash(rgm);
			processPayToMobile(rgm);
			processSummaryPerIssuerBranch(rgm);
			processSummaryPerAcquirerBranch(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException e) {
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

	private void processEmergencyCash(ReportGenerationMgr rgm) {
		logger.debug("In AtmListCardlessWithdrawal.processEmergencyCash()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		pagination++;
		try {
			preProcessing(rgm, true, null);
			writeHeader(rgm, pagination);

			StringBuilder line = new StringBuilder();
			line.append("I. EMERGENCY CASH : ").append(";").append("ATM WITHDRAWAL (NOW)").append(";");
			line.append(getEol());
			line.append(ReportConstants.CHANNEL + " : ").append(";").append(ReportConstants.ATM).append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());

			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					line = new StringBuilder();
					line.append(ReportConstants.BRANCH + " : ").append(";").append(branchCode).append(";")
							.append(branchName).append(";");
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						rgm.setBodyQuery(getTxnBodyQuery());
						rgm.setTrailerQuery(getTxnTrailerQuery());
						preProcessing(rgm, branchCode, terminal, "emergencyCash");
						line = new StringBuilder();
						line.append(ReportConstants.TERMINAL + " : ").append(";").append(terminal).append(";")
								.append(location).append(";");
						line.append(getEol());
						rgm.writeLine(line.toString().getBytes());
						writeBodyHeader(rgm);
						executeBodyQuery(rgm, false);
						line = new StringBuilder();
						line.append(getEol());
						rgm.writeLine(line.toString().getBytes());
					}
					executeTrailerQuery(rgm, false);
				}
			}
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in processEmergencyCash", e);
		}
	}

	private void processPayToMobile(ReportGenerationMgr rgm) {
		logger.debug("In AtmListCardlessWithdrawal.processPayToMobile()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		pagination++;
		try {
			preProcessing(rgm, true, null);
			writeHeader(rgm, pagination);

			StringBuilder line = new StringBuilder();
			line.append("II. PAY TO MOBILE : ").append(";").append("ATM WITHDRAWAL (JUMP)").append(";");
			line.append(getEol());
			line.append(ReportConstants.CHANNEL + " : ").append(";").append(ReportConstants.ATM).append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());

			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					line = new StringBuilder();
					line.append(ReportConstants.BRANCH + " : ").append(";").append(branchCode).append(";")
							.append(branchName).append(";");
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						rgm.setBodyQuery(getTxnBodyQuery());
						rgm.setTrailerQuery(getTxnTrailerQuery());
						preProcessing(rgm, branchCode, terminal, "payToMobile");
						line = new StringBuilder();
						line.append(ReportConstants.TERMINAL + " : ").append(";").append(terminal).append(";")
								.append(location).append(";");
						line.append(getEol());
						rgm.writeLine(line.toString().getBytes());
						writeBodyHeader(rgm);
						executeBodyQuery(rgm, false);
						line = new StringBuilder();
						line.append(getEol());
						rgm.writeLine(line.toString().getBytes());
					}
					executeTrailerQuery(rgm, false);
				}
			}
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in processPayToMobile", e);
		}
	}

	private void processSummaryPerIssuerBranch(ReportGenerationMgr rgm) {
		logger.debug("In AtmListCardlessWithdrawal.processSummaryPerIssuerBranch()");
		pagination++;
		try {
			preProcessing(rgm, false, "issuer");
			logger.debug("getSummaryBodyQuery(): " + getSummaryBodyQuery());
			writeSummaryHeader(rgm, pagination);
			StringBuilder line = new StringBuilder();
			line.append("PER ISSUER BRANCH").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeSummaryBodyHeader(rgm);

			for (String branchCode : filterByBranchCode(rgm)) {
				rgm.setBodyQuery(getSummaryIssuerQuery());
				rgm.setTrailerQuery(getSummaryIssuerTrailerQuery());
				preProcessing(rgm, branchCode, null, "issuerSummary");
				executeBodyQuery(rgm, true);
			}

			executeTrailerQuery(rgm, true);
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in processSummaryPerIssuerBranch", e);
		}
	}

	private void processSummaryPerAcquirerBranch(ReportGenerationMgr rgm) {
		logger.debug("In AtmListCardlessWithdrawal.processSummaryPerAcquirerBranch()");
		pagination++;
		try {
			preProcessing(rgm, false, "acquirer");
			writeSummaryHeader(rgm, pagination);
			StringBuilder line = new StringBuilder();
			line.append("PER ACQUIRER BRANCH").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeSummaryBodyHeader(rgm);

			for (String branchCode : filterByBranchCode(rgm)) {
				rgm.setBodyQuery(getSummaryBodyQuery());
				rgm.setTrailerQuery(getSummaryTrailerQuery());
				preProcessing(rgm, branchCode, null, "acquirerSummary");
				executeBodyQuery(rgm, true);
			}

			executeTrailerQuery(rgm, true);
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in processSummaryPerAcquirerBranch", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In AtmListCardlessWithdrawal.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setTxnBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}

		if (rgm.getTrailerQuery() != null) {
			setTxnTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, boolean indicator, String summaryType)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmListCardlessWithdrawal.preProcessing()");
		if (indicator) {
			rgm.setBodyQuery(getTxnBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", ""));
			rgm.setTrailerQuery(getTxnTrailerQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", ""));
		} else {
			if (summaryType != null) {

				if (summaryType.equals("issuer")) {

					String summaryCriteria = CriteriaParamsUtil.replaceInstitution(
							" COALESCE(CBA.CBA_MNEM, TXN.TRL_ISS_NAME, '') = {V_Iss_Name} ", rgm.getInstitution(),
							ReportConstants.VALUE_ISSUER_NAME);

					StringBuilder summaryQuery = new StringBuilder();
					summaryQuery.append(summaryCriteria);

					setSummaryIssuerQuery(
							getSummaryBodyQuery().replace(" {" + ReportConstants.PARAM_SUMMARY + "}", summaryQuery));

					setSummaryIssuerQuery(getSummaryIssuerQuery().replace("ABR.ABR_CODE",
							"CASE WHEN ISS_BRC.BRC_CODE IS NOT NULL THEN ISS_BRC.BRC_CODE ELSE ISS_BRC_A.BRC_CODE END ")
							.replace("ABR.ABR_NAME",
									"CASE WHEN ISS_BRC.BRC_NAME IS NOT NULL THEN ISS_BRC.BRC_NAME ELSE ISS_BRC_A.BRC_NAME END "));

					setSummaryIssuerTrailerQuery(getSummaryTrailerQuery().replace(" {" + ReportConstants.PARAM_SUMMARY + "}",
							summaryCriteria));

					rgm.setBodyQuery(
							getSummaryIssuerQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));

				} else {

					String summaryQuery = CriteriaParamsUtil.replaceInstitution(
							" (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = {V_Acqr_Inst_Id}) ",
							rgm.getInstitution(), ReportConstants.VALUE_DEO_NAME, ReportConstants.VALUE_ACQR_INST_ID);

					setSummaryBodyQuery(
							getSummaryBodyQuery().replace(" {" + ReportConstants.PARAM_SUMMARY + "}", summaryQuery));

					setSummaryTrailerQuery(
							getSummaryTrailerQuery().replace(" {" + ReportConstants.PARAM_SUMMARY + "}", summaryQuery));

					rgm.setBodyQuery(
							getSummaryBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
				}
			}
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal,
			String txnType) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmListCardlessWithdrawal.preProcessing()");
		ReportGenerationFields txnCode = null;
		if (filterByBranchCode != null) {
			
			if (txnType.equalsIgnoreCase("issuerSummary")) {
				ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
						ReportGenerationFields.TYPE_STRING, "(ISS_BRC.BRC_CODE = '" + filterByBranchCode
								+ "' OR ISS_BRC_A.BRC_CODE = '" + filterByBranchCode + "')");
				getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
				
			}else {
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

		if (txnType.equals("emergencyCash")) {
			txnCode = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA, ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_TSC_CODE = 142");
			getGlobalFileFieldsMap().put(txnCode.getFieldName(), txnCode);
		} else if (txnType.equals("payToMobile")) {
			txnCode = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA, ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_TSC_CODE = 143");
			getGlobalFileFieldsMap().put(txnCode.getFieldName(), txnCode);
		}
	}

	protected SortedSet<String> filterByBranchCode(ReportGenerationMgr rgm) {
		logger.debug("In PdfReportProcessor.filterByBranchCode()");
		String branchCode = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedSet<String> branchCodeList = new TreeSet<>();
		String query = getBodyQuery(rgm);
		logger.info("Query to filter branch code: {}", query);

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
						}
					}
					branchCodeList.add(branchCode);
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
		return branchCodeList;
	}

}
