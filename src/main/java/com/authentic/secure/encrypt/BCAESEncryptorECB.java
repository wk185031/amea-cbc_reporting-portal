package com.authentic.secure.encrypt;

import java.security.Key;
import java.security.Security;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
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

public class BCAESEncryptorECB extends Encryptor {

	private final static Logger logger = LoggerFactory.getLogger(BCAESEncryptorECB.class);
	private static final String PROVIDER = "BC";
	private static final String KEY_ALGORITHM = "AES";
	private static final String CIPHER_ALGORITHM = "AES/ECB/PKCS5PADDING";
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
	private GenericObjectPool<Cipher> eCipherPool = new GenericObjectPool<Cipher>(new EncryptorFactory(), poolConfig);
	private GenericObjectPool<Cipher> dCipherPool = new GenericObjectPool<Cipher>(new DecryptorFactory(), poolConfig);

	private class EncryptorFactory extends BasePooledObjectFactory<Cipher> {
		@Override
		public Cipher create() throws Exception {
			Cipher cipher = Cipher.getInstance(CIPHER_ALGORITHM, PROVIDER);
			cipher.init(Cipher.ENCRYPT_MODE, key);
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
			cipher.init(Cipher.DECRYPT_MODE, key);
			return cipher;
		}

		@Override
		public PooledObject<Cipher> wrap(Cipher cipher) {
			return new DefaultPooledObject<Cipher>(cipher);
		}
	}

	public BCAESEncryptorECB() throws Exception {
		KeyGenerator keyGenerator = KeyGenerator.getInstance(KEY_ALGORITHM, PROVIDER);
		keyGenerator.init(PREFERRED_KEY_LENGTH * 8);
		key = keyGenerator.generateKey();
	}

	public BCAESEncryptorECB(byte[] rawKey) throws Exception {
		key = new SecretKeySpec(rawKey, KEY_ALGORITHM);
	}

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

	@Override
	public String encrypt(String string) throws Exception {
		return string == null ? null : new String(encode(encrypt(string.getBytes("UTF-8"))), "UTF-8");
	}

	@Override
	public String decrypt(String string) throws Exception {
		return string == null ? null : new String(decrypt(decode(string.getBytes("UTF-8"))), "UTF-8");
	}

	public byte[] getKey() {
		return key.getEncoded();
	}

	public int getPreferredKeyLength() {
		return PREFERRED_KEY_LENGTH;
	}

	public boolean isKeyOk(byte[] key) {
		return key.length == PREFERRED_KEY_LENGTH;
	}

	public String getCheckValue() throws Exception {
		String checkValue = new String(encode(encrypt(new byte[PREFERRED_KEY_LENGTH])), "UTF-8");
		return checkValue.substring(0, 6);
	}
}
