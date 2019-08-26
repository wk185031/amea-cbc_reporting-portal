package my.com.mandrill.base.reporting.security;

import java.util.Properties;

public class SecureKeyProperty {

	protected byte[] data;
	protected Properties properties;

	/**
	 * Create a secure key from the specified data that encapsulates that key and
	 * the settings that may be required to access that key.
	 * 
	 * @param data
	 * @param properties
	 */
	public SecureKeyProperty(byte[] data, Properties properties) {
		this.data = data;
		this.properties = properties;
	}

	public SecureKeyProperty(SecureKeyProperty secureKey) {
		this.data = secureKey.getData();
		this.properties = secureKey.getProperties();
	}

	/**
	 * Set the data that encapsulates the key.
	 * 
	 * @param data
	 *            The data in which the key is encapsulated.
	 */
	public void setData(byte[] data) {
		this.data = data;
	}

	/**
	 * Get the data in which the key is encapsulated.
	 * 
	 * @return The data in which the key is encapsulated.
	 */
	public byte[] getData() {
		return data;
	}

	/**
	 * Set the properties associated with this key.
	 * 
	 * @param properties
	 *            The propeties.
	 */
	public void setProperties(Properties properties) {
		this.properties = properties;
	}

	/**
	 * Get the properties associated with this key.
	 * 
	 * @return The properties.
	 */
	public Properties getProperties() {
		return properties;
	}
}
