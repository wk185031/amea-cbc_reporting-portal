package my.com.mandrill.base.reporting.ibftTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.IbftReportProcessor;
import my.com.mandrill.base.service.util.CriteriaParamsUtil;
import my.com.mandrill.base.service.util.DbUtils;

public class ApprovedIbftTransactionsAcquiringBank extends IbftReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ApprovedIbftTransactionsAcquiringBank.class);
	public static final String RETAIL = "RETAIL";
	public static final String CORPORATE = "CORPORATE";
	public static final String IVRS = "IVRS";
	public static final String CBC_AT_CBC_TO_OTHER_BANK = "CBC at CBC to OTHER BANK";
	public static final String OTHER_BANK_AT_CBC_TO_CBC = "OTHER BANK at CBC to CBC";
	public static final String OTHER_BANK_AT_CBC_TO_OTHER_BANK = "OTHER BANK at CBC to OTHER BANK";
	private int pagination = 0;
	private double overallSectionTotal = 0.00;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		boolean summary = false;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			summary = false;
			pagination = 1;
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm, pagination);
			rgm.setBodyQuery(getTxnBodyQuery());

			StringBuilder line = new StringBuilder();
			line.append("I. ").append(";").append("ONLINE").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			overallSectionTotal = 0.00;
			preProcessing(rgm, RETAIL);
			retailDetails(rgm, formatter);
			overallSectionTotal = 0.00;
			preProcessing(rgm, CORPORATE);
			corporateDetails(rgm, formatter);

			line = new StringBuilder();
			line.append("II. ").append(";").append("IVRS").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			overallSectionTotal = 0.00;
			preProcessing(rgm, IVRS);
			ivrsDetails(rgm, formatter);

			line = new StringBuilder();
			line.append("III. ").append(";").append("ATM").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			overallSectionTotal = 0.00;
			preProcessing(rgm, CBC_AT_CBC_TO_OTHER_BANK);
			cbcAtCbcToOtherBankDetails(rgm, formatter);
			overallSectionTotal = 0.00;
			preProcessing(rgm, OTHER_BANK_AT_CBC_TO_CBC);
			otherBankAtCbcToCbcDetails(rgm, formatter);
			overallSectionTotal = 0.00;
			preProcessing(rgm, OTHER_BANK_AT_CBC_TO_OTHER_BANK);
			otherBankAtCbcToOtherBankDetails(rgm, formatter);

			summary = true;
			pagination++;
			rgm.setBodyQuery(getSummaryBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
			summaryDetails(rgm, pagination, summary);

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

	private void retailDetails(ReportGenerationMgr rgm, DecimalFormat formatter) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.retailDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("A.").append("CBC AS ISSUER/TRANSMITTING BRANCH - EBK PPC-IBFT TMP ACC ").append(";").append("")
					.append(";").append("(RETAIL ONLINE)").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, false);
			line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append("SECTION A OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in retailDetails", e);
		}
	}

	private void corporateDetails(ReportGenerationMgr rgm, DecimalFormat formatter) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.corporateDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("B.").append("CBC AS ISSUER/TRANSMITTING BRANCH - EBK PPC-IBFT TMP ACC ").append(";").append("")
					.append(";").append("(CORPORATE ONLINE)").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, false);
			line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append("SECTION B OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in corporateDetails", e);
		}
	}

	private void ivrsDetails(ReportGenerationMgr rgm, DecimalFormat formatter) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.ivrsDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("A.").append("CBC AS ISSUER/TRANSMITTING BRANCH - IVR PPC-IBFT TMP ACC ").append(";").append("")
					.append(";").append("(IVRS TRANSACTION)").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, false);
			line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append("SECTION A OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in ivrsDetails", e);
		}
	}

	private void cbcAtCbcToOtherBankDetails(ReportGenerationMgr rgm, DecimalFormat formatter) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.cbcAtCbcToOtherBankDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("A.").append(CBC_AT_CBC_TO_OTHER_BANK).append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, false);
			line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append("SECTION A OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in cbcAtCbcToOtherBankDetails", e);
		}
	}

	private void otherBankAtCbcToCbcDetails(ReportGenerationMgr rgm, DecimalFormat formatter) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.otherBankAtCbcToCbcDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("B.").append(OTHER_BANK_AT_CBC_TO_CBC).append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, true);
			line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append("SECTION B OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in otherBankAtCbcToCbcDetails", e);
		}
	}

	private void otherBankAtCbcToOtherBankDetails(ReportGenerationMgr rgm, DecimalFormat formatter) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.otherBankAtCbcToOtherBankDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("C.").append(OTHER_BANK_AT_CBC_TO_OTHER_BANK).append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, false);
			line = new StringBuilder();
			line.append(";").append(";").append(";").append(";").append(";").append("SECTION C OVERALL TOTAL")
					.append(";").append(formatter.format(overallSectionTotal)).append(";");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in otherBankAtCbcToOtherBankDetails", e);
		}
	}

	private void summaryDetails(ReportGenerationMgr rgm, int pagination, boolean summary) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.summaryDetails()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		try {
			writeSummaryHeader(rgm, pagination);
			writeSummaryBodyHeader(rgm);

			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					StringBuilder line = new StringBuilder();
					line.append(branchCode).append(";").append(";").append(branchName).append(";");
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						preProcessing(rgm, branchCode, terminal);
						executeBodyQuery(rgm, summary, location);
					}
				}
			}
			executeTrailerQuery(rgm);
			StringBuilder line = new StringBuilder();
			line.append("*** END OF REPORT ***");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in summaryDetails", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setTxnBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.preProcessing()");
		if (filterByBranchCode != null) {
			rgm.setBodyQuery(getSummaryBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null) {
			rgm.setBodyQuery(getSummaryBodyQuery());
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String indicator) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.preProcessing()");
		// Corporate hardcoded PAN '100200003990000021'
		if (indicator.equals(RETAIL)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					CriteriaParamsUtil.replaceInstitution("TXN.TRL_ISS_NAME = {V_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') != {V_IE_Recv_Inst_Id} AND TXN.TRL_PAN != 'FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971'", 
							rgm.getInstitution(), ReportConstants.VALUE_ISSUER_NAME, ReportConstants.VALUE_INTER_RECV_INST_ID));
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"'' AS \"ISSUER BANK MNEM\", '' AS \"ISSUER BRANCH NAME\", (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"RECEIVING BANK MNEM\", '' AS \"RECEIVING BRANCH NAME\",");
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		} else if (indicator.equals(CORPORATE)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					CriteriaParamsUtil.replaceInstitution("LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') != {V_IE_Recv_Inst_Id} AND TXN.TRL_PAN = 'FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971'", 
							rgm.getInstitution(), ReportConstants.VALUE_INTER_RECV_INST_ID));
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"'' AS \"ISSUER BANK MNEM\", '' AS \"ISSUER BRANCH NAME\", (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"RECEIVING BANK MNEM\", '' AS \"RECEIVING BRANCH NAME\",");
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		} else if (indicator.equals(IVRS)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					CriteriaParamsUtil.replaceInstitution("TXN.TRL_ISS_NAME = {V_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') != {V_IE_Recv_Inst_Id}", 
							rgm.getInstitution(), ReportConstants.VALUE_ISSUER_NAME, ReportConstants.VALUE_INTER_RECV_INST_ID));
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"'' AS \"ISSUER BANK MNEM\", '' AS \"ISSUER BRANCH NAME\", (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"RECEIVING BANK MNEM\", '' AS \"RECEIVING BRANCH NAME\",");
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		} else if (indicator.equals(CBC_AT_CBC_TO_OTHER_BANK)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					CriteriaParamsUtil.replaceInstitution("TXN.TRL_ISS_NAME = {V_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') != {V_IE_Recv_Inst_Id}", 
							rgm.getInstitution(), ReportConstants.VALUE_ISSUER_NAME, ReportConstants.VALUE_INTER_RECV_INST_ID));
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					CriteriaParamsUtil.replaceInstitution("{V_Iss_Name} AS \"ISSUER BANK MNEM\", BRC.BRC_NAME \"ISSUER BRANCH NAME\", (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"RECEIVING BANK MNEM\", '' AS \"RECEIVING BRANCH NAME\",", 
							rgm.getInstitution(), ReportConstants.VALUE_ISSUER_NAME));
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		} else if (indicator.equals(OTHER_BANK_AT_CBC_TO_CBC)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					CriteriaParamsUtil.replaceInstitution("TXN.TRL_ISS_NAME IS NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = {V_Recv_Inst_Id}", 
							rgm.getInstitution(), ReportConstants.VALUE_RECV_INST_ID));
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					CriteriaParamsUtil.replaceInstitution("CBA.CBA_MNEM AS \"ISSUER BANK MNEM\", '' AS \"ISSUER BRANCH NAME\", {V_Iss_Name} AS \"RECEIVING BANK MNEM\",", 
							rgm.getInstitution(), ReportConstants.VALUE_ISSUER_NAME));
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		} else if (indicator.equals(OTHER_BANK_AT_CBC_TO_OTHER_BANK)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					CriteriaParamsUtil.replaceInstitution("TXN.TRL_ISS_NAME IS NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') != {V_Recv_Inst_Id}", 
							rgm.getInstitution(), ReportConstants.VALUE_RECV_INST_ID));
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"CBA.CBA_MNEM AS \"ISSUER BANK MNEM\", '' AS \"ISSUER BRANCH NAME\", (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"RECEIVING BANK MNEM\", '' AS \"RECEIVING BRANCH NAME\",");
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.writeBodyHeader()");
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
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
			case 24:
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
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.writeSummaryBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 38:
			case 39:
			case 40:
			case 41:
			case 42:
			case 43:
			case 44:
			case 45:
			case 46:
			case 47:
			case 48:
			case 49:
			case 50:
			case 51:
			case 52:
			case 53:
			case 54:
			case 55:
			case 56:
			case 57:
			case 58:
			case 59:
			case 60:
			case 61:
			case 62:
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

	private void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			boolean indicator, String toAccountNo, String toAccountNoEkyId)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			switch (field.getSequence()) {
			case 25:
			case 26:
			case 27:
			case 28:
			case 29:
			case 30:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			case 31:
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					overallSectionTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					overallSectionTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			case 32:
			case 33:
			case 34:
			case 35:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			case 36:
				if (indicator) {
					line.append(retrieveReceivingBranchName(rgm, toAccountNo, toAccountNoEkyId));
					line.append(field.getDelimiter());
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
				}
				break;
			case 37:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm, boolean indicator) {
		logger.debug("In ApprovedIbftTransactionsAcquiringBank.executeBodyQuery()");
		Connection conn = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String toAccountNo = null;
		String toAccountNoEkyId = null;
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				conn = rgm.getNewConnection();
				ps = conn.prepareStatement(query);
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
							if (key.equalsIgnoreCase(ReportConstants.TO_ACCOUNT_NO)) {
								toAccountNo = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.TO_ACCOUNT_NO_EKY_ID)) {
								toAccountNoEkyId = result.toString();
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap, indicator, toAccountNo, toAccountNoEkyId);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				DbUtils.cleanDbResources(conn, ps, rs);
			}
		}
	}
}
