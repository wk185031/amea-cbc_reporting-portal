package my.com.mandrill.base.reporting.crypto;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

/**
 * <p>
 * Java class for anonymous complex type.
 * 
 * <p>
 * The following schema fragment specifies the expected content contained within
 * this class.
 * 
 * <pre>
 * &lt;complexType&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Header" type="{http://jms.crypto.authentic.com/CryptoService/types}cryptoHeaderType"/&gt;
 *         &lt;element name="Body" type="{http://jms.crypto.authentic.com/CryptoService/types}decryptResponseBody"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = { "header", "body" })
@XmlRootElement(name = "DecryptStringResponse")
public class DecryptStringResponse {

	@XmlElement(name = "Header", required = true)
	protected CryptoHeaderType header;
	@XmlElement(name = "Body", required = true)
	protected DecryptResponseBody body;

	/**
	 * Gets the value of the header property.
	 * 
	 * @return possible object is {@link CryptoHeaderType }
	 * 
	 */
	public CryptoHeaderType getHeader() {
		return header;
	}

	/**
	 * Sets the value of the header property.
	 * 
	 * @param value
	 *            allowed object is {@link CryptoHeaderType }
	 * 
	 */
	public void setHeader(CryptoHeaderType value) {
		this.header = value;
	}

	/**
	 * Gets the value of the body property.
	 * 
	 * @return possible object is {@link DecryptResponseBody }
	 * 
	 */
	public DecryptResponseBody getBody() {
		return body;
	}

	/**
	 * Sets the value of the body property.
	 * 
	 * @param value
	 *            allowed object is {@link DecryptResponseBody }
	 * 
	 */
	public void setBody(DecryptResponseBody value) {
		this.body = value;
	}
}
