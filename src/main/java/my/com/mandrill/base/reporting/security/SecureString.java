package my.com.mandrill.base.reporting.security;

import java.io.Externalizable;
import java.io.IOException;
import java.io.ObjectInput;
import java.io.ObjectOutput;

import my.com.mandrill.base.reporting.security.SecureCrypt.StringCrypt;

public class SecureString implements Externalizable {

	protected enum DataFormat {
		CLEAR, ENCRYPTED
	}

	private String clearData = null;
	private String encryptedData = null;
	private String maskedData = null;
	private String databaseData = null;

	private int keyIndex;
	private boolean ok = true;

	private static final boolean lazy = true;

	/**
	 * Create a secure string from the specified clear string. The data will be
	 * encrypted using the current system encryptor. If possible, please use the
	 * {@link #fromClear(String) fromClear} factory method instead.
	 * 
	 * @param data
	 *            The clear string.
	 * @param dataFormat
	 *            The format of the data, clear or encrypted.
	 */
	public SecureString(String clearData) {
		this(clearData, DataFormat.CLEAR);
	}

	/**
	 * DO NOT USE : This is the default secure string constructor used during
	 * reconstruction of a serialised secure string.
	 */
	public SecureString() {
		this("SECURE-STRING", DataFormat.CLEAR);
	}

	/**
	 * Create a secure string from the specified clear data. The data will be
	 * encrypted using the current system encryptor.
	 * 
	 * @param clearData
	 *            The data in the clear.
	 * @return The secure string.
	 */
	static public SecureString fromClear(String clearData) {
		return new SecureString(clearData, DataFormat.CLEAR);
	}

	/**
	 * Create a secure string from the specified clear data. The data will be
	 * encrypted using the specified encryptor.
	 * 
	 * @param clearData
	 *            The data in the clear.
	 * @param keyIndex
	 *            The index of the encryptor.
	 * @return The secure string.
	 */
	static public SecureString fromClear(String clearData, int keyIndex) {
		return new SecureString(clearData, DataFormat.CLEAR, keyIndex);
	}

	/**
	 * Create a secure string from the specified encrypted data where the specified
	 * encryptor has been used to encrypt the data.
	 * 
	 * @param encryptedData
	 *            The encrypted data.
	 * @param keyIndex
	 *            The index of the encryptor.
	 * @return The secure string.
	 */
	static public SecureString fromEncrypted(String encryptedData, int keyIndex) {
		return new SecureString(encryptedData, DataFormat.ENCRYPTED, keyIndex);
	}

	/**
	 * Create a secure string from the data retrieved from the database where the
	 * specified encryptor will be used to encrypt or decrypt the data. Use
	 * {@link #fromDatabase(String, int) fromDatabase} if the secure string is being
	 * extracted from the database.
	 * 
	 * @param databaseData
	 *            The data extracted from the database.
	 * @param keyIndex
	 *            The index of the encryptor.
	 * @return The secure string.
	 */
	static public SecureString fromDatabase(String databaseData, int keyIndex) {
		return SecurityManagerService.isDatabaseDataClear() ? fromClear(databaseData, keyIndex)
				: fromEncrypted(databaseData, keyIndex);
	}

	/**
	 * Create a secure string from the specified string.
	 * 
	 * @param data
	 *            The data, clear or encrypted.
	 * @param dataFormat
	 *            The format of the data, clear or encrypted.
	 */
	protected SecureString(String data, DataFormat dataFormat) {
		this(data, dataFormat, SecurityManagerService.getCurrentKeyIndex());
	}

	/**
	 * Create a secure string from the specified string and use the specified
	 * encryptor for encryption or decryption.
	 * 
	 * @param data
	 *            The data, clear or encrypted.
	 * @param dataFormat
	 *            The format of the data, clear or encrypted.
	 * @param keyIndex
	 *            The index of the encryptor.
	 */
	protected SecureString(String data, DataFormat dataFormat, int keyIndex) {
		super();
		initialise(data, dataFormat, keyIndex);
	}

	/**
	 * Get the clear form.
	 * 
	 * @return The clear form.
	 */
	public String getClear() {
		String result = clearData;
		if (clearData == null && encryptedData != null) {
			StringCrypt crypt = SecurityManagerService.decrypt(encryptedData, keyIndex);
			result = crypt.getValue();
			keyIndex = crypt.getKeyIndex();
			ok = crypt.isOk();

			if (!SecurityManagerService.onlyHoldEncryptedForm()) {
				clearData = result;
			}
		}
		return result;
	}

	/**
	 * Get the encrypted form.
	 * 
	 * @return The encrypted form.
	 */
	public String getEncrypted() {
		if (encryptedData == null) {
			StringCrypt crypt = SecurityManagerService.encrypt(clearData, keyIndex);
			encryptedData = crypt.getValue();
			keyIndex = crypt.getKeyIndex();
			ok = crypt.isOk();
		}
		return encryptedData;
	}

	/**
	 * Get the masked form.
	 * 
	 * @return The masked form.
	 */
	public String getMasked() {
		String result = maskedData;
		if (maskedData == null) {
			result = SecurityManagerService.mask(getClear());
			if (!SecurityManagerService.onlyHoldEncryptedForm()) {
				maskedData = result;
			}
		}
		return result;
	}

	/**
	 * Get the index of the encryptor being used to encrypted the data of this
	 * secure string.
	 * 
	 * @return The key index.
	 */
	public int getKeyIndex() {
		return keyIndex;
	}

	/**
	 * Identifies whether the internal state of this secure string is thought to be
	 * OK or not. It will not be regarded as OK if an error occurred during the last
	 * encrypt or decrypt operation performed.
	 * 
	 * @return <code>true</code> implies things are OK, <code>false</code>
	 *         otherwise.
	 */
	public boolean isOk() {
		return ok;
	}

	/**
	 * Get the form suitable for storage in the database.
	 * 
	 * @return The form suitable for storage in the database.
	 */
	public String toDatabase() {
		String result = databaseData;
		if (databaseData == null) {
			result = SecurityManagerService.isDatabaseDataClear() ? getClear() : getEncrypted();
			if (!SecurityManagerService.onlyHoldEncryptedForm()) {
				databaseData = result;
			}
		}
		return result;
	}

	/**
	 * Indicates whether some other object is "equal to" this one.
	 * 
	 * @param other
	 *            The other object to compare this secure object against.
	 * @return <code>true</code> if the other object is an equivalent secure string,
	 *         <code>false</code> otherwise.
	 */
	public boolean equals(Object other) {
		return other instanceof SecureString && getClear().equals(((SecureString) other).getClear());
	}

	/**
	 * Compare the clear version of this secure string to that of another while
	 * ignoring case considerations.
	 * 
	 * @param other
	 *            The other object to compare this secure string against.
	 * @return <code>true</code> if the other object is an equivalent secure string
	 *         ignoring case, <code>false</code> otherwise.
	 */
	public boolean equalsIgnoreCase(Object other) {
		return other instanceof SecureString && getClear().equalsIgnoreCase(((SecureString) other).getClear());
	}

	/**
	 * The hash code of this secure string. return The hash code.
	 */
	public int hashCode() {
		return getClear().hashCode();
	}

	/*
	 * -------------------------------------------------------------------------
	 * SERIALISATION
	 * -------------------------------------------------------------------------
	 * 
	 * ONLY MARSHAL THE ENCRYPTED DATA.
	 * 
	 * -------------------------------------------------------------------------
	 */
	public void readExternal(ObjectInput in) throws IOException {
		/* retrieve in right order */
		int keyIndex = in.readInt();
		String encryptedData = loadString(in);
		/* nullify the default clear data */
		clearData = null;
		/* initialise other fields */
		initialise(encryptedData, DataFormat.ENCRYPTED, keyIndex);
	}

	public void writeExternal(ObjectOutput out) throws IOException {
		/* only save encrypted data */
		out.writeInt(keyIndex);
		saveString(out, getEncrypted());
	}

	private void saveString(ObjectOutput out, String string) throws IOException {
		if (string == null) {
			out.writeInt(-1);
		} else {
			byte[] data = string.getBytes("UTF-8");
			out.writeInt(data.length);
			out.write(data);
		}
	}

	private String loadString(ObjectInput in) throws IOException {
		String string = null;
		int length = in.readInt();
		if (length == 0) {
			string = "";
		} else if (length < 0) {
			string = null;
		} else {
			byte[] data = new byte[length];
			in.readFully(data);
			string = new String(data, "UTF-8");
		}

		return string;
	}

	/**
	 * Controls the initialisation of the secure string. It sets the various forms
	 * of the data depending on the current security parameters.
	 * 
	 * @param data
	 *            The data, clear or encrypted.
	 * @param dataFormat
	 *            The format of the data, clear or encrypted.
	 * @param keyIndex
	 *            The index of the encryptor.
	 */
	@SuppressWarnings("unused")
	private void initialise(String data, DataFormat dataFormat, int keyIndex) {
		/* set encryption key */
		this.keyIndex = keyIndex;
		/* set clear and encrypted versions */
		switch (dataFormat) {
		case CLEAR:
			if (SecurityManagerService.onlyHoldEncryptedForm()) {
				StringCrypt crypt = SecurityManagerService.encrypt(data, keyIndex);
				encryptedData = crypt.getValue();
				this.keyIndex = crypt.getKeyIndex();
				ok = crypt.isOk();
			} else {
				clearData = data;
				if (!lazy) {
					StringCrypt crypt = SecurityManagerService.encrypt(data, keyIndex);
					encryptedData = crypt.getValue();
					this.keyIndex = crypt.getKeyIndex();
					ok = crypt.isOk();
				}
			}
			break;
		case ENCRYPTED:
			encryptedData = data;
			if (!lazy && !SecurityManagerService.onlyHoldEncryptedForm()) {
				StringCrypt crypt = SecurityManagerService.decrypt(data, keyIndex);
				clearData = crypt.getValue();
				this.keyIndex = crypt.getKeyIndex();
				ok = crypt.isOk();
			}
			break;
		default:
			clearData = "";
			encryptedData = "";
		}

		if (!lazy && !SecurityManagerService.onlyHoldEncryptedForm()) {
			/* set masked version */
			maskedData = getMasked();
			/* set database version */
			databaseData = toDatabase();
		}
	}
}
