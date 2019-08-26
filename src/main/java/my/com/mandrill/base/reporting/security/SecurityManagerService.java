package my.com.mandrill.base.reporting.security;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Constructor;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.Random;

import javax.crypto.Cipher;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.authentic.secure.SecureKeyManager;
import com.authentic.secure.key.AESSecureKey;

import my.com.mandrill.base.domain.SecurityParameters;
import my.com.mandrill.base.reporting.security.SecureCrypt.ByteArrayCrypt;
import my.com.mandrill.base.reporting.security.SecureCrypt.StringCrypt;
import my.com.mandrill.base.reporting.security.SecurityConstants.Format;
import my.com.mandrill.base.reporting.security.SecurityConstants.Status;
import my.com.mandrill.base.repository.EncryptionKeyRepository;
import my.com.mandrill.base.repository.LocalWebServiceRepository;
import my.com.mandrill.base.repository.SecureKeyRepository;
import my.com.mandrill.base.repository.SecurityParametersRepository;

@Service
public class SecurityManagerService {

	private final static Logger logger = LoggerFactory.getLogger(SecurityManagerService.class);

	private enum DeploymentMode {
		LOCAL, REMOTE
	}

	private static final int INVALID_KEY_INDEX = -1;

	private static final String KEY_ENCRYPTOR_KEY_CATEGORY = "system";
	private static final String KEY_ENCRYPTOR_KEY_PART_A_NAME = "masterA";
	private static final String KEY_ENCRYPTOR_KEY_PART_B_NAME = "masterB";

	private static final String INTERNAL_ENCRYPTOR_KEY_CATEGORY = "system";
	private static final String INTERNAL_ENCRYPTOR_KEY_PART_A_FILE = "authentica.dat";
	private static final String INTERNAL_ENCRYPTOR_KEY_PART_B_NAME = "masterC";

	private static final String MAC_GENERATOR_KEY_CATEGORY = "system";
	private static final String MAC_GENERATOR_KEY_NAME = "masterD";

	private static final String SECURITY_PROPERTIES_FILE = "security.properties";
	private static final String SECURITY_PROPERTIES_DEPLOYMENT_ID_KEY = "deployment.id";
	private static final String SECURITY_PROPERTIES_DEPLOYMENT_MODE_KEY = "deployment.mode";

	private static final String RANDOM_NUMBER_PROVIDER = "SUN";
	private static final String RANDOM_NUMBER_ALGORITHM = "SHA1PRNG";

	private static final Properties defaultSecurityProperties = new Properties();

	private static SecurityParameters securityParameters = null;
	private static SecureEncryptionService encryptionService = null;

	private static Masker masker = null;
	private static Hasher hasher = null;
	private static Encryptor keyEncryptor = null;
	private static Encryptor internalEncryptor = null;
	private static MacGenerator macGenerator = null;

	private static DeploymentMode deploymentMode = DeploymentMode.LOCAL;
	private static String deploymentId = "";
	private static int currentKeyIndex = INVALID_KEY_INDEX;
	private static int fallbackKeyIndex = INVALID_KEY_INDEX;
	private static String maskChar = "";
	private static boolean isDatabaseDataClear = false;
	private static boolean isDatabaseDataEncrypted = false;
	private static String defaultDataEncryptorClassName = "";
	private static boolean onlyHoldEncryptedForm = true;

	private final SecurityParametersRepository securityParametersRepository;
	private final LocalWebServiceRepository localWebServiceRepository;
	private final SecureKeyRepository secureKeyRepository;
	private final EncryptionKeyRepository encryptionKeyRepository;

	public SecurityManagerService(SecurityParametersRepository securityParametersRepository,
			LocalWebServiceRepository localWebServiceRepository, SecureKeyRepository secureKeyRepository,
			EncryptionKeyRepository encryptionKeyRepository) {
		this.securityParametersRepository = securityParametersRepository;
		this.localWebServiceRepository = localWebServiceRepository;
		this.secureKeyRepository = secureKeyRepository;
		this.encryptionKeyRepository = encryptionKeyRepository;
	}

	static {
		defaultSecurityProperties.put(SECURITY_PROPERTIES_DEPLOYMENT_ID_KEY, "authentic server");
		defaultSecurityProperties.put(SECURITY_PROPERTIES_DEPLOYMENT_MODE_KEY, "local");
	}

	/**
	 * Get the mode of deployment.
	 * 
	 * @return The deployment mode.
	 */
	public static DeploymentMode getDeploymentMode() {
		return deploymentMode;
	}

	/**
	 * Get the deployment id.
	 * 
	 * @return The deployment id.
	 */
	public static String getDeploymentId() {
		return deploymentId;
	}

	/**
	 * Get the index of the current encryptor.
	 * 
	 * @return The index for the encryptor that will be used to encrypt all new
	 *         data.
	 */
	public static int getCurrentKeyIndex() {
		return currentKeyIndex;
	}

	/**
	 * Get the index of the fallback encryptor.
	 * 
	 * @return The index for the fallback encryptor.
	 */
	public static int getFallbackKeyIndex() {
		return fallbackKeyIndex;
	}

	/**
	 * Get the character used for masking.
	 * 
	 * @return The mask char.
	 */
	public static String getMaskChar() {
		return maskChar;
	}

	/**
	 * Identifies whether sensitive data is to be stored in the database in the
	 * clear.
	 * 
	 * @return <code>true</code> if data is to be stored in the clear.
	 */
	public static boolean isDatabaseDataClear() {
		return isDatabaseDataClear;
	}

	/**
	 * Identifies whether sensitive data is to be encrypted when stored in the
	 * database.
	 * 
	 * @return <code>true</code> if data is to be encrypted.
	 */
	public static boolean isDatabaseDataEncrypted() {
		return isDatabaseDataEncrypted;
	}

	/**
	 * Get the name of the default sensitive data encryptor class.
	 * 
	 * @return The default data encryptor class name.
	 */
	public static String getDefaultDataEncryptorClassName() {
		return defaultDataEncryptorClassName;
	}

	/**
	 * Identifies whether the security framework should only hold the encrypted form
	 * of sensitive data in memory.
	 * 
	 * @return <code>true</code> if only the encrypted form should be held in
	 *         memory.
	 */
	public static boolean onlyHoldEncryptedForm() {
		return onlyHoldEncryptedForm;
	}

	/**
	 * Identifies whether the deployment is a remote deployment.
	 * 
	 * @return <code>true</code> is a remote deployment, <code>false</code>
	 *         otherwise.
	 */
	public static boolean isRemoteDeployment() {
		return deploymentMode == DeploymentMode.REMOTE;
	}

	/**
	 * Get the key encryptor.
	 * 
	 * @return The key encryptor.
	 */
	public static Encryptor getKeyEncryptor() {
		return keyEncryptor;
	}

	/**
	 * Get the MAC generator.
	 * 
	 * @return The MAC generator.
	 */
	public static MacGenerator getMacGenerator() {
		return macGenerator;
	}

	/**
	 * Initialise the security manager. The security manager will normally
	 * initialise itself as and when any one of its methods is called but, if the
	 * initialisation must be enforced at a particular point, this is the
	 * appropriate method to call.
	 * 
	 * @return <code>true</code> if initialised, <code>false</code> otherwise.
	 */
	public boolean initialise() {
		try {
			if (Cipher.getMaxAllowedKeyLength("AES") > 128) {
				logger.debug("Unlimited strength JCE installed.");
			} else {
				logger.debug("Unlimited strength JCE NOT installed.");
			}
		} catch (Exception e) {
			logger.error("Unable to determine whether or not the unlimited strength JCE is installed.");
		}
		load();
		return isOk();
	}

	/**
	 * Identifies whether the security manager has been successfully initialised or
	 * not.
	 * 
	 * @return <code>true</code> if initialised, <code>false</code> otherwise.
	 */
	public static boolean isOk() {
		return securityParameters != null && masker != null && hasher != null && macGenerator != null
				&& (isRemoteDeployment() ? true : keyEncryptor != null) && internalEncryptor != null
				&& encryptionService != null && encryptionService.isOk();
	}

	/**
	 * Identifies whether or not an encryptor is available.
	 * 
	 * @return <code>true</code> if available, <code>false</code> otherwise.
	 */
	public static boolean isEncryptorAvailable() {
		return encryptionService != null && encryptionService.isRunning();
	}

	/**
	 * Reload the security framework.
	 */
	public void reload() {
		load();
	}

	/**
	 * Initialise or reload the security framework.
	 */
	private void load() {
		deploymentMode = DeploymentMode.LOCAL;
		deploymentId = "";
		securityParameters = null;
		encryptionService = null;
		masker = null;
		hasher = null;
		keyEncryptor = null;
		internalEncryptor = null;
		currentKeyIndex = INVALID_KEY_INDEX;
		maskChar = "";
		isDatabaseDataClear = false;
		isDatabaseDataEncrypted = false;

		/* load properties */
		Properties securityProperties = loadProperties();

		if (securityProperties != null) {
			String property = securityProperties.getProperty(SECURITY_PROPERTIES_DEPLOYMENT_ID_KEY);
			if (property != null) {
				deploymentId = property;
			}
			property = securityProperties.getProperty(SECURITY_PROPERTIES_DEPLOYMENT_MODE_KEY);
			if (property != null) {
				deploymentMode = DeploymentMode.valueOf(property.toUpperCase());
			}
			logger.debug("Deployment : id=" + deploymentId + ",mode=" + deploymentMode + ".");
		}

		/* load parameters */
		securityParameters = loadParameters();

		if (securityParameters != null) {
			currentKeyIndex = securityParameters.getCurrentEkyId().intValue();

			fallbackKeyIndex = securityParameters.getFallbackEkyId().intValue();

			isDatabaseDataClear = Format.CLEAR.toString().equalsIgnoreCase(securityParameters.getDatabaseFormat());

			isDatabaseDataEncrypted = Format.ENCRYPTED.toString()
					.equalsIgnoreCase(securityParameters.getDatabaseFormat());

			maskChar = securityParameters.getMaskChar();

			masker = createMasker(securityParameters.getMaskClass());

			hasher = createHasher(securityParameters.getHashClass());

			defaultDataEncryptorClassName = securityParameters.getDefaultEncryptClass();
		}

		/* create internal encryptor */
		if (securityProperties != null && securityParameters != null) {
			internalEncryptor = createInternalEncryptor(securityParameters.getInternalEncryptClass());
		}

		/* create key encryptor */
		if (securityProperties != null && securityParameters != null) {
			if (isRemoteDeployment()) {
				logger.debug("Key encryptor not created : remote deployment.");
			} else {
				keyEncryptor = createKeyEncryptor(securityParameters.getKeyEncryptClass());
			}
		}

		/* create MAC generator */
		if (securityProperties != null && securityParameters != null) {
			macGenerator = createMacGenerator(securityParameters.getMacClass());
		}

		/* create encryption service */
		if (securityProperties != null && securityParameters != null) {
			encryptionService = createEncryptionService();
		}
	}

	/**
	 * Loads the security properties from the security.properties file.
	 * 
	 * @return The security properties. <code>null</code> if not found.
	 */
	private static Properties loadProperties() {
		Properties properties = new Properties();
		InputStream in = null;
		try {
			in = SecurityManagerService.class.getResourceAsStream("/" + SECURITY_PROPERTIES_FILE);
			properties.load(in);
			logger.debug("Security properties loaded.");
		} catch (Exception e) {
			logger.error("Security properties load failed - defaults apply.");
			properties = defaultSecurityProperties;
		} finally {
			if (in != null) {
				try {
					in.close();
				} catch (IOException e) {
				}
			}
		}
		return properties;
	}

	/**
	 * Loads the security parameters. Only the "active" parameters are loaded and an
	 * error is thrown if more than one "active" set is found.
	 * 
	 * @return The security parameters.
	 */
	private SecurityParameters loadParameters() {
		List<SecurityParameters> activeList = null;
		SecurityParameters parameters = null;
		try {
			List<SecurityParameters> list = securityParametersRepository.findAll();
			activeList = new ArrayList<SecurityParameters>();

			for (SecurityParameters entry : list) {
				if (Status.ACTIVE.getName().equalsIgnoreCase(entry.getStatus())) {
					activeList.add(entry);
				}
			}
		} catch (Throwable e) {
			logger.error("Security parameters load failed.", e);
		}

		if (activeList != null) {
			if (activeList.size() == 0) {
				logger.error("Security parameters load failed - none defined.");
			} else if (activeList.size() > 1) {
				logger.error("Security parameters load failed - more than one active set found.");
			} else {
				parameters = activeList.get(0);
				logger.debug("Security parameters loaded.");
			}
		}
		return parameters;
	}

	/**
	 * Create the encryption service appropriate to the deployment mode.
	 * 
	 * @return An instance of the encryption service or <code>null</code> if the
	 *         creation failed.
	 */
	private SecureEncryptionService createEncryptionService() {
		SecureEncryptionService service = null;
		switch (deploymentMode) {
		case REMOTE:
			service = new RemoteEncryptionService(localWebServiceRepository);
			break;
		default:
			service = new StandardEncryptionService(encryptionKeyRepository);
			break;
		}
		service.load();

		logger.debug(service.getClass().getName() + " encryption service created.");

		return service;
	}

	/**
	 * Creates an instance of the internal encryptor.
	 * 
	 * @param className
	 *            The name of the internal encryptor class.
	 * @return The internal or <code>null</code> if the creation failed.
	 */
	private Encryptor createInternalEncryptor(String className) {
		Encryptor encryptor = null;
		SecureKeyManager secureKeyManager = new SecureKeyManager(secureKeyRepository);
		try {
			encryptor = createEncryptor(className,
					combineKeys(loadKey(INTERNAL_ENCRYPTOR_KEY_PART_A_FILE), secureKeyManager
							.getKey(INTERNAL_ENCRYPTOR_KEY_PART_B_NAME, INTERNAL_ENCRYPTOR_KEY_CATEGORY).getData()));
			logger.debug("Internal encryptor created : " + encryptor.toString());
		} catch (Exception e) {
			logger.error("Internal encryptor create failed.", e);
		}

		return encryptor;
	}

	/**
	 * Creates an instance of the encryptor key encryptor.
	 * 
	 * @param className
	 *            The name of the key encryptor class.
	 * @return The encryptor key encryptor or <code>null</code> if the creation
	 *         failed.
	 */
	private Encryptor createKeyEncryptor(String className) {
		SecureKeyManager secureKeyManager = new SecureKeyManager(secureKeyRepository);
		SecureKeyProperty secureKeyA = secureKeyManager.getKey(KEY_ENCRYPTOR_KEY_PART_A_NAME,
				KEY_ENCRYPTOR_KEY_CATEGORY);
		SecureKeyProperty secureKeyB = secureKeyManager.getKey(KEY_ENCRYPTOR_KEY_PART_B_NAME,
				KEY_ENCRYPTOR_KEY_CATEGORY);

		byte[] key = null;

		if (secureKeyA != null && secureKeyB != null) {
			AESSecureKey aesSecureKeyA = new AESSecureKey(secureKeyA.getData(), secureKeyA.getProperties());
			AESSecureKey aesSecureKeyB = new AESSecureKey(secureKeyB.getData(), secureKeyB.getProperties());
			key = combineKeys(aesSecureKeyA.getKey(), aesSecureKeyB.getKey());
		}

		Encryptor encryptor = null;

		if (key != null) {
			encryptor = createEncryptor(className, key);
		}

		if (encryptor == null || key == null) {
			logger.error("Key encryptor creation failed.");
		} else {
			logger.error("Key encryptor created : " + encryptor.toString());
		}

		return encryptor;
	}

	/**
	 * Creates the MAC generator.
	 * 
	 * @param className
	 *            The name of the MAC generator class.
	 * @return The MAC generator or <code>null</code> if the creation failed.
	 */
	private MacGenerator createMacGenerator(String className) {
		SecureKeyManager secureKeyManager = new SecureKeyManager(secureKeyRepository);
		SecureKeyProperty secureKey = secureKeyManager.getKey(MAC_GENERATOR_KEY_NAME, MAC_GENERATOR_KEY_CATEGORY);

		byte[] key = null;

		if (secureKey != null) {
			key = secureKey.getData();
		}

		MacGenerator generator = null;

		if (key != null) {
			generator = createMacGenerator(className, key);
		}

		if (generator == null) {
			logger.error("MAC generator creation failed.");
		} else {
			logger.error("MAC generator created.");
		}
		return generator;
	}

	/**
	 * Creates an instance of the masker.
	 * 
	 * @param className
	 *            The name of the masker class.
	 * @return The masker or <code>null</code> if the creation failed.
	 */
	private static Masker createMasker(String className) {
		Masker masker = null;
		try {
			Class<? extends Masker> clazz = Class.forName(className).asSubclass(Masker.class);
			masker = clazz.newInstance();
			logger.debug(className + " masker class created.");
		} catch (Exception e) {
			logger.error(className + " masker class creation failed.", e);
		}
		return masker;
	}

	/**
	 * Creates an instance of the specified hasher.
	 * 
	 * @param className
	 *            The name of the hasher class.
	 * @return The hasher or <code>null</code> if the creation failed.
	 */
	private static Hasher createHasher(String className) {
		Hasher hasher = null;
		try {
			Class<? extends Hasher> clazz = Class.forName(className).asSubclass(Hasher.class);
			hasher = clazz.newInstance();
			logger.debug(className + " hasher class created.");
		} catch (Exception e) {
			logger.error(className + " hasher class creation failed.", e);
		}
		return hasher;
	}

	/**
	 * Creates an instance of the specified MAC generator.
	 * 
	 * @param className
	 *            The name of the MAC generator class.
	 * @param key
	 *            The key to be passed to the MAC generator.
	 * @return The MAC generator or <code>null</code> if the creation failed.
	 */
	private static MacGenerator createMacGenerator(String className, byte[] key) {
		MacGenerator generator = null;
		try {
			Constructor<?> constructor = Class.forName(className).getConstructor(byte[].class);
			generator = (MacGenerator) constructor.newInstance(key);
			logger.debug(className + " MAC generator created.");
		} catch (Exception e) {
			logger.error(className + " MAC generator creation failed.", e);
		}
		return generator;
	}

	/**
	 * Create instance of the specified encryptor.
	 * 
	 * @param className
	 *            The name of the encryptor.
	 * @param key
	 *            The key to be passed to the encryptor.
	 * @return An instance of the encryptor or <code>null</code> if the creation
	 *         failed.
	 */
	private static Encryptor createEncryptor(String className, byte[] key) {
		Encryptor encryptor = null;
		try {
			Constructor<?> constructor = Class.forName(className).getConstructor(byte[].class);
			encryptor = (Encryptor) constructor.newInstance(key);
			logger.debug(className + " encryptor created.");
		} catch (Exception e) {
			logger.error(className + " encryptor creation failed.", e);
		}
		return encryptor;
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
				try {
					is.close();
				} catch (IOException e) {
				}
			}
		}
		return key;
	}

	/**
	 * Reload the sensitive data encryptors.
	 */
	public static void reloadEncryptors() {
		if (encryptionService != null) {
			encryptionService.load();
		}
	}

	/**
	 * Encrypt the specified data using the current encryptor.
	 * 
	 * @param data
	 *            The data to encrypt.
	 * @return The encrypted data.
	 */
	public static ByteArrayCrypt encrypt(byte[] data) {
		return encrypt(data, getCurrentKeyIndex());
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
	public static ByteArrayCrypt encrypt(byte[] data, int keyIndex) {
		ByteArrayCrypt result = new ByteArrayCrypt(data, getFallbackKeyIndex(), false);
		if (encryptionService == null) {
			logger.warn("Encryption service not available.");
		} else {
			try {
				result = encryptionService.encrypt(data, keyIndex);
			} catch (Exception e) {
				logger.error("Encrypt failure.", e);
			}
		}
		return result;
	}

	/**
	 * Get the encrypted version of the specified data encrypted using each of the
	 * available encryptors.
	 * 
	 * @param data
	 *            The data to encrypt.
	 * @return The encrypted versions.
	 */
	public static List<ByteArrayCrypt> encryptForAll(byte[] data) {
		List<ByteArrayCrypt> results = new ArrayList<ByteArrayCrypt>();
		if (encryptionService == null) {
			logger.warn("Encryption service not available.");
		} else {
			try {
				results = encryptionService.encryptForAll(data);
			} catch (Exception e) {
				logger.error("Encrypt failure.", e);
			}
		}
		return results;
	}

	/**
	 * Encrypt the specified string using the current encryptor.
	 * 
	 * @param string
	 *            The string to encrypt.
	 * @return The encrypted string.
	 */
	public static StringCrypt encrypt(String string) {
		return encrypt(string, getCurrentKeyIndex());
	}

	/**
	 * Encrypt the specified string using the specified encryptor.
	 * 
	 * @param string
	 *            The string to encrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The encrypted string or the original string if an error occurred.
	 */
	public static StringCrypt encrypt(String string, int keyIndex) {
		StringCrypt result = new StringCrypt(string, getFallbackKeyIndex(), false);
		if (encryptionService == null) {
			logger.warn("Encryption service not available.");
		} else {
			try {
				result = encryptionService.encrypt(string, keyIndex);
			} catch (Exception e) {
				logger.error("Encrypt failure.", e);
			}
		}
		return result;
	}

	/**
	 * Get the encrypted version of the specified string encrypted using each of the
	 * available encryptors.
	 * 
	 * @param string
	 *            The string to encrypt.
	 * @return The encrypted versions.
	 */
	public static List<StringCrypt> encryptForAll(String string) {
		List<StringCrypt> results = new ArrayList<StringCrypt>();
		if (encryptionService == null) {
			logger.warn("Encryption service not available.");
		} else {
			try {
				results = encryptionService.encryptForAll(string);
			} catch (Exception e) {
				logger.error("Encrypt failure.", e);
			}
		}
		return results;
	}

	/**
	 * Decrypt the specified data using the current encryptor.
	 * 
	 * @param data
	 *            The data to decrypt.
	 * @return The decrypted data.
	 */
	public static ByteArrayCrypt decrypt(byte[] data) {
		return decrypt(data, getCurrentKeyIndex());
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
	public static ByteArrayCrypt decrypt(byte[] data, int keyIndex) {
		ByteArrayCrypt result = new ByteArrayCrypt(data, getFallbackKeyIndex(), false);
		if (encryptionService == null) {
			logger.warn("Encryption service not available.");
		} else {
			try {
				result = encryptionService.decrypt(data, keyIndex);
			} catch (Exception e) {
				logger.error("Decrypt failure.", e);
			}
		}
		return result;
	}

	/**
	 * Decrypt the specified string using the current encryptor.
	 * 
	 * @param value
	 *            The string to decrypt.
	 * @return The decrypted string.
	 */
	public static StringCrypt decrypt(String string) {
		return decrypt(string, getCurrentKeyIndex());
	}

	/**
	 * Decrypt the specified string using the specified encryptor.
	 * 
	 * @param string
	 *            The string to decrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The decrypted string or the original string if an error occurred.
	 */
	public static StringCrypt decrypt(String string, int keyIndex) {
		StringCrypt result = new StringCrypt(string, getFallbackKeyIndex(), false);
		if (encryptionService == null) {
			logger.warn("Encryption service not available.");
		} else {
			try {
				result = encryptionService.decrypt(string, keyIndex);
			} catch (Exception e) {
				logger.error("Decrypt failure.", e);
			}
		}
		return result;
	}

	/**
	 * Encrypt the specified key using the key encryptor.
	 * 
	 * @param key
	 *            The key to encrypt.
	 * @return The encrypted key.
	 */
	public static byte[] encryptKey(byte[] key) {
		byte[] result = key;
		if (keyEncryptor == null) {
			logger.warn("Key encryptor not available.");
		} else {
			try {
				result = keyEncryptor.encrypt(key);
			} catch (Exception e) {
				logger.error("Key encryption failed.", e);
			}
		}
		return result;
	}

	/**
	 * Decrypt the specified key using the key decryptor.
	 * 
	 * @param key
	 *            The key to decrypt.
	 * @return The decrypted key.
	 */
	public static byte[] decryptKey(byte[] key) {
		byte[] result = key;
		if (keyEncryptor == null) {
			logger.warn("Key encryptor not available.");
		} else {
			try {
				result = keyEncryptor.decrypt(key);
			} catch (Exception e) {
				logger.error("Key decryption failed.", e);
			}
		}
		return result;
	}

	/**
	 * Create random key of the specified length.
	 * 
	 * @param length
	 *            The length of the key.
	 * @return The key.
	 */
	public static byte[] createKey(int length) {
		char[] chars = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();
		StringBuilder sb = new StringBuilder();
		Random random = null;
		try {
			random = SecureRandom.getInstance(RANDOM_NUMBER_ALGORITHM, RANDOM_NUMBER_PROVIDER);
		} catch (NoSuchAlgorithmException | NoSuchProviderException e) {
			logger.error("Random number creation failure.", e);
			random = new Random();
		}

		for (int i = 0; i < length; i++) {
			sb.append(chars[random.nextInt(chars.length)]);
		}

		return sb.toString().getBytes();
	}

	/**
	 * Create a new key from the specified parts. Note that the key parts must be
	 * different but of equal length.
	 * 
	 * @param keyA
	 *            The first key part.
	 * @param keyB
	 *            The second key part.
	 * @return The new key.
	 * @throws IllegalArgumentException
	 *             Thrown if the keys parts are not the same length or are the same.
	 */
	public static byte[] combineKeys(byte[] keyA, byte[] keyB) throws IllegalArgumentException {
		if (keyA.length != keyB.length) {
			throw new IllegalArgumentException("Key part lengths are different.");
		}

		if (Arrays.equals(keyA, keyB)) {
			throw new IllegalArgumentException("Key parts are the same.");
		}

		byte[] key = new byte[keyA.length];

		for (int i = 0; i < keyA.length; i++) {
			key[i] = (byte) (0xff & (keyA[i] ^ keyB[i]));
		}

		return key;
	}

	/**
	 * Get the internal encryptor.
	 * 
	 * @return The internal encryptor.
	 */
	public static Encryptor getInternalEncryptor() {
		return internalEncryptor;
	}

	/**
	 * Encrypt the specified data using the internal encryptor.
	 * 
	 * @param data
	 *            The data to encrypt.
	 * @return The encrypted data or the original data if an error occurred.
	 */
	public static byte[] conceal(byte[] data) {
		byte[] result = data;
		if (internalEncryptor == null) {
			logger.warn("Internal encryptor not available.");
		} else {
			try {
				result = internalEncryptor.encrypt(data);
			} catch (Exception e) {
				logger.error("Internal encryption failed.", e);
			}
		}
		return result;
	}

	/**
	 * Decrypt the specified data using the internal decryptor.
	 * 
	 * @param data
	 *            The data to decrypt.
	 * @return The decrypted data or the original data if an error occurred.
	 */
	public static byte[] reveal(byte[] data) {
		byte[] result = data;
		if (internalEncryptor == null) {
			logger.warn("Internal encryptor not available.");
		} else {
			try {
				result = internalEncryptor.decrypt(data);
			} catch (Exception e) {
				logger.error("Internal decryption failed.", e);
			}
		}
		return result;
	}

	/**
	 * Encrypt the specified string using the internal encryptor.
	 * 
	 * @param value
	 *            The string to encrypt.
	 * @return The encrypted string or the original string if an error occurred.
	 */
	public static String conceal(String value) {
		String result = value;
		if (internalEncryptor == null) {
			logger.warn("Internal encryptor not available.");
		} else {
			try {
				result = internalEncryptor.encrypt(value);
			} catch (Exception e) {
				logger.error("Internal encryption failed.", e);
			}
		}
		return result;
	}

	/**
	 * Decrypt the specified string using the internal decryptor.
	 * 
	 * @param value
	 *            The string to decrypt.
	 * @return The decrypted string or the original string if an error occurred.
	 */
	public static String reveal(String value) {
		String result = value;
		if (internalEncryptor == null) {
			logger.warn("Internal encryptor not available.");
		} else {
			try {
				result = internalEncryptor.decrypt(value);
			} catch (Exception e) {
				logger.error("Internal decryption failed.", e);
			}
		}
		return result;
	}

	/**
	 * Mask the specified value.
	 * 
	 * @param value
	 *            The value to mask.
	 * @return The masked value or the original value if an error occurred.
	 */
	public static String mask(String value) {
		String result = value;
		if (masker == null) {
			logger.warn("Masker not available.");
		} else {
			try {
				result = masker.mask(value);
			} catch (Exception e) {
				logger.error("Mask failed.", e);
			}
		}
		return result;
	}

	/**
	 * Generate a hash of the specified string.
	 * 
	 * @param value
	 *            The string to hash.
	 * @return The hash.
	 */
	public static String hash(String value) {
		String result = "";
		if (hasher == null) {
			logger.warn("Hasher not available.");
		} else {
			try {
				result = hasher.hash(value);
			} catch (Exception e) {
				logger.error("String hash failed.", e);
			}
		}

		return result;
	}

	/**
	 * Generate a hash of the contents of the specified file.
	 * 
	 * @param value
	 *            The file to hash.
	 * @return The hash.
	 */
	public static String hash(File file) {
		String result = "";
		if (hasher == null) {
			logger.warn("Hasher not available.");
		} else {
			try {
				result = hasher.hash(file);
			} catch (Exception e) {
				logger.error("File hash failed.", e);
			}
		}
		return result;
	}
}
