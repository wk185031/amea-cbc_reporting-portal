package com.authentic.secure.encrypt;

import java.security.Key;
import java.security.Security;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.pool2.BasePooledObjectFactory;
import org.apache.commons.pool2.PooledObject;
import org.apache.commons.pool2.impl.DefaultPooledObject;
import org.apache.commons.pool2.impl.GenericObjectPool;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.security.Encryptor;

public class BCAESEncryptorCBC extends Encryptor {

	private final static Logger logger = LoggerFactory.getLogger(BCAESEncryptorCBC.class);
	private static final String PROVIDER = "BC";
	private static final String KEY_ALGORITHM = "AES";
	private static final String CIPHER_ALGORITHM = "AES/CBC/PKCS5PADDING";
	private static final String IV = "Ii288zNA4SrzvwD1";
	private static final int PREFERRED_KEY_LENGTH = 32;
	private static final int POOL_SIZE = 100;
	private static final GenericObjectPoolConfig poolConfig = new GenericObjectPoolConfig();

	static {
		if (Security.getProvider(PROVIDER) == null) {
			try {
				Security.addProvider(BouncyCastleProvider.class.newInstance());
			} catch (Exception e) {
				logger.error("Failed to load the Bouncy Castle security provider.", e);
			}
		}
		poolConfig.setMaxTotal(POOL_SIZE);
	}

	private final Key key;
	private final IvParameterSpec iv;
	private GenericObjectPool<Cipher> eCipherPool = new GenericObjectPool<Cipher>(new EncryptorFactory(), poolConfig);
	private GenericObjectPool<Cipher> dCipherPool = new GenericObjectPool<Cipher>(new DecryptorFactory(), poolConfig);

	private class EncryptorFactory extends BasePooledObjectFactory<Cipher> {
		@Override
		public Cipher create() throws Exception {
			Cipher cipher = Cipher.getInstance(CIPHER_ALGORITHM, PROVIDER);
			cipher.init(Cipher.ENCRYPT_MODE, key, iv);
			return cipher;
		}

		@Override
		public PooledObject<Cipher> wrap(Cipher cipher) {
			return new DefaultPooledObject<Cipher>(cipher);
		}
	}

	private class DecryptorFactory extends BasePooledObjectFactory<Cipher> {
		@Override
		public Cipher create() throws Exception {
			Cipher cipher = Cipher.getInstance(CIPHER_ALGORITHM, PROVIDER);
			cipher.init(Cipher.DECRYPT_MODE, key, iv);
			return cipher;
		}

		@Override
		public PooledObject<Cipher> wrap(Cipher cipher) {
			return new DefaultPooledObject<Cipher>(cipher);
		}
	}

	/**
	 * Construct a Bouncy Castle AES encryptor.
	 */
	public BCAESEncryptorCBC() throws Exception {
		KeyGenerator keyGenerator = KeyGenerator.getInstance(KEY_ALGORITHM, PROVIDER);
		keyGenerator.init(PREFERRED_KEY_LENGTH * 8);

		key = keyGenerator.generateKey();
		iv = new IvParameterSpec(IV.getBytes());
	}

	/**
	 * Construct a Bouncy Castle AES encryptor.
	 * 
	 * @param rawKey
	 *            The encryption key.
	 */
	public BCAESEncryptorCBC(byte[] rawKey) throws Exception {
		key = new SecretKeySpec(rawKey, KEY_ALGORITHM);
		iv = new IvParameterSpec(IV.getBytes());
	}

	/**
	 * Encrypt the specified data.
	 * 
	 * @param data
	 *            The data to be encrypted.
	 * @return The encrypted form of the specified data.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	@Override
	public byte[] encrypt(byte[] data) throws Exception {
		byte[] encrypted = data;
		if (data != null) {
			Cipher cipher = eCipherPool.borrowObject();
			try {
				encrypted = cipher.doFinal(data);
			} finally {
				eCipherPool.returnObject(cipher);
			}
		}
		return encrypted;
	}

	/**
	 * Decrypt the specified data.
	 * 
	 * @param data
	 *            The data to be decrypted.
	 * @return The decrypted form of the specified data.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	@Override
	public byte[] decrypt(byte[] data) throws Exception {
		byte[] decrypted = data;
		if (data != null) {
			Cipher cipher = dCipherPool.borrowObject();
			try {
				decrypted = cipher.doFinal(data);
			} finally {
				dCipherPool.returnObject(cipher);
			}
		}
		return decrypted;
	}

	/**
	 * Encrypt the specified string.
	 * 
	 * @param string
	 *            The string to be encrypted.
	 * @return The encrypted form of the specified string.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	@Override
	public String encrypt(String string) throws Exception {
		return string == null ? null : new String(encode(encrypt(string.getBytes("UTF-8"))), "UTF-8");
	}

	/**
	 * Decrypt the specified string.
	 * 
	 * @param string
	 *            The string to be decrypted.
	 * @return The decrypted form of the specified string.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	@Override
	public String decrypt(String string) throws Exception {
		return string == null ? null : new String(decrypt(decode(string.getBytes("UTF-8"))), "UTF-8");
	}

	/**
	 * Get the raw key.
	 * 
	 * @return The key.
	 */
	public byte[] getKey() {
		return key.getEncoded();
	}

	/**
	 * Get the preferred length of a key.
	 * 
	 * @return The preferred key length.
	 */
	public int getPreferredKeyLength() {
		return PREFERRED_KEY_LENGTH;
	}

	/**
	 * Determines whether the specified key is acceptable.
	 * 
	 * @return <code>true</code> implies the key is acceptable, <code>false</code>
	 *         otherwise.
	 */
	public boolean isKeyOk(byte[] key) {
		return key.length == PREFERRED_KEY_LENGTH;
	}

	/**
	 * Calculate a check value.
	 * 
	 * @return The check value.
	 * @throws Exception
	 *             Thrown if an error occurs during the evaluation of the check
	 *             value.
	 */
	public String getCheckValue() throws Exception {
		String checkValue = new String(encode(encrypt(new byte[PREFERRED_KEY_LENGTH])), "UTF-8");
		return checkValue.substring(0, 6);
	}

	/**
	 * Returns a description of this encryptor.
	 * 
	 * @return The description of this encryptor.
	 */
	public String toString() {
		String string = "";
		try {
			Cipher eCipher = (Cipher) eCipherPool.borrowObject();
			Cipher dCipher = (Cipher) dCipherPool.borrowObject();
			string = "BC AES CBC Encryptor : " + "encryptor[" + "provider=" + eCipher.getProvider().getName()
					+ ",version=" + eCipher.getProvider().getVersion() + ",algorithm=" + eCipher.getAlgorithm()
					+ ",block=" + eCipher.getBlockSize() + "] decryptor[" + "provider="
					+ dCipher.getProvider().getName() + ",version=" + dCipher.getProvider().getVersion() + ",algorithm="
					+ dCipher.getAlgorithm() + ",block=" + dCipher.getBlockSize() + "] key[" + "algorithm="
					+ key.getAlgorithm() + ",length=" + (8 * key.getEncoded().length) + "].";
			eCipherPool.returnObject(eCipher);
			dCipherPool.returnObject(dCipher);
		} catch (Exception e) {
			string = "BC AES CBC Encryptor : " + "encryptor[UNKNOWN] decryptor[UNKNOWN].";
		}
		return string;
	}
}
