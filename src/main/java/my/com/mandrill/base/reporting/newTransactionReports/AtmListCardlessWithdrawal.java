package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.MovingCashReportProcessor;

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
		String branchCode = null;
		pagination++;
		try {
			preProcessing(rgm, false, "issuer");
			writeSummaryHeader(rgm, pagination);
			StringBuilder line = new StringBuilder();
			line.append("PER ISSUER BRANCH").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeSummaryBodyHeader(rgm);

			for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				rgm.setBodyQuery(getSummaryBodyQuery());
				rgm.setTrailerQuery(getSummaryTrailerQuery());
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
		String branchCode = null;
		pagination++;
		try {
			preProcessing(rgm, false, "acquirer");
			writeSummaryHeader(rgm, pagination);
			StringBuilder line = new StringBuilder();
			line.append("PER ACQUIRER BRANCH").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeSummaryBodyHeader(rgm);

			for (SortedMap.Entry<String, String> branchCodeMap : filterByBranch(rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
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
					setSummaryBodyQuery(getSummaryBodyQuery()
							.replace("{" + ReportConstants.PARAM_BRANCH_CODE + "} \"BRANCH CODE\"",
									"BRC.BRC_CODE \"BRANCH CODE\"")
							.replace("{" + ReportConstants.PARAM_BRANCH_NAME + "} \"BRANCH NAME\"",
									"BRC.BRC_NAME \"BRANCH NAME\"")
							.replace("{" + ReportConstants.PARAM_JOIN_CRITERIA + "}",
									"JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE"));
					rgm.setBodyQuery(
							getSummaryBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
				} else {
					setSummaryBodyQuery(getSummaryBodyQuery()
							.replace("BRC.BRC_CODE \"BRANCH CODE\"", "ABR.ABR_CODE \"BRANCH CODE\"")
							.replace("BRC.BRC_NAME \"BRANCH NAME\"", "ABR.ABR_NAME \"BRANCH NAME\"").replace(
									"JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE",
									"JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID"));
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
			if (txnType.equals("issuerSummary")) {
				ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
						ReportGenerationFields.TYPE_STRING, "BRC.BRC_CODE = '" + filterByBranchCode + "'");
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
}
