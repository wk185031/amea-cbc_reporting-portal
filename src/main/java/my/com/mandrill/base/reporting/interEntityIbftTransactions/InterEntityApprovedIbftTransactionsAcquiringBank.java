package my.com.mandrill.base.reporting.interEntityIbftTransactions;

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
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.IbftReportProcessor;

public class InterEntityApprovedIbftTransactionsAcquiringBank extends IbftReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(InterEntityApprovedIbftTransactionsAcquiringBank.class);
	public static final String RETAIL = "RETAIL";
	public static final String CORPORATE = "CORPORATE";
	public static final String IVRS = "IVRS";
	public String CBC_AT_CBC_TO_CBS = "CBC at CBC to CBS";
	public String CBS_AT_CBC_TO_CBC = "CBS at CBC to CBC";
	public String CBS_AT_CBC_TO_OTHER_BANK = "CBS at CBC to OTHER BANK";
	private int pagination = 0;
	private double overallSectionTotal = 0.00;
	private String ie_ins_name = "CBS";
	private String ie_ins_id = "0000000112";
	private String ins_id = "0000000010";

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

			if (rgm.getInstitution().equalsIgnoreCase("CBS")) {
				ie_ins_name = "CBC";
				ie_ins_id = "0000000010";
				ins_id = "0000000112";

				CBC_AT_CBC_TO_CBS = "CBS at CBS to CBC";
				CBS_AT_CBC_TO_CBC = "CBC at CBS to CBS";
				CBS_AT_CBC_TO_OTHER_BANK = "CBC at CBS to OTHER BANK";
			}

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
			preProcessing(rgm, CBC_AT_CBC_TO_CBS);
			cbcAtCbcToCbsDetails(rgm, formatter);
			overallSectionTotal = 0.00;
			preProcessing(rgm, CBS_AT_CBC_TO_CBC);
			cbsAtCbcToCbcDetails(rgm, formatter);
			overallSectionTotal = 0.00;
			preProcessing(rgm, CBS_AT_CBC_TO_OTHER_BANK);
			cbsAtCbcToOtherBankDetails(rgm, formatter);

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
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.retailDetails()");
		try {
			StringBuilder line = new StringBuilder();
			if (rgm.getInstitution().equalsIgnoreCase("CBS")) {
				line.append("A.").append("CBS AS ISSUER/TRANSMITTING BRANCH - EBK PPC-IBFT TMP ACC ").append(";")
						.append("").append(";").append("(RETAIL ONLINE)").append(";");
			} else {
				line.append("A.").append("CBC AS ISSUER/TRANSMITTING BRANCH - EBK PPC-IBFT TMP ACC ").append(";")
						.append("").append(";").append("(RETAIL ONLINE)").append(";");
			}
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
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.corporateDetails()");
		try {
			StringBuilder line = new StringBuilder();
			if (rgm.getInstitution().equalsIgnoreCase("CBS")) {
				line.append("B.").append("CBS AS ISSUER/TRANSMITTING BRANCH - EBK PPC-IBFT TMP ACC ").append(";")
						.append("").append(";").append("(CORPORATE ONLINE)").append(";");
			} else {
				line.append("B.").append("CBC AS ISSUER/TRANSMITTING BRANCH - EBK PPC-IBFT TMP ACC ").append(";")
						.append("").append(";").append("(CORPORATE ONLINE)").append(";");
			}
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
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.ivrsDetails()");
		try {
			StringBuilder line = new StringBuilder();
			if (rgm.getInstitution().equalsIgnoreCase("CBS")) {
				line.append("A.").append("CBS AS ISSUER/TRANSMITTING BRANCH - IVR PPC-IBFT TMP ACC ").append(";")
						.append("").append(";").append("(IVRS TRANSACTION)").append(";");
			} else {
				line.append("A.").append("CBC AS ISSUER/TRANSMITTING BRANCH - IVR PPC-IBFT TMP ACC ").append(";")
						.append("").append(";").append("(IVRS TRANSACTION)").append(";");
			}
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

	private void cbcAtCbcToCbsDetails(ReportGenerationMgr rgm, DecimalFormat formatter) {
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.cbcAtCbcToCbsDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("A.").append(CBC_AT_CBC_TO_CBS).append(";");
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
			logger.error("Error in cbcAtCbcToCbsDetails", e);
		}
	}

	private void cbsAtCbcToCbcDetails(ReportGenerationMgr rgm, DecimalFormat formatter) {
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.cbsAtCbcToCbcDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("B.").append(CBS_AT_CBC_TO_CBC).append(";");
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
			logger.error("Error in cbsAtCbcToCbcDetails", e);
		}
	}

	private void cbsAtCbcToOtherBankDetails(ReportGenerationMgr rgm, DecimalFormat formatter) {
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.cbsAtCbcToOtherBankDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("C.").append(CBS_AT_CBC_TO_OTHER_BANK).append(";");
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
			logger.error("Error in cbsAtCbcToOtherBankDetails", e);
		}
	}

	private void summaryDetails(ReportGenerationMgr rgm, int pagination, boolean summary) {
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.summaryDetails()");
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

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.preProcessing()");
		if (filterByBranchCode != null) {
			rgm.setBodyQuery(getSummaryBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null) {
			rgm.setBodyQuery(getSummaryBodyQuery());
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(AST.AST_TERMINAL_ID, -4) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String indicator) {
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.preProcessing()");
		// Corporate hardcoded PAN '100200003990000021'
		if (indicator.equals(RETAIL)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"
							+ " AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ie_ins_id + "'"
							+ " AND TXN.TRL_PAN != 'FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971' AND TXNC.TRL_ORIGIN_CHANNEL IN ( '"
							+ ReportConstants.MBK + "','" + ReportConstants.EBK + "')");
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
					ReportGenerationFields.TYPE_STRING, "LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ie_ins_id + "'"
							+ "  AND TXN.TRL_PAN = 'FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971' AND TXNC.TRL_ORIGIN_CHANNEL IN ( '"
							+ ReportConstants.MBK + "','" + ReportConstants.EBK + "')");
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
					"TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"
							+ " AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ie_ins_id
							+ "' AND TXNC.TRL_ORIGIN_CHANNEL = '" + ReportConstants.IVR + "'");
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"'' AS \"ISSUER BANK MNEM\", '' AS \"ISSUER BRANCH NAME\", (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"RECEIVING BANK MNEM\", '' AS \"RECEIVING BRANCH NAME\",");
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		} else if (indicator.equals(CBC_AT_CBC_TO_CBS)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"
							+ " AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ie_ins_id + "'");
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"'CBC' AS \"ISSUER BANK MNEM\", BRC.BRC_NAME \"ISSUER BRANCH NAME\", (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"RECEIVING BANK MNEM\", '' AS \"RECEIVING BRANCH NAME\",");
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		} else if (indicator.equals(CBS_AT_CBC_TO_CBC)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ISS_NAME = '" + ie_ins_name + "'"
							+ " AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ins_id + "'");
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"CBA.CBA_MNEM AS \"ISSUER BANK MNEM\", '' AS \"ISSUER BRANCH NAME\", 'CBC' AS \"RECEIVING BANK MNEM\",");
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		} else if (indicator.equals(CBS_AT_CBC_TO_OTHER_BANK)) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ISS_NAME = '" + ie_ins_name + "'" + " AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') NOT IN ('"
							+ ins_id + "', '" + ie_ins_id + "')");
			ReportGenerationFields fieldCriteria = new ReportGenerationFields(ReportConstants.PARAM_FIELD_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"CBA.CBA_MNEM AS \"ISSUER BANK MNEM\", '' AS \"ISSUER BRANCH NAME\", (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"RECEIVING BANK MNEM\", '' AS \"RECEIVING BRANCH NAME\",");
			ReportGenerationFields joinCriteria = new ReportGenerationFields(ReportConstants.PARAM_JOIN_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID");

			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
			getGlobalFileFieldsMap().put(fieldCriteria.getFieldName(), fieldCriteria);
			getGlobalFileFieldsMap().put(joinCriteria.getFieldName(), joinCriteria);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setTxnBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.writeBodyHeader()");
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
		logger.debug("In InterEntityApprovedIbftTransactionsAcquiringBank.writeSummaryBodyHeader()");
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
			case 63:
			case 64:
			case 65:
			case 66:
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
				try {
					if (ps != null) {
						ps.close();
					}

					if (rs != null) {
						rs.close();
					}
					rs.close();
				} catch (SQLException e) {
					rgm.errors++;
					logger.error("Error closing DB resources", e);
				}
			}
		}
	}
}
