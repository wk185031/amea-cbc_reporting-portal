package my.com.mandrill.base.reporting.security;

import java.lang.reflect.Constructor;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import my.com.mandrill.base.domain.EncryptionKey;
import my.com.mandrill.base.repository.EncryptionKeyRepository;

@Service
public class SecureEncryptorManagerService {

	private final static Logger logger = LoggerFactory.getLogger(SecureEncryptorManagerService.class);
	private final EncryptionKeyRepository encryptionKeyRepository;
	private static Map<Long, Encryptor> encryptorCache = null;
	private static Map<Long, Encryptor> dataEncryptorCache = null;
	private static Map<Long, Encryptor> fallbackEncryptorCache = null;

	public SecureEncryptorManagerService(EncryptionKeyRepository encryptionKeyRepository) {
		this.encryptionKeyRepository = encryptionKeyRepository;
	}

	/**
	 * Load the sensitive data encryptors.
	 * 
	 * @return A map of the encryptors.
	 */
	public Map<Long, Encryptor> loadEncryptors() {
		Map<Long, Encryptor> encryptorMap = new HashMap<Long, Encryptor>();
		Map<Long, Encryptor> dataEncryptorMap = new HashMap<Long, Encryptor>();
		Map<Long, Encryptor> fallbackEncryptorMap = new HashMap<Long, Encryptor>();
		try {
			List<EncryptionKey> encryptionKeys = encryptionKeyRepository.findAll();
			for (EncryptionKey encryptionKey : encryptionKeys) {
				Encryptor encryptor = createEncryptor(encryptionKey);
				if (encryptor != null) {
					encryptorMap.put(encryptionKey.getId(), encryptor);
					if (encryptionKey.getCategory().equals(SecurityConstants.Category.DATA.getName())) {
						dataEncryptorMap.put(encryptionKey.getId(), encryptor);
					}

					if (encryptionKey.getCategory().equals(SecurityConstants.Category.FALLBACK.getName())) {
						fallbackEncryptorMap.put(encryptionKey.getId(), encryptor);
					}
				}
			}
			logger.debug(encryptorMap.size() + " of " + encryptionKeys.size() + " encryptors loaded.");
		} catch (Throwable e) {
			encryptorMap = new HashMap<Long, Encryptor>();
			dataEncryptorMap = new HashMap<Long, Encryptor>();
			fallbackEncryptorMap = new HashMap<Long, Encryptor>();
			logger.error("Encryptor load failed.", e);
		}
		encryptorCache = encryptorMap;
		dataEncryptorCache = dataEncryptorMap;
		fallbackEncryptorCache = fallbackEncryptorMap;

		return encryptorCache;
	}

	/**
	 * Get the sensitive data encryptors.
	 * 
	 * @return A map of the encryptors.
	 */
	public Map<Long, Encryptor> getDataEncryptors() {
		if (encryptorCache == null || dataEncryptorCache == null || fallbackEncryptorCache == null) {
			loadEncryptors();
		}
		return new HashMap<Long, Encryptor>(dataEncryptorCache);
	}

	/**
	 * Get the fallback encryptors.
	 * 
	 * @return A map of the encryptors.
	 */
	public Map<Long, Encryptor> getFallbackEncryptors() {
		if (encryptorCache == null || dataEncryptorCache == null || fallbackEncryptorCache == null) {
			loadEncryptors();
		}
		return new HashMap<Long, Encryptor>(fallbackEncryptorCache);
	}

	/**
	 * Create an encryptor defined by the specified encryptor class name and a
	 * randomly generated key.
	 * 
	 * @param className
	 *            The encryptor class name.
	 * @return The encryptor or <code>null</code> if the creation failed.
	 */
	public static Encryptor createEncryptor(String className) {
		return createEncryptor(className, false);
	}

	/**
	 * Create an encryptor defined by the specified encryptor class name and a
	 * randomly generated key.
	 * 
	 * @param className
	 *            The encryptor class name.
	 * @param suppress
	 *            Use <code>true</code> to suppress exception logging.
	 * @return The encryptor or <code>null</code> if the creation failed.
	 */
	public static Encryptor createEncryptor(String className, boolean suppress) {
		Encryptor encryptor = null;
		try {
			encryptor = (Encryptor) Class.forName(className).newInstance();
		} catch (Exception e) {
			encryptor = null;
			if (!suppress) {
				logger.error("Encryptor " + className + " create failed.", e);
			}
		}

		if (encryptor != null) {
			logger.debug("Encryptor " + className + " created.");
		}
		return encryptor;
	}

	/**
	 * Create an encryptor defined by the specified encryptor class name and raw
	 * key.
	 * 
	 * @param className
	 *            The encryptor class name.
	 * @param rawKey
	 *            The key.
	 * @return The encryptor or <code>null</code> if the creation failed.
	 */
	public Encryptor createEncryptor(String className, byte[] rawKey) {
		return createEncryptor(className, rawKey, false);
	}

	/**
	 * Create an encryptor defined by the specified encryptor class name and raw
	 * key.
	 * 
	 * @param className
	 *            The encryptor class name.
	 * @param rawKey
	 *            The key.
	 * @param suppress
	 *            Use <code>true</code> to suppress exception logging.
	 * @return The encryptor or <code>null</code> if the creation failed.
	 */
	public Encryptor createEncryptor(String className, byte[] rawKey, boolean suppress) {
		Encryptor encryptor = null;
		try {
			Constructor<?> constructor = Class.forName(className).getConstructor(byte[].class);
			encryptor = (Encryptor) constructor.newInstance(rawKey);
		} catch (Exception e) {
			encryptor = null;
			if (!suppress) {
				logger.error("Encryptor " + className + " create failed.", e);
			}
		}

		if (encryptor != null) {
			logger.debug("Encryptor " + className + " created.");
		}
		return encryptor;
	}

	/**
	 * Create the encryptor defined by the specified ENCRYPTION_KEY record.
	 * 
	 * @param encryptionKey
	 *            The ENCRYPTION_KEY record data access object.
	 * @return The encryptor or <code>null</code> if the creation failed.
	 */
	private static Encryptor createEncryptor(EncryptionKey encryptionKey) {
		Encryptor encryptor = null;
		try {
			Constructor<?> constructor = Class.forName(encryptionKey.getClassName()).getConstructor(byte[].class);
			encryptor = (Encryptor) constructor
					.newInstance(SecurityManagerService.decryptKey(encryptionKey.getKeyData()));
		} catch (Exception e) {
			encryptor = null;
			logger.error("Encryptor " + encryptionKey.getId() + " create failed.", e);
		}

		if (encryptor != null && encryptionKey.getCheckValue() != null) {
			if (!encryptionKey.getCheckValue().equals(createCheckValue(encryptor))) {
				encryptor = null;
				logger.error("Encryptor " + encryptionKey.getId() + " check value failure.");
			}
		}

		if (encryptor != null) {
			logger.info("Encryptor " + encryptionKey.getId() + " created : " + encryptor.toString());
		}
		return encryptor;
	}

	/**
	 * Check a check value for the specified encryptor.
	 * 
	 * @param encryptor
	 *            The encryptor.
	 * @return A 6 character check value.
	 */
	public static String createCheckValue(Encryptor encryptor) {
		return createCheckValue(encryptor, false);
	}

	/**
	 * Check a check value for the specified encryptor.
	 * 
	 * @param encryptor
	 *            The encryptor.
	 * @param suppress
	 *            Use <code>true</code> to suppress exception logging.
	 * @return A 6 character check value.
	 */
	public static String createCheckValue(Encryptor encryptor, boolean suppress) {
		String checkValue = null;
		try {
			checkValue = encryptor.getCheckValue();
		} catch (Exception e) {
			if (!suppress) {
				logger.error("Encryptor check value creation failed.", e);
			}
		}
		return checkValue;
	}
}
