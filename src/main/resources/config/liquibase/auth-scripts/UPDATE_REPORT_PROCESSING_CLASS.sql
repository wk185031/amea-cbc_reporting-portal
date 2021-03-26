SET DEFINE OFF;

UPDATE report_definition SET RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.atmTransactionListsBranch.TransactionSummaryGrandTotal.TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts'
WHERE RED_NAME = 'Transaction Summary Grand Total for On-Us and Other Branches Accounts';

UPDATE report_definition SET RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.atmTransactionListsBranch.TransactionSummaryGrandTotal.TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts'
WHERE RED_NAME = 'Transaction Summary Grand Total for Cash Card';

UPDATE report_definition SET RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.atmTransactionListsBranch.TransactionSummaryGrandTotal.TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts'
WHERE RED_NAME = 'Transaction Summary Grand Total for Inter-Entity';

UPDATE report_definition SET RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.atmTransactionListsBranch.TransactionSummaryGrandTotal.TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts'
WHERE RED_NAME = 'Transaction Summary Grand Total for Other Banks';

UPDATE report_definition SET RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.atmTransactionListsBranch.EftAtmTransactionList.EftAtmTransactionListOnUs'
WHERE RED_NAME = 'EFT - ATM Transaction List (On-Us)';

UPDATE report_definition SET RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.atmTransactionListsBranch.EftAtmTransactionList.EftAtmTransactionListOtherBranch'
WHERE RED_NAME = 'EFT - ATM Transaction List (Other Branch)';

UPDATE report_definition SET RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.atmTransactionListsBranch.EftAtmTransactionList.EftAtmTransactionListCashCard'
WHERE RED_NAME = 'EFT - ATM Transaction List (Cash Card)';

UPDATE report_definition SET RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.atmTransactionListsBranch.EftAtmTransactionList.EftAtmTransactionListInterEntity'
WHERE RED_NAME = 'EFT - ATM Transaction List (Inter-Entity)';

UPDATE report_definition SET RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.atmTransactionListsBranch.EftAtmTransactionList.EftAtmTransactionListOnUs'
WHERE RED_NAME = 'EFT - ATM Transaction List (Other Banks)';

COMMIT;