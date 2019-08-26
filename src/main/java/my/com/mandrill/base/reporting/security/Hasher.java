package my.com.mandrill.base.reporting.security;

import java.io.File;

public abstract class Hasher {

	public Hasher() {
	}

	/**
	 * Produce a hash of the specified string.
	 * 
	 * @param String
	 *            The string to be hashed.
	 * @return The hash of the specified string.
	 * @throws Exception
	 *             Thrown if an error occurs during the hashing.
	 */
	public abstract String hash(String string) throws Exception;

	/**
	 * Produce a hash for the contents of the specified file.
	 * 
	 * @param File
	 *            The file to be hashed.
	 * @return The hash of the specified file.
	 * @throws Exception
	 *             Thrown if an error occurs during the hashing.
	 */
	public abstract String hash(File file) throws Exception;
}
