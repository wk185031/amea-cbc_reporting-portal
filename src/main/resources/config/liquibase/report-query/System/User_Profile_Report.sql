-- Tracking					Date			Name	Description
-- CBCAXUPISSLOG-06			16-FEB-2022		LY		Initial Release

DECLARE

	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;

BEGIN 
	  i_BODY_FIELDS := ('[{"sequence":1,"sectionName":"L2","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Group/Role ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Role_ID Label","firstField":true},{"sequence":2,"sectionName":"L3","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Group/Role Name","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Role_Name Label"},{"sequence":3,"sectionName":"L4","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Total Members","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Total_Member Label"},{"sequence":4,"sectionName":"L5","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"List of Members  (User ID & User Name)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Members_List Label"},{"sequence":5,"sectionName":"L6","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Access Rights,  Permissions & Limits","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Permission_List Label"},{"sequence":6,"sectionName":"L7","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Date Group/Role ID Created","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Created_Date Label","eol":true},{"sequence":7,"sectionName":"F2","fieldName":"Role_ID","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"firstField":true},{"sequence":8,"sectionName":"F3","fieldName":"Role_Name","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"F4","fieldName":"Total_Member","fieldType":"Number","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"F5","fieldName":"Members_List","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"F6","fieldName":"Permission_List","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"F7","fieldName":"Created_Date","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');  
	
	  i_BODY_QUERY := TO_CLOB('select DISTINCT re1.NAME as Role_ID,
			re1.DESCRIPTION as Role_Name,
			(select count(ju2.LOGIN)
    			from JHI_USER ju2
    			join USER_EXTRA ue2 on ju2.ID = ue2.USER_ID
    			join USER_EXTRA_ROLES uer2 on uer2.USER_EXTRAS_ID = ue2.ID where uer1.ROLES_ID = uer2.ROLES_ID) as Total_Member,
			(select LISTAGG(ju3.LOGIN, '', '') within group (order by ju3.LOGIN)
    			from JHI_USER ju3
    			join USER_EXTRA ue3 on ju3.ID = ue3.USER_ID
    			join USER_EXTRA_ROLES uer3 on uer3.USER_EXTRAS_ID = ue3.ID where uer1.ROLES_ID = uer3.ROLES_ID) as Members_List,
			(select LISTAGG(ar3.NAME, '', '') within group (order by ar3.NAME)
    			from ROLE_EXTRA re3
    			join ROLE_EXTRA_PERMISSIONS rep3 on rep3.ROLE_EXTRAS_ID = re3.ID
    			join APP_RESOURCE ar3 on rep3.PERMISSIONS_ID = ar3.ID where uer1.ROLES_ID = re3.ID) as Permission_List,
		re1.CREATED_DATE as Created_Date
		from ROLE_EXTRA re1
		join USER_EXTRA_ROLES uer1 on uer1.ROLES_ID = re1.ID
		join USER_EXTRA ue1 on ue1.ID = uer1.USER_EXTRAS_ID
		join JHI_USER ju1 on ju1.ID = ue1.USER_ID');
		
	  UPDATE REPORT_DEFINITION SET 
	    RED_BODY_FIELDS = i_BODY_FIELDS,
	  	RED_BODY_QUERY = i_BODY_QUERY 
	  WHERE RED_NAME = 'List of Groups Roles Report';
	  
END;
/