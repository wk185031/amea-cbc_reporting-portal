package my.com.mandrill.base.service;

import javax.annotation.PostConstruct;

import org.springframework.stereotype.Component;

import com.ncr.dcms.util.DecryptUtility;

import my.com.mandrill.base.reporting.security.SecurePANField;
import my.com.mandrill.base.reporting.security.SecureString;

@Component
public class EncryptionService {
	
	private DecryptUtility dcmsDecrypt;

	public String decryptAuthenticField(String encString, int keyIndex) {
		return SecurePANField.fromDatabase(encString, keyIndex).getClear();
	}
	
	public String decryptAuthenticTag(String encString, int keyIndex) {
		return SecureString.fromDatabase(encString, keyIndex).getClear();
	}
	
	public String decryptDcms(String encString) {
		return dcmsDecrypt.decrypt("CBC", 0, encString);
	}
	
	@PostConstruct
	public void init() {
		dcmsDecrypt = new DecryptUtility();
	}
}
