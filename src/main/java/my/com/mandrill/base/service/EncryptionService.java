package my.com.mandrill.base.service;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.ncr.dcms.util.DecryptUtility;

import my.com.mandrill.base.reporting.security.SecurePANField;
import my.com.mandrill.base.reporting.security.SecureString;

@Component
public class EncryptionService {
	
	private final Logger logger = LoggerFactory.getLogger(EncryptionService.class);
	
	private DecryptUtility dcmsDecrypt;

	public String decryptAuthenticField(String encString, int keyIndex) {
		return SecurePANField.fromDatabase(encString, keyIndex).getClear();
	}
	
	public String decryptAuthenticTag(String encString, int keyIndex) {
		return SecureString.fromDatabase(encString, keyIndex).getClear();
	}
	
	public String decryptDcms(String encString, String institutionCode, int rotationNumber) {
		logger.debug("encString={}, institutionCode={}, rotationNumber={}", encString, institutionCode, rotationNumber);
		String decrypt = dcmsDecrypt.decrypt(institutionCode, rotationNumber, encString);
		return decrypt == null ? encString : decrypt;
	}

	
	@PostConstruct
	public void init() {
		dcmsDecrypt = new DecryptUtility();
	}

}
