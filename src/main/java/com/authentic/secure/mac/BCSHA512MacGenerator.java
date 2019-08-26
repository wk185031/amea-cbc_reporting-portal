package com.authentic.secure.mac;

import java.security.Key;
import java.security.Security;

import javax.crypto.KeyGenerator;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.pool2.BasePooledObjectFactory;
import org.apache.commons.pool2.PooledObject;
import org.apache.commons.pool2.impl.DefaultPooledObject;
import org.apache.commons.pool2.impl.GenericObjectPool;
import org.apache.commons.pool2.impl.GenericObjectPoolConfig;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.security.MacGenerator;

public class BCSHA512MacGenerator extends MacGenerator {

	private final static Logger logger = LoggerFactory.getLogger(BCSHA512MacGenerator.class);
	private static final String PROVIDER = "BC";
	private static final String ALGORITHM = "HMACSHA512";
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
	private GenericObjectPool<Mac> macPool = new GenericObjectPool<Mac>(new MacFactory(), poolConfig);

	private class MacFactory extends BasePooledObjectFactory<Mac> {
		@Override
		public Mac create() throws Exception {
			Mac mac = Mac.getInstance(ALGORITHM, PROVIDER);
			mac.init(key);
			return mac;
		}

		@Override
		public PooledObject<Mac> wrap(Mac mac) {
			return new DefaultPooledObject<Mac>(mac);
		}
	}

	public BCSHA512MacGenerator() throws Exception {
		KeyGenerator keyGenerator = KeyGenerator.getInstance(ALGORITHM);
		key = keyGenerator.generateKey();
	}

	public BCSHA512MacGenerator(byte[] rawKey) throws Exception {
		key = new SecretKeySpec(rawKey, ALGORITHM);
	}

	@Override
	public byte[] mac(byte[] data) throws Exception {
		byte[] hash = data;
		if (data != null) {
			Mac mac = macPool.borrowObject();
			try {
				hash = encode(mac.doFinal(data));
			} finally {
				macPool.returnObject(mac);
			}
		}
		return hash;
	}

	@Override
	public String mac(String string) throws Exception {
		return string == null ? null : new String(mac(string.getBytes("UTF-8")), "UTF-8");
	}

	public byte[] getKey() {
		return key.getEncoded();
	}
}
