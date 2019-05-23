/*
 * This Program forms part of a Software Product. All and any copyright,
 * trademark or other intellectual property rights used or embodied in or in
 * connection with this Program and the Software Product and including all
 * documentation relating thereto is and shall remain the exclusive property of
 * NCR Limited. Except as may be expressly permitted under the UK
 * Copyright, Designs and Patents Act 1988 as amended by the UK Copyright
 * (Computer Programs) Regulations 1992 or any other relevant national law or
 * as may be expressly permitted in a properly executed licence agreement
 * between NCR Limited and you, you shall have no rights to (and shall
 * not attempt to nor allow any third party to or attempt to) adapt, alter,
 * amend, modify, reverse engineer, decompile, disassemble or decode the whole
 * or any part of the Program or Software Product or translate the whole or any
 * part of the Program or Software Product into another language nor shall you
 * create derivative works of the Program or Software Product.
 */

package com.authentic.activemq.jndi;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URISyntaxException;
import java.security.SecureRandom;
import java.util.Hashtable;
import java.util.Properties;

import javax.servlet.ServletContext;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.ActiveMQSslConnectionFactory;
import org.apache.activemq.jndi.ActiveMQInitialContextFactory;
import org.apache.log4j.Logger;

import com.authentic.activemq.jndi.activemqresources.ActiveMQResources;
import com.authentic.activemq.jndi.activemqresources.KeyStore;
import com.authentic.activemq.jndi.activemqresources.Security;
import com.authentic.secure.SSLKeyConstants;
import com.authentic.secure.SSLKeyManager;
import com.authentic.secure.key.SSLSecureKey;
import com.ncr.cxp.webui.framework.webservice.utils.Encryption.Data;
import com.ncr.cxp.webui.framework.webservice.utils.impl.AESBase64Data;
import com.ncr.cxp.webui.framework.webservice.utils.impl.AESBase64Encription;

/**
 * ActiveMQSSLInitialContextFactory
 * @author NCR Limited
 **/
/*
 * Tracking             Date            Name        Description
 * AUTH-2511            07 Jan 2015     RW250122    initial version 
 * AUTH-4835            26 JUL 2016     HY-AK    	Fixed resource leak
 * AUTH-4627            26-JUL-2016     HY-AK       Fixed the RESOURCE_LEAK in getKey(ServletContext) method.
 * AUTH-6275            11-MAY-2017     KL-NFM		If security is set to NONE, no need to retrieve the SSL key. 
 * AUTH-6275            11-MAY-2017     KL-NFM		Fixed same issue if security is set to NONE, no need to retrieve the SSL key. 
 */
public class ActiveMQSSLInitialContextFactory extends ActiveMQInitialContextFactory {

    private static final String KEY_KEY = "key.hex";
    private static final String KEY_FILE = "key.properties";
    private Logger logger = Logger.getLogger(ActiveMQSSLInitialContextFactory.class);

    private String getKey(ServletContext servletContext) throws IOException {
        InputStream inputStream = null;
		try{
			if (null != servletContext) {
				try {
					inputStream = servletContext.getResourceAsStream(KEY_FILE);
				} catch (Exception e) {
					this.logger.error(ActiveMQSSLInitialContextFactory.class.getSimpleName() + "#getKey() Unable to load key from servletContext");
					inputStream = null;
				}
			}
			if (null == inputStream) {
				inputStream = Thread.currentThread().getContextClassLoader().getResourceAsStream(KEY_FILE);
			}
			if (null != inputStream) {
				BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));
				String line = bufferedReader.readLine();
				if (null != line) {
					String elements[] = line.split("=");
					if (2 == elements.length && KEY_KEY.equals(elements[0].toLowerCase())) {
						return elements[1];
					}
				}
			}
		} finally{
        	if(inputStream != null){
        		inputStream.close();
        	}
        }
        return null;
    }

    private ActiveMQResources loadResources(ServletContext servletContext) throws Exception {
        InputStream inputStream = null;
        ActiveMQResources resource = null;
        try {
	        if (null != servletContext) {
	            try {
	                inputStream = servletContext.getResourceAsStream("ActiveMQResources.xml");
	            } catch (Exception e) {
	                this.logger.error(ActiveMQSSLInitialContextFactory.class.getSimpleName() + "#loadResources() Unable to load ActiveMQResources.xml from servletContext");
	                inputStream = null;
	            }
	        }
	        if (null == inputStream) {
	            inputStream = Thread.currentThread().getContextClassLoader().getResourceAsStream("ActiveMQResources.xml");
	        }
	        if (null == inputStream) {
	            this.logger.error(ActiveMQSSLInitialContextFactory.class.getSimpleName() + "#loadResources() Unable to load ActiveMQResources.xml");
	            return null;
	        }
	        JAXBContext jaxbContext = JAXBContext.newInstance(ActiveMQResources.class);
	        Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
	        resource = (ActiveMQResources) unmarshaller.unmarshal(inputStream);
        } finally {
        	if(inputStream != null){
	    		inputStream.close();
	    	}
	    }
        if (null != resource) {
            if (resource.isSecure()) {
                String key = getKey(servletContext);
                
                if (!Security.NONE.equals(resource.getSecurityModule().getSecurity())) {
                    KeyStore trustStore = resource.getSecurityModule().getTrustStore();

                    Data data = AESBase64Data.newCipherData(trustStore.getStorePassword(), key);
                    AESBase64Encription.I.decrypt(data);
                    resource.getSecurityModule().getTrustStore().setStorePassword(data.getPlain());

                    data = AESBase64Data.newCipherData(trustStore.getKeyPassword(), key);
                    AESBase64Encription.I.decrypt(data);
                    resource.getSecurityModule().getTrustStore().setKeyPassword(data.getPlain());

                    if (Security.TWO_WAY.equals(resource.getSecurityModule().getSecurity())) {
                        KeyStore keyStore = resource.getSecurityModule().getKeyStore();

                        data = AESBase64Data.newCipherData(keyStore.getStorePassword(), key);
                        AESBase64Encription.I.decrypt(data);
                        resource.getSecurityModule().getKeyStore().setStorePassword(data.getPlain());

                        data = AESBase64Data.newCipherData(keyStore.getKeyPassword(), key);
                        AESBase64Encription.I.decrypt(data);
                        resource.getSecurityModule().getKeyStore().setKeyPassword(data.getPlain());
                    }
                }
            }
        }
        return resource;
    }
    
    private Properties getTrustProperties(ActiveMQResources activeMQResources) {
        Properties properties = null;
        if (null != activeMQResources.getSecurityModule()) {
            properties = new Properties();
            properties.put(SSLKeyConstants.KEYSTORETYPE_PROP, activeMQResources.getSecurityModule().getTrustStore().getType());
            properties.put(SSLKeyConstants.KEYSTOREPATH_PROP, activeMQResources.getSecurityModule().getTrustStore().getPath());
            properties.put(SSLKeyConstants.KEYSTORE_PSWD_PROP, activeMQResources.getSecurityModule().getTrustStore().getStorePassword());
            if (null != activeMQResources.getSecurityModule().getTrustStore().getKeyPassword()) {
                properties.put(SSLKeyConstants.KEY_PSWD_PROP, activeMQResources.getSecurityModule().getTrustStore().getKeyPassword());
            }
            if (null != activeMQResources.getSecurityModule().getTrustStore().getAlias()) {
                properties.put(SSLKeyConstants.KEYALIAS_PROP, activeMQResources.getSecurityModule().getTrustStore().getAlias());
            }
        }
        return properties;
    }

    private Properties getKeyProperties(ActiveMQResources activeMQResources) {
        Properties properties = null;
        if (null != activeMQResources.getSecurityModule() && null != activeMQResources.getSecurityModule().getKeyStore()) {
            properties = new Properties();
            properties.put(SSLKeyConstants.KEYSTORETYPE_PROP, activeMQResources.getSecurityModule().getKeyStore().getType());
            properties.put(SSLKeyConstants.KEYSTOREPATH_PROP, activeMQResources.getSecurityModule().getKeyStore().getPath());
            properties.put(SSLKeyConstants.KEYSTORE_PSWD_PROP, activeMQResources.getSecurityModule().getKeyStore().getStorePassword());
            if (null != activeMQResources.getSecurityModule().getKeyStore().getKeyPassword()) {
                properties.put(SSLKeyConstants.KEY_PSWD_PROP, activeMQResources.getSecurityModule().getKeyStore().getKeyPassword());
            }
            if (null != activeMQResources.getSecurityModule().getKeyStore().getAlias()) {
                properties.put(SSLKeyConstants.KEYALIAS_PROP, activeMQResources.getSecurityModule().getKeyStore().getAlias());
            }
        }
        return properties;
    }

    @SuppressWarnings({"rawtypes", "unchecked"})
    @Override
    protected ActiveMQConnectionFactory createConnectionFactory(Hashtable environment) throws URISyntaxException {
        ActiveMQSslConnectionFactory answer = new ActiveMQSslConnectionFactory();
        Properties properties = new Properties();
        properties.putAll(environment);
        answer.setProperties(properties);
        try {
            ActiveMQResources activeMQResources = this.loadResources(null);
            
            if (null != activeMQResources.getSecurityModule() && !((activeMQResources.getSecurityModule().getSecurity().value()).equals("NONE"))) {
            	SSLKeyManager sslkeyManager = new SSLKeyManager(new SSLSecureKey(null, this.getKeyProperties(activeMQResources)),
                        new SSLSecureKey(null, this.getTrustProperties(activeMQResources)));
                    answer.setKeyAndTrustManagers(sslkeyManager.getKeyManagers(), sslkeyManager.getTrustManagers(),
                        new SecureRandom());
            }
            
            
        } catch (Exception e) {
            this.logger.error(this.getClass()
                + ":TrustManagerFactory could not establish, SSL context could not establish.", e);
        }
        return answer;
    }

}