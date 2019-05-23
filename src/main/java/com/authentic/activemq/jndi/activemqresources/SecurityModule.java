//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vhudson-jaxb-ri-2.1-833 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2019.03.06 at 06:20:25 PM SGT 
//


package com.authentic.activemq.jndi.activemqresources;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for SecurityModule complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="SecurityModule">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="protocol" type="{http://www.jndi.activemq.authentic.com/ActiveMQResources}Protocol"/>
 *         &lt;element name="security" type="{http://www.jndi.activemq.authentic.com/ActiveMQResources}Security"/>
 *         &lt;element name="trustStore" type="{http://www.jndi.activemq.authentic.com/ActiveMQResources}KeyStore"/>
 *         &lt;element name="keyStore" type="{http://www.jndi.activemq.authentic.com/ActiveMQResources}KeyStore" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "SecurityModule", propOrder = {
    "protocol",
    "security",
    "trustStore",
    "keyStore"
})
public class SecurityModule {

    @XmlElement(required = true)
    protected Protocol protocol;
    @XmlElement(required = true)
    protected Security security;
    @XmlElement(required = true)
    protected KeyStore trustStore;
    protected KeyStore keyStore;

    /**
     * Gets the value of the protocol property.
     * 
     * @return
     *     possible object is
     *     {@link Protocol }
     *     
     */
    public Protocol getProtocol() {
        return protocol;
    }

    /**
     * Sets the value of the protocol property.
     * 
     * @param value
     *     allowed object is
     *     {@link Protocol }
     *     
     */
    public void setProtocol(Protocol value) {
        this.protocol = value;
    }

    /**
     * Gets the value of the security property.
     * 
     * @return
     *     possible object is
     *     {@link Security }
     *     
     */
    public Security getSecurity() {
        return security;
    }

    /**
     * Sets the value of the security property.
     * 
     * @param value
     *     allowed object is
     *     {@link Security }
     *     
     */
    public void setSecurity(Security value) {
        this.security = value;
    }

    /**
     * Gets the value of the trustStore property.
     * 
     * @return
     *     possible object is
     *     {@link KeyStore }
     *     
     */
    public KeyStore getTrustStore() {
        return trustStore;
    }

    /**
     * Sets the value of the trustStore property.
     * 
     * @param value
     *     allowed object is
     *     {@link KeyStore }
     *     
     */
    public void setTrustStore(KeyStore value) {
        this.trustStore = value;
    }

    /**
     * Gets the value of the keyStore property.
     * 
     * @return
     *     possible object is
     *     {@link KeyStore }
     *     
     */
    public KeyStore getKeyStore() {
        return keyStore;
    }

    /**
     * Sets the value of the keyStore property.
     * 
     * @param value
     *     allowed object is
     *     {@link KeyStore }
     *     
     */
    public void setKeyStore(KeyStore value) {
        this.keyStore = value;
    }

}