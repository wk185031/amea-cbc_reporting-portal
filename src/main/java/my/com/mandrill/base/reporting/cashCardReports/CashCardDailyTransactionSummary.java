package my.com.mandrill.base.reporting.cashCardReports;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.processor.BaseReportProcessor;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.writer.CsvWriter;

@Component
public class CashCardDailyTransactionSummary extends BaseReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(CashCardDailyTransactionSummary.class);

	@Autowired
	private CsvWriter csvWriter;

	@Autowired
	private DataSource datasource;

	private static final String PARAM_CURRENT_MONTH_DATE = "{current_month_year}";

	private static final String SQL_SUM_AMOUNT = "select sum(ACN.ACN_BALANCE_1) \"TOTAL BALANCE\", sum(case when CTR.CTR_DEBIT_CREDIT = 'DEBIT' then TXN.TRL_AMT_TXN else 0 end) \"TOTAL DEBIT\", sum(case when CTR.CTR_DEBIT_CREDIT = 'CREDIT' then TXN.TRL_AMT_TXN else 0 end) \"TOTAL CREDIT\" from TRANSACTION_LOG txn left join TRANSACTION_LOG_CUSTOM TXNC on TXN.TRL_ID=TXNC.TRL_ID left join CARD CRD on TXN.TRL_PAN=CRD.CRD_PAN  left join BRANCH BRC on TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE left join CARD_ACCOUNT CAT on CRD.CRD_ID=CAT.CAT_CRD_ID left join ACCOUNT ACN on CAT.CAT_ACN_ID=ACN.ACN_ID left join CARD_PRODUCT CPD on CRD.CRD_CPD_ID=CPD.CPD_ID left join CBC_TRAN_CODE CTR on TXN.TRL_TSC_CODE=CTR.CTR_CODE and TXNC.TRL_ORIGIN_CHANNEL=CTR.CTR_CHANNEL where CPD.CPD_CODE in ('80','81','82','83') ";

	private static final String SQL_COUNT_ACTIVE_ACCOUNT = "select BRC.BRC_CODE \"BRANCH CODE\", sum(CASE WHEN CPD.CPD_CODE = '83' THEN 1 ELSE 0 END) AS \"CORPORATE ACCOUNT\", sum(CASE WHEN CPD.CPD_CODE = '83' THEN 0 ELSE 1 END) AS \"RETAIL ACCOUNT\" from ACCOUNT ACN join CARD_ACCOUNT CAT on ACN.ACN_ID = CAT.CAT_ACN_ID join CARD CRD on CRD.CRD_ID = CAT.CAT_CRD_ID join CARD_CUSTOM CST on CRD.CRD_ID = CST.CRD_ID join CARD_PRODUCT CPD on CRD.CRD_CPD_ID = CPD.CPD_ID left join BRANCH BRC on BRC.BRC_CODE = CST.CRD_BRANCH_CODE where CPD.CPD_CODE in ('80','81','82','83') AND ACN_STATUS = 'A' group by BRC.BRC_CODE";

	private static final String SQL_COUNT_ACTIVE_CARD = "select BRC.BRC_CODE, CUST.CUST_FIRST_NAME, count(CRD.CRD_ID) from CARD CRD join CARD_CUSTOM CST on CRD.CRD_ID = CST.CRD_ID join CARD_PRODUCT CPD on CRD.CRD_CPD_ID = CPD.CPD_ID join CUSTOMER CUST on CRD.CRD_CUST_ID = CUST.CUST_ID left join BRANCH BRC on BRC.BRC_CODE = CST.CRD_BRANCH_CODE where CPD.CPD_CODE in ('83') AND CRD_STATUS_1 = 'A' AND {date_range_criteria} group by BRC.BRC_CODE, CUST.CUST_FIRST_NAME order by BRC.BRC_CODE, CUST.CUST_FIRST_NAME";

	private static final String SQL_SUM_TXN_AMOUNT = "select BRC.BRC_CODE, CUST.CUST_FIRST_NAME, SUM(TXN.TRL_AMT_TXN) from CARD CRD join CARD_CUSTOM CST on CRD.CRD_ID = CST.CRD_ID join CARD_PRODUCT CPD on CRD.CRD_CPD_ID = CPD.CPD_ID join CUSTOMER CUST on CRD.CRD_CUST_ID = CUST.CUST_ID  left join TRANSACTION_LOG TXN on TXN.TRL_PAN = CRD.CRD_PAN   left join BRANCH BRC on BRC.BRC_CODE = CST.CRD_BRANCH_CODE where CPD.CPD_CODE in ('83') AND CRD_STATUS_1 = 'A' AND {date_range_criteria} group by BRC.BRC_CODE, CUST.CUST_FIRST_NAME";

	private static final String CORPORATE_PREFIX = "C_";

	private static final String RETAIL_PREFIX = "R_";

	private static final String BRANCH_ACCOUNT_KEY = "BRANCH_ACCOUNTS";
	private static final String CARD_CURRENT_MONTH_DATA = "CARD_COUNT_CURRENT_MONTH_DATA";
	private static final String CARD_PREVIOUS_MONTH_DATA = "CARD_COUNT_PREVIOUS_MONTH_DATA";
	private static final String CARD_TXN_CURRENT_MONTH_DATA = "CARD_TXN_CURRENT_MONTH_DATA";
	private static final String CARD_TXN_PREVIOUS_MONTH_DATA = "CARD_TXN_PREVIOUS_MONTH_DATA";

	protected void writeReportHeader(FileOutputStream out, String headerFieldConfig,
			Map<String, ReportGenerationFields> predefinedDataMap) throws Exception {
		List<ReportGenerationFields> headerFields = parseFieldConfig(headerFieldConfig);

		for (ReportGenerationFields f : headerFields) {
			if (f.getDefaultValue().contains(PARAM_CURRENT_MONTH_DATE)) {
				String txnStartDate = predefinedDataMap.get(ReportConstants.AS_OF_DATE_VALUE).getValue();
				logger.debug("txnStartDate = {}", txnStartDate);

				f.setDefaultValue(f.getDefaultValue().replace(PARAM_CURRENT_MONTH_DATE,
						LocalDate.parse(txnStartDate).format(DateTimeFormatter.ofPattern("MMM yyyy"))));
			}
		}

		csvWriter.writeLine(out, headerFields, predefinedDataMap);
		csvWriter.writeLine(out, CsvWriter.EOL);
	}

	@Override
	protected void preProcessBodyHeader(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		ReportGenerationFields branchCode = bodyFields.stream()
				.filter(field -> getBranchCodeFieldName().equals(field.getFieldName())).findAny().orElse(null);
		ReportGenerationFields branchName = bodyFields.stream()
				.filter(field -> getBranchNameFieldName().equals(field.getFieldName())).findAny().orElse(null);
		ReportGenerationFields transactionGroup = bodyFields.stream()
				.filter(field -> getTransactionGroupFieldName().equals(field.getFieldName())).findAny().orElse(null);

		boolean isCorporate = transactionGroup.getValue().contains("CORPORATE");

		if (context.getCurrentBranch() != null && !context.getCurrentBranch().equals(branchCode.getValue())) {
			writeCorporateCardStatisticSection(context, out);
		}
		
		if (isCorporate && context.isWriteBodyHeader()) {
			context.setWriteBodyHeader(false);
			writeBranchSection(out, branchCode, branchName);
			context.setCurrentBranch(branchCode.getValue());
			context.getCurrentGroupMap().remove(getTransactionGroupFieldName());
		} else if (context.getCurrentBranch() == null || !context.getCurrentBranch().equals(branchCode.getValue())) {
			context.setWriteBodyHeader(true);
			writeBranchSection(out, branchCode, branchName);
			context.setCurrentBranch(branchCode.getValue());
			context.getCurrentGroupMap().remove(getTransactionGroupFieldName());
		}

		if (!context.getCurrentGroupMap().containsKey(getTransactionGroupFieldName()) || !context.getCurrentGroupMap()
				.get(getTransactionGroupFieldName()).equals(transactionGroup.getValue())) {
			writeBalanceSection(context, out, branchCode, transactionGroup, isCorporate);
		}
	}

	private void writeBalanceSection(ReportContext context, FileOutputStream out, ReportGenerationFields branchCode,
			ReportGenerationFields transactionGroup, boolean isCorporate) throws IOException {
		context.getCurrentGroupMap().put(getTransactionGroupFieldName(), transactionGroup.getValue());
		String transactionGroupLine = CsvWriter.DELIMITER_SEMICOLON + transactionGroup.getValue();
		csvWriter.writeLine(out, transactionGroupLine);
		csvWriter.writeLine(out, CsvWriter.EOL);

		DecimalFormat df = new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT);

		List<BigDecimal> balanceSummary = getBalanceSummary(SQL_SUM_AMOUNT, branchCode.getValue(), isCorporate);
		csvWriter.writeLine(out, ("PREVIOUS MONTH AP BALANCE:" + CsvWriter.DELIMITER_SEMICOLON
				+ df.format(balanceSummary.get(0).doubleValue())));
		csvWriter.writeLine(out, CsvWriter.EOL);
		csvWriter.writeLine(out,
				("MTD AP BALANCE:" + CsvWriter.DELIMITER_SEMICOLON + df.format(balanceSummary.get(1).doubleValue())));
		csvWriter.writeLine(out, CsvWriter.EOL);
		csvWriter.writeLine(out, CsvWriter.EOL);

		Integer activeAccountCount = 0;
		if (isCorporate) {
			activeAccountCount = (Integer) context.getDataMap().get(BRANCH_ACCOUNT_KEY)
					.get(CORPORATE_PREFIX + branchCode.getValue());
		} else {
			activeAccountCount = (Integer) context.getDataMap().get(BRANCH_ACCOUNT_KEY)
					.get(RETAIL_PREFIX + branchCode.getValue());
		}
		csvWriter.writeLine(out, "NUMBER OF ACTIVE ACCOUNTS: " + (activeAccountCount == null ? 0 : activeAccountCount));
		csvWriter.writeLine(out, CsvWriter.EOL);
		csvWriter.writeLine(out, CsvWriter.EOL);

		csvWriter.writeLine(out, "CHANNEL" + CsvWriter.DELIMITER_SEMICOLON + "TOTAL DEBIT"
				+ CsvWriter.DELIMITER_SEMICOLON + "TOTAL CREDIT");
		csvWriter.writeLine(out, CsvWriter.EOL);
	}

	private void writeCorporateCardStatisticSection(ReportContext context, FileOutputStream out) throws IOException {

		if (context.getDataMap().get(CARD_CURRENT_MONTH_DATA).containsKey(context.getCurrentBranch())) {
			csvWriter.writeLine(out, CsvWriter.EOL);
			StringBuilder sb = new StringBuilder();
			sb.append("Avg. AP volume of Corporate Clients").append(CsvWriter.DELIMITER_SEMICOLON);
			sb.append("Previous Month").append(CsvWriter.DELIMITER_SEMICOLON);
			sb.append("Current Month");
			csvWriter.writeLine(out, sb.toString());
			csvWriter.writeLine(out, CsvWriter.EOL);

			Map<String, BigDecimal> currentMonthCard = (Map<String, BigDecimal>) context.getDataMap()
					.get(CARD_CURRENT_MONTH_DATA).get(context.getCurrentBranch());
			currentMonthCard.forEach((k, v) -> {
				logger.debug("currentMonthCard customerName: {}", k);

				String customerName = k;
				int currentMonthCardCount = v.toBigInteger().intValue();
				int previousMonthCardCount = 0;
				BigDecimal currentMonthCardTxn = BigDecimal.ZERO;
				BigDecimal previousMonthCardTxn = BigDecimal.ZERO;

				if (context.getDataMap().get(CARD_PREVIOUS_MONTH_DATA).containsKey(context.getCurrentBranch())) {
					Map<String, BigDecimal> previousMonthCard = (Map<String, BigDecimal>) context.getDataMap()
							.get(CARD_PREVIOUS_MONTH_DATA).get(context.getCurrentBranch());
					if (previousMonthCard.containsKey(customerName)) {
						logger.debug("previousMonthCard customerName: {}", k);
						previousMonthCardCount = previousMonthCard.get(customerName).toBigInteger().intValue();
					}
				}
				if (context.getDataMap().get(CARD_TXN_PREVIOUS_MONTH_DATA).containsKey(context.getCurrentBranch())) {
					Map<String, BigDecimal> previousMonthCardTxnMap = (Map<String, BigDecimal>) context.getDataMap()
							.get(CARD_TXN_PREVIOUS_MONTH_DATA).get(context.getCurrentBranch());
					if (previousMonthCardTxnMap.containsKey(customerName)) {
						logger.debug("previousMonthCardTxn customerName: {}", k);
						previousMonthCardTxn = previousMonthCardTxnMap.get(customerName);
					}
				}
				if (context.getDataMap().get(CARD_TXN_CURRENT_MONTH_DATA).containsKey(context.getCurrentBranch())) {
					Map<String, BigDecimal> currentMonthCardTxnMap = (Map<String, BigDecimal>) context.getDataMap()
							.get(CARD_TXN_CURRENT_MONTH_DATA).get(context.getCurrentBranch());
					if (currentMonthCardTxnMap.containsKey(customerName)) {
						logger.debug("currentMonthCardTxn customerName: {}", k);
						currentMonthCardTxn = currentMonthCardTxnMap.get(customerName);
					}
				}

				try {
					csvWriter.writeLine(out, (k + CsvWriter.DELIMITER_SEMICOLON + CsvWriter.DELIMITER_SEMICOLON));
					csvWriter.writeLine(out, CsvWriter.EOL);
					String line = "Number of Active Cash Cards" + CsvWriter.DELIMITER_SEMICOLON + previousMonthCardCount
							+ CsvWriter.DELIMITER_SEMICOLON + currentMonthCardCount;
					csvWriter.writeLine(out, line.toString());
					csvWriter.writeLine(out, CsvWriter.EOL);

					BigDecimal averageVolumeCurrentMounth = currentMonthCardCount == 0 ? BigDecimal.ZERO
							: currentMonthCardTxn.divide(new BigDecimal(currentMonthCardCount), RoundingMode.HALF_UP);
					BigDecimal averageVolumePreviousMounth = previousMonthCardCount == 0 ? BigDecimal.ZERO
							: previousMonthCardTxn.divide(new BigDecimal(previousMonthCardCount), RoundingMode.HALF_UP);

					String averageVolumePreviousMounthStr = "\""
							+ new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT)
									.format(averageVolumePreviousMounth.doubleValue())
							+ "\"";
					String averageVolumeCurrentMounthStr = "\""
							+ new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT)
									.format(averageVolumeCurrentMounth.doubleValue())
							+ "\"";

					String volumeline = "Cash Card Average Volume" + CsvWriter.DELIMITER_SEMICOLON
							+ averageVolumePreviousMounthStr + CsvWriter.DELIMITER_SEMICOLON
							+ averageVolumeCurrentMounthStr;
					csvWriter.writeLine(out, volumeline.toString());
					csvWriter.writeLine(out, CsvWriter.EOL);

				} catch (IOException e) {
					throw new RuntimeException(e);
				}

			});
		}
		csvWriter.writeLine(out, CsvWriter.EOL);
	}

	private void writeBranchSection(FileOutputStream out, ReportGenerationFields branchCode,
			ReportGenerationFields branchName) throws IOException {
		String branchCodeLine = branchCode.getFieldName() + ":" + CsvWriter.DELIMITER_SEMICOLON + branchCode.getValue();
		csvWriter.writeLine(out, CsvWriter.EOL);
		csvWriter.writeLine(out, branchCodeLine);
		csvWriter.writeLine(out, CsvWriter.EOL);

		String branchNameLine = branchName.getFieldName() + ":" + CsvWriter.DELIMITER_SEMICOLON + branchName.getValue();
		csvWriter.writeLine(out, branchNameLine);
		csvWriter.writeLine(out, CsvWriter.EOL);
		csvWriter.writeLine(out, CsvWriter.EOL);
	}

	@Override
	protected void handleGroupFieldInBody(ReportContext context, ReportGenerationFields field, StringBuilder bodyLine) {
		// Do nothing. Skip writing group column
	}

	@Override
	protected void writeBodyHeader(ReportContext context, List<ReportGenerationFields> bodyHeaderFields,
			FileOutputStream out) throws Exception {
		// Do nothing. Handle body header in writeBalanceSection
	}

	@Override
	protected Map<String, Map<String, ?>> initDataMap(ReportGenerationMgr rgm) {
		Map<String, Map<String, ?>> dataMap = new HashMap<>();
		Map<String, Integer> branchAccountMap = getAllActiveAccountsByBranch();
		dataMap.put(BRANCH_ACCOUNT_KEY, branchAccountMap);

		Map<String, Map<String, BigDecimal>> currentMonthActiveCardMap = getCorporateCardStatistic(
				SQL_COUNT_ACTIVE_CARD, true, true, rgm.getTxnEndDate());
		dataMap.put(CARD_CURRENT_MONTH_DATA, currentMonthActiveCardMap);

		Map<String, Map<String, BigDecimal>> previousMonthActiveCardMap = getCorporateCardStatistic(
				SQL_COUNT_ACTIVE_CARD, false, true, rgm.getTxnEndDate());
		dataMap.put(CARD_PREVIOUS_MONTH_DATA, previousMonthActiveCardMap);

		Map<String, Map<String, BigDecimal>> currentMonthCardTxnMap = getCorporateCardStatistic(SQL_SUM_TXN_AMOUNT,
				true, false, rgm.getTxnEndDate());
		dataMap.put(CARD_TXN_CURRENT_MONTH_DATA, currentMonthCardTxnMap);

		Map<String, Map<String, BigDecimal>> previousMonthCardTxnMap = getCorporateCardStatistic(SQL_SUM_TXN_AMOUNT,
				false, false, rgm.getTxnEndDate());
		dataMap.put(CARD_TXN_PREVIOUS_MONTH_DATA, previousMonthCardTxnMap);

		logger.debug("DataMap size={}, Branch accounts size={}", dataMap.size(),
				dataMap.get(BRANCH_ACCOUNT_KEY).size());

		return dataMap;
	}

	@Override
	protected void initQueryPlaceholder(ReportGenerationMgr rgm,
			Map<String, ReportGenerationFields> predefinedDataMap) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		String txnEnd = rgm.getTxnEndDate().format(formatter);

		ReportGenerationFields txnEndDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_END_DATE,
				ReportGenerationFields.TYPE_STRING,
				"TO_DATE('" + txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE + "')");

		predefinedDataMap.put(txnEndDate.getFieldName(), txnEndDate);
	}

	private String getBranchCodeFieldName() {
		return "BRANCH CODE";
	}

	private String getBranchNameFieldName() {
		return "BRANCH NAME";
	}

	private String getTransactionGroupFieldName() {
		return "TRANSACTION GROUP";
	}

	@Override
	protected void preProcessBodyData(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		// TODO Auto-generated method stub

	}

	@Override
	protected void writeBodyTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
	}

	@Override
	protected void postReportGeneration(File outputFile) throws Exception {
		String csvFilePath = outputFile.getAbsolutePath();
		String pdfFilePath = outputFile.getAbsolutePath().substring(0, csvFilePath.lastIndexOf('.')) + ".pdf";

		PDDocument doc = new PDDocument();

		PDPageContentStream contentStream = null;
		BufferedReader reader = null;
		boolean firstBranchSection = true;
		try {
			reader = new BufferedReader(new FileReader(new File(csvFilePath)));
			String line = reader.readLine();
			while (line != null) {
				logger.debug("write line:{}", line);
				if (line.startsWith("BRANCH CODE")) {
					if (!firstBranchSection) {
						logger.debug("create new page for branch");
						contentStream.endText();
						contentStream.close();
						contentStream = newPage(doc);
					} else {
						firstBranchSection = false;
					}

				} else if (line.startsWith("CHINA BANK")) {
					logger.debug("create new page for header");
					contentStream = newPage(doc);
				}

				String[] columns = line.split(CsvWriter.DELIMITER_SEMICOLON);
				for (String col : columns) {
					col = col.replace("\"", "");
					contentStream.showText(String.format("%1$-" + 40 + "s", col));
				}
				contentStream.newLine();

				line = reader.readLine();
			}
			reader.close();
			contentStream.endText();
			contentStream.close();

		} catch (Exception e) {
			throw new RuntimeException(e);
		}

		doc.save(new File(pdfFilePath));
		doc.close();
	}

	private PDPageContentStream newPage(PDDocument doc) throws Exception {
		PDPage page = new PDPage(PDRectangle.A4);
		doc.addPage(page);
		float margin = 30;
		float startX = PDRectangle.A4.getLowerLeftX() + margin;
		float startY = PDRectangle.A4.getUpperRightY() - margin;
		float leading = 1.5f * 8;
		PDPageContentStream contentStream = new PDPageContentStream(doc, page);
		contentStream.setFont(PDType1Font.COURIER, 8);
		contentStream.setLeading(leading);
		contentStream.beginText();
		contentStream.newLineAtOffset(startX, startY);

		return contentStream;
	}

	/**
	 * Retrieve balance for current and previous month for Cash Card
	 * 
	 * @param sql
	 * @param branchCode
	 * @param isCorporate
	 * @return A list contains 2 elements - First element: Balance for previous
	 *         month - Second element: Current balance
	 */
	private List<BigDecimal> getBalanceSummary(String sql, String branchCode, boolean isCorporate) {
		List<BigDecimal> balanceSummary = new ArrayList<>();

		Connection conn = null;
		ResultSet rs = null;
		PreparedStatement ps = null;

		sql += " and TXNC.TRL_IS_CORPORATE_CARD = " + (isCorporate ? "1" : "0");
		sql += " and BRC.BRC_CODE = '" + branchCode + "'";

		try {
			conn = datasource.getConnection();
			ps = conn.prepareStatement(sql);
			rs = ps.executeQuery();

			rs.next();

			BigDecimal currentBalance = rs.getBigDecimal("TOTAL BALANCE");
			BigDecimal totalDebit = rs.getBigDecimal("TOTAL DEBIT");
			BigDecimal totalCredit = rs.getBigDecimal("TOTAL CREDIT");

			if (currentBalance == null) {
				currentBalance = BigDecimal.ZERO;
			}
			if (totalDebit == null) {
				totalDebit = BigDecimal.ZERO;
			}
			if (totalCredit == null) {
				totalCredit = BigDecimal.ZERO;
			}

			BigDecimal previousMonthBalance = currentBalance.subtract(totalDebit).add(totalCredit);
			balanceSummary.add(previousMonthBalance);
			balanceSummary.add(currentBalance);

			return balanceSummary;
		} catch (Exception e) {
			logger.error("Failed to get balance summary", e);
			throw new RuntimeException(e);
		} finally {

			if (ps != null) {
				try {
					ps.close();
				} catch (Exception e2) {
					logger.warn("Failed to close preparedStatement.");
				}

			}
			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e3) {
					logger.warn("Failed to close resultSet.");
				}

			}

			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e4) {
					logger.warn("Failed to close connection.");
				}
			}
		}
	}

	private Map<String, Map<String, BigDecimal>> getCorporateCardStatistic(String sql, boolean currentMonth,
			boolean countCard, LocalDateTime txnEndDate) {
		Connection conn = null;
		ResultSet rs = null;
		PreparedStatement ps = null;

		Map<String, Map<String, BigDecimal>> statisticMap = new HashMap<>();
		String date_range_criteria = "";
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		if (currentMonth) {
			if (countCard) {
				String txnEnd = txnEndDate.format(formatter);
				date_range_criteria = "CRD.CRD_ISSUE_DATE_1 < TO_DATE('" + txnEnd + "','YYYYMMDD HH24:MI:SS')";

			} else {
				LocalDateTime currentMonthEndDateTime = txnEndDate;
				LocalDateTime currentMonthStartDateTime = txnEndDate.minusDays(1L).toLocalDate().withDayOfMonth(1)
						.atStartOfDay();
				String txnStart = currentMonthStartDateTime.format(formatter);
				String txnEnd = currentMonthEndDateTime.format(formatter);
				date_range_criteria = "TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart
						+ "','YYYYMMDD HH24:MI:SS') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd
						+ "','YYYYMMDD HH24:MI:SS')";
			}
		} else {
			if (countCard) {
				String txnEnd = txnEndDate.toLocalDate().minusDays(1L).withDayOfMonth(1).atStartOfDay()
						.format(formatter);
				date_range_criteria = "CRD.CRD_ISSUE_DATE_1 < TO_DATE('" + txnEnd + "','YYYYMMDD HH24:MI:SS')";
			} else {
				LocalDateTime previousMonthEndDateTime = txnEndDate.minusDays(1L).toLocalDate().withDayOfMonth(1)
						.atStartOfDay();
				LocalDateTime previousMonthStartDateTime = txnEndDate.minusDays(1L).toLocalDate().withDayOfMonth(1)
						.minusMonths(1L).atStartOfDay();
				String txnStart = previousMonthStartDateTime.format(formatter);
				String txnEnd = previousMonthEndDateTime.format(formatter);
				date_range_criteria = "TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart
						+ "','YYYYMMDD HH24:MI:SS') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd
						+ "','YYYYMMDD HH24:MI:SS')";
			}
		}

		sql = sql.replace("{date_range_criteria}", date_range_criteria);
		logger.debug("getCorporateStatistics: currentMonth={}, countCard={}, sql={}", currentMonth, countCard, sql);

		try {
			conn = datasource.getConnection();
			ps = conn.prepareStatement(sql);
			rs = ps.executeQuery();
			while (rs.next()) {
				String branchCode = rs.getString(1);
				String customerName = rs.getString(2);
				BigDecimal count = BigDecimal.ZERO;
				if (countCard) {
					count = new BigDecimal(new Integer(rs.getInt(3)));
				} else {
					count = rs.getBigDecimal(3);
				}

				if (statisticMap.containsKey(branchCode)) {
					statisticMap.get(branchCode).put(customerName, count);
				} else {
					Map<String, BigDecimal> clientStatisticCountMap = new HashMap<>();
					clientStatisticCountMap.put(customerName, count);
					statisticMap.put(branchCode, clientStatisticCountMap);
				}
			}
		} catch (Exception e) {
			logger.error("Failed to get corporate card statistics", e);
			throw new RuntimeException(e);
		} finally {

			if (ps != null) {
				try {
					ps.close();
				} catch (Exception e2) {
					logger.warn("Failed to close preparedStatement.");
				}

			}
			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e3) {
					logger.warn("Failed to close resultSet.");
				}

			}

			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e4) {
					logger.warn("Failed to close connection.");
				}
			}
		}
		logger.debug("statisticMap size={}", statisticMap.size());
		return statisticMap;
	}

	private Map<String, Integer> getAllActiveAccountsByBranch() {
		Map<String, Integer> branchAccounts = new HashMap<String, Integer>();

		Connection conn = null;
		ResultSet rs = null;
		PreparedStatement ps = null;

		try {
			conn = datasource.getConnection();
			ps = conn.prepareStatement(SQL_COUNT_ACTIVE_ACCOUNT);
			rs = ps.executeQuery();

			while (rs.next()) {
				String branchCode = rs.getString(1);
				Integer corporateTotalAccount = rs.getInt(2);
				Integer retailTotalAccount = rs.getInt(3);

				branchAccounts.put(CORPORATE_PREFIX + branchCode, corporateTotalAccount);
				branchAccounts.put(RETAIL_PREFIX + branchCode, retailTotalAccount);
			}

		} catch (Exception e) {
			logger.error("Failed to get balance summary", e);
			throw new RuntimeException(e);
		} finally {

			if (ps != null) {
				try {
					ps.close();
				} catch (Exception e2) {
					logger.warn("Failed to close preparedStatement.");
				}

			}
			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e3) {
					logger.warn("Failed to close resultSet.");
				}

			}

			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e4) {
					logger.warn("Failed to close connection.");
				}
			}
		}

		return branchAccounts;
	}

}
