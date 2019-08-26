package my.com.mandrill.base.reporting.usec;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>
 * Java class for AuthenticationResultType complex type.
 * 
 * <p>
 * The following schema fragment specifies the expected content contained within
 * this class.
 * 
 * <pre>
 * &lt;complexType name="AuthenticationResultType"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="ApplicationType" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="UserId" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *         &lt;element name="UserName" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="LDAPDomainName" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="GroupId" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *         &lt;element name="GroupName" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="SessionToken" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Status" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="ExceptionReason" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="ExceptionMessage" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Menus" type="{http://usec.authentic.com/UsecService/}MenuType" maxOccurs="unbounded" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "AuthenticationResultType", propOrder = { "applicationType", "userId", "userName", "ldapDomainName",
		"groupId", "groupName", "sessionToken", "status", "exceptionReason", "exceptionMessage", "menus" })
public class AuthenticationResultType {

	@XmlElement(name = "ApplicationType", required = true)
	protected String applicationType;
	@XmlElement(name = "UserId")
	protected int userId;
	@XmlElement(name = "UserName", required = true)
	protected String userName;
	@XmlElement(name = "LDAPDomainName", required = true)
	protected String ldapDomainName;
	@XmlElement(name = "GroupId")
	protected int groupId;
	@XmlElement(name = "GroupName", required = true)
	protected String groupName;
	@XmlElement(name = "SessionToken")
	protected String sessionToken;
	@XmlElement(name = "Status", required = true)
	protected String status;
	@XmlElement(name = "ExceptionReason")
	protected String exceptionReason;
	@XmlElement(name = "ExceptionMessage")
	protected String exceptionMessage;
	@XmlElement(name = "Menus")
	protected List<MenuType> menus;

	/**
	 * Gets the value of the applicationType property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getApplicationType() {
		return applicationType;
	}

	/**
	 * Sets the value of the applicationType property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setApplicationType(String value) {
		this.applicationType = value;
	}

	/**
	 * Gets the value of the userId property.
	 * 
	 */
	public int getUserId() {
		return userId;
	}

	/**
	 * Sets the value of the userId property.
	 * 
	 */
	public void setUserId(int value) {
		this.userId = value;
	}

	/**
	 * Gets the value of the userName property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getUserName() {
		return userName;
	}

	/**
	 * Sets the value of the userName property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setUserName(String value) {
		this.userName = value;
	}

	/**
	 * Gets the value of the ldapDomainName property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getLDAPDomainName() {
		return ldapDomainName;
	}

	/**
	 * Sets the value of the ldapDomainName property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setLDAPDomainName(String value) {
		this.ldapDomainName = value;
	}

	/**
	 * Gets the value of the groupId property.
	 * 
	 */
	public int getGroupId() {
		return groupId;
	}

	/**
	 * Sets the value of the groupId property.
	 * 
	 */
	public void setGroupId(int value) {
		this.groupId = value;
	}

	/**
	 * Gets the value of the groupName property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getGroupName() {
		return groupName;
	}

	/**
	 * Sets the value of the groupName property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setGroupName(String value) {
		this.groupName = value;
	}

	/**
	 * Gets the value of the sessionToken property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getSessionToken() {
		return sessionToken;
	}

	/**
	 * Sets the value of the sessionToken property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setSessionToken(String value) {
		this.sessionToken = value;
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
	 * Gets the value of the exceptionReason property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getExceptionReason() {
		return exceptionReason;
	}

	/**
	 * Sets the value of the exceptionReason property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setExceptionReason(String value) {
		this.exceptionReason = value;
	}

	/**
	 * Gets the value of the exceptionMessage property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getExceptionMessage() {
		return exceptionMessage;
	}

	/**
	 * Sets the value of the exceptionMessage property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setExceptionMessage(String value) {
		this.exceptionMessage = value;
	}

	/**
	 * Gets the value of the menus property.
	 * 
	 * <p>
	 * This accessor method returns a reference to the live list, not a snapshot.
	 * Therefore any modification you make to the returned list will be present
	 * inside the JAXB object. This is why there is not a <CODE>set</CODE> method
	 * for the menus property.
	 * 
	 * <p>
	 * For example, to add a new item, do as follows:
	 * 
	 * <pre>
	 * getMenus().add(newItem);
	 * </pre>
	 * 
	 * 
	 * <p>
	 * Objects of the following type(s) are allowed in the list {@link MenuType }
	 * 
	 * 
	 */
	public List<MenuType> getMenus() {
		if (menus == null) {
			menus = new ArrayList<MenuType>();
		}
		return this.menus;
	}
}
