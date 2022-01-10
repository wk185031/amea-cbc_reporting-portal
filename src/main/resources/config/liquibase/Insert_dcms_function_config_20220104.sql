DELETE FROM SYSTEM_CONFIGURATION WHERE NAME = 'dcms.function.pattern.Batch_Update';
DELETE FROM SYSTEM_CONFIGURATION WHERE NAME = 'dcms.function.pattern.Change_Card_Status';
DELETE FROM SYSTEM_CONFIGURATION WHERE NAME = 'dcms.function.pattern.Batch_Update_Card_Activation';
DELETE FROM SYSTEM_CONFIGURATION WHERE NAME = 'dcms.function.pattern.Change_Branch';
DELETE FROM SYSTEM_CONFIGURATION WHERE NAME = 'dcms.function.pattern.Withheld_Auto_Renewal';
DELETE FROM SYSTEM_CONFIGURATION WHERE NAME = 'dcms.function.pattern.Change_Withheld';
DELETE FROM SYSTEM_CONFIGURATION WHERE NAME = 'dcms.function.pattern.Modify_CIF';
DELETE FROM SYSTEM_CONFIGURATION WHERE NAME = 'dcms.function.pattern.Update_CC_Balance';
DELETE FROM SYSTEM_CONFIGURATION WHERE NAME = 'dcms.function.pattern.Update_CC_Acc_Sts';

INSERT INTO SYSTEM_CONFIGURATION (ID, NAME, DESCRIPTION, CONFIG, CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE) VALUES
((SELECT MAX(ID) + 1 FROM SYSTEM_CONFIGURATION), 'dcms.function.pattern.Change_Card_Status','Pattern for Batch Update Change Card Status','^(Card status changed from).*to.*',
'system',current_timestamp,null,null);

INSERT INTO SYSTEM_CONFIGURATION (ID, NAME, DESCRIPTION, CONFIG, CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE) VALUES
((SELECT MAX(ID) + 1 FROM SYSTEM_CONFIGURATION), 'dcms.function.pattern.Batch_Update_Card_Activation','Pattern for Batch Update Card Activation','(Card status changed from Inactive to Active).*',
'system',current_timestamp,null,null);

INSERT INTO SYSTEM_CONFIGURATION (ID, NAME, DESCRIPTION, CONFIG, CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE) VALUES
((SELECT MAX(ID) + 1 FROM SYSTEM_CONFIGURATION), 'dcms.function.pattern.Change_Branch','Pattern for Batch Update Change Branch','(Branch changed from).*',
'system',current_timestamp,null,null);

INSERT INTO SYSTEM_CONFIGURATION (ID, NAME, DESCRIPTION, CONFIG, CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE) VALUES
((SELECT MAX(ID) + 1 FROM SYSTEM_CONFIGURATION), 'dcms.function.pattern.Withheld_Auto_Renewal','Pattern for Withheld_Auto_Renewal','Auto renewal turned Off',
'system',current_timestamp,null,null);

INSERT INTO SYSTEM_CONFIGURATION (ID, NAME, DESCRIPTION, CONFIG, CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE) VALUES
((SELECT MAX(ID) + 1 FROM SYSTEM_CONFIGURATION), 'dcms.function.pattern.Change_Withheld','Pattern for Batch Update Change Withheld','Auto renewal turned On',
'system',current_timestamp,null,null);

INSERT INTO SYSTEM_CONFIGURATION (ID, NAME, DESCRIPTION, CONFIG, CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE) VALUES
((SELECT MAX(ID) + 1 FROM SYSTEM_CONFIGURATION), 'dcms.function.pattern.Modify_CIF','Pattern for Modify CIF','(Modify CIF request raised for).*',
'system',current_timestamp,null,null);

INSERT INTO SYSTEM_CONFIGURATION (ID, NAME, DESCRIPTION, CONFIG, CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE) VALUES
((SELECT MAX(ID) + 1 FROM SYSTEM_CONFIGURATION), 'dcms.function.pattern.Update_CC_Balance','Pattern for Update Cash Card Balance','^Request to.*(Debit|Credit).*',
'system',current_timestamp,null,null);

INSERT INTO SYSTEM_CONFIGURATION (ID, NAME, DESCRIPTION, CONFIG, CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE) VALUES
((SELECT MAX(ID) + 1 FROM SYSTEM_CONFIGURATION), 'dcms.function.pattern.Update_CC_Acc_Sts','Pattern for Update Cash Card Account Status','(Request to change account status from).*',
'system',current_timestamp,null,null);