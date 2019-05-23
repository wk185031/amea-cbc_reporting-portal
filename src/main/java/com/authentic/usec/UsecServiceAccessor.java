/*
 * This Program forms part of a Software Product. All and any copyright,
 * trademark or other intellectual property rights used or embodied in or in
 * connection with this Program and the Software Product and including all
 * documentation relating thereto is and shall remain the exclusive property of
 * NCR Limited. Except as may be expressly permitted under the UK
 * Copyright, Designs and Patents Act 1988 as amended by the UK Copyright
 * (Computer Programs) Regulations 1992 or any other relevant national law or
 * as may be expressly permitted in a properly executed licence agreement
 * between NCR Limited and you, you shall have no rights to (and shall
 * not attempt to nor allow any third party to or attempt to) adapt, alter,
 * amend, modify, reverse engineer, decompile, disassemble or decode the whole
 * or any part of the Program or Software Product or translate the whole or any
 * part of the Program or Software Product into another language nor shall you
 * create derivative works of the Program or Software Product.
 */

package com.authentic.usec;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.ws.Service;

import org.apache.cxf.transport.jms.spec.JMSSpecConstants;

import com.authentic.usec.usecservice.AuthenticateUserRequestType;
import com.authentic.usec.usecservice.AuthenticateUserResponseType;
import com.authentic.usec.usecservice.AuthenticationResultType;
import com.authentic.usec.usecservice.AuthoriseUserRequest;
import com.authentic.usec.usecservice.AuthoriseUserResponse;
import com.authentic.usec.usecservice.ChangePasswordCredentialType;
import com.authentic.usec.usecservice.ChangePasswordRequestType;
import com.authentic.usec.usecservice.ChangePasswordResponseType;
import com.authentic.usec.usecservice.ChangeUserGroupStatusRequestType;
import com.authentic.usec.usecservice.ChangeUserGroupStatusResponseType;
import com.authentic.usec.usecservice.GetAllPermissionTypeRequestType;
import com.authentic.usec.usecservice.GetAllPermissionTypeResponseType;
import com.authentic.usec.usecservice.GetSessionInfoRequest;
import com.authentic.usec.usecservice.GetSessionInfoResponseType;
import com.authentic.usec.usecservice.InvalidateSessionRequestType;
import com.authentic.usec.usecservice.InvalidateSessionResponseType;
import com.authentic.usec.usecservice.IsPermissionGrantedRequestType;
import com.authentic.usec.usecservice.IsPermissionGrantedResponseType;
import com.authentic.usec.usecservice.PermissionType;
import com.authentic.usec.usecservice.SessionInfoType;
import com.authentic.usec.usecservice.UpdatePasswordRequest;
import com.authentic.usec.usecservice.UsecServicePortType;
import com.authentic.usec.usecservice.UserCredentialType;
import com.authentic.usec.usecservice.ValidateCredentialRequest;
import com.authentic.usec.usecservice.ValidateSessionRequestType;
import com.authentic.usec.usecservice.ValidateSessionResponseType;



/**
 * Performs local or remote (web service) calls for Unified user security services.
 *
 * @author NCR Limited
 **/
/*
 * Tracking				Date			Name		Description
 * AUTH-2541			23-FEB-2015		KL-ARA		Baseline.
 * AUTH-2541			11-MAR-2015		KL-ARA		Add Properties for service configuration.
 * AUTH-2541			13-MAR-2015 	KL-ARA  	Standardize URL constant for endpoint.
 * AUTH-2541			16-MAR-2015		KL-ARA		Rename UsecServiceMgr to UsecClient.
 * AUTH-2541			24-MAR-2015		KL-ARA		Add changes from the WSDL changes.
 * AUTH-2541			01-APR-2015		KL-ARA		Add method WSDL getSessionInfo().
 * AUTH-2541			20-APR-2015		KL-ARA		Remove class name and uses FINEST log level. 
 */
public class UsecServiceAccessor {
	private final static Logger logger = Logger.getLogger(UsecServiceAccessor.class.getName());
	
	/** service endpoint url configuration in properties*/
	public final static String USEC_SERVICE_ENDPOINT = "usec-service.endpoint";
	/** default local web service name */
	public static final String LOCAL_WEBSERVICE_PROCESS = "UsecService";
	/** default local web service executive process name */
	public static final String LOCAL_WEBSERVICE_NAME    = "UsecService";
	
	public static final String DEFAULT_LOCAL_SERVICE_CLASSS = "com.authentic.architecture.security.UsecServiceBaseImpl";
	
	private static UsecServicePortType serviceCaller;
	
	private static Properties serviceProperties;
	
	private static UsecServicePortType getCaller() {
		if(serviceCaller == null) {
			// always tries to get local implementation first.
			serviceCaller = getLocal();
			
			// then tries remote calls
			if(serviceCaller == null) {
				serviceCaller = getRemote();
			}
			
			// When fails throws exception.
			if(serviceCaller == null) {
				throw new IllegalStateException("Fails to obtain service implementation calls");
			}
		}
		return serviceCaller;
	}
	
	private static UsecServicePortType getRemote() {
		UsecServicePortType remoteImpl = null;
		String endpointPublishingUrl = null;
		endpointPublishingUrl = "jms:queue:authentic.unifiedqueue?jndiInitialContextFactory=com.authentic.activemq.jndi.ActiveMQSSLInitialContextFactory&jndiURL=tcp://153.58.18.104:61616&priority=3&timeToLive=10000&receiveTimeout=10000&jndi-serviceName=UsecService";
		logger.finest("Using remote URL ["+endpointPublishingUrl+"] webservice endpoint.");
		
		if(endpointPublishingUrl == null) {
			throw new IllegalStateException("Invalid service endpoint url");
		}

		try {
			Service service = Service.create(com.authentic.usec.usecservice.UsecService.SERVICE);
			service.addPort(com.authentic.usec.usecservice.UsecService.SERVICE, JMSSpecConstants.SOAP_JMS_SPECIFICATION_TRANSPORTID, endpointPublishingUrl);
			remoteImpl = service.getPort(com.authentic.usec.usecservice.UsecService.SERVICE,  UsecServicePortType.class);
		}catch(Exception e) {
			logger.finest("Failed to load remote service, exception ["+e+"]");
			e.printStackTrace();
		}

		return remoteImpl;
	}
	
	private static UsecServicePortType getLocal() {
		UsecServicePortType localImpl = null;
		String localClass = DEFAULT_LOCAL_SERVICE_CLASSS;
		logger.finest("Loading local service class ["+localClass+"].");
		try {
			ClassLoader classLoader = UsecServiceAccessor.class.getClassLoader();
			@SuppressWarnings("rawtypes")
			Class serverImpl = classLoader.loadClass(localClass);
			localImpl = (UsecServicePortType) serverImpl.newInstance();
		}catch(ClassNotFoundException | InstantiationException | IllegalAccessException e) {
			logger.finest(UsecServiceAccessor.class+": Failed to load local service, exception [" + e + "]");
		}
		return localImpl;
	}
	
	private static String getProperty(String key, String defaultValue) {
		if(serviceProperties != null) {
			if(defaultValue != null) {
				return serviceProperties.getProperty(key, defaultValue);
			}else{
				return serviceProperties.getProperty(key);
			}
		}
		
		return null;
	}
	
	public static AuthenticationResultType authenticateUser(UserCredentialType userCredential, boolean retrieveMenu) {
		logger.finest("Executing method authenticateUser at ["+LocalDateTime.now()+"]");
		AuthenticateUserRequestType req  = new AuthenticateUserRequestType();
		userCredential.setSessionRequired(true);
		req.setCredential(userCredential);
		req.setRetrieveMenu(retrieveMenu);
		AuthenticateUserResponseType res = getCaller().authenticateUser(req);
		logger.finest("Completed method authenticateUser at ["+LocalDateTime.now()+"]");
		return res.getAuthenticationResult();
	}
	
	public static AuthenticationResultType validateCredential(String sessionToken, UserCredentialType userCredential) {
		logger.finest("Executing method validateCredential at ["+LocalDateTime.now()+"]");
		ValidateCredentialRequest req  = new ValidateCredentialRequest();
		userCredential.setSessionRequired(false);
		req.setSessionToken(sessionToken);
		req.setCredential(userCredential);
		AuthenticationResultType res = getCaller().validateCredential(req);
		logger.finest("Completed method validateCredential at ["+LocalDateTime.now()+"]");
		return res;
	}
	
	public static List<com.authentic.usec.usecservice.MenuType> authoriseUser(String sessionToken) {
		logger.finest("Executing method authoriseUser at ["+LocalDateTime.now()+"]");
		AuthoriseUserRequest req = new AuthoriseUserRequest();
		req.setSessionToken(sessionToken);
		AuthoriseUserResponse res = getCaller().authoriseUser(req);
		logger.finest("Completed method authoriseUser at ["+LocalDateTime.now()+"]");
		return res.getMenus();
	}
	
	public static ValidateSessionResponseType validateSession(String sessionToken, boolean extendSession) {
		logger.finest("Executing method validateSession at ["+LocalDateTime.now()+"]");
		ValidateSessionRequestType req = new ValidateSessionRequestType();
		req.setSessionToken(sessionToken);
		req.setExtendSession(extendSession);
		ValidateSessionResponseType res = getCaller().validateSession(req);
		logger.finest("Completed method validateSession at ["+LocalDateTime.now()+"]");
		return res;
	}
	
	public static ChangePasswordResponseType changePassword(String sessionToken, ChangePasswordCredentialType credential) {
		logger.finest("Executing method changePassword at ["+LocalDateTime.now()+"]");
		ChangePasswordRequestType req = new ChangePasswordRequestType();
		req.setSessionToken(sessionToken);
		req.setCredential(credential);
		ChangePasswordResponseType res = getCaller().changePassword(req);
		logger.finest("Completed method changePassword at ["+LocalDateTime.now()+"]");
		return res;
	}
	
	public static boolean invalidateSession(String sessionToken) {
		logger.finest("Executing method invalidateSession at ["+LocalDateTime.now()+"]");
		InvalidateSessionRequestType req = new InvalidateSessionRequestType();
		req.setSessionToken(sessionToken);
		InvalidateSessionResponseType res = getCaller().invalidateSession(req);
		logger.finest("Completed method invalidateSession at ["+LocalDateTime.now()+"]");
		return res.isSessionInvalidated();
	}
	
	public static List<PermissionType> getAllPermissionType(String sessionToken) {
		logger.finest("Executing method getAllPermissionType at ["+LocalDateTime.now()+"]");
		GetAllPermissionTypeRequestType req = new GetAllPermissionTypeRequestType();
		req.setSessionToken(sessionToken);
		GetAllPermissionTypeResponseType res = getCaller().getAllPermissionType(req);
		logger.finest("Completed method getAllPermissionType at ["+LocalDateTime.now()+"]");
		return res.getPermissions();
	}
	
	public static boolean changeUserStatus(String sessionToken, UserCredentialType changedUserCredential) {
		logger.finest("Executing method changeUserStatus at ["+LocalDateTime.now()+"]");
		ChangeUserGroupStatusRequestType req = new ChangeUserGroupStatusRequestType();
		req.setSessionToken(sessionToken);
		req.setChangedUserCredential(changedUserCredential);
		ChangeUserGroupStatusResponseType res = getCaller().changeUserStatus(req);
		logger.finest("Completed method changeUserStatus at ["+LocalDateTime.now()+"]");
		return res.isIsStatusChanged();
	}
	
	public static boolean isPermissionGranted(String sessionToken, PermissionType permissionType) {
		logger.finest("Executing method isUserAllowedPermission at ["+LocalDateTime.now()+"]");
		IsPermissionGrantedRequestType req = new IsPermissionGrantedRequestType();
		req.setSessionToken(sessionToken);
		req.setPermission(permissionType);
		IsPermissionGrantedResponseType res = getCaller().isPermissionGranted(req);
		logger.finest("Completed method isUserAllowedPermission at ["+LocalDateTime.now()+"]");
		return res.isPermissionAllowed();
	}
	
	public static ChangePasswordResponseType updatePassword(String sessionToken, ChangePasswordCredentialType credential) {
		logger.finest("Executing method updatePassword at ["+LocalDateTime.now()+"]");
		UpdatePasswordRequest req = new UpdatePasswordRequest();
		req.setSessionToken(sessionToken);
		req.setCredential(credential);
		ChangePasswordResponseType res = getCaller().updatePassword(req);
		logger.finest("Completed method updatePassword at ["+LocalDateTime.now()+"]");
		return res;
	}
	
	public static SessionInfoType getSessionInfo(String sessionToken) {
		logger.finest("Executing method getSessionInfo at ["+LocalDateTime.now()+"]");
		GetSessionInfoRequest req = new GetSessionInfoRequest();
		req.setSessionToken(sessionToken);
		GetSessionInfoResponseType res = getCaller().getSessionInfo(req);
		logger.finest("Completed method getSessionInfo at ["+LocalDateTime.now()+"]");
		return res.getSessionInfoType();
	}

	/**
	 * @return Returns the serviceProperties.
	 */
	public static Properties getServiceProperties() {
		return serviceProperties;
	}

	/**
	 * @param serviceProperties The serviceProperties to set.
	 */
	public static void setServiceProperties(Properties serviceProperties) {
		UsecServiceAccessor.serviceProperties = serviceProperties;
	}
}
