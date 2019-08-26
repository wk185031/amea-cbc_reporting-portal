package com.authentic.secure;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InvalidClassException;
import java.io.ObjectInputStream;
import java.io.ObjectStreamClass;
import java.io.Serializable;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.domain.SecureKey;
import my.com.mandrill.base.reporting.security.SecureKeyProperty;
import my.com.mandrill.base.reporting.security.SecurityManagerService;
import my.com.mandrill.base.repository.SecureKeyRepository;

public class SecureKeyManager {

	private final static Logger logger = LoggerFactory.getLogger(SecureKeyManager.class);
	private final SecureKeyRepository secureKeyRepository;

	public SecureKeyManager(SecureKeyRepository secureKeyRepository) {
		this.secureKeyRepository = secureKeyRepository;
	}

	/**
	 * The KeyAccess class encapsulates the access details of an secure key stored
	 * in the SECURE_KEY table.
	 */
	static private class KeyAccess implements Serializable {
		private static final long serialVersionUID = 8572584901135945115L;
		private final Properties properties;
		private final String storeUri;

		/**
		 * The default key access constructor.
		 * 
		 * @param properties
		 *            The associated properties.
		 * @param storeUri
		 *            The uri of the file in which the data is stored. If
		 *            <code>null</code> the data is stored in the database.
		 */
		public KeyAccess(Properties properties, String storeUri) {
			this.properties = properties;
			this.storeUri = storeUri;
		}

		/**
		 * Get the associated properties.
		 * 
		 * @return The associated properties.
		 */
		public Properties getProperties() {
			return properties;
		}

		/**
		 * Get the data store uri.
		 * 
		 * @return The store uri.
		 */
		public String getStoreUri() {
			return storeUri;
		}

		/**
		 * Unmarshal the specified marshalled key access object.
		 * 
		 * @param marshalledKeyAccess
		 *            The marshalled key access object.
		 * @return The key access object.
		 */
		static public KeyAccess unmarshal(byte[] marshalledKeyAccess) {
			ByteArrayInputStream bais = null;
			ObjectInputStream ois = null;
			KeyAccess keyAccess = null;
			try {
				bais = new ByteArrayInputStream(marshalledKeyAccess);
				ois = new KeyAccessInputStream(bais);
				keyAccess = (KeyAccess) ois.readObject();
			} catch (Exception e) {
				logger.error("Secure key access deserialisation failed.", e);
			} finally {
				try {
					bais.close();
					ois.close();
				} catch (IOException e) {
					logger.error("Secure key access deserialisation close failed.", e);
				}
			}
			return keyAccess;
		}
	}

	/**
	 * A KeyAccessInputStream deserialises a marshalled SecureKeyManager.KeyAccess
	 * object making sure that the object will only be deserialised if it contains
	 * classes that appear in a whitelist of acceptable classes.
	 */
	private static class KeyAccessInputStream extends ObjectInputStream {
		private static HashSet<String> whitelist = new HashSet<String>();
		static {
			/* default set */
			whitelist.add("java.util.Hashtable");
			whitelist.add("java.util.Properties");
			whitelist.add("com.authentic.secure.SecureKeyManager$KeyAccess");
		}

		/**
		 * Creates a KeyAccessInputStream that reads from the specified InputStream.
		 * 
		 * @see ObjectInputStream#ObjectInputStream(InputStream in)
		 */
		public KeyAccessInputStream(InputStream in) throws IOException {
			super(in);
		}

		/**
		 * A class resolver that whitelists the classes that may be deserialised.
		 * 
		 * @throws InvalidClassException
		 *             - if the specified class is not whitelisted.
		 */
		@Override
		protected Class<?> resolveClass(ObjectStreamClass desc) throws IOException, ClassNotFoundException {
			if (!whitelist.contains(desc.getName())) {
				logger.error("Unexpected serialised class: " + desc.getName());
				throw new InvalidClassException("Unexpected serialised class", desc.getName());
			}
			return super.resolveClass(desc);
		}
	}

	/**
	 * Retrieve the specified secure key from the SECURE_KEY table.
	 * 
	 * @param id
	 *            The id secure key.
	 * @return The secure key or <code>null</code> if the specified secure key was
	 *         not found.
	 */
	public SecureKeyProperty getKey(Long id) {
		SecureKeyProperty secureKey = null;
		try {
			SecureKey secureKeyDA = secureKeyRepository.findOne(id);
			KeyAccess keyAccess = new KeyAccess(null, null);

			if (secureKeyDA.getAccess() != null) {
				keyAccess = KeyAccess.unmarshal(SecurityManagerService.reveal(secureKeyDA.getAccess()));
			}

			byte[] keyData = secureKeyDA.getData();

			if (keyAccess.getStoreUri() != null) {
				URL url = SecureKeyManager.class.getResource("/" + keyAccess.getStoreUri());
				keyData = Files.readAllBytes(Paths.get(url.toURI()));
			}

			secureKey = new SecureKeyProperty(keyData, keyAccess.getProperties());

			logger.debug("Secure key retrieved : " + "id=" + id + ",name=" + secureKeyDA.getName() + ",category="
					+ secureKeyDA.getCategory() + ".");
		} catch (Throwable e) {
			logger.error("Secure key retrieval failed : " + "id=" + id + ".", e);
			secureKey = null;
		}
		return secureKey;
	}

	/**
	 * Retrieve the specified secure key from the SECURE_KEY table.
	 * 
	 * @param name
	 *            The name of the secure key.
	 * @param category
	 *            The category of the secure key.
	 * @return The secure key or <code>null</code> if the specified secure key was
	 *         not found.
	 */
	public SecureKeyProperty getKey(String name, String category) {
		SecureKeyProperty secureKey = null;
		try {
			SecureKey secureKeyDA = secureKeyRepository.findByNameAndCategory(name, category);
			KeyAccess keyAccess = new KeyAccess(null, null);

			if (secureKeyDA.getAccess() != null) {
				keyAccess = KeyAccess.unmarshal(SecurityManagerService.reveal(secureKeyDA.getAccess()));
			}

			byte[] keyData = secureKeyDA.getData();

			if (keyAccess.getStoreUri() != null) {
				keyData = loadKey(keyAccess.getStoreUri());
			}

			secureKey = new SecureKeyProperty(keyData, keyAccess.getProperties());

			logger.debug("Secure key retrieved : " + "name=" + name + ",category=" + category + ",id="
					+ secureKeyDA.getId() + ".");
		} catch (Throwable e) {
			logger.error("Secure key retrieval failed : " + "name=" + name + ",category=" + category + ".", e);
			secureKey = null;
		}
		return secureKey;
	}

	/**
	 * Retrieve a key from the specified file that is assumed to be on the class
	 * path.
	 * 
	 * @param filename
	 *            The name of the key file.
	 * @return The key.
	 * @throws Exception
	 *             Thrown if an error occurs while retrieving the key.
	 */
	private static byte[] loadKey(String filename) throws Exception {
		byte[] key = null;
		InputStream is = null;
		try {
			is = SecurityManagerService.class.getResourceAsStream("/" + filename);
			if (is == null) {
				throw new FileNotFoundException(filename + " not found.");
			}

			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			int ch;
			while ((ch = is.read()) != -1) {
				baos.write(ch);
			}

			key = baos.toByteArray();
		} finally {
			if (is != null) {
				is.close();
			}
		}
		return key;
	}
}
