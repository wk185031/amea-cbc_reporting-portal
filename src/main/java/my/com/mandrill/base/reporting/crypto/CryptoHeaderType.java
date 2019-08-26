package my.com.mandrill.base.reporting.crypto;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.datatype.XMLGregorianCalendar;

/**
 * <p>
 * Java class for cryptoHeaderType complex type.
 * 
 * <p>
 * The following schema fragment specifies the expected content contained within
 * this class.
 * 
 * <pre>
 * &lt;complexType name="cryptoHeaderType"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Username" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Password" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="SessionID" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Service" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Originator" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="RequestTime" type="{http://www.w3.org/2001/XMLSchema}dateTime" minOccurs="0"/&gt;
 *         &lt;element name="ResponseTime" type="{http://www.w3.org/2001/XMLSchema}dateTime" minOccurs="0"/&gt;
 *         &lt;element name="Status" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="StatusMessage" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "cryptoHeaderType", propOrder = { "username", "password", "sessionID", "service", "originator",
		"requestTime", "responseTime", "status", "statusMessage" })
public class CryptoHeaderType {

	@XmlElement(name = "Username")
	protected String username;
	@XmlElement(name = "Password")
	protected String password;
	@XmlElement(name = "SessionID")
	protected String sessionID;
	@XmlElement(name = "Service")
	protected String service;
	@XmlElement(name = "Originator")
	protected String originator;
	@XmlElement(name = "RequestTime")
	@XmlSchemaType(name = "dateTime")
	protected XMLGregorianCalendar requestTime;
	@XmlElement(name = "ResponseTime")
	@XmlSchemaType(name = "dateTime")
	protected XMLGregorianCalendar responseTime;
	@XmlElement(name = "Status")
	protected String status;
	@XmlElement(name = "StatusMessage")
	protected String statusMessage;

	/**
	 * Gets the value of the username property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getUsername() {
		return username;
	}

	/**
	 * Sets the value of the username property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setUsername(String value) {
		this.username = value;
	}

	/**
	 * Gets the value of the password property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getPassword() {
		return password;
	}

	/**
	 * Sets the value of the password property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setPassword(String value) {
		this.password = value;
	}

	/**
	 * Gets the value of the sessionID property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getSessionID() {
		return sessionID;
	}

	/**
	 * Sets the value of the sessionID property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setSessionID(String value) {
		this.sessionID = value;
	}

	/**
	 * Gets the value of the service property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getService() {
		return service;
	}

	/**
	 * Sets the value of the service property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setService(String value) {
		this.service = value;
	}

	/**
	 * Gets the value of the originator property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getOriginator() {
		return originator;
	}

	/**
	 * Sets the value of the originator property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setOriginator(String value) {
		this.originator = value;
	}

	/**
	 * Gets the value of the requestTime property.
	 * 
	 * @return possible object is {@link XMLGregorianCalendar }
	 * 
	 */
	public XMLGregorianCalendar getRequestTime() {
		return requestTime;
	}

	/**
	 * Sets the value of the requestTime property.
	 * 
	 * @param value
	 *            allowed object is {@link XMLGregorianCalendar }
	 * 
	 */
	public void setRequestTime(XMLGregorianCalendar value) {
		this.requestTime = value;
	}

	/**
	 * Gets the value of the responseTime property.
	 * 
	 * @return possible object is {@link XMLGregorianCalendar }
	 * 
	 */
	public XMLGregorianCalendar getResponseTime() {
		return responseTime;
	}

	/**
	 * Sets the value of the responseTime property.
	 * 
	 * @param value
	 *            allowed object is {@link XMLGregorianCalendar }
	 * 
	 */
	public void setResponseTime(XMLGregorianCalendar value) {
		this.responseTime = value;
	}

	/**
	 * Gets the value of the status property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getStatus() {
		return status;
	}

	/**
	 * Sets the value of the status property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setStatus(String value) {
		this.status = value;
	}

	/**
	 * Gets the value of the statusMessage property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getStatusMessage() {
		return statusMessage;
	}

	/**
	 * Sets the value of the statusMessage property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setStatusMessage(String value) {
		this.statusMessage = value;
	}
}
