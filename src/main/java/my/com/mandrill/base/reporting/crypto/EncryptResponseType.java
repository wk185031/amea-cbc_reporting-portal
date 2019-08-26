package my.com.mandrill.base.reporting.crypto;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>
 * Java class for encryptResponseType complex type.
 * 
 * <p>
 * The following schema fragment specifies the expected content contained within
 * this class.
 * 
 * <pre>
 * &lt;complexType name="encryptResponseType"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Values" type="{http://jms.crypto.authentic.com/CryptoService/types}encryptValueType" maxOccurs="unbounded"/&gt;
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
@XmlType(name = "encryptResponseType", propOrder = { "values", "resultCode", "resultMessage" })
public class EncryptResponseType {

	@XmlElement(name = "Values", required = true)
	protected List<EncryptValueType> values;
	@XmlElement(name = "ResultCode", required = true)
	protected String resultCode;
	@XmlElement(name = "ResultMessage", required = true)
	protected String resultMessage;

	/**
	 * Gets the value of the values property.
	 * 
	 * <p>
	 * This accessor method returns a reference to the live list, not a snapshot.
	 * Therefore any modification you make to the returned list will be present
	 * inside the JAXB object. This is why there is not a <CODE>set</CODE> method
	 * for the values property.
	 * 
	 * <p>
	 * For example, to add a new item, do as follows:
	 * 
	 * <pre>
	 * getValues().add(newItem);
	 * </pre>
	 * 
	 * 
	 * <p>
	 * Objects of the following type(s) are allowed in the list
	 * {@link EncryptValueType }
	 * 
	 * 
	 */
	public List<EncryptValueType> getValues() {
		if (values == null) {
			values = new ArrayList<EncryptValueType>();
		}
		return this.values;
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
