package my.com.mandrill.base.reporting.eloadTransactions;

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

public class ApprovedEloadIssuerTransactions extends IbftReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ApprovedEloadIssuerTransactions.class);
	private int pagination = 0;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String bankCode = null;
		String bankName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			separateQuery(rgm);
			preProcessing(rgm, bankCode);

			pagination++;
			writeHeader(rgm, pagination);
			for (SortedMap.Entry<String, String> bankCodeMap : filterByCriteriaByBank(rgm).entrySet()) {
				bankCode = bankCodeMap.getKey();
				bankName = bankCodeMap.getValue();
				preProcessing(rgm, bankCode);
				processingDetails(rgm, bankCode, bankName);
			}

			pagination++;
			writeSummaryHeader(rgm, pagination);
			processingSummaryDetails(rgm);

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

	private void processingDetails(ReportGenerationMgr rgm, String bankCode, String bankName) {
		logger.debug("In ApprovedEloadIssuerTransactions.processingDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("ACQUIRER BANK : ").append(bankCode + "  ").append(bankName).append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);
			rgm.setBodyQuery(getIbftBodyQuery());
			executeBodyQuery(rgm, false);
			rgm.setTrailerQuery(getIbftTrailerQuery());
			executeTrailerQuery(rgm, false);
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in processingDetails", e);
		}
	}

	private void processingSummaryDetails(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedIbftTransactionsTransmittingBank.processingSummaryDetails()");
		try {
			preProcessing(rgm, null);
			writeSummaryBodyHeader(rgm);
			rgm.setBodyQuery(getSummaryBodyQuery());
			executeBodyQuery(rgm, true);
			rgm.setTrailerQuery(getSummaryTrailerQuery());
			executeTrailerQuery(rgm, true);
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in processingSummaryDetails", e);
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

	private void preProcessing(ReportGenerationMgr rgm, String filterByBankCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ApprovedEloadIssuerTransactions.preProcessing()");
		if (filterByBankCode != null) {
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING,
					"LPAD(TXN.TRL_ACQR_INST_ID, 4, '0') = '" + filterByBankCode + "'");
			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In ApprovedEloadIssuerTransactions.writeBodyHeader()");
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
					line.append(getGlobalFieldValue(field, true));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(field, true));
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
		logger.debug("In ApprovedEloadIssuerTransactions.writeSummaryBodyHeader()");
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
				if (field.isEol()) {
					line.append(getGlobalFieldValue(field, true));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(field, true));
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
				switch (field.getFieldName()) {
				case ReportConstants.ATM_CARD_NUMBER:
					if (getFieldValue(field, fieldsMap, true).length() <= 19) {
						line.append(String.format("%1$" + 19 + "s", getFieldValue(field, fieldsMap, true)).replace(' ',
								'0'));
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
					}
					line.append(field.getDelimiter());
					break;
				case ReportConstants.SEQ_NUMBER:
				case ReportConstants.TRACE_NUMBER:
					if (getFieldValue(field, fieldsMap, true).length() <= 6) {
						line.append(String.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ',
								'0'));
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
					}
					line.append(field.getDelimiter());
					break;
				case ReportConstants.FROM_ACCOUNT_NO:
				case ReportConstants.TO_ACCOUNT_NO:
					if (getFieldValue(field, fieldsMap, true).length() <= 16) {
						line.append(String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ',
								'0'));
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
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeSummaryBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 45:
			case 46:
			case 47:
			case 48:
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
					line.append(getFieldValue(field, fieldsMap, true) + " DR");
				} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
					line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					line.append("");
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
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
	protected void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In ApprovedEloadIssuerTransactions.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 12:
			case 13:
			case 14:
			case 15:
				break;
			default:
				if (field.isEol()) {
					if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
						line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						line.append("");
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
					}
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
						line.append(getFieldValue(field, fieldsMap, true) + " DR");
					} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
						line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						line.append("");
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
					}
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
		logger.debug("In ApprovedEloadIssuerTransactions.writeSummaryTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 12:
			case 13:
			case 14:
			case 15:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AMOUNT)) {
						line.append(getFieldValue(field, fieldsMap, true) + " DR");
					} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
						line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						line.append("");
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
					}
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
						line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						line.append("");
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
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
}