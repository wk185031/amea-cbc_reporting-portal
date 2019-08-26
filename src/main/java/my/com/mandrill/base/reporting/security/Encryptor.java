package my.com.mandrill.base.reporting.security;

public abstract class Encryptor {

	/**
	 * Encrypt the specified data.
	 * 
	 * @param data
	 *            The data to be encrypted.
	 * @return The encrypted form of the specified data.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public abstract byte[] encrypt(byte[] data) throws Exception;

	/**
	 * Decrypt the specified data.
	 * 
	 * @param data
	 *            The data to be decrypted.
	 * @return The decrypted form of the specified data.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	public abstract byte[] decrypt(byte[] data) throws Exception;

	/**
	 * Encrypt the specified string.
	 * 
	 * @param string
	 *            The string to be encrypted.
	 * @return The encrypted form of the specified string.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public abstract String encrypt(String string) throws Exception;

	/**
	 * Decrypt the specified string.
	 * 
	 * @param string
	 *            The string to be decrypted.
	 * @return The decrypted form of the specified string.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	public abstract String decrypt(String string) throws Exception;

	/**
	 * Get the raw key.
	 * 
	 * @return The key.
	 */
	public abstract byte[] getKey();

	/**
	 * Get the preferred length of a key. A positive number implies a specific key
	 * length, a negative number means any key length is acceptable, <code>0</code>
	 * means this encryptor does not require a key.
	 * 
	 * @return The preferred key length.
	 */
	public abstract int getPreferredKeyLength();

	/**
	 * Determines whether the specified key is acceptable.
	 * 
	 * @return <code>true</code> implies the key is acceptable, <code>false</code>
	 *         otherwise.
	 */
	public abstract boolean isKeyOk(byte[] key);

	/**
	 * Calculate a check value.
	 * 
	 * @return The check value.
	 * @throws Exception
	 *             Thrown if an error occurs during the evaluation of the check
	 *             value.
	 */
	public abstract String getCheckValue() throws Exception;

	/**
	 * Convert the specified data into a hex binary string.
	 * 
	 * @param data
	 *            The data to encode.
	 * @return The hex binary encoding.
	 */
	protected static byte[] encode(byte[] data) {
		return SecureHexBinaryAdapter.encode(data);
	}

	/**
	 * Decode the specified hex encoded string.
	 * 
	 * @param string
	 *            The encoded string.
	 * @return The decoded data.
	 */
	protected static byte[] decode(byte[] data) {
		return SecureHexBinaryAdapter.decode(data);
	}
}
