package my.com.mandrill.base.reporting.security;

public abstract class MacGenerator {

	/**
	 * Create an MAC generator.
	 */
	public MacGenerator() {
	}

	/**
	 * Produce a MAC of the specified data.
	 * 
	 * @param data
	 *            The data for which to produce a MAC.
	 * @return The hex encoded MAC of the specified data.
	 * @throws Exception
	 *             Thrown if an error occurs.
	 */
	public abstract byte[] mac(byte[] data) throws Exception;

	/**
	 * Produce a MAC of the specified string.
	 * 
	 * @param string
	 *            The string for which to produce a MAC.
	 * @return The hex encoded MAC of the specified string.
	 * @throws Exception
	 *             Thrown if an error occurs.
	 */
	public abstract String mac(String string) throws Exception;

	/**
	 * Get the raw key.
	 * 
	 * @return The key.
	 */
	public abstract byte[] getKey();

	/**
	 * Convert the specified data into a hex binary string.
	 * 
	 * @param data
	 *            The data to encode.
	 * @return The hex binary encoding.
	 */
	protected static byte[] encode(byte[] data) {
		return SecureHexBinaryAdapter.encode(data);
	}

	/**
	 * Decode the specified hex encoded string.
	 * 
	 * @param string
	 *            The encoded string.
	 * @return The decoded data.
	 */
	protected static byte[] decode(byte[] data) {
		return SecureHexBinaryAdapter.decode(data);
	}
}
