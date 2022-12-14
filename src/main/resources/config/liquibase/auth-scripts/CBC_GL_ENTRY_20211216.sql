-- Update description for IBFT service charge
update CBC_GL_ENTRY set GLE_DEBIT_DESCRIPTION='BANCNET IBFT SERVICE CHARGE', GLE_CREDIT_DESCRIPTION='BANCNET IBFT SERVICE CHARGE' where GLE_GLT_ID=9 and GLE_TRAN_CHANNEL='BNT' and GLE_TRAN_TYPE=44 and GLE_MAIN_DIRECTION='TRANSMITTING' and GLE_SVC_ENABLED='Y'; 

-- Remove duplicate for InstaPay
delete from CBC_GL_ENTRY where gle_glt_id=(select glt_id from CBC_GL_TRANSACTION where GLT_NAME='CASH CARD') and GLE_MAIN_DIRECTION='TRANSMITTING' and GLE_TRAN_CHANNEL='BRM' and GLE_TRAN_TYPE=46 and GLE_SVC_ENABLED='Y' and ROWNUM = 1;
delete from CBC_GL_ENTRY where gle_glt_id=(select glt_id from CBC_GL_TRANSACTION where GLT_NAME='CASH CARD') and GLE_MAIN_DIRECTION='TRANSMITTING' and GLE_TRAN_CHANNEL='BRM' and GLE_TRAN_TYPE=46 and GLE_SVC_ENABLED is null and ROWNUM = 1;
delete from CBC_GL_ENTRY where gle_glt_id=(select glt_id from CBC_GL_TRANSACTION where GLT_NAME='CASH CARD') and GLE_MAIN_DIRECTION='INTER-ENTITY' and GLE_TRAN_CHANNEL='BRM' and GLE_TRAN_TYPE=46 and GLE_SVC_ENABLED='Y' and ROWNUM = 1;
delete from CBC_GL_ENTRY where gle_glt_id=(select glt_id from CBC_GL_TRANSACTION where GLT_NAME='CASH CARD') and GLE_MAIN_DIRECTION='INTER-ENTITY' and GLE_TRAN_CHANNEL='BRM' and GLE_TRAN_TYPE=46 and GLE_SVC_ENABLED is null and ROWNUM = 1;


COMMIT;