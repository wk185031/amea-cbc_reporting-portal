package com.authentic.secure.key;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.security.Key;
import java.security.KeyStore;
import java.security.Security;
import java.util.Properties;
import java.util.Random;

import javax.crypto.KeyGenerator;
import javax.crypto.spec.SecretKeySpec;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.security.SecureKeyProperty;
import my.com.mandrill.base.reporting.security.SecurityManagerService;

public class AESSecureKey extends SecureKeyProperty {

	private final static Logger logger = LoggerFactory.getLogger(AESSecureKey.class);
	private static final String PROVIDER = "BC";
	private static final String KEYSTORE_TYPE = "BKS";
	private static final String KEY_ALGORITHM = "AES";

	private static final String PROPERTY_STORE_TYPE = "storeType";
	private static final String PROPERTY_STORE_PSWD = "storePassword";
	private static final String PROPERTY_KEY_ALIAS = "keyAlias";
	private static final String PROPERTY_KEY_PSWD = "keyPassword";

	/**
	 * Initialise the provider.
	 */
	static {
		if (Security.getProvider(PROVIDER) == null) {
			try {
				Security.addProvider(BouncyCastleProvider.class.newInstance());
			} catch (Exception e) {
				logger.error("Failed to load Bouncy Castle security provider.", e);
			}
		}
	}

	/**
	 * Create an AES secure key from the specified data that encapsulates that key
	 * and the settings that may be required to access that key.
	 * 
	 * @param data
	 * @param properties
	 */
	public AESSecureKey(byte[] data, Properties properties) {
		super(data, properties);
	}

	/**
	 * Get the raw AES key from this secure key.
	 * 
	 * @return The raw AES key.
	 */
	public byte[] getKey() {
		Key key = null;
		try {
			String storeType = properties.getProperty(PROPERTY_STORE_TYPE);
			String storePassword = properties.getProperty(PROPERTY_STORE_PSWD);
			String keyAlias = properties.getProperty(PROPERTY_KEY_ALIAS);
			String keyPassword = properties.getProperty(PROPERTY_KEY_PSWD);
			KeyStore keystore = KeyStore.getInstance(storeType);
			keystore.load(new ByteArrayInputStream(data), storePassword.toCharArray());
			key = keystore.getKey(keyAlias, keyPassword.toCharArray());
		} catch (Exception e) {
			logger.error("AES secure key get failed.", e);
			key = null;
		}
		return key != null ? key.getEncoded() : null;
	}

	/**
	 * Create a randomly generated AES key, encapsulated within a secure key.
	 * 
	 * @return The randomly generated AES secure key.
	 */
	public static AESSecureKey createKey() {
		AESSecureKey secureKey = null;
		try {
			secureKey = createKey(KeyGenerator.getInstance(KEY_ALGORITHM).generateKey().getEncoded());
		} catch (Exception e) {
			logger.error("AES secure key create failed.", e);
		}
		return secureKey;
	}

	/**
	 * Create a secure AES key using the specified raw key.
	 * 
	 * @param rawKey
	 *            The raw key.
	 * @return The AES secure key.
	 * @throws Exception
	 *             Thrown if unable to create the AES secure key.
	 */
	public static AESSecureKey createKey(byte[] rawKey) throws Exception {
		AESSecureKey secureKey = null;
		try {
			String storeType = KEYSTORE_TYPE;
			String storePassword = createPassword();
			String keyAlias = createPassword();
			String keyPassword = createPassword();

			/* create key */
			Key key = new SecretKeySpec(rawKey, KEY_ALGORITHM);

			/* create empty key store */
			KeyStore keystore = KeyStore.getInstance(KEYSTORE_TYPE);
			keystore.load(null, storePassword.toCharArray());

			/* add key to key store */
			keystore.setKeyEntry(keyAlias, key, keyPassword.toCharArray(), null);

			/* write key store to buffer */
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			keystore.store(baos, storePassword.toCharArray());

			/* create properties list */
			Properties properties = new Properties();
			properties.put(PROPERTY_STORE_TYPE, storeType);
			properties.put(PROPERTY_STORE_PSWD, storePassword);
			properties.put(PROPERTY_KEY_ALIAS, keyAlias);
			properties.put(PROPERTY_KEY_PSWD, keyPassword);

			/* save key store and properties */
			secureKey = new AESSecureKey(baos.toByteArray(), properties);
		} catch (Exception e) {
			logger.error("AES secure key create failed.", e);
		}
		return secureKey;
	}

	/**
	 * Create a password of a random length, between 24 and 48 characters, made up
	 * of randomly selected upper and lower case alphabetical characters and digits.
	 * 
	 * @return Randomly generated password.
	 */
	private static String createPassword() {
		Random random = new Random();
		return new String(SecurityManagerService.createKey(random.nextInt(25) + 24));
	}
}
