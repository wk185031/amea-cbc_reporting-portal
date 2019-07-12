package my.com.mandrill.base.reporting.posTransactions;

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
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class PosTransactionsCardholderBranch extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(PosTransactionsCardholderBranch.class);
	private int pagination = 0;
	private int txnCount = 0;
	private double total = 0.00;
	private double totalCommission = 0.00;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String branchCode = null;
		String branchName = null;
		String merchantName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			for (SortedMap.Entry<String, Map<String, Map<String, TreeSet<String>>>> branchCodeMap : filterByBranch(rgm)
					.entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, Map<String, TreeSet<String>>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					pagination++;
					writeHeader(rgm, pagination, branchCode, branchName);
					for (SortedMap.Entry<String, TreeSet<String>> merchantMap : branchNameMap.getValue().entrySet()) {
						merchantName = merchantMap.getKey();
						for (String customData : merchantMap.getValue()) {
							txnCount = 0;
							total = 0.00;
							totalCommission = 0.00;
							preProcessing(rgm, branchCode, merchantName);
							writeBodyHeader(rgm);
							executeBodyQuery(rgm, customData);
							executeTrailerQuery(rgm, customData);
							writeMerchantTotal(rgm, merchantName, txnCount, total, totalCommission);
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

	private SortedMap<String, Map<String, Map<String, TreeSet<String>>>> filterByBranch(ReportGenerationMgr rgm) {
		logger.debug("In PosTransactionsCardholderBranch.filterByBranch()");
		String branchCode = null;
		String branchName = null;
		String merchantName = null;
		String customData = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, Map<String, TreeSet<String>>>> criteriaMap = new TreeMap<>();
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
							if (key.equalsIgnoreCase(ReportConstants.MERCHANT_NAME)) {
								merchantName = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.CUSTOM_DATA)) {
								customData = result.toString();
							}
						}
					}
					if (criteriaMap.get(branchCode) == null) {
						Map<String, Map<String, TreeSet<String>>> branchNameMap = new HashMap<>();
						Map<String, TreeSet<String>> merchantMap = new HashMap<>();
						TreeSet<String> customDataList = new TreeSet<>();
						customDataList.add(customData);
						merchantMap.put(merchantName, customDataList);
						branchNameMap.put(branchName, merchantMap);
						criteriaMap.put(branchCode, branchNameMap);
					} else {
						Map<String, Map<String, TreeSet<String>>> branchNameMap = criteriaMap.get(branchCode);
						if (branchNameMap.get(branchName) == null) {
							Map<String, TreeSet<String>> merchantMap = new HashMap<>();
							TreeSet<String> customDataList = new TreeSet<>();
							customDataList.add(customData);
							merchantMap.put(merchantName, customDataList);
							branchNameMap.put(branchName, merchantMap);
						} else {
							Map<String, TreeSet<String>> merchantMap = branchNameMap.get(branchName);
							if (merchantMap.get(merchantName) == null) {
								TreeSet<String> customDataList = new TreeSet<>();
								customDataList.add(customData);
								merchantMap.put(merchantName, customDataList);
							} else {
								Set<String> customDataList = merchantMap.get(merchantName);
								customDataList.add(customData);
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
		logger.debug("In PosTransactionsCardholderBranch.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_MERCHANT + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByMerchantName)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In PosTransactionsCardholderBranch.preProcessing()");
		rgm.setBodyQuery(rgm.getTmpBodyQuery());
		if (filterByBranchCode != null && filterByMerchantName != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(BRC.BRC_CODE) = '" + filterByBranchCode + "'");
			ReportGenerationFields merchant = new ReportGenerationFields(ReportConstants.PARAM_MERCHANT,
					ReportGenerationFields.TYPE_STRING, "TRIM(MER.MER_NAME) = '" + filterByMerchantName + "'");

			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			getGlobalFileFieldsMap().put(merchant.getFieldName(), merchant);
		}
	}

	private void writeMerchantTotal(ReportGenerationMgr rgm, String merchantName, int txnCount, double total,
			double totalCommission) throws IOException {
		logger.debug("In PosTransactionsCardholderBranch.writeMerchantTotal()");
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		StringBuilder line = new StringBuilder();
		line.append(";").append(";").append(";").append(";").append(";").append("NET : ").append(";")
				.append(String.format("%,d", txnCount)).append(";").append(formatter.format(total)).append(";")
				.append(formatter.format(totalCommission)).append(";");
		line.append(getEol());
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In PosTransactionsCardholderBranch.writeBodyHeader()");
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
			String customData)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		double txnAmt = 0.00;
		double commission = 0.00;
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					txnAmt = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
					total += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					txnAmt = Double.parseDouble(getFieldValue(field, fieldsMap));
					total += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}

			switch (field.getFieldName()) {
			case ReportConstants.POS_COMMISSION:
				DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
				if (extractCommission(customData) != null && extractCommission(customData).trim().length() > 0) {
					commission = Double.parseDouble(extractCommission(customData));
					commission = txnAmt * commission / 100;
					totalCommission += commission;
					line.append(formatter.format(commission));
				} else {
					totalCommission += commission;
					line.append(formatter.format(commission));
				}
				line.append(field.getDelimiter());
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String customData)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In PosTransactionsCardholderBranch.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		double txnAmt = 0.00;
		double revTxnAmt = 0.00;
		double commission = 0.00;
		double revCommission = 0.00;
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TRAN_COUNT:
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					txnCount += Integer.parseInt(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					txnCount += Integer.parseInt(getFieldValue(field, fieldsMap));
				}
				line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap))));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.REV_TRAN_COUNT:
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					txnCount += Integer.parseInt(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					txnCount += Integer.parseInt(getFieldValue(field, fieldsMap));
				}
				line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap))));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.AMOUNT:
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					txnAmt = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
					total += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					txnAmt = Double.parseDouble(getFieldValue(field, fieldsMap));
					total += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				line.append(getFieldValue(field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.REV_AMOUNT:
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					revTxnAmt = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
					total += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					revTxnAmt = Double.parseDouble(getFieldValue(field, fieldsMap));
					total += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				line.append("(" + getFieldValue(field, fieldsMap) + ")");
				line.append(field.getDelimiter());
				break;
			case ReportConstants.POS_COMMISSION:
				DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
				if (extractCommission(customData) != null && extractCommission(customData).trim().length() > 0) {
					commission = Double.parseDouble(extractCommission(customData));
					commission = txnAmt * commission / 100;
					totalCommission += commission;
					line.append(formatter.format(commission));
				} else {
					totalCommission += commission;
					line.append(formatter.format(commission));
				}
				line.append(field.getDelimiter());
				line.append(getEol());
				break;
			case ReportConstants.POS_REV_COMMISSION:
				DecimalFormat revFormatter = new DecimalFormat(field.getFieldFormat());
				if (extractCommission(customData) != null && extractCommission(customData).trim().length() > 0) {
					revCommission = Double.parseDouble(extractCommission(customData));
					revCommission = revTxnAmt * revCommission / 100;
					totalCommission += revCommission;
					line.append("(" + revFormatter.format(revCommission) + ")");
				} else {
					totalCommission += revCommission;
					line.append("(" + revFormatter.format(revCommission) + ")");
				}
				line.append(field.getDelimiter());
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void executeTrailerQuery(ReportGenerationMgr rgm, String customData) {
		logger.debug("In PosTransactionsCardholderBranch.executeTrailerQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

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
					writeTrailer(rgm, lineFieldsMap, customData);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
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

	private String extractCommission(String customData) {
		Pattern pattern = Pattern.compile("<([^<>]+)>([^<>]+)</\\1>");
		Matcher matcher = pattern.matcher(customData);
		Map<String, String> map = new HashMap<>();

		while (matcher.find()) {
			String xmlElem = matcher.group();
			String key = xmlElem.substring(1, xmlElem.indexOf('>'));
			String value = xmlElem.substring(xmlElem.indexOf('>') + 1, xmlElem.lastIndexOf('<'));
			map.put(key, value);
			if (map.get(ReportConstants.COMMISSION) != null) {
				return map.get(ReportConstants.COMMISSION);
			}
		}
		return "";
	}
}
