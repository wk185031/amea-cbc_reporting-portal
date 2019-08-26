package com.authentic.secure.encrypt;

import my.com.mandrill.base.reporting.security.Encryptor;

public class ClearEncryptor extends Encryptor {

	public ClearEncryptor() {
	}

	/**
	 * Create a clear encryptor.
	 * 
	 * @param rawKey
	 *            Not required.
	 */
	public ClearEncryptor(byte[] rawKey) {
	}

	/**
	 * Encrypt the specified data. No encryption is performed and the supplied data
	 * is returned unchanged.
	 * 
	 * @param data
	 *            The data to be encrypted.
	 * @return The original data returned unchanged.
	 */
	@Override
	public byte[] encrypt(byte[] data) {
		return data;
	}

	/**
	 * Decrypt the specified data. No decryption is performed and the supplied data
	 * is returned unchanged.
	 * 
	 * @param data
	 *            The data to be decrypted.
	 * @return The original data returned unchanged.
	 */
	@Override
	public byte[] decrypt(byte[] data) {
		return data;
	}

	/**
	 * Encrypt the specified string. No encryption is performed and the supplied
	 * string is returned unchanged.
	 * 
	 * @param The
	 *            string to be encrypted.
	 * @return The original string returned unchanged.
	 */
	@Override
	public String encrypt(String string) {
		return string;
	}

	/**
	 * Decrypt the specified string. No decryption is performed and the supplied
	 * string is returned unchanged.
	 * 
	 * @param The
	 *            string to be decrypted.
	 * @return The original string returned unchanged.
	 */
	@Override
	public String decrypt(String string) {
		return string;
	}

	/**
	 * Get the raw key.
	 * 
	 * @return The key.
	 */
	public byte[] getKey() {
		return new byte[0];
	}

	/**
	 * Get the preferred length of a key. This encryptor does not need a key
	 * therefore 0 will be returned.
	 * 
	 * @return The preferred key length.
	 */
	public int getPreferredKeyLength() {
		return 0;
	}

	/**
	 * Determines whether the specified key is acceptable.
	 * 
	 * @return <code>true</code> implies the key is acceptable, <code>false</code>
	 *         otherwise.
	 */
	public boolean isKeyOk(byte[] key) {
		return true;
	}

	/**
	 * Calculate a check value.
	 * 
	 * @return The check value.
	 * @throws Exception
	 *             Thrown if an error occurs during the evaluation of the check
	 *             value.
	 */
	public String getCheckValue() throws Exception {
		return "000000";
	}

	/**
	 * Returns a description of this encryptor.
	 * 
	 * @return The description of this encryptor.
	 */
	public String toString() {
		return "Clear passthrough encryptor.";
	}
}
