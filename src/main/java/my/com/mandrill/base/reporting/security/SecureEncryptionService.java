package my.com.mandrill.base.reporting.security;

import java.util.List;

import my.com.mandrill.base.reporting.security.SecureCrypt.ByteArrayCrypt;
import my.com.mandrill.base.reporting.security.SecureCrypt.StringCrypt;

public interface SecureEncryptionService {

	/**
	 * Initialise the encryption service.
	 */
	public abstract void load();

	/**
	 * Identifies whether the encryption service has been successfully initialised
	 * or not.
	 * 
	 * @return <code>true</code> if initialised, <code>false</code> otherwise.
	 */
	public abstract boolean isOk();

	/**
	 * Identifies whether the encryption service is currently running and able to
	 * service encryption and decryption requests.
	 * 
	 * @return <code>true</code> if running, <code>false</code> otherwise.
	 */
	public abstract boolean isRunning();

	/**
	 * Encrypt the specified data using the specified encryptor.
	 * 
	 * @param data
	 *            The data to encrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The encrypted data.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public abstract ByteArrayCrypt encrypt(byte[] data, int keyIndex) throws Exception;

	/**
	 * Decrypt the specified data using the specified encryptor.
	 * 
	 * @param data
	 *            The data to decrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The decrypted data.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	public abstract ByteArrayCrypt decrypt(byte[] data, int keyIndex) throws Exception;

	/**
	 * Encrypt the specified string using the specified encryptor.
	 * 
	 * @param string
	 *            The string to encrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The encrypted string.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public abstract StringCrypt encrypt(String string, int keyIndex) throws Exception;

	/**
	 * Decrypt the specified string using the specified encryptor.
	 * 
	 * @param string
	 *            The string to decrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The decrypted string.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	public abstract StringCrypt decrypt(String string, int keyIndex) throws Exception;

	/**
	 * Get the encrypted version of the specified data encrypted using each of the
	 * available encryptors.
	 * 
	 * @param data
	 *            The data to encrypt.
	 * @return The encrypted versions.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public abstract List<ByteArrayCrypt> encryptForAll(byte[] data) throws Exception;

	/**
	 * Get the encrypted version of the specified string encrypted using each of the
	 * available encryptors.
	 * 
	 * @param string
	 *            The string to encrypt.
	 * @return The encrypted versions.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public abstract List<StringCrypt> encryptForAll(String string) throws Exception;
}
