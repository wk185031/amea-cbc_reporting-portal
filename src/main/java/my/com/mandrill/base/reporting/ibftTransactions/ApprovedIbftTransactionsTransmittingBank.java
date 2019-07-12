package my.com.mandrill.base.reporting.ibftTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.SortedMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.IbftReportProcessor;

public class ApprovedIbftTransactionsTransmittingBank extends IbftReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ApprovedIbftTransactionsTransmittingBank.class);
	private int pagination = 0;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String bankCode = null;
		String bankName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			separateQuery(rgm);

			pagination++;
			preProcessing(rgm, "retail", null);
			writeRetailHeader(rgm, pagination);
			for (SortedMap.Entry<String, String> bankCodeMap : filterByCriteriaByBank(rgm).entrySet()) {
				bankCode = bankCodeMap.getKey();
				bankName = bankCodeMap.getValue();
				retailDetails(rgm, bankCode, bankName);
			}

			pagination++;
			preProcessing(rgm, "corporate", null);
			writeCorporateHeader(rgm, pagination);
			for (SortedMap.Entry<String, String> bankCodeMap : filterByCriteriaByBank(rgm).entrySet()) {
				bankCode = bankCodeMap.getKey();
				bankName = bankCodeMap.getValue();
				corporateDetails(rgm, bankCode, bankName);
			}

			pagination++;
			writeSummaryHeader(rgm, pagination);
			retailSummaryDetails(rgm);
			corporateSummaryDetails(rgm);
			consolidatedSummaryDetails(rgm);

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

	private void retailDetails(ReportGenerationMgr rgm, String bankCode, String bankName) {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.retailDetails()");
		try {
			StringBuilder line = new StringBuilder();
			preProcessingFilter(rgm, bankCode);
			line = new StringBuilder();
			line.append("RECEIVING BANK : ").append(bankCode + "  ").append(bankName).append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			rgm.setBodyQuery(getIbftBodyQuery());
			executeBodyQuery(rgm, false, "retail");
			rgm.setTrailerQuery(getIbftTrailerQuery());
			executeTrailerQuery(rgm, false, "retail");
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in retailDetails", e);
		}
	}

	private void corporateDetails(ReportGenerationMgr rgm, String bankCode, String bankName) {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.corporateDetails()");
		try {
			StringBuilder line = new StringBuilder();
			preProcessingFilter(rgm, bankCode);
			line = new StringBuilder();
			line.append("RECEIVING BANK : ").append(bankCode + "  ").append(bankName).append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			rgm.setBodyQuery(getIbftBodyQuery());
			executeBodyQuery(rgm, false, "corporate");
			rgm.setTrailerQuery(getIbftTrailerQuery());
			executeTrailerQuery(rgm, false, "corporate");
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in corporateDetails", e);
		}
	}

	private void retailSummaryDetails(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.retailDetails()");
		try {
			preProcessing(rgm, "retail", null);
			StringBuilder retailLine = new StringBuilder();
			retailLine.append("FOR RETAIL TRANSACTIONS");
			retailLine.append(getEol());
			rgm.writeLine(retailLine.toString().getBytes());
			writeSummaryBodyHeader(rgm, "retail");
			rgm.setBodyQuery(getSummaryBodyQuery().replace("{" + ReportConstants.PARAM_CORPORATE_COUNT + "},", "")
					.replace("{" + ReportConstants.PARAM_CORPORATE_INCOME + "},", ""));
			executeBodyQuery(rgm, true, "retail");
			rgm.setTrailerQuery(
					getSummaryTrailerQuery().replace("{" + ReportConstants.PARAM_CORPORATE_INCOME + "},", ""));
			executeTrailerQuery(rgm, true, "retail");
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in retailSummaryDetails", e);
		}
	}

	private void corporateSummaryDetails(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.corporateDetails()");
		try {
			preProcessing(rgm, "corporate", null);
			StringBuilder corporateLine = new StringBuilder();
			corporateLine.append("FOR CORPORATE TRANSACTIONS");
			corporateLine.append(getEol());
			rgm.writeLine(corporateLine.toString().getBytes());
			writeSummaryBodyHeader(rgm, "corporate");
			rgm.setBodyQuery(getSummaryBodyQuery().replace("{" + ReportConstants.PARAM_CORPORATE_COUNT + "},", "")
					.replace("{" + ReportConstants.PARAM_CORPORATE_INCOME + "},", ""));
			executeBodyQuery(rgm, true, "corporate");
			rgm.setTrailerQuery(
					getSummaryTrailerQuery().replace("{" + ReportConstants.PARAM_CORPORATE_INCOME + "},", ""));
			executeTrailerQuery(rgm, true, "corporate");
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in consolidatedSummaryDetails", e);
		}
	}

	private void consolidatedSummaryDetails(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.consolidatedDetails()");
		try {
			StringBuilder consolidatedLine = new StringBuilder();
			consolidatedLine.append("CONSOLIDATED TRANSACTIONS");
			consolidatedLine.append(getEol());
			rgm.writeLine(consolidatedLine.toString().getBytes());
			writeSummaryBodyHeader(rgm, "corporate");
			preProcessing(rgm, "consolidated", "body");
			rgm.setBodyQuery(getSummaryBodyQuery().replace("AND {" + ReportConstants.PARAM_IBFT_CRITERIA + "}", "")
					.replace("125.00 * COUNT(\"TRAN COUNT\") AS \"CORP. INCOME\",", ""));
			executeBodyQuery(rgm, true, "corporate");
			preProcessing(rgm, "consolidated", "trailer");
			rgm.setTrailerQuery(
					getSummaryTrailerQuery().replace("AND {" + ReportConstants.PARAM_IBFT_CRITERIA + "}", "")
							.replace("SUM(125.00 * COUNT(TXN.TRL_ID)) AS \"CORP. INCOME\",", ""));
			executeTrailerQuery(rgm, true, "corporate");
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in corporateSummaryDetails", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setIbftBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCriteriaQuery(getIbftBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", ""));
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

	private void preProcessing(ReportGenerationMgr rgm, String filterType, String queryType)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.preProcessing()");
		// TBD - retrieve clear PAN from decryption
		if (filterType.equalsIgnoreCase("retail")) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_PAN != '100200003990000021'");
			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
		}

		if (filterType.equalsIgnoreCase("corporate")) {
			ReportGenerationFields ibftCriteria = new ReportGenerationFields(ReportConstants.PARAM_IBFT_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_PAN = '100200003990000021'");
			getGlobalFileFieldsMap().put(ibftCriteria.getFieldName(), ibftCriteria);
		}

		if (filterType.equalsIgnoreCase("consolidated")) {
			if (queryType.equalsIgnoreCase("body")) {
				ReportGenerationFields corporateCount = new ReportGenerationFields(
						ReportConstants.PARAM_CORPORATE_COUNT, ReportGenerationFields.TYPE_STRING,
						"CASE WHEN TXN.TRL_PAN = '100200003990000021' THEN TXN.TRL_ID END AS \"CORPORATE COUNT\"");
				ReportGenerationFields corporateIncome = new ReportGenerationFields(
						ReportConstants.PARAM_CORPORATE_INCOME, ReportGenerationFields.TYPE_STRING,
						"125.00 * COUNT(\"CORPORATE COUNT\") AS \"CORP. INCOME\"");

				getGlobalFileFieldsMap().put(corporateCount.getFieldName(), corporateCount);
				getGlobalFileFieldsMap().put(corporateIncome.getFieldName(), corporateIncome);
			} else {
				ReportGenerationFields corporateIncome = new ReportGenerationFields(
						ReportConstants.PARAM_CORPORATE_INCOME, ReportGenerationFields.TYPE_STRING,
						"SUM(125.00 * COUNT(CASE WHEN TXN.TRL_PAN = '100200003990000021' THEN TXN.TRL_ID END)) AS \"CORP. INCOME\"");
				getGlobalFileFieldsMap().put(corporateIncome.getFieldName(), corporateIncome);
			}
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessingFilter(ReportGenerationMgr rgm, String filterByBankCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.preProcessing()");
		if (filterByBankCode != null) {
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING,
					"LPAD(TXN.TRL_FRD_REV_INST_ID, 4, '0') = '" + filterByBankCode + "'");
			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
		}
	}

	private void writeRetailHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.writeRetailHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 4:
			case 12:
				break;
			default:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
						line.append(String.valueOf(pagination));
					} else {
						line.append(getGlobalFieldValue(rgm, field));
					}
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeCorporateHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.writeCorporateHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 4:
			case 11:
				break;
			default:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
						line.append(String.valueOf(pagination));
					} else {
						line.append(getGlobalFieldValue(rgm, field));
					}
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeSummaryHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.writeSummaryHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 3:
			case 11:
				break;
			case 12:
				line.append(field.getDelimiter());
				break;
			default:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
						line.append(String.valueOf(pagination));
					} else {
						line.append(getGlobalFieldValue(rgm, field));
					}
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.writeBodyHeader()");
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

	private void writeSummaryBodyHeader(ReportGenerationMgr rgm, String filterType) throws IOException, JSONException {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.writeSummaryBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 37:
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
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 48:
				if (filterType.equalsIgnoreCase("retail")) {
					line.append(getEol());
					break;
				}
			case 49:
			case 50:
			case 51:
			case 52:
			case 53:
			case 54:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 55:
				if (filterType.equalsIgnoreCase("retail")) {
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				}
				break;
			default:
				break;
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
			switch (field.getSequence()) {
			case 25:
			case 26:
			case 27:
			case 28:
			case 29:
			case 30:
			case 31:
			case 32:
			case 33:
			case 34:
			case 35:
			case 36:
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
	protected void writeSummaryBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String filterType)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 56:
			case 57:
			case 58:
			case 59:
			case 60:
			case 61:
				switch (field.getFieldName()) {
				case ReportConstants.AMOUNT:
					line.append(getFieldValue(rgm, field, fieldsMap) + " DR");
					break;
				case ReportConstants.ISSUER_EXPENSE:
					line.append("(" + getFieldValue(rgm, field, fieldsMap) + ")");
					break;
				default:
					line.append(getFieldValue(rgm, field, fieldsMap));
					break;
				}
				line.append(field.getDelimiter());
				break;
			case 62:
				if (filterType.equalsIgnoreCase("corporate")) {
					line.append(getFieldValue(rgm, field, fieldsMap));
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

	@Override
	protected void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
				break;
			default:
				if (field.isEol()) {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}
