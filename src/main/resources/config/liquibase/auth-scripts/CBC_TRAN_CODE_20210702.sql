Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,145,'BNT','BBI','BBC','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,145,'EBK','EBI','EBC','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,145,'IVR','TBI','TBC','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,145,'MBK','MBI','MBC','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,146,'BNT','BBL','BBX','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,146,'EBK','EBL','EBX','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,146,'IVR','TBL','TBX','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,146,'MBK','MBL','MBX','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,146,'CBS E','EIL','ERB','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,146,'CBS I','TIL','TRB','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,146,'CBS M','MIL','MRB','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,142,'CBS A','AMI','AMR','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,142,'CBS E','EMI','EMR','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,142,'CBS I','TMI','TMR','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,142,'CBS M','MMI','MMR','DEBIT',CURRENT_TIMESTAMP);

Insert into CBC_TRAN_CODE (CTR_ID,CTR_CODE,CTR_CHANNEL,CTR_MNEM,CTR_REV_MNEM,CTR_DEBIT_CREDIT,CTR_LAST_UPDATE_TS) values (CBC_TRAN_CODE_SEQUENCE.nextVal,142,'CBS C','CMI','CMR','DEBIT',CURRENT_TIMESTAMP);


DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'ATM' AND CTR_CODE = 52 AND CTR_MNEM = 'BTD';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'ATM' AND CTR_CODE = 52 AND CTR_MNEM = 'BTC';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'BNT' AND CTR_CODE = 52 AND CTR_MNEM = 'BTD';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS A' AND CTR_CODE = 52 AND CTR_MNEM = 'ACI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS A' AND CTR_CODE = 52 AND CTR_MNEM = 'ADI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS C' AND CTR_CODE = 52 AND CTR_MNEM = 'CDI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS C' AND CTR_CODE = 52 AND CTR_MNEM = 'CCI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS E' AND CTR_CODE = 52 AND CTR_MNEM = 'ECI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS E' AND CTR_CODE = 52 AND CTR_MNEM = 'EDI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS I' AND CTR_CODE = 52 AND CTR_MNEM = 'TCI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS I' AND CTR_CODE = 52 AND CTR_MNEM = 'TDI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS M' AND CTR_CODE = 52 AND CTR_MNEM = 'MCI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CBS M' AND CTR_CODE = 52 AND CTR_MNEM = 'MDI';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'CDM' AND CTR_CODE = 52 AND CTR_MNEM = 'CTD';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'EBK' AND CTR_CODE = 52 AND CTR_MNEM = 'ETD';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'IVR' AND CTR_CODE = 52 AND CTR_MNEM = 'TTD';
DELETE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = 'MBK' AND CTR_CODE = 52 AND CTR_MNEM = 'MTD';

COMMIT;



