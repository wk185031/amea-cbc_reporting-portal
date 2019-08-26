package my.com.mandrill.base.reporting.security;

import my.com.mandrill.base.reporting.usec.AuthenticationResultType;
import my.com.mandrill.base.reporting.usec.UsecConstants;

public class UsecClient {

	/** singleton instance reference */
	private static UsecClient instance = null;
	/** authentication result when login or authenticate user is performed */
	private volatile AuthenticationResultType authenticationResult = null;

	/**
	 * 
	 * Initialize and return a static instance of
	 * {@code UnifiedUserSecurityServiceMgr}.<br>
	 * 
	 * 
	 * @return Instance of {@code UnifiedUserSecurityServiceMgr} in memory.
	 */
	public static UsecClient getInstance() {
		if (instance == null) {
			instance = new UsecClient();
		}
		return instance;
	}

	/**
	 * 
	 * Create an instance of {@code UnifiedUserSecurityServiceMgr}.<br>
	 * 
	 * @return Instance of {@code UnifiedUserSecurityServiceMgr} in memory.
	 */
	public static UsecClient createInstance() {
		return new UsecClient();
	}

	/**
	 * 
	 * Return the session token from previous successful authentication.
	 * 
	 * @return Session Token or null when no authentication is completed.
	 */
	public String getSessionToken() {
		if (authenticationResult != null && isAuthenticated()) {
			return authenticationResult.getSessionToken();
		} else {
			return null;
		}
	}

	/**
	 *
	 * Check whether the previous authentication is successful.
	 * 
	 * @return {@code true} if previous authentication is successful.
	 */
	public boolean isAuthenticated() {
		return isAuthenticated(getAuthenticationResult());
	}

	private AuthenticationResultType getAuthenticationResult() {
		return authenticationResult;
	}

	/**
	 *
	 * Check whether the previous authentication is successful.
	 * 
	 * @return {@code true} if previous authentication is successful.
	 */
	public static boolean isAuthenticated(AuthenticationResultType authenticationResult) {
		if (authenticationResult == null || !(authenticationResult.getStatus().equals(UsecConstants.AUTH_OK)
				|| authenticationResult.getStatus().equals(UsecConstants.AUTH_OK_PSWD_CHANGE))) {
			return false;
		} else {
			return true;
		}
	}
}
