package my.com.mandrill.base.reporting.newTransactionReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.IbftReportProcessor;

public class ApprovedPesonetTransactionsTransmittingBank extends IbftReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ApprovedPesonetTransactionsTransmittingBank.class);
	private int pagination = 0;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String channel = null;
		String bankCode = null;
		String bankName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);

			pagination++;
			writeHeader(rgm, pagination);
			rgm.setBodyQuery(getCriteriaQuery());
			for (SortedMap.Entry<String, TreeMap<String, String>> channelMap : filterByChannel(rgm).entrySet()) {
				channel = channelMap.getKey();
				StringBuilder line = new StringBuilder();
				line.append(ReportConstants.CHANNEL + " : ").append(";").append(channel).append(";");
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
				for (SortedMap.Entry<String, String> bankCodeMap : channelMap.getValue().entrySet()) {
					bankCode = bankCodeMap.getKey();
					bankName = bankCodeMap.getValue();
					processingDetails(rgm, channel, bankCode, bankName);
				}
			}

			pagination++;
			writeSummaryHeader(rgm, pagination);
			bankSummaryDetails(rgm);
			channelSummaryDetails(rgm);

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

	private void processingDetails(ReportGenerationMgr rgm, String channel, String bankCode, String bankName) {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.processingDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("RECEIVING BANK : ").append(";").append(bankCode + "  ").append(";").append(bankName)
					.append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			preProcessing(rgm, channel, bankCode);
			writeBodyHeader(rgm);
			rgm.setBodyQuery(getTxnBodyQuery());
			rgm.setTrailerQuery(getTxnTrailerQuery());
			executeBodyQuery(rgm, false);
			executeTrailerQuery(rgm, false);
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in processingDetails", e);
		}
	}

	private void bankSummaryDetails(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.bankSummaryDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("PER BANK SUMMARY TRANSACTIONS");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			preProcessing(rgm, true);
			writeSummaryBodyHeader(rgm, true);
			rgm.setBodyQuery(getSummaryBodyQuery());
			rgm.setTrailerQuery(getSummaryTrailerQuery());
			executeBodyQuery(rgm, true, true);
			executeTrailerQuery(rgm, true);
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in bankSummaryDetails", e);
		}
	}

	private void channelSummaryDetails(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.channelSummaryDetails()");
		try {
			StringBuilder line = new StringBuilder();
			line.append("PER CHANNEL SUMMARY TRANSACTIONS");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			preProcessing(rgm, false);
			writeSummaryBodyHeader(rgm, false);
			rgm.setBodyQuery(getSummaryBodyQuery());
			rgm.setTrailerQuery(getSummaryTrailerQuery());
			executeBodyQuery(rgm, true, false);
			executeTrailerQuery(rgm, true);
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in channelSummaryDetails", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setTxnBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setSummaryBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCriteriaQuery(getTxnBodyQuery().replace("AND {" + ReportConstants.PARAM_CHANNEL + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", ""));
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

	private void preProcessing(ReportGenerationMgr rgm, String filterByChannel, String filterByBankCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.preProcessing()");
		if (filterByChannel != null) {
			ReportGenerationFields channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXNC.TRL_ORIGIN_CHANNEL = '" + filterByChannel + "'");
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
		}

		if (filterByBankCode != null) {
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING,
					"LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD('" + filterByBankCode + "', 10, '0')");
			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, boolean indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.preProcessing()");
		if (indicator) {
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING, "\"BANK CODE\", \"BANK NAME\",");
			ReportGenerationFields channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"(SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"BANK CODE\", (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD(CBA_CODE, 10, '0')) AS \"BANK NAME\",");
			ReportGenerationFields grouping = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"GROUP BY \"BANK CODE\", \"BANK NAME\" ORDER BY \"BANK CODE\" ASC");

			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
			getGlobalFileFieldsMap().put(grouping.getFieldName(), grouping);
		} else {
			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING, "\"CHANNEL\",");
			ReportGenerationFields channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXNC.TRL_ORIGIN_CHANNEL \"CHANNEL\",");
			ReportGenerationFields grouping = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "GROUP BY \"CHANNEL\" ORDER BY \"CHANNEL\" ASC");

			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
			getGlobalFileFieldsMap().put(grouping.getFieldName(), grouping);
		}
	}

	@Override
	protected void writeHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.writeRetailHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 4:
			case 16:
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
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.writeSummaryHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 3:
			case 15:
				break;
			case 16:
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
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.writeBodyHeader()");
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
			case 25:
			case 26:
			case 27:
			case 28:
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

	private void writeSummaryBodyHeader(ReportGenerationMgr rgm, boolean indicator) throws IOException, JSONException {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.writeSummaryBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 37:
			case 38:
			case 39:
			case 40:
			case 41:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 42:
				if (indicator) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 43:
				if (!indicator) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 44:
			case 45:
			case 46:
			case 47:
			case 48:
				if (field.isEol()) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 49:
				if (indicator) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 50:
				if (!indicator) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
					line.append(field.getDelimiter());
				}
				break;
			case 51:
				if (indicator) {
					line.append(getGlobalFieldValue(rgm, field));
					line.append(field.getDelimiter());
				}
				break;
			case 52:
			case 53:
			case 54:
			case 55:
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

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
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

	private void writeSummaryBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			boolean indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 56:
			case 57:
				if (indicator) {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
				}
				break;
			case 58:
				if (!indicator) {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
					line.append(field.getDelimiter());
				}
				break;
			case 59:
			case 60:
			case 61:
			case 62:
				switch (field.getFieldName()) {
				case ReportConstants.AMOUNT:
					line.append(getFieldValue(rgm, field, fieldsMap) + " DR");
					break;
				case ReportConstants.BANCNET_FEE:
					line.append("(" + getFieldValue(rgm, field, fieldsMap) + ")");
					break;
				default:
					line.append(getFieldValue(rgm, field, fieldsMap));
					break;
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
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.writeTrailer()");
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

	@Override
	protected void writeSummaryTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.writeSummaryTrailer()");
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
				switch (field.getFieldName()) {
				case ReportConstants.TOTAL_AMOUNT:
					line.append(getFieldValue(rgm, field, fieldsMap) + " DR");
					line.append(field.getDelimiter());
					break;
				case ReportConstants.BANCNET_FEE:
					line.append("(" + getFieldValue(rgm, field, fieldsMap) + ")");
					line.append(field.getDelimiter());
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
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void executeBodyQuery(ReportGenerationMgr rgm, boolean summary, boolean indicator) {
		logger.debug("In ApprovedPesonetTransactionsTransmittingBank.executeBodyQuery()");
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
					if (summary) {
						writeSummaryBody(rgm, lineFieldsMap, indicator);
					} else {
						writeBody(rgm, lineFieldsMap);
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
		}
	}
}
