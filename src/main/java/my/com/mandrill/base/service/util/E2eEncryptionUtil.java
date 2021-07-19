package my.com.mandrill.base.service.util;

import java.nio.charset.StandardCharsets;
import java.security.DigestException;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class E2eEncryptionUtil {

	public static String encryptEcb(String clearKey, String token) {
    	try {
        	byte[] bToken = token.getBytes();

        	SecretKeySpec key = new SecretKeySpec(clearKey.getBytes(), "AES");

        	Cipher aesCBC = Cipher.getInstance("AES");
        	aesCBC.init(Cipher.ENCRYPT_MODE, key);
        	byte[] encryptedData = aesCBC.doFinal(bToken);
        	String b64ncryptedText = new String(Base64.getEncoder().encode(encryptedData));
        	
        	return b64ncryptedText;
    	} catch (Exception e) {
    		throw new RuntimeException(e);
    	}
    }
	
	public static String decryptEcb(String clearKey, String token) {
    	try {
        	SecretKeySpec key = new SecretKeySpec(clearKey.getBytes(StandardCharsets.UTF_8), "AES");
   
        	Cipher aesCBC = Cipher.getInstance("AES");
        	aesCBC.init(Cipher.DECRYPT_MODE, key);
        	byte[] encryptedData = aesCBC.doFinal(Base64.getDecoder().decode(token));

        	return new String(encryptedData);
    	} catch (Exception e) {
    		throw new RuntimeException(e);
    	}
    }
	
	public static String decryptToken(String clearKey, String cipherText) {
    	try {
        	byte[] cipherData = Base64.getDecoder().decode(cipherText);
        	byte[] saltData = Arrays.copyOfRange(cipherData, 8, 16);

        	MessageDigest md5 = MessageDigest.getInstance("MD5");
        	final byte[][] keyAndIV = GenerateKeyAndIV(32, 16, 1, saltData, clearKey.getBytes(StandardCharsets.UTF_8), md5);
        	SecretKeySpec key = new SecretKeySpec(keyAndIV[0], "AES");
        	IvParameterSpec iv = new IvParameterSpec(keyAndIV[1]);

        	byte[] encrypted = Arrays.copyOfRange(cipherData, 16, cipherData.length);
        	Cipher aesCBC = Cipher.getInstance("AES/CBC/PKCS5Padding");
        	aesCBC.init(Cipher.DECRYPT_MODE, key, iv);
        	byte[] decryptedData = aesCBC.doFinal(encrypted);
        	String decryptedText = new String(decryptedData, StandardCharsets.UTF_8);
        	
        	return decryptedText;
    	} catch (Exception e) {
    		throw new RuntimeException(e);
    	}
    }
	
	public static byte[][] GenerateKeyAndIV(int keyLength, int ivLength, int iterations, byte[] salt, byte[] password, MessageDigest md) {

        int digestLength = md.getDigestLength();
        int requiredLength = (keyLength + ivLength + digestLength - 1) / digestLength * digestLength;
        byte[] generatedData = new byte[requiredLength];
        int generatedLength = 0;

        try {
            md.reset();

            // Repeat process until sufficient data has been generated
            while (generatedLength < keyLength + ivLength) {

                // Digest data (last digest if available, password data, salt if available)
                if (generatedLength > 0)
                    md.update(generatedData, generatedLength - digestLength, digestLength);
                md.update(password);
                if (salt != null)
                    md.update(salt, 0, 8);
                md.digest(generatedData, generatedLength, digestLength);

                // additional rounds
                for (int i = 1; i < iterations; i++) {
                    md.update(generatedData, generatedLength, digestLength);
                    md.digest(generatedData, generatedLength, digestLength);
                }

                generatedLength += digestLength;
            }

            // Copy key and IV into separate byte arrays
            byte[][] result = new byte[2][];
            result[0] = Arrays.copyOfRange(generatedData, 0, keyLength);
            if (ivLength > 0)
                result[1] = Arrays.copyOfRange(generatedData, keyLength, keyLength + ivLength);

            return result;

        } catch (DigestException e) {
            throw new RuntimeException(e);

        } finally {
            // Clean out temporary data
            Arrays.fill(generatedData, (byte)0);
        }
    }
	
	public static void main(String[] args) {
		String key = "0+4*LjOrxdic|>1L";
		String plainText = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjYmNvcGVyYXRvciIsImF1dGgiOiJST0xFX1VTRVIiLCJleHAiOjE2MjY2OTEzODV9.2vgRHnuxFTiZHDJq3zLsPv4UEYBm7rm3XwZmz5aVdy2UVW4_OZLoQYzqc1wSe9P46gNlteiCBEr_iGmw4JwpTg";
		//String encryptedStr = "jA2gE+eI4W9RMuWx1tQVSSDFj4M9xXFV3FvYzhjQISgjM7vhvNXufRLDrAYOpdxZEbbZBvnViLr/W9RHhJ5lLje5cIsJHZCovXtnlY/ZSiPw2qWvL2151QZsnGFhsYmGBi5gevCTcnaOMu340pEfWobr7BnkGQgY5hw9ye51VhMWcCQHScF90UP6HsDgyCTU4CA03AKIrKJu337KipJRTDR2JyrhATZ2CjLJIRqUm0hE+BePGIw5Sl2PoE9Fz0Y8";
		String encryptedStr = "U2FsdGVkX1/U34COYyD9yAorCzkRxnQWu6ErhSPiN0HqnWScyYAq4erQ2k/LMdWjTgl5nULYJ8KH6TQVYExcd8YjLUxIAkYSpb4TeacGsQ6j6r3CBmpP4jz1LRbvzYJbzzu5gibCQg6oCZ+VcqgxDwHLCbyRvDEOYQgk07DeBkqOB+u3DsA4JDyag3b03DnTMyH8rdJa+BIHNCtGR0VDDC2awuqrYE6Y6zU8/KbzktBS1V+nYhuNRRlXrvzdermnNx847HMVvmYwHlj1oMbjsw==";
		System.out.println("b64Key="+Base64.getEncoder().encodeToString(key.getBytes()));
		System.out.println(E2eEncryptionUtil.encryptEcb(key, plainText));
		
		System.out.println("----"+E2eEncryptionUtil.decryptEcb(key, encryptedStr));
		
		
	}
}
