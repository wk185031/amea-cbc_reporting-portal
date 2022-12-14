package my.com.mandrill.base.reporting.crypto;

public final class JMSSpecConstants {

	public static final String SOAP_JMS_SPECIFICATION_TRANSPORTID = "http://www.w3.org/2010/soapjms/";
	@Deprecated
	public static final String SOAP_JMS_NAMESPACE = SOAP_JMS_SPECIFICATION_TRANSPORTID;

	public static final String SOAP_JMS_PREFIX = "SOAPJMS_";

	// Connection to a destination properties
	// just for jms uri
	public static final String LOOKUPVARIANT_PARAMETER_NAME = "lookupVariant";
	public static final String DESTINATIONNAME_PARAMETER_NAME = "destinationName";
	// other connection destination properties
	public static final String JNDICONNECTIONFACTORYNAME_PARAMETER_NAME = "jndiConnectionFactoryName";
	public static final String JNDIINITIALCONTEXTFACTORY_PARAMETER_NAME = "jndiInitialContextFactory";
	public static final String JNDIURL_PARAMETER_NAME = "jndiURL";
	public static final String JNDICONTEXTPARAMETER_PARAMETER_NAME = "jndiContextParameter";

	// JMS Message Header properties
	public static final String DELIVERYMODE_PARAMETER_NAME = "deliveryMode";
	// Expiration Time
	public static final String TIMETOLIVE_PARAMETER_NAME = "timeToLive";
	public static final String PRIORITY_PARAMETER_NAME = "priority";
	// Destination
	public static final String REPLYTONAME_PARAMETER_NAME = "replyToName";

	// JMS Message properties' names.
	public static final String REQUESTURI_PARAMETER_NAME = "requestURI";
	public static final String BINDINGVERSION_PARAMETER_NAME = "bindingVersion";
	public static final String SOAPACTION_PARAMETER_NAME = "soapAction";
	public static final String TARGETSERVICE_PARAMETER_NAME = "targetService";
	public static final String CONTENTTYPE_PARAMETER_NAME = "contentType";
	public static final String CONTENTENCODING_PARAMETER_NAME = "contentEncoding";
	public static final String ISFAULT_PARAMETER_NAME = "isFault";

	// JMS Field name
	public static final String REQUESTURI_FIELD = SOAP_JMS_PREFIX + REQUESTURI_PARAMETER_NAME;
	public static final String BINDINGVERSION_FIELD = SOAP_JMS_PREFIX + BINDINGVERSION_PARAMETER_NAME;
	public static final String SOAPACTION_FIELD = SOAP_JMS_PREFIX + SOAPACTION_PARAMETER_NAME;
	public static final String TARGETSERVICE_FIELD = SOAP_JMS_PREFIX + TARGETSERVICE_PARAMETER_NAME;
	public static final String CONTENTTYPE_FIELD = SOAP_JMS_PREFIX + CONTENTTYPE_PARAMETER_NAME;
	public static final String CONTENTENCODING_FIELD = SOAP_JMS_PREFIX + CONTENTENCODING_PARAMETER_NAME;
	public static final String ISFAULT_FIELD = SOAP_JMS_PREFIX + ISFAULT_PARAMETER_NAME;

	private JMSSpecConstants() {
	}
}
