package my.com.mandrill.base.reporting.usec;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>
 * Java class for MenuType complex type.
 * 
 * <p>
 * The following schema fragment specifies the expected content contained within
 * this class.
 * 
 * <pre>
 * &lt;complexType name="MenuType"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Id" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *         &lt;element name="Type" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="Specialised" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="Icon" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="Name" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="MakerEnforced" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="ParentId" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/&gt;
 *         &lt;element name="Sequence" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *         &lt;element name="Class" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="Permissions" type="{http://usec.authentic.com/UsecService/}PermissionType"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "MenuType", propOrder = { "id", "type", "specialised", "icon", "name", "makerEnforced", "parentId",
		"sequence", "clazz", "permissions" })
public class MenuType {

	@XmlElement(name = "Id")
	protected int id;
	@XmlElement(name = "Type", required = true)
	protected String type;
	@XmlElement(name = "Specialised", required = true)
	protected String specialised;
	@XmlElement(name = "Icon", required = true)
	protected String icon;
	@XmlElement(name = "Name", required = true)
	protected String name;
	@XmlElement(name = "MakerEnforced")
	protected boolean makerEnforced;
	@XmlElement(name = "ParentId")
	protected Integer parentId;
	@XmlElement(name = "Sequence")
	protected int sequence;
	@XmlElement(name = "Class", required = true)
	protected String clazz;
	@XmlElement(name = "Permissions", required = true)
	protected PermissionType permissions;

	/**
	 * Gets the value of the id property.
	 * 
	 */
	public int getId() {
		return id;
	}

	/**
	 * Sets the value of the id property.
	 * 
	 */
	public void setId(int value) {
		this.id = value;
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
	 * Gets the value of the specialised property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getSpecialised() {
		return specialised;
	}

	/**
	 * Sets the value of the specialised property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setSpecialised(String value) {
		this.specialised = value;
	}

	/**
	 * Gets the value of the icon property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getIcon() {
		return icon;
	}

	/**
	 * Sets the value of the icon property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setIcon(String value) {
		this.icon = value;
	}

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
	 * Gets the value of the makerEnforced property.
	 * 
	 */
	public boolean isMakerEnforced() {
		return makerEnforced;
	}

	/**
	 * Sets the value of the makerEnforced property.
	 * 
	 */
	public void setMakerEnforced(boolean value) {
		this.makerEnforced = value;
	}

	/**
	 * Gets the value of the parentId property.
	 * 
	 * @return possible object is {@link Integer }
	 * 
	 */
	public Integer getParentId() {
		return parentId;
	}

	/**
	 * Sets the value of the parentId property.
	 * 
	 * @param value
	 *            allowed object is {@link Integer }
	 * 
	 */
	public void setParentId(Integer value) {
		this.parentId = value;
	}

	/**
	 * Gets the value of the sequence property.
	 * 
	 */
	public int getSequence() {
		return sequence;
	}

	/**
	 * Sets the value of the sequence property.
	 * 
	 */
	public void setSequence(int value) {
		this.sequence = value;
	}

	/**
	 * Gets the value of the clazz property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getClazz() {
		return clazz;
	}

	/**
	 * Sets the value of the clazz property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setClazz(String value) {
		this.clazz = value;
	}

	/**
	 * Gets the value of the permissions property.
	 * 
	 * @return possible object is {@link PermissionType }
	 * 
	 */
	public PermissionType getPermissions() {
		return permissions;
	}

	/**
	 * Sets the value of the permissions property.
	 * 
	 * @param value
	 *            allowed object is {@link PermissionType }
	 * 
	 */
	public void setPermissions(PermissionType value) {
		this.permissions = value;
	}
}
