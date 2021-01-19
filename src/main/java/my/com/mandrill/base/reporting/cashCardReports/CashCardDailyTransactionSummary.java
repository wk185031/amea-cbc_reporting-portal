package my.com.mandrill.base.reporting.cashCardReports;

import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.processor.BaseReportProcessor;
import my.com.mandrill.base.reporting.ReportGenerationFields;
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

	private static final String CORPORATE_PREFIX = "C_";

	private static final String RETAIL_PREFIX = "R_";

	private static final String BRANCH_ACCOUNT_KEY = "BRANCH_ACCOUNTS";

	protected void writeReportHeader(FileOutputStream out, String headerFieldConfig,
			Map<String, ReportGenerationFields> predefinedDataMap) throws Exception {
		List<ReportGenerationFields> headerFields = parseFieldConfig(headerFieldConfig);

		for (ReportGenerationFields f : headerFields) {
			if (f.getDefaultValue().contains(PARAM_CURRENT_MONTH_DATE)) {
				f.setDefaultValue(f.getDefaultValue().replace(PARAM_CURRENT_MONTH_DATE,
						LocalDate.now().format(DateTimeFormatter.ofPattern("MMM yyyy"))));
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

		if (context.getCurrentBranch() == null || !context.getCurrentBranch().equals(branchCode.getValue())) {
			String branchCodeLine = branchCode.getFieldName() + ":" + CsvWriter.DEFAULT_DELIMITER
					+ branchCode.getValue();
			csvWriter.writeLine(out, CsvWriter.EOL);
			csvWriter.writeLine(out, branchCodeLine);
			csvWriter.writeLine(out, CsvWriter.EOL);

			String branchNameLine = branchName.getFieldName() + ":" + CsvWriter.DEFAULT_DELIMITER
					+ branchName.getValue();
			csvWriter.writeLine(out, branchNameLine);
			csvWriter.writeLine(out, CsvWriter.EOL);
			csvWriter.writeLine(out, CsvWriter.EOL);

			context.setCurrentBranch(branchCode.getValue());
			context.getCurrentGroupMap().remove(getTransactionGroupFieldName());
		}

		if (!context.getCurrentGroupMap().containsKey(getTransactionGroupFieldName()) || !context.getCurrentGroupMap()
				.get(getTransactionGroupFieldName()).equals(transactionGroup.getValue())) {
			context.getCurrentGroupMap().put(getTransactionGroupFieldName(), transactionGroup.getValue());
			String transactionGroupLine = CsvWriter.DEFAULT_DELIMITER + transactionGroup.getValue();
			csvWriter.writeLine(out, transactionGroupLine);
			csvWriter.writeLine(out, CsvWriter.EOL);

			DecimalFormat df = new DecimalFormat(ReportGenerationFields.DEFAULT_DECIMAL_FORMAT);

			boolean isCorporate = transactionGroup.getValue().contains("CORPORATE");

			List<BigDecimal> balanceSummary = getBalanceSummary(SQL_SUM_AMOUNT, branchCode.getValue(), isCorporate);
			csvWriter.writeLine(out, ("PREVIOUS MONTH AP BALANCE:" + CsvWriter.DEFAULT_DELIMITER
					+ df.format(balanceSummary.get(0).doubleValue())));
			csvWriter.writeLine(out, CsvWriter.EOL);
			csvWriter.writeLine(out,
					("MTD AP BALANCE:" + CsvWriter.DEFAULT_DELIMITER + df.format(balanceSummary.get(1).doubleValue())));
			csvWriter.writeLine(out, CsvWriter.EOL);
			csvWriter.writeLine(out, CsvWriter.EOL);

			csvWriter.writeLine(out,
					"NUMBER OF ACTIVE ACCOUNTS: " + (isCorporate
							? context.getDataMap().get(BRANCH_ACCOUNT_KEY).get(CORPORATE_PREFIX + branchCode.getValue())
							: context.getDataMap().get(BRANCH_ACCOUNT_KEY).get(RETAIL_PREFIX + branchCode.getValue())));
			csvWriter.writeLine(out, CsvWriter.EOL);
			csvWriter.writeLine(out, CsvWriter.EOL);
		}
	}

	@Override
	protected void handleGroupFieldInBody(ReportContext context, ReportGenerationFields field, StringBuilder bodyLine) {
		// Do nothing. Skip writing group column
	}

	@Override
	protected Map<String, Map<String, ?>> initDataMap() {
		Map<String, Map<String, ?>> dataMap = new HashMap<>();
		Map<String, Integer> branchAccountMap = getAllActiveAccountsByBranch();
		dataMap.put(BRANCH_ACCOUNT_KEY, branchAccountMap);
		logger.debug("DataMap size={}, Branch accounts size={}", dataMap.size(),
				dataMap.get(BRANCH_ACCOUNT_KEY).size());

		return dataMap;
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
		// TODO Auto-generated method stub

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
