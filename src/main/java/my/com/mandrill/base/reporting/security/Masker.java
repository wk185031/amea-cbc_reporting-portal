package my.com.mandrill.base.reporting.security;

public abstract class Masker {

	/**
	 * Create an masker.
	 */
	public Masker() {
	}

	/**
	 * Mask the specified string.
	 * 
	 * @param String
	 *            The string to be masked.
	 * @return The masked form of the specified string.
	 * @throws Exception
	 *             Thrown if an error occurs during the masking.
	 */
	public abstract String mask(String string) throws Exception;
}
