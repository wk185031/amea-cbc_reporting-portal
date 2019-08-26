package com.authentic.secure.hash;

import java.io.File;
import java.io.FileInputStream;
import java.security.MessageDigest;
import java.security.Security;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.security.Hasher;
import my.com.mandrill.base.reporting.security.SecureHexBinaryAdapter;

public class BCSHA512Digester extends Hasher {

	private final static Logger logger = LoggerFactory.getLogger(BCSHA512Digester.class);
	private static final String PROVIDER = "BC";
	private static final String HASH_ALGORITHM = "SHA-512";

	static {
		if (Security.getProvider(PROVIDER) == null) {
			try {
				Security.addProvider(BouncyCastleProvider.class.newInstance());
			} catch (Exception e) {
				logger.error("Failed to load the Bouncy Castle security provider.", e);
			}
		}
	}

	@Override
	public String hash(String string) throws Exception {
		MessageDigest md = MessageDigest.getInstance(HASH_ALGORITHM, PROVIDER);
		md.update(string.getBytes());
		return new String(SecureHexBinaryAdapter.encode(md.digest()), "UTF-8").toLowerCase();
	}

	@Override
	public String hash(File file) throws Exception {
		String hash = "";
		FileInputStream fis = null;
		try {
			MessageDigest md = MessageDigest.getInstance(HASH_ALGORITHM, PROVIDER);
			fis = new FileInputStream(file);
			byte[] dataBytes = new byte[1024];
			int nread = 0;
			while ((nread = fis.read(dataBytes)) != -1) {
				md.update(dataBytes, 0, nread);
			}
			hash = new String(SecureHexBinaryAdapter.encode(md.digest()), "UTF-8");
		} finally {
			if (fis != null) {
				fis.close();
			}
		}
		return hash.toLowerCase();
	}
}
