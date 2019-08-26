package my.com.mandrill.base.reporting.crypto;

import java.net.MalformedURLException;
import java.net.URL;

import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import javax.xml.ws.WebEndpoint;
import javax.xml.ws.WebServiceClient;
import javax.xml.ws.WebServiceFeature;

@WebServiceClient(name = "JMSCryptoService", wsdlLocation = "file:/F:/ci-build/Alaric/5.0.00/workspace/authentic-crypto-common/src/main/resources/AuthenticCryptoService.wsdl", targetNamespace = "http://jms.crypto.authentic.com/CryptoService")
public class JMSCryptoService extends Service {

	public final static URL WSDL_LOCATION;
	public final static QName SERVICE = new QName("http://jms.crypto.authentic.com/CryptoService", "JMSCryptoService");
	public final static QName ServicePort = new QName("http://jms.crypto.authentic.com/CryptoService", "ServicePort");
	static {
		URL url = null;
		try {
			url = new URL(
					"file:/F:/ci-build/Alaric/5.0.00/workspace/authentic-crypto-common/src/main/resources/AuthenticCryptoService.wsdl");
		} catch (MalformedURLException e) {
			java.util.logging.Logger.getLogger(JMSCryptoService.class.getName()).log(java.util.logging.Level.INFO,
					"Can not initialize the default wsdl from {0}",
					"file:/F:/ci-build/Alaric/5.0.00/workspace/authentic-crypto-common/src/main/resources/AuthenticCryptoService.wsdl");
		}
		WSDL_LOCATION = url;
	}

	public JMSCryptoService(URL wsdlLocation) {
		super(wsdlLocation, SERVICE);
	}

	public JMSCryptoService(URL wsdlLocation, QName serviceName) {
		super(wsdlLocation, serviceName);
	}

	public JMSCryptoService() {
		super(WSDL_LOCATION, SERVICE);
	}

	// This constructor requires JAX-WS API 2.2. You will need to endorse the 2.2
	// API jar or re-run wsdl2java with "-frontend jaxws21" to generate JAX-WS 2.1
	// compliant code instead.
	public JMSCryptoService(WebServiceFeature... features) {
		super(WSDL_LOCATION, SERVICE, features);
	}

	// This constructor requires JAX-WS API 2.2. You will need to endorse the 2.2
	// API jar or re-run wsdl2java with "-frontend jaxws21" to generate JAX-WS 2.1
	// compliant code instead.
	public JMSCryptoService(URL wsdlLocation, WebServiceFeature... features) {
		super(wsdlLocation, SERVICE, features);
	}

	// This constructor requires JAX-WS API 2.2. You will need to endorse the 2.2
	// API jar or re-run wsdl2java with "-frontend jaxws21" to generate JAX-WS 2.1
	// compliant code instead.
	public JMSCryptoService(URL wsdlLocation, QName serviceName, WebServiceFeature... features) {
		super(wsdlLocation, serviceName, features);
	}

	/**
	 *
	 * @return returns CryptoPortType
	 */
	@WebEndpoint(name = "ServicePort")
	public CryptoPortType getServicePort() {
		return super.getPort(ServicePort, CryptoPortType.class);
	}

	/**
	 * 
	 * @param features
	 *            A list of {@link javax.xml.ws.WebServiceFeature} to configure on
	 *            the proxy. Supported features not in the <code>features</code>
	 *            parameter will have their default values.
	 * @return returns CryptoPortType
	 */
	@WebEndpoint(name = "ServicePort")
	public CryptoPortType getServicePort(WebServiceFeature... features) {
		return super.getPort(ServicePort, CryptoPortType.class, features);
	}
}
