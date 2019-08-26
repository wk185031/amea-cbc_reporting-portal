package my.com.mandrill.base.reporting.security;

public class SecureField extends SecureString {

	public SecureField(String clearData) {
		this(clearData, DataFormat.CLEAR);
	}
	
	public SecureField() {
		this("SECURE-FIELD", DataFormat.CLEAR);
	}
	
	static public SecureField fromClear(String clearData) {
		return new SecureField(clearData, DataFormat.CLEAR);
	}
	
	static public SecureField fromClear(String clearData, int keyIndex) {
		return new SecureField(clearData, DataFormat.CLEAR, keyIndex);
	}
	
	static public SecureField fromEncrypted(String encryptedData, int keyIndex) {
		return new SecureField(encryptedData, DataFormat.ENCRYPTED, keyIndex);
	}
	
	static public SecureField fromDatabase(String databaseData, int keyIndex) {
		return 
			SecurityManagerService.isDatabaseDataClear() ? 
				fromClear(databaseData, keyIndex) : 
				fromEncrypted(databaseData, keyIndex);
	}
	
	protected SecureField(String data, DataFormat dataFormat) {
		super(data, dataFormat);
	}

	protected SecureField(String data, DataFormat dataFormat, int keyIndex) {
		super(data, dataFormat, keyIndex);
	}
	
	public byte[] toByteArray() {
		return getClear().getBytes();
	}
}
