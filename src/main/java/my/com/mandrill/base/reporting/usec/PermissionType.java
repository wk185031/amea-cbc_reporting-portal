package my.com.mandrill.base.reporting.usec;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>
 * Java class for PermissionType complex type.
 * 
 * <p>
 * The following schema fragment specifies the expected content contained within
 * this class.
 * 
 * <pre>
 * &lt;complexType name="PermissionType"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Name" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="Category" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="Set" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="Type" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="Access" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "PermissionType", propOrder = { "name", "category", "set", "type", "access" })
public class PermissionType {

	@XmlElement(name = "Name", required = true)
	protected String name;
	@XmlElement(name = "Category", required = true)
	protected String category;
	@XmlElement(name = "Set", required = true)
	protected String set;
	@XmlElement(name = "Type", required = true)
	protected String type;
	@XmlElement(name = "Access", required = true)
	protected String access;

	/**
	 * Gets the value of the name property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getName() {
		return name;
	}

	/**
	 * Sets the value of the name property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setName(String value) {
		this.name = value;
	}

	/**
	 * Gets the value of the category property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getCategory() {
		return category;
	}

	/**
	 * Sets the value of the category property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setCategory(String value) {
		this.category = value;
	}

	/**
	 * Gets the value of the set property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getSet() {
		return set;
	}

	/**
	 * Sets the value of the set property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setSet(String value) {
		this.set = value;
	}

	/**
	 * Gets the value of the type property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getType() {
		return type;
	}

	/**
	 * Sets the value of the type property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setType(String value) {
		this.type = value;
	}

	/**
	 * Gets the value of the access property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getAccess() {
		return access;
	}

	/**
	 * Sets the value of the access property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setAccess(String value) {
		this.access = value;
	}
}
