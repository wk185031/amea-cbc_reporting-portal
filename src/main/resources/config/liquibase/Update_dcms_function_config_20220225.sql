UPDATE SYSTEM_CONFIGURATION SET NAME = 'dcms.function.pattern.Card_Renewal/Replacement' WHERE NAME = 'dcms.function.pattern.Renewal_Replace';

UPDATE SYSTEM_CONFIGURATION SET CONFIG = 'Auto renewal value changed from (Yes|No) to (Yes|No)' WHERE NAME = 'dcms.function.pattern.Withheld_Auto_Renewal';

UPDATE SYSTEM_CONFIGURATION SET CONFIG = 'Auto renewal turned (On|Off)' WHERE NAME = 'dcms.function.pattern.Change_Withheld';