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
 * Java class for encryptValueType complex type.
 * 
 * <p>
 * The following schema fragment specifies the expected content contained within
 * this class.
 * 
 * <pre>
 * &lt;complexType name="encryptValueType"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Data" type="{http://www.w3.org/2001/XMLSchema}hexBinary"/&gt;
 *         &lt;element name="EncryptionKeyID" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "encryptValueType", propOrder = { "data", "encryptionKeyID" })
public class EncryptValueType {

	@XmlElement(name = "Data", required = true, type = String.class)
	@XmlJavaTypeAdapter(HexBinaryAdapter.class)
	@XmlSchemaType(name = "hexBinary")
	protected byte[] data;
	@XmlElement(name = "EncryptionKeyID")
	protected int encryptionKeyID;

	/**
	 * Gets the value of the data property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public byte[] getData() {
		return data;
	}

	/**
	 * Sets the value of the data property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setData(byte[] value) {
		this.data = value;
	}

	/**
	 * Gets the value of the encryptionKeyID property.
	 * 
	 */
	public int getEncryptionKeyID() {
		return encryptionKeyID;
	}

	/**
	 * Sets the value of the encryptionKeyID property.
	 * 
	 */
	public void setEncryptionKeyID(int value) {
		this.encryptionKeyID = value;
	}
}
