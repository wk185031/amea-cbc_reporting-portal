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
 * Java class for decryptResponseType complex type.
 * 
 * <p>
 * The following schema fragment specifies the expected content contained within
 * this class.
 * 
 * <pre>
 * &lt;complexType name="decryptResponseType"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Value" type="{http://www.w3.org/2001/XMLSchema}hexBinary"/&gt;
 *         &lt;element name="EncryptionKeyID" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *         &lt;element name="ResultCode" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *         &lt;element name="ResultMessage" type="{http://www.w3.org/2001/XMLSchema}string"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "decryptResponseType", propOrder = { "value", "encryptionKeyID", "resultCode", "resultMessage" })
public class DecryptResponseType {

	@XmlElement(name = "Value", required = true, type = String.class)
	@XmlJavaTypeAdapter(HexBinaryAdapter.class)
	@XmlSchemaType(name = "hexBinary")
	protected byte[] value;
	@XmlElement(name = "EncryptionKeyID")
	protected int encryptionKeyID;
	@XmlElement(name = "ResultCode", required = true)
	protected String resultCode;
	@XmlElement(name = "ResultMessage", required = true)
	protected String resultMessage;

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

	/**
	 * Gets the value of the resultCode property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getResultCode() {
		return resultCode;
	}

	/**
	 * Sets the value of the resultCode property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setResultCode(String value) {
		this.resultCode = value;
	}

	/**
	 * Gets the value of the resultMessage property.
	 * 
	 * @return possible object is {@link String }
	 * 
	 */
	public String getResultMessage() {
		return resultMessage;
	}

	/**
	 * Sets the value of the resultMessage property.
	 * 
	 * @param value
	 *            allowed object is {@link String }
	 * 
	 */
	public void setResultMessage(String value) {
		this.resultMessage = value;
	}
}
