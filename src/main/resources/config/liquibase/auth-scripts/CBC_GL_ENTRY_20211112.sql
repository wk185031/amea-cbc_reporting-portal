-- OTC
update CBC_GL_ENTRY set GLE_DEBIT_ACCOUNT='Accts. Payable - Cash Card', GLE_DEBIT_DESCRIPTION='OTC CashCard Withdrawal Cash', GLE_CREDIT_ACCOUNT='Cash Card Tran Clrg', GLE_CREDIT_DESCRIPTION='OTC CashCard Withdrawal Cash' where GLE_GLT_ID=9 and GLE_TRAN_CHANNEL='OTC' and GLE_TRAN_TYPE=1; 
update CBC_GL_ENTRY set GLE_MAIN_DIRECTION='RECEIVING', GLE_DEBIT_DESCRIPTION='OTC CashCard Loading Cash', GLE_CREDIT_DESCRIPTION='OTC CashCard Loading Cash' where GLE_GLT_ID=9 and GLE_TRAN_CHANNEL='OTC' and GLE_TRAN_TYPE=21; 

COMMIT;