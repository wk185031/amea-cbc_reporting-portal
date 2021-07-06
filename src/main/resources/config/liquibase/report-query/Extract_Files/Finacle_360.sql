-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-673	01-JULY-2021	WY		Fix empty report generated for Finacle 360
-- CBCAXUPISSLOG-673	06-JULY-2021	WY		Fix issue data generated in one single row

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Transaction Count Report
	i_HEADER_FIELDS := TO_CLOB('[]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"14","fieldName":"CIF ID","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CIF ID","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"15","fieldName":"BANK ID","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"BANK ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"16","fieldName":"CARD / IVRS NUMBER","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CARD / IVRS NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"17","fieldName":"ACCOUNT NUMBER","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"18","fieldName":"OPERATION FLAG","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"OPERATION FLAG","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"19","fieldName":"EMBOSSED NAME","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"EMBOSSED NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"20","fieldName":"CARD / IVRS TYPE","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CARD / IVRS TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"21","fieldName":"CARD SUBTYPE","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CARD SUBTYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"22","fieldName":"CARD / IVRS STATUS","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CARD / IVRS STATUS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"23","fieldName":"NO. OF JOINT ACCOUNT HOLDERS","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"NO. OF JOINT ACCOUNT HOLDERS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"24","fieldName":"CIF ID","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CIF ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"25","fieldName":"ACCOUNT HOLDER TYPE","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"ACCOUNT HOLDER TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"26","fieldName":"DEL / ADD / MOD FLAG","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"DEL / ADD / MOD FLAG","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"eol":true},{"sequence":14,"sectionName":"1","fieldName":"CIF","csvTxtLength":"50","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"2","fieldName":"BANK ID","csvTxtLength":"8","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"3","fieldName":"ATM CARD NUMBER","csvTxtLength":"19","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":17,"sectionName":"4","fieldName":"FROM ACCOUNT NO","csvTxtLength":"16","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":18,"sectionName":"5","fieldName":"OPERATION FLAG","csvTxtLength":"1","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"6","fieldName":"ACCOUNT NAME","csvTxtLength":"80","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"7","fieldName":"CARD TYPE","csvTxtLength":"5","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"8","fieldName":"CARD SUBTYPE","csvTxtLength":"5","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"9","fieldName":"CARD STATUS","csvTxtLength":"1","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"10","fieldName":"NO OF JOINT ACC HOLDERS","csvTxtLength":"2","fieldType":"Integer","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"11","fieldName":"CIF ID","csvTxtLength":"50","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"12","fieldName":"ACCOUNT HOLDER TYPE","csvTxtLength":"50","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"13","fieldName":"FLAG","csvTxtLength":"1","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"eol":true}]');
	i_TRAILER_FIELDS := TO_CLOB('[]');
	
	i_BODY_QUERY := TO_CLOB('				
select * from
(select
	clt.clt_cif_number as "CIF",
	''{Iss_Name}'' as "BANK ID",
	crd.crd_number_enc as "ATM CARD NUMBER",
	crd.CRD_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	bac.bac_account_number as "FROM ACCOUNT NO",
	''A'' as "OPERATION FLAG",
	dcr.dcr_embossing_name as "ACCOUNT NAME",
	''ATM'' as "CARD TYPE",
	prs.prs_name as "CARD SUBTYPE",
	sts.sts_name as "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
from
	{DCMS_Schema}.issuance_debit_card_request@{DB_LINK_DCMS} dcr
	inner join {DCMS_Schema}.issuance_card@{DB_LINK_DCMS} crd on crd.crd_id = dcr.dcr_crd_id
	inner join {DCMS_Schema}.issuance_client@{DB_LINK_DCMS} clt on clt.clt_id = dcr.dcr_clt_id
	inner join {DCMS_Schema}.issuance_bank_account@{DB_LINK_DCMS} bac on bac.bac_clt_id = clt.clt_id
	inner join {DCMS_Schema}.card_program_setup@{DB_LINK_DCMS} prs on prs.prs_id = dcr.dcr_prs_id
	inner join {DCMS_Schema}.master_status@{DB_LINK_DCMS} sts on sts_id = dcr.dcr_sts_id
	inner join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON crd.CRD_INS_ID = INS.INS_ID
where dcr.dcr_ins_id = {Iss_Id}
union all
select
	clt.clt_cif_number as "CIF",
	''{Iss_Name}'' as "BANK ID",
	csh.csh_card_number_enc as "ATM CARD NUMBER",
	csh.CSH_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	bac.bac_account_number as "FROM ACCOUNT NO",
	''A'' as "OPERATION FLAG",
	ccr.ccr_embossing_name as "ACCOUNT NAME",
	''CASH'' as "CARD TYPE",
	prs.prs_name as "CARD SUBTYPE",
	sts.sts_name as "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
from
	{DCMS_Schema}.issuance_cash_card_request@{DB_LINK_DCMS} ccr
	inner join {DCMS_Schema}.issuance_cash_card@{DB_LINK_DCMS} csh on csh.csh_id = ccr.ccr_csh_id
	inner join {DCMS_Schema}.issuance_client@{DB_LINK_DCMS} clt on clt.clt_id = ccr.ccr_clt_id
	inner join {DCMS_Schema}.issuance_bank_account@{DB_LINK_DCMS} bac on bac.bac_clt_id = clt.clt_id
	inner join {DCMS_Schema}.card_program_setup@{DB_LINK_DCMS} prs on prs.prs_id = ccr.ccr_prs_id
	inner join {DCMS_Schema}.master_status@{DB_LINK_DCMS} sts on sts_id = ccr.ccr_sts_id
	inner join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON csh.CSH_INS_ID = INS.INS_ID
	where ccr.ccr_ins_id = {Iss_Id}) tb
	where tb."ROTATION_NUMBER" is not null
order by
	tb.cif, tb."ATM CARD NUMBER"		
	');	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Finacle 360';
	
END;
/