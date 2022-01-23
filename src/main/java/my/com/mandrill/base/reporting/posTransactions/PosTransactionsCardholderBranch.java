package my.com.mandrill.base.reporting.posTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;
import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.domain.Amount;
import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.domain.builder.AmountBuilder;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class PosTransactionsCardholderBranch extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(PosTransactionsCardholderBranch.class);
	private int pagination = 0;
	private int txnCount = 0;
	private double totalAmount = 0.00;
	private double totalCommission = 0.00;
	private static final String DEFAULT_SEPARATOR = ";";
	private static final String LINE_ITEM_PURCHASE = "PURCHASES";
	private static final String LINE_ITEM_REVERSAL = "REVERSALS";
	private static final String LINE_ITEM_NET = "NET";

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String branchCode = null;
		String branchName = null;
		String bankCode = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);

			ResultSet rs = null;
			PreparedStatement ps = null;

//			writeHeader(rgm, pagination, branchCode == null ? "" : branchCode, branchName == null ? "" : branchName);

			preProcessing(rgm);
			SortedMap<String, Map<String, TreeSet<String>>> branchList = filterByBranches(rgm);

			if (branchList == null || branchList.isEmpty()) {
				StringBuilder line = new StringBuilder();
				line.append(ReportConstants.NO_RECORD);
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
			} else {
				for (Entry<String, Map<String, TreeSet<String>>> branchCodeMap : branchList.entrySet()) {
					branchCode = branchCodeMap.getKey();
					for (Entry<String, TreeSet<String>> branchNameMap : branchCodeMap.getValue().entrySet()) {
						branchName = branchNameMap.getKey();
						pagination++;
						writeHeader(rgm, pagination, branchCode, branchName);
//						writeBodyHeader(rgm);

						for (String bankName : branchNameMap.getValue()) {

							txnCount = 0;
							totalAmount = 0.00;
							totalCommission = 0.00;
							preProcessing(rgm, branchCode);

							executeBodyQuery(rgm, bankCode);

							Map<String, LineItem> summaryItemMap = new HashMap<String, PosTransactionsCardholderBranch.LineItem>();
							summaryItemMap.put(LINE_ITEM_PURCHASE, new LineItem(LINE_ITEM_PURCHASE));
							summaryItemMap.put(LINE_ITEM_REVERSAL, new LineItem(LINE_ITEM_REVERSAL));
							summaryItemMap.put(LINE_ITEM_NET, new LineItem(LINE_ITEM_NET));

							executeTrailerQuery(rgm, bankCode, summaryItemMap);
							int purchaseCount = summaryItemMap.get(LINE_ITEM_PURCHASE).getCount();
							int peversalCount = summaryItemMap.get(LINE_ITEM_REVERSAL).getCount();
							if (purchaseCount!=0 ||peversalCount!=0 ) {
							summaryItemMap.get(LINE_ITEM_NET).setCount(purchaseCount-peversalCount);
							}
							
							writeLineItem(rgm, bankName, summaryItemMap.get(LINE_ITEM_PURCHASE));
							writeLineItem(rgm, null, summaryItemMap.get(LINE_ITEM_REVERSAL));
							writeLineItem(rgm, null, summaryItemMap.get(LINE_ITEM_NET));
							rgm.writeLine(getEol().getBytes());
							// writeMerchantTotal(rgm, merchantName, txnCount, totalAmount,
							// totalCommission);
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

	private SortedMap<String, Map<String, TreeSet<String>>> filterByBranches(ReportGenerationMgr rgm) {
		logger.debug("In PosTransactionsCardholderBranch.filterByBranches()");
		String branchCode = null;
		String branchName = null;
		String bankName = null;
		// String customData = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, TreeSet<String>>> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter criteria: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
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
							if (key.equalsIgnoreCase(ReportConstants.BANK_NAME)) {
								bankName = result.toString();
							}
//							if (key.equalsIgnoreCase(ReportConstants.CUSTOM_DATA)) {
//								customData = result.toString();
//							}
						}
					}
					if (criteriaMap.get(branchCode) == null) {
						Map<String, TreeSet<String>> branchNameMap = new HashMap<>();
						TreeSet<String> bankcodeList = new TreeSet<>();
						if (bankcodeList != null) {
							bankcodeList.add(bankName);
						}
						branchNameMap.put(branchName, bankcodeList);
						criteriaMap.put(branchCode, branchNameMap);
					}
//					if (criteriaMap.get(branchCode) == null) {
//						Map<String, Map<String, TreeSet<String>>> branchNameMap = new HashMap<>();
//						Map<String, TreeSet<String>> merchantMap = new HashMap<>();
//						TreeSet<String> customDataList = new TreeSet<>();
//						if (customData != null) {
//							customDataList.add(customData);
//						}
//						merchantMap.put(merchantName, customDataList);
//
//						branchNameMap.put(branchName, merchantMap);
//						criteriaMap.put(branchCode, branchNameMap);
//					} else {
//						Map<String, Map<String, TreeSet<String>>> branchNameMap = criteriaMap.get(branchCode);
//						if (branchNameMap.get(branchName) == null) {
//							Map<String, TreeSet<String>> merchantMap = new HashMap<>();
//							TreeSet<String> customDataList = new TreeSet<>();
//							if (customData != null) {
//								customDataList.add(customData);
//							}
//								merchantMap.put(merchantName, customDataList);	
//							branchNameMap.put(branchName, merchantMap);
//						} else {
//							Map<String, TreeSet<String>> merchantMap = branchNameMap.get(branchName);
//							if (customData != null) {
//								if (merchantMap.get(merchantName) == null) {
//									TreeSet<String> customDataList = new TreeSet<>();
//									customDataList.add(customData);
//									merchantMap.put(merchantName, customDataList);
//								} else {
//									Set<String> customDataList = merchantMap.get(merchantName);
//									customDataList.add(customData);
//								}
//							}
//							
//						}
//					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the criteria", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
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
					.replace("AND {" + ReportConstants.PARAM_BANK_CODE + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In PosTransactionsCardholderBranch.preProcessing()");
		rgm.setBodyQuery(rgm.getTmpBodyQuery());
		if (filterByBranchCode != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "BRC.BRC_CODE = '" + filterByBranchCode + "'");
//			ReportGenerationFields bankCode = new ReportGenerationFields(ReportConstants.PARAM_BANK_CODE,
//					ReportGenerationFields.TYPE_STRING, "CBA_CODE = '" + filterByBankCode + "'");

			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
//			getGlobalFileFieldsMap().put(bankCode.getFieldName(), bankCode);
		}
	}

	private void writeLineItem(ReportGenerationMgr rgm, String merchantName, LineItem item) throws IOException {
		StringBuilder line = new StringBuilder();
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		line.append(DEFAULT_SEPARATOR).append(DEFAULT_SEPARATOR);
		 BigDecimal C30 = new BigDecimal("0.3");
		if (merchantName != null) {
			line.append(merchantName);
		}

		line.append(DEFAULT_SEPARATOR).append(DEFAULT_SEPARATOR).append(DEFAULT_SEPARATOR).append(item.getName())
				.append(DEFAULT_SEPARATOR).append(String.format("%,d", item.getCount())).append(DEFAULT_SEPARATOR);

		if (LINE_ITEM_REVERSAL.equals(item.getName())) {
			line.append("(" + formatter.format(item.getTxnAmount().getValue()) + ")").append(DEFAULT_SEPARATOR)
					.append("(" + formatter.format(item.getTxnAmount().getValue().multiply(C30)) + ")").append(DEFAULT_SEPARATOR);
		} else {
			line.append(StringUtils.wrap(formatter.format(item.getTxnAmount().getValue()), "\""))
					.append(DEFAULT_SEPARATOR)
					.append(StringUtils.wrap(formatter.format(item.getTxnAmount().getValue().multiply(C30)), "\""))
					.append(DEFAULT_SEPARATOR);
		}

		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeMerchantTotal(ReportGenerationMgr rgm, String merchantName, int txnCount, double total,
			double totalCommission) throws IOException {
		logger.debug("In PosTransactionsCardholderBranch.writeMerchantTotal()");
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		StringBuilder line = new StringBuilder();
		line.append(DEFAULT_SEPARATOR).append(DEFAULT_SEPARATOR).append(DEFAULT_SEPARATOR).append(DEFAULT_SEPARATOR)
				.append(DEFAULT_SEPARATOR).append("NET : ").append(DEFAULT_SEPARATOR)
				.append(String.format("%,d", txnCount)).append(DEFAULT_SEPARATOR).append(formatter.format(total))
				.append(DEFAULT_SEPARATOR).append(formatter.format(totalCommission)).append(DEFAULT_SEPARATOR);
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
		Amount txnAmount = null;

		String qualifier = fieldsMap.get(ReportConstants.TXN_QUALIFIER).getValue();

		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			switch (field.getFieldName()) {
			case ReportConstants.AMOUNT:
				txnAmount = new AmountBuilder(getFieldValue(field, fieldsMap)).build();

				String formattedAmount = txnAmount.format(field.getFieldFormat());
				if ("R".equals(qualifier)) {
					formattedAmount = "(" + formattedAmount + ")";
				}
				line.append(StringUtils.wrap(formattedAmount, "\""));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.POS_COMMISSION_AMOUNT:
				BigDecimal commission = txnAmount.calculateFee(extractCommission(customData));
				String formattedCommission = new DecimalFormat(field.getFieldFormat()).format(commission);
				if ("R".equals(qualifier)) {
					formattedCommission = "(" + formattedCommission + ")";
				}
				line.append(StringUtils.wrap(formattedCommission, "\""));
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
			String customData, Map<String, LineItem> summaryItemMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In PosTransactionsCardholderBranch.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		Amount txnAmt = null;
		Amount revTxnAmt = null;
		Amount txnAmount = null;

		BigDecimal commission = BigDecimal.ZERO;
		BigDecimal revCommission = BigDecimal.ZERO;
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TRAN_COUNT:
				int count = Integer.parseInt(getFieldValue(field, fieldsMap));
				summaryItemMap.get(LINE_ITEM_PURCHASE)
						.setCount(summaryItemMap.get(LINE_ITEM_PURCHASE).getCount() + count);
				summaryItemMap.get(LINE_ITEM_NET).setCount(summaryItemMap.get(LINE_ITEM_NET).getCount() + count);
				break;
			case ReportConstants.REV_TRAN_COUNT:
				int revCount = Integer.parseInt(getFieldValue(field, fieldsMap));
				summaryItemMap.get(LINE_ITEM_REVERSAL)
						.setCount(summaryItemMap.get(LINE_ITEM_REVERSAL).getCount() + revCount);
				summaryItemMap.get(LINE_ITEM_NET).setCount(summaryItemMap.get(LINE_ITEM_NET).getCount() + revCount);
				break;
			case ReportConstants.AMOUNT:
				txnAmt = new AmountBuilder(getFieldValue(field, fieldsMap)).build();
				summaryItemMap.get(LINE_ITEM_PURCHASE).getTxnAmount().add(txnAmt);
				summaryItemMap.get(LINE_ITEM_NET).getTxnAmount().add(txnAmt);
				break;
			case ReportConstants.REV_AMOUNT:
				revTxnAmt = new AmountBuilder(getFieldValue(field, fieldsMap)).build();
				summaryItemMap.get(LINE_ITEM_REVERSAL).getTxnAmount().add(revTxnAmt);
				summaryItemMap.get(LINE_ITEM_NET).getTxnAmount().subtract(revTxnAmt);
				break;
//			case ReportConstants.POS_TRAILER_COMMISSION:
//				BigDecimal commission = txnAmount.calculateFee(extractCommission(customData));
//				String formattedCommission = new DecimalFormat(field.getFieldFormat()).format(commission);
//				if ("R".equals(qualifier)) {
//					formattedCommission = "(" + formattedCommission + ")";
//				}
//				line.append(StringUtils.wrap(formattedCommission, "\""));
//				line.append(field.getDelimiter());
//				break;
//			case ReportConstants.POS_TRAILER_REV_COMMISSION:
//				BigDecimal revcommission = txnAmount.calculateFee(extractCommission(customData));
//				String revformattedCommission = new DecimalFormat(field.getFieldFormat()).format(revcommission);
//				if ("R".equals(qualifier)) {
//					formattedCommission = "(" + revformattedCommission + ")";
//				}
//				line.append(StringUtils.wrap(revformattedCommission, "\""));
//				line.append(field.getDelimiter());
//				break;
			default:
				break;

			}

		}

		rgm.writeLine(line.toString().getBytes());
	}

	private void executeTrailerQuery(ReportGenerationMgr rgm, String customData, Map<String, LineItem> summaryItemMap) {
		logger.debug("In PosTransactionsCardholderBranch.executeTrailerQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				String currentMerchant = null;
				while (rs.next()) {
					new StringBuffer();
					lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
					boolean writeNewGroup = false;
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
						if ("MERCHANT NAME".equals(field.getFieldName())) {
							if (currentMerchant == null || !currentMerchant.equals(field.getValue())) {
								writeNewGroup = true;
							}
							currentMerchant = field.getValue();
						}
					}
					writeTrailer(rgm, lineFieldsMap, customData, summaryItemMap);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm, String branchCode) {
		logger.debug("In CsvReportProcessor.executeBodyQuery()");
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

				String currentMerchant = null;
				while (rs.next()) {
					boolean writeNewGroup = false;

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
						if ("MERCHANT NAME".equals(field.getFieldName())) {
							if (currentMerchant == null || !currentMerchant.equals(field.getValue())) {
								writeNewGroup = true;
							}
							currentMerchant = field.getValue();
						}
					}

					if (writeNewGroup) {
						writeBodyHeader(rgm);

					}
					writeBody(rgm, lineFieldsMap, currentMerchant);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
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

	class LineItem {
		private final String name;
		private int count = 0;
		private Amount txnAmount = new Amount(BigDecimal.ZERO);
		private Amount commission = new Amount(BigDecimal.ZERO);

		public LineItem(String name) {
			this.name = name;
		}

		public String getName() {
			return name;
		}

		public int getCount() {
			return count;
		}

		public void setCount(int count) {
			this.count = count;
		}

		public Amount getTxnAmount() {
			return txnAmount;
		}

		public void setTxnAmount(Amount txnAmount) {
			this.txnAmount = txnAmount;
		}

		public Amount getCommission() {
			return commission;
		}

		public void setCommission(Amount commission) {
			this.commission = commission;
		}
	}
}
