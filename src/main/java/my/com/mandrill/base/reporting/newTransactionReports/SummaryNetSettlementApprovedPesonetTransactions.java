package my.com.mandrill.base.reporting.newTransactionReports;

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
import java.util.SortedMap;
import java.util.TreeMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class SummaryNetSettlementApprovedPesonetTransactions extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(SummaryNetSettlementApprovedPesonetTransactions.class);
	public static final String SUBSTRING_START_ISSUING = "START ISSUING";
	public static final String SUBSTRING_END_ISSUING = "END ISSUING";
	private int pagination = 0;
	private int transmittingCount = 0;
	private double transmittingTotal = 0.00;
	private double overallTransmittingTotal = 0.00;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		boolean issuing = false;
		SortedMap<String, String> bankCodesMap = new TreeMap<>();
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm, pagination);
			StringBuilder line = new StringBuilder();
			line.append("REFERENCE BANK: ").append(";").append("CHINA BANK").append(";");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			writeBodyHeader(rgm);

			preProcessing(rgm, "issuing");
			for (SortedMap.Entry<String, String> bankCodeMap : filterCriteriaByBank(rgm).entrySet()) {
				bankCodesMap.put(bankCodeMap.getValue(), bankCodeMap.getKey());
			}

			for (SortedMap.Entry<String, String> allBankCodesMap : bankCodesMap.entrySet()) {
				preProcessing(rgm, "issuing");
				for (SortedMap.Entry<String, String> bankCodeMap : filterCriteriaByBank(rgm).entrySet()) {
					if (bankCodeMap.getKey().equals(allBankCodesMap.getValue())) {
						issuing = true;
					}
				}

				if (issuing) {
					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, String> bankCodeMap : filterCriteriaByBank(rgm).entrySet()) {
						if (bankCodeMap.getKey().equals(allBankCodesMap.getValue())) {
							transmittingTotal = 0.00;
							ReportGenerationFields bankCode = new ReportGenerationFields(
									ReportConstants.PARAM_BANK_CODE, ReportGenerationFields.TYPE_STRING,
									"LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD('" + allBankCodesMap.getValue()
											+ "', 10, '0')");
							getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
							rgm.setBodyQuery(getIssuingBodyQuery());
							executeBodyQuery(rgm, allBankCodesMap.getValue());
						}
					}
				}

			}

			writeTrailer(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
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
		logger.debug("In SummaryNetSettlementApprovedPesonetTransactions.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setIssuingBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(SUBSTRING_START_ISSUING) + 13,
					rgm.getBodyQuery().indexOf(SUBSTRING_END_ISSUING)));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String indicator) {
		logger.debug("In SummaryNetSettlementApprovedPesonetTransactions.preProcessing()");
		if (indicator.equalsIgnoreCase("issuing")) {
			rgm.setBodyQuery(getIssuingBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", ""));
		} 
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In SummaryNetSettlementApprovedPesonetTransactions.writeBodyHeader()");
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
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String filterByBankCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TRANSMITTING_COUNT:
				if (filterByBankCode != null) {
					ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
							ReportGenerationFields.TYPE_STRING,
							"LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = LPAD('" + filterByBankCode + "', 10, '0')");
					getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
				}

				rgm.setBodyQuery(getIssuingBodyQuery());
				fieldsMap.get(field.getFieldName())
						.setValue(executeQuery(rgm, ReportConstants.TRANSMITTING_COUNT, null));
				line.append(getFieldValue(rgm, field, fieldsMap));
				transmittingCount += Integer.parseInt(getFieldValue(field, fieldsMap));
				break;
			case ReportConstants.TRANSMITTING_TOTAL:
				fieldsMap.get(field.getFieldName())
						.setValue(executeQuery(rgm, null, ReportConstants.TRANSMITTING_TOTAL));
				line.append(getFieldValue(rgm, field, fieldsMap) + " DR");

				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					transmittingTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					transmittingTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				overallTransmittingTotal += transmittingTotal;
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			}
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeTrailer(ReportGenerationMgr rgm)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In SummaryNetSettlementApprovedPesonetTransactions.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TRANSMITTING_COUNT:
				line.append(transmittingCount);
				line.append(field.getDelimiter());
				break;
			case ReportConstants.TRANSMITTING_TOTAL:
				line.append(formatter.format(overallTransmittingTotal) + " DR");
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

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm, String bankCode) {
		logger.debug("In SummaryNetSettlementApprovedPesonetTransactions.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

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
					writeBody(rgm, lineFieldsMap, bankCode);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanUpDbResource(ps, rs);
			}
		}
	}

	private String executeQuery(ReportGenerationMgr rgm, String count, String total) {
		logger.debug("In SummaryNetSettlementApprovedPesonetTransactions.executeQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = getBodyQuery(rgm);
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.getConnection().prepareStatement(query);
			rs = ps.executeQuery();

			while (rs.next()) {
				if (count != null) {
					return rs.getObject(count).toString();
				}
				if (total != null) {
					return rs.getObject(total).toString();
				}
			}
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Error trying to execute the body query", e);
		} finally {
			rgm.cleanUpDbResource(ps, rs);
		}
		return "0";
	}
}
