package my.com.mandrill.base.reporting.security;

public class SecurePANField extends SecureField {

	/**
	 * Create a secure PAN from the specified clear PAN. The PAN will be encrypted
	 * using the current system encryptor. In preference, please use the
	 * {@link #fromClear(String) fromClear} factory method.
	 * 
	 * @param clearPAN
	 *            The PAN in the clear.
	 */
	public SecurePANField(String clearPAN) {
		this(clearPAN, DataFormat.CLEAR);
	}

	/**
	 * DO NOT USE : This is the default secure PAN constructor used during
	 * reconstruction of a serialised secure PAN object.
	 */
	public SecurePANField() {
		this("SECURE-PAN", DataFormat.CLEAR);
	}

	/**
	 * Create a secure PAN from the specified clear PAN. The PAN will be encrypted
	 * using the current system encryptor.
	 * 
	 * @param clearPAN
	 *            The PAN in the clear.
	 * @return The secure PAN.
	 */
	static public SecurePANField fromClear(String clearPAN) {
		return new SecurePANField(clearPAN, DataFormat.CLEAR);
	}

	/**
	 * Create a secure PAN from the specified clear PAN. The PAN will be encrypted
	 * using the specified encryptor.
	 * 
	 * @param clearPAN
	 *            The PAN in the clear.
	 * @param keyIndex
	 *            The index of the encryptor.
	 * @return The secure PAN.
	 */
	static public SecurePANField fromClear(String clearPAN, int keyIndex) {
		return new SecurePANField(clearPAN, DataFormat.CLEAR, keyIndex);
	}

	/**
	 * Create a secure PAN from the specified encrypted PAN where the specified
	 * encryptor has been used to encrypt the PAN. Use
	 * {@link #fromDatabase(String, int) fromDatabase} if the secure PAN is being
	 * extracted from the database.
	 * 
	 * @param encryptedPAN
	 *            The encrypted PAN.
	 * @param keyIndex
	 *            The index of the encryptor.
	 * @return The secure PAN.
	 */
	static public SecurePANField fromEncrypted(String encryptedPAN, int keyIndex) {
		return new SecurePANField(encryptedPAN, DataFormat.ENCRYPTED, keyIndex);
	}

	/**
	 * Create a secure PAN from the PAN retrieved from the database where the
	 * specified encryptor will be used to encrypt or decrypt the PAN.
	 * 
	 * @param databasePAN
	 *            The PAN extracted from the database.
	 * @param keyIndex
	 *            The index of the encryptor.
	 * @return The secure PAN.
	 */
	static public SecurePANField fromDatabase(String databasePAN, int keyIndex) {
		return SecurityManagerService.isDatabaseDataClear() ? fromClear(databasePAN, keyIndex)
				: fromEncrypted(databasePAN, keyIndex);
	}

	protected SecurePANField(String data, DataFormat dataFormat) {
		super(data, dataFormat);
	}

	protected SecurePANField(String data, DataFormat dataFormat, int keyIndex) {
		super(data, dataFormat, keyIndex);
	}
}
