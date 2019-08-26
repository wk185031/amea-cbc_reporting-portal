package my.com.mandrill.base.reporting.crypto;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.HexBinaryAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;

/**
 * <p>
 * Java class for decryptRequestType complex type.
 * 
 * <p>
 * The following schema fragment specifies the expected content contained within
 * this class.
 * 
 * <pre>
 * &lt;complexType name="decryptRequestType"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Value" type="{http://www.w3.org/2001/XMLSchema}hexBinary"/&gt;
 *         &lt;element name="EncryptionKeyID" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "decryptRequestType", propOrder = { "value", "encryptionKeyID" })
public class DecryptRequestType {

	@XmlElement(name = "Value", required = true, type = String.class)
	@XmlJavaTypeAdapter(HexBinaryAdapter.class)
	@XmlSchemaType(name = "hexBinary")
	protected byte[] value;
	@XmlElement(name = "EncryptionKeyID")
	protected Integer encryptionKeyID;

	/**
	 * Gets the value of the value property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public byte[] getValue() {
		return value;
	}

	/**
	 * Sets the value of the value property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setValue(byte[] value) {
		this.value = value;
	}

	/**
	 * Gets the value of the encryptionKeyID property.
	 * 
	 * @return possible object is {@link Integer }
	 * 
	 */
	public Integer getEncryptionKeyID() {
		return encryptionKeyID;
	}

	/**
	 * Sets the value of the encryptionKeyID property.
	 * 
	 * @param value
	 *            allowed object is {@link Integer }
	 * 
	 */
	public void setEncryptionKeyID(Integer value) {
		this.encryptionKeyID = value;
	}
}
