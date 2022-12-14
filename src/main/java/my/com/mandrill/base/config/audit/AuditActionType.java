package my.com.mandrill.base.config.audit;

public enum AuditActionType {

	CONFIGURATION_CREATE,
	CONFIGURATION_UPDATE,
	CONFIGURATION_DELETE,
	
	
	
	INSTITUTION_CREATE,
	INSTITUTION_UPDATE,
	INSTITUTION_DELETE,
	LOGIN,
	LOGOUT,
	PASSWORD_CHANGE,
	PASSWORD_RESET,
	REPORT_CATEGORY_CREATE,
	REPORT_CATEGORY_UPDATE,
	REPORT_CATEGORY_DELETE,
	REPORT_DEFINITION_CREATE,
	REPORT_DEFINITION_UPDATE,
	REPORT_DEFINITION_DELETE,
	REPORT_DELETE,
	REPORT_DOWNLOAD,
	REPORT_GENERATE,
	ROLE_CREATE,
	ROLE_UPDATE,
	ROLE_DELETE,
	SYNCHRONIZE_DATABASE,
	SYNC_SCHEDULER_UDPATE,
	USER_CREATE,
	USER_UPDATE,
	USER_DELETE,
// --- To refactor
	RESET_PASSWORD_SUCCESS,
	RESET_PASSWORD_FAILED,
	CHANGE_PASSWORD_SUCCESS,
	CHANGE_PASSWORD_FAILED

}
