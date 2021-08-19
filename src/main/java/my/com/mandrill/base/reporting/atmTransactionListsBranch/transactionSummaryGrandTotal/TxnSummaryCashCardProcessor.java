package my.com.mandrill.base.reporting.atmTransactionListsBranch.transactionSummaryGrandTotal;

import my.com.mandrill.base.reporting.reportProcessor.BranchReportProcessor;

public class TxnSummaryCashCardProcessor extends BranchReportProcessor {

	private static final String GROUP_FIELD_CARD_PRODUCT = "CARD_PRODUCT";
	
	@Override
	protected String getLowestLevelGroupField() {
		return GROUP_FIELD_CARD_PRODUCT;
	}

}
