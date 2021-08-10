package my.com.mandrill.base.reporting.posTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
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
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class PosApprovedTransactions extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(PosApprovedTransactions.class);
	private int pagination = 0;
	private int txnCount = 0;
	private double total = 0.00;
	private double totalCommission = 0.00;
	private double totalNetSettAmt = 0.00;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String bankCode = null;
		String bankName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination++;
			preProcessing(rgm);
			writeHeader(rgm, pagination);
			for (SortedMap.Entry<String, String> bankMap : filterByBank(rgm).entrySet()) {
				bankCode = bankMap.getKey();
				bankName = bankMap.getValue();
				txnCount = 0;
				total = 0.00;
				totalCommission = 0.00;
				totalNetSettAmt = 0.00;
				preProcessing(rgm, bankCode);
				writeMerchantHeader(rgm, bankCode, bankName);
				writeBodyHeader(rgm);
				executeBodyQuery(rgm, bankCode);
				writeMerchantTotal(rgm, txnCount, total, totalCommission, totalNetSettAmt);
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

	private SortedMap<String, String> filterByBank(ReportGenerationMgr rgm) {
		logger.debug("In PosApprovedTransactions.filterByBank()");
		String bankCode = null;
		String bankName = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter bank: {}", query);

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
						}
					}
					if (bankCode == null) {
						criteriaMap.put("-", "-");
					} else {
						criteriaMap.put(bankCode, bankName);
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
		logger.debug("In PosApprovedTransactions.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBankCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In PosApprovedTransactions.preProcessing()");
		if (filterByBankCode != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields merchant = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
					ReportGenerationFields.TYPE_STRING, "CBA_CODE = '" + filterByBankCode + "'");
			getGlobalFileFieldsMap().put(merchant.getFieldName(), merchant);
		}
	}

	private void writeMerchantHeader(ReportGenerationMgr rgm, String bankCode, String bankName)
			throws IOException {
		logger.debug("In PosApprovedTransactions.writeMerchantHeader()");
		StringBuilder line = new StringBuilder();
		line.append("BANK NAME : ").append(";").append(bankCode).append(" ").append(bankName).append(";").append("COMMISSION : ").append(";")
				.append("30%").append(";");
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeMerchantTotal(ReportGenerationMgr rgm, int txnCount, double total, double totalCommission,
			double totalNetSettAmt) throws IOException {
		logger.debug("In PosApprovedTransactions.writeMerchantTotal()");
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		StringBuilder line = new StringBuilder();
		line.append(";").append(";").append(";").append(";").append(";").append(";").append("TOTAL : ").append(";")
				.append(String.format("%,d", txnCount)).append(";").append(formatter.format(total)).append(";")
				.append(formatter.format(totalCommission)).append(";").append(formatter.format(totalNetSettAmt))
				.append(";");
		line.append(getEol());
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In PosApprovedTransactions.writeBodyHeader()");
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
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String bankCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		double txnAmt = 0.00;
		double commission = 0.00;
		double netSettAmt = 0.00;
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					txnAmt = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
					total += txnAmt;
				} else {
					txnAmt = Double.parseDouble(getFieldValue(field, fieldsMap));
					total += txnAmt;
				}
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.POS_COMMISSION)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					commission = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
					totalCommission += commission;
				} else {
					commission = Double.parseDouble(getFieldValue(field, fieldsMap));
					totalCommission += commission;
				}
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.POS_NET_SETT_AMT)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					netSettAmt = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
					totalNetSettAmt += netSettAmt;
				} else {
					netSettAmt = Double.parseDouble(getFieldValue(field, fieldsMap));
					totalNetSettAmt += netSettAmt;
				}
			}

			line.append(getFieldValue(rgm, field, fieldsMap));
			line.append(field.getDelimiter());
		}
		txnCount++;
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

//	private String extractCommission(String customData) {
//		if (customData != null) {
//			Pattern pattern = Pattern.compile("<([^<>]+)>([^<>]+)</\\1>");
//			Matcher matcher = pattern.matcher(customData);
//			Map<String, String> map = new HashMap<>();
//
//			while (matcher.find()) {
//				String xmlElem = matcher.group();
//				String key = xmlElem.substring(1, xmlElem.indexOf('>'));
//				String value = xmlElem.substring(xmlElem.indexOf('>') + 1, xmlElem.lastIndexOf('<'));
//				map.put(key, value);
//				if (map.get(ReportConstants.COMMISSION) != null) {
//					return map.get(ReportConstants.COMMISSION);
//				}
//			}
//		}
//		return "";
//	}

//	private String extractDepositoryBank(String customData) {
//		if (customData != null) {
//			Pattern pattern = Pattern.compile("<([^<>]+)>([^<>]+)</\\1>");
//			Matcher matcher = pattern.matcher(customData);
//			Map<String, String> map = new HashMap<>();
//
//			while (matcher.find()) {
//				String xmlElem = matcher.group();
//				String key = xmlElem.substring(1, xmlElem.indexOf('>'));
//				String value = xmlElem.substring(xmlElem.indexOf('>') + 1, xmlElem.lastIndexOf('<'));
//				map.put(key, value);
//				if (map.get(ReportConstants.DEPOSITORY_BANK) != null) {
//					return map.get(ReportConstants.DEPOSITORY_BANK);
//				}
//			}
//		}
//		
//		return "";
//	}
}
