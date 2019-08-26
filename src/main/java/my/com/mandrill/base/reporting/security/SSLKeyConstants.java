package my.com.mandrill.base.reporting.security;

import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.net.ssl.SSLContext;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.domain.SecureKey;

public interface SSLKeyConstants {

	final static Logger logger = LoggerFactory.getLogger(SSLKeyConstants.class);

	/** Key to the store key path in a {@link SecureKey} Properties object **/
	static final String KEYSTOREPATH_PROP = "sslKeystorePath";

	/**
	 * Key to the store keystore password in a {@link SecureKey} Properties object
	 **/
	static final String KEYSTORE_PSWD_PROP = "sslKeystorePassword";

	/** Key to the store key type in a {@link SecureKey} Properties object **/
	static final String KEYSTORETYPE_PROP = "sslKeystoreType";

	/** Key to the store key password in a {@link SecureKey} Properties object **/
	static final String KEY_PSWD_PROP = "sslKeyPassword";

	/** Key to the store key alias in a {@link SecureKey} Properties object **/
	static final String KEYALIAS_PROP = "sslKeyAlias";

	/** Name of SSL {@link SecureKey} Category **/
	static final String CATEGORY_NAME = "SSL Key";

	/**
	 * Key to the validator Class alias in a {@link SecureKey} Properties object
	 **/
	static final String VALIDATORCLASS_PROP = "sslValidatorClass";

	/** Key to the validator properties in a {@link SecureKey} Properties object **/
	static final String VALIDATORPARAMETERS_PROP = "sslValidatorParameters";

	/* Name of SSL Truststore secure key record */
	static final String SSL_TRUST_STORENAME = "TRUSTSTORENAME";

	/* Name of SSL Truststore secure key reference in Connector Data */
	static final String CONNECTOR_TRUST_STORENAME = "TrustStoreName";

	/* Name of SSL Keystore secure key record */
	static final String SSL_KEY_STORENAME = "KEYSTORENAME";

	/* Name of SSL Truststore secure key reference in Connector Data */
	static final String CONNECTOR_KEY_STORENAME = "KeyStoreName";

	/* Name of Crypto local web service */
	static final String CRYPTO_LOCAL_WEB_SERVICENAME = "CryptoService";

	/* Name of Secure local web service */
	static final String SECURE_LOCAL_WEB_SERVICENAME = "SecureService";

	/* Flag to enable or disable the secure connection */
	static final String SSL_CONNECTION_FLAG = "ssl.connection.flag";

	/* Field containing list of Enabled Ciphers */
	static final String ENABLED_CIPHER_SUITES = "EnabledCipherSuites";

	/* Field containing list of Enabled Protocols */
	static final String ADDITIONAL_PROTOCOLS = "AdditionalProtocols";

	/* Flag to enable or disable the secure connection */
	static final String SSL_WANT_AUTH = "wantClientAuth";

	/* Flag to enable or disable the secure connection */
	static final String SSL_NEED_AUTH = "needClientAuth";

	/* Default Protocol for the secure connection */
	static final String DEFAULT_PROTOCOL = "TLSv1.2";

	/* Default Protocol for the secure connection */
	static final String PARAMETER_SEPARATOR = ",";

	/**
	 * Get the protocol list to be enabled for the connection. If passed
	 * 'allowedProtocols' is null, the function returns the Authentic default
	 * protocol. If passed 'allowedprotocols' is not null and does not contain
	 * Authentic default protocol, the function adds the default protocols to the
	 * list and returns.
	 * 
	 * @param allowedProtocols
	 *            - Configured protocols for the connection.
	 * @return List of protocols to enable for the connection.
	 */
	public static String[] getProtocolsList(String allowedProtocols) {
		String protocolList = SSLKeyConstants.DEFAULT_PROTOCOL;
		if (null != allowedProtocols && !allowedProtocols.isEmpty()) {
			for (String protocol : Arrays.asList(allowedProtocols.split(PARAMETER_SEPARATOR))) {
				if (!protocol.matches(SSLKeyConstants.DEFAULT_PROTOCOL)) {
					protocolList = protocolList + PARAMETER_SEPARATOR + protocol;
				}
			}
		}
		logger.debug("Enabled Protocols = [" + protocolList + "]");
		return protocolList.split(PARAMETER_SEPARATOR);
	}

	/**
	 * Get the protocol list to be excluded for the connection. If passed
	 * 'allowedProtocols' is null, the function returns all protocols enabled in the
	 * JVM except the Authentic default protocol. If passed 'allowedprotocols' is
	 * not null, the function returns all protocols enabled in the JVM expect the
	 * values in 'allowedprotocols' and Authentc default protocol.
	 * 
	 * @param list
	 *            - Configured protocols for the connection.
	 * @return List of protocols to exclude for the connection.
	 */
	public static List<String> getExcludeProtocolsList(String list) {
		List<String> excludeProtocols = new ArrayList<String>();
		try {
			String[] defaultProtocols = SSLContext.getDefault().getSupportedSSLParameters().getProtocols();
			for (String defaultProtocol : defaultProtocols) {
				if (!defaultProtocol.matches(SSLKeyConstants.DEFAULT_PROTOCOL)) {
					if (list == null || list.isEmpty()) {
						excludeProtocols.add(defaultProtocol);
						continue;
					}
					boolean match = false;
					for (String enabledProtocol : Arrays.asList(list.split(PARAMETER_SEPARATOR))) {
						if (enabledProtocol.matches(defaultProtocol)) {
							match = true;
							break;
						}
					}
					if (!match) {
						excludeProtocols.add(defaultProtocol);
					}
				}
			}
		} catch (NoSuchAlgorithmException e) {
			logger.error("Failed to retrieve default protocols.", e);
		}

		logger.debug("Exclude Protocols = " + Arrays.toString(excludeProtocols.toArray()));
		return excludeProtocols;
	}
}
