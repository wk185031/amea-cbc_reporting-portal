package my.com.mandrill.base.reporting.security;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import my.com.mandrill.base.reporting.security.SecureCrypt.ByteArrayCrypt;
import my.com.mandrill.base.reporting.security.SecureCrypt.StringCrypt;
import my.com.mandrill.base.repository.EncryptionKeyRepository;

@Service
public class StandardEncryptionService implements SecureEncryptionService {

	private final Logger logger = LoggerFactory.getLogger(StandardEncryptionService.class);
	private final EncryptionKeyRepository encryptionKeyRepository;
	private Map<Long, Encryptor> allEncryptors = null;
	private Map<Long, Encryptor> dataEncryptors = null;

	public StandardEncryptionService(EncryptionKeyRepository encryptionKeyRepository) {
		this.encryptionKeyRepository = encryptionKeyRepository;
	}

	/**
	 * Initialise the encryption service.
	 */
	public void load() {
		SecureEncryptorManagerService secureEncryptorManagerService = new SecureEncryptorManagerService(
				encryptionKeyRepository);
		allEncryptors = secureEncryptorManagerService.loadEncryptors();
		dataEncryptors = secureEncryptorManagerService.getDataEncryptors();
	}

	/**
	 * Identifies whether the encryption service has been successfully initialised
	 * or not.
	 * 
	 * @return <code>true</code> if initialised, <code>false</code> otherwise.
	 */
	public boolean isOk() {
		return allEncryptors != null && allEncryptors.size() > 0;
	}

	/**
	 * Identifies whether the encryption service is currently running and able to
	 * service encryption and decryption requests.
	 * 
	 * @return <code>true</code> if running, <code>false</code> otherwise.
	 */
	public boolean isRunning() {
		return encryptForAll("000000").size() > 0;
	}

	/**
	 * Encrypt the specified data using the specified encryptor.
	 * 
	 * @param data
	 *            The data to encrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The encrypted data or the original data if an error occurred.
	 */
	public ByteArrayCrypt encrypt(byte[] data, int keyIndex) {
		ByteArrayCrypt result = new ByteArrayCrypt(data, SecurityManagerService.getFallbackKeyIndex(), false);
		Encryptor encryptor = allEncryptors.get(new Long(keyIndex));
		if (encryptor == null) {
			load();
			encryptor = allEncryptors.get(new Long(keyIndex));
		}

		if (encryptor == null) {
			logger.error("Encryptor " + keyIndex + " not available.");
		} else {
			try {
				result = new ByteArrayCrypt(encryptor.encrypt(data), keyIndex, true);
			} catch (Exception e) {
				logger.error("Encryptor " + keyIndex + " encrypt failure.", e);
			}
		}
		return result;
	}

	/**
	 * Decrypt the specified data using the specified encryptor.
	 * 
	 * @param data
	 *            The data to decrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The decrypted data or the original data if an error occurred.
	 */
	public ByteArrayCrypt decrypt(byte[] data, int keyIndex) {
		ByteArrayCrypt result = new ByteArrayCrypt(data, SecurityManagerService.getFallbackKeyIndex(), false);
		Encryptor encryptor = allEncryptors.get(new Long(keyIndex));
		if (encryptor == null) {
			load();
			encryptor = allEncryptors.get(new Long(keyIndex));
		}

		if (encryptor == null) {
			logger.error("Encryptor " + keyIndex + " not available.");
		} else {
			try {
				result = new ByteArrayCrypt(encryptor.decrypt(data), keyIndex, true);
			} catch (Exception e) {
				logger.error("Encryptor " + keyIndex + " decrypt failure.", e);
			}
		}
		return result;
	}

	/**
	 * Encrypt the specified string using the specified encryptor.
	 * 
	 * @param string
	 *            The string to encrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The encrypted string or original string if an error occurred.
	 */
	public StringCrypt encrypt(String string, int keyIndex) {
		StringCrypt result = new StringCrypt(string, SecurityManagerService.getFallbackKeyIndex(), false);
		Encryptor encryptor = allEncryptors.get(new Long(keyIndex));
		if (encryptor == null) {
			load();
			encryptor = allEncryptors.get(new Long(keyIndex));
		}

		if (encryptor == null) {
			logger.error("Encryptor " + keyIndex + " not available.");
		} else {
			try {
				result = new StringCrypt(encryptor.encrypt(string), keyIndex, true);
			} catch (Exception e) {
				logger.error("Encryptor " + keyIndex + " encrypt failure.", e);
			}
		}
		return result;
	}

	/**
	 * Decrypt the specified string using the specified encryptor.
	 * 
	 * @param string
	 *            The string to decrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The decrypted string or original string if an error occurred.
	 */
	public StringCrypt decrypt(String string, int keyIndex) {
		StringCrypt result = new StringCrypt(string, SecurityManagerService.getFallbackKeyIndex(), false);
		Encryptor encryptor = allEncryptors.get(new Long(keyIndex));
		if (encryptor == null) {
			load();
			encryptor = allEncryptors.get(new Long(keyIndex));
		}

		if (encryptor == null) {
			logger.error("Encryptor " + keyIndex + " not available.");
		} else {
			try {
				result = new StringCrypt(encryptor.decrypt(string), keyIndex, true);
			} catch (Exception e) {
				logger.error("Encryptor " + keyIndex + " decrypt failure.", e);
			}
		}
		return result;
	}

	/**
	 * Get the encrypted version of the specified data encrypted using each of the
	 * available data encryptors.
	 * <p>
	 * Note that only data encryptors are included. Fallback encryptors, for
	 * example, are excluded.
	 * <p>
	 * 
	 * @param data
	 *            The data to encrypt.
	 * @return The encrypted versions.
	 */
	public List<ByteArrayCrypt> encryptForAll(byte[] data) {
		List<ByteArrayCrypt> results = new ArrayList<ByteArrayCrypt>();
		for (Long keyIndex : dataEncryptors.keySet()) {
			results.add(encrypt(data, keyIndex.intValue()));
		}
		return results;
	}

	/**
	 * Get the encrypted version of the specified string encrypted using each of the
	 * available data encryptors.
	 * <p>
	 * Note that only data encryptors are included. Fallback encryptors, for
	 * example, are excluded.
	 * <p>
	 * 
	 * @param string
	 *            The string to encrypt.
	 * @return The encrypted versions.
	 */
	public List<StringCrypt> encryptForAll(String string) {
		List<StringCrypt> results = new ArrayList<StringCrypt>();
		for (Long keyIndex : dataEncryptors.keySet()) {
			results.add(encrypt(string, keyIndex.intValue()));
		}
		return results;
	}
}
