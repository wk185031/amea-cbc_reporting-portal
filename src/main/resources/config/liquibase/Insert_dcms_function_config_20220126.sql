INSERT INTO SYSTEM_CONFIGURATION (ID, NAME, DESCRIPTION, CONFIG, CREATED_BY, CREATED_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_DATE) VALUES
((SELECT MAX(ID) + 1 FROM SYSTEM_CONFIGURATION), 'dcms.function.pattern.Pre-gen.card.activation','Pattern for Pre-gen card activation','^(Kit Number).*',
'system',current_timestamp,null,null);