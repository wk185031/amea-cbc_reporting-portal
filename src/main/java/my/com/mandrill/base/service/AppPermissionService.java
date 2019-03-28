package my.com.mandrill.base.service;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.CREATE;
import static my.com.mandrill.base.service.AppPermissionService.DOT;
import static my.com.mandrill.base.service.AppPermissionService.OPER;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_INSTITUTION;

import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.domain.AppResource;
import my.com.mandrill.base.security.SecurityUtils;

/**
 * Custom service to evaluate authorization requests.
 * <p>
 * Usage:
 * <pre>
 * @PreAuthorize("@AppPermissionService.hasPermission('resource')")
 * </pre>
 * Example:
 * <pre>
 * @PreAuthorize("@AppPermissionService.hasPermission('OPER:CompanyStructure.READ')")
 * </pre>
 * </p>
 */
@Component("AppPermissionService")
public class AppPermissionService {

    private final Logger log = LoggerFactory.getLogger(AppPermissionService.class);

	private final AppService appService;

    public static final String MENU = "MENU";
    public static final String OPER = "OPER";
    public static final String COLON = ":";
    public static final String DOT = ".";

    public static final String CREATE = "CREATE";
    public static final String READ = "READ";
    public static final String UPDATE = "UPDATE";
    public static final String DELETE = "DELETE";
    public static final String SHIPPING_MANAGER = "SHIPPINGMANAGER";
    public static final String SUPERVISOR = "SUPERVISOR";
    public static final String WORKFLOW = "WORKFLOW";
    
    public static final String RESOURCE_INSTITUTION = "Institution";
    public static final String RESOURCE_USER_ROLE = "UserRole";
    public static final String RESOURCE_USER = "User";
    public static final String RESOURCE_SYSTEM_CONFIGURATION = "SystemConfiguration";
    public static final String RESOURCE_CUSTOMER = "Customer";
    public static final String RESOURCE_WORKFLOW_TEMPLATE = "WorkflowTemplate";
    public static final String RESOURCE_DASHBOARD = "Dashboard";
    public static final String RESOURCE_SHIPMENT = "Shipment";
    public static final String RESOURCE_ENTITY_AUDIT = "EntityAudit";
    public static final String RESOURCE_REPORT_CATEGORY = "ReportCategory";
    public static final String RESOURCE_REPORT_DEFINITION = "ReportDefinition";
    public static final String RESOURCE_GENERATE_REPORT = "GenerateReport";
    public static final String RESOURCE_REPORT_DASHBOARD = "Dashboard";

    public AppPermissionService(AppService companyService) {
		this.appService = companyService;
	}

	/**
     * Evaluates permission for the given resource and access
     *
     * @param resource
     * @return
     */
    public boolean hasPermission(String resource) {
		log.debug("SecurityUtils.getCurrentUserLogin():"+SecurityUtils.getCurrentUserLogin());
		if (!SecurityUtils.getCurrentUserLogin().isPresent()) {
			return false;
		}
    	Set<AppResource> permissions = appService.getPermissionsForUser(SecurityUtils.getCurrentUserLogin().get());

    	boolean hasAccess = false;
        if (permissions != null && !permissions.isEmpty()){
        	hasAccess = permissions.stream().anyMatch(permission -> permission.getCode().equalsIgnoreCase(resource));
        }

        if (hasAccess) {
            log.debug("Role has access to resource: {} ", resource);
        }
        else {
        	log.warn("Role does not have access to resource: {} ", resource);
        }
        return hasAccess;
    }

}
