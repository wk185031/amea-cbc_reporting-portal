package my.com.mandrill.base.reporting.security;

public class SecureCrypt {

	/**
	 * A class used to return the result of an attempt to encrypt or decrypt a
	 * string.
	 */
	public static class StringCrypt {

		private final String value;
		private final int keyIndex;
		private final boolean ok;

		/**
		 * The constructor of a StringCrypt.
		 * 
		 * @param value
		 *            The string that was returned by the encrypt or decrypt.
		 * @param keyIndex
		 *            The index of the encryptor used.
		 * @param ok
		 *            <code>true</code> means the operation was successful,
		 *            <code>false</code> otherwise.
		 */
		public StringCrypt(String value, int keyIndex, boolean ok) {
			this.value = value;
			this.keyIndex = keyIndex;
			this.ok = ok;
		}

		/**
		 * Get the value returned by the encrypt or decrypt operation. This will be a
		 * copy of the data passed into the operation if the operation was unsuccessful.
		 * 
		 * @return The value.
		 */
		public String getValue() {
			return value;
		}

		/**
		 * Get the id of the encryptor used to encrypt or decrypt the data. This will be
		 * the id of the fallback encryptor if the operation was unsuccessful.
		 * 
		 * @return The id of the encryptor.
		 */
		public int getKeyIndex() {
			return keyIndex;
		}

		/**
		 * Identify whether the operation was successful or otherwise.
		 * 
		 * @return <code>true</code> implies the operation was successful,
		 *         <code>false</code> otherwise.
		 */
		public boolean isOk() {
			return ok;
		}
	}

	/**
	 * A class used to return the result of an attempt to encrypt or decrypt the
	 * contents of a byte array.
	 */
	public static class ByteArrayCrypt {

		private final byte[] value;
		private final int keyIndex;
		private final boolean ok;

		/**
		 * The constructor of a ByteArrayCrypt.
		 * 
		 * @param value
		 *            The byte array that was returned by the encrypt or decrypt.
		 * @param keyIndex
		 *            The index of the encryptor used.
		 * @param ok
		 *            <code>true</code> means the operation was successful,
		 *            <code>false</code> otherwise.
		 */
		public ByteArrayCrypt(byte[] value, int keyIndex, boolean ok) {
			this.value = value;
			this.keyIndex = keyIndex;
			this.ok = ok;
		}

		/**
		 * Get the value returned by the encrypt or decrypt operation. This will be a
		 * copy of the data passed into the operation if the operation was unsuccessful.
		 * 
		 * @return The value.
		 */
		public byte[] getValue() {
			return value;
		}

		/**
		 * Get the id of the encryptor used to encrypt or decrypt the data. This will be
		 * the id of the fallback encryptor if the operation was unsuccessful.
		 * 
		 * @return The id of the encryptor.
		 */
		public int getKeyIndex() {
			return keyIndex;
		}

		/**
		 * Identify whether the operation was successful or otherwise.
		 * 
		 * @return <code>true</code> implies the operation was successful,
		 *         <code>false</code> otherwise.
		 */
		public boolean isOk() {
			return ok;
		}
	}
}
