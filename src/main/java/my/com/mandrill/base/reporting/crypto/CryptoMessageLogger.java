package my.com.mandrill.base.reporting.crypto;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CryptoMessageLogger {

	private final static Logger logger = LoggerFactory.getLogger(CryptoMessageLogger.class);

	private CryptoMessageLogger() {
	}

	private static String formatData(byte[] data) {
		if (null == data || 0 == data.length) {
			return null;
		}

		String str = new String(HexBinaryAdapter.decode(data));
		int len = str.length();
		boolean printable = true;
		char ch[] = new char[len];

		str.getChars(0, len, ch, 0);

		for (int i = 0; i < len; i++) {
			if (ch[i] < 32 || ch[i] >= 127) {
				printable = false;
				break;
			}
		}

		if (printable) {
			return str;
		} else {
			return "Byte - ".concat(new String(data).toUpperCase());
		}
	}

	/**
	 * Log decrypt string request message at trace level
	 * 
	 * @param DecryptStringRequest
	 *            request message
	 */
	public static void trace(DecryptStringRequest val) {
		logger.debug("Decrypt String Request".concat(getDecryptRequestMessage(val.getHeader(), val.getBody())));
	}

	/**
	 * Log decrypt byte array request message at trace level
	 * 
	 * @param DecryptByteArrayRequest
	 *            request message
	 */
	public static void trace(DecryptByteArrayRequest val) {
		logger.debug("Decrypt ByteArray Request".concat(getDecryptRequestMessage(val.getHeader(), val.getBody())));
	}

	private static String getDecryptRequestMessage(CryptoHeaderType header, DecryptRequestBody body) {
		String str = new String();
		int i = 0;

		str = str.concat(" Session ID [" + header.getSessionID() + "]");
		str = str.concat(" User [" + header.getUsername() + "]");
		str = str.concat(" Password [Not Shown]");
		str = str.concat(" Request Time [" + header.getRequestTime() + "]");
		str = str.concat(" Originator [" + header.getOriginator() + "]");
		str = str.concat(" Service [" + header.getService() + "]");
		for (DecryptRequestType data : body.getRequest()) {
			i++;
			str = str.concat("\n\t\t Request " + i + ": Data [" + formatData(data.getValue()) + "] Key ["
					+ data.getEncryptionKeyID() + "]");
		}
		str = str.concat("\n\tStatus [" + header.getStatus() + "]");
		str = str.concat(" Status Message [" + header.getStatusMessage() + "]");
		return str;
	}

	/**
	 * Log decrypt string response message at trace level
	 * 
	 * @param DecryptStringResponse
	 *            response message
	 */
	public static void trace(DecryptStringResponse val) {
		logger.trace("Decrypt String Response".concat(getDecryptResponseMessage(val.getHeader(), val.getBody())));
	}

	/**
	 * Log decrypt byte array response message at trace level
	 * 
	 * @param DecryptByteArrayResponse
	 *            response message
	 */
	public static void trace(DecryptByteArrayResponse val) {
		logger.trace("Decrypt ByteArray Response".concat(getDecryptResponseMessage(val.getHeader(), val.getBody())));
	}

	private static String getDecryptResponseMessage(CryptoHeaderType header, DecryptResponseBody body) {
		String str = new String();
		int i = 0;

		str = str.concat(" Session ID [" + header.getSessionID() + "]");
		str = str.concat(" User [" + header.getUsername() + "]");
		str = str.concat(" Password [Not Shown]");
		str = str.concat(" Request Time [" + header.getRequestTime() + "]");
		str = str.concat(" Response Time [" + header.getResponseTime() + "]");
		str = str.concat(" Originator [" + header.getOriginator() + "]");
		str = str.concat(" Service [" + header.getService() + "]");
		for (DecryptResponseType data : body.getResponse()) {
			i++;
			str = str.concat("\n \t\t Response " + i + ": Data [" + formatData(data.getValue()) + "] Key ["
					+ data.getEncryptionKeyID() + "]" + " ResultCode [" + data.getResultCode() + "] ResultMessage ["
					+ data.getResultMessage() + "]");
		}
		str = str.concat("\n\tStatus [" + header.getStatus() + "]");
		str = str.concat(" Status Message [" + header.getStatusMessage() + "]");

		return str;
	}

	/**
	 * Log encrypt string request message at trace level
	 * 
	 * @param EncryptStringRequest
	 *            request message
	 */
	public static void trace(EncryptStringRequest val) {
		logger.trace("Encrypt String Request".concat(getEncryptRequestMessage(val.getHeader(), val.getBody())));
	}

	/**
	 * Log encrypt byte array request message at trace level
	 * 
	 * @param EncryptByteArrayRequest
	 *            request message
	 */
	public static void trace(EncryptByteArrayRequest val) {
		logger.trace("Encrypt ByteArray Request".concat(getEncryptRequestMessage(val.getHeader(), val.getBody())));
	}

	private static String getEncryptRequestMessage(CryptoHeaderType header, EncryptRequestBody body) {
		String str = new String();
		int i = 0;

		str = str.concat(" Session ID [" + header.getSessionID() + "]");
		str = str.concat(" User [" + header.getUsername() + "]");
		str = str.concat(" Password [Not Shown]");
		str = str.concat(" Request Time [" + header.getRequestTime() + "]");
		str = str.concat(" Originator [" + header.getOriginator() + "]");
		str = str.concat(" Service [" + header.getService() + "]");
		for (EncryptRequestType data : body.getRequest()) {
			i++;
			str = str.concat("\n\t\t Request " + i + ": Data [" + formatData(data.getValue()) + "] Key ["
					+ data.getEncryptionKeyID() + "]");
		}
		str = str.concat("\n\tStatus [" + header.getStatus() + "]");
		str = str.concat(" Status Message [" + header.getStatusMessage() + "]");

		return str;
	}

	/**
	 * Log encrypt string response message at trace level
	 * 
	 * @param EncryptStringResponse
	 *            response message
	 */
	public static void trace(EncryptStringResponse val) {
		logger.trace("Encrypt String Response".concat(getEncryptResponseMessage(val.getHeader(), val.getBody())));
	}

	/**
	 * Log encrypt byte array response message at trace level
	 * 
	 * @param EncryptByteArrayResponse
	 *            response message
	 */
	public static void trace(EncryptByteArrayResponse val) {
		logger.trace("Encrypt ByteArray Response".concat(getEncryptResponseMessage(val.getHeader(), val.getBody())));
	}

	private static String getEncryptResponseMessage(CryptoHeaderType header, EncryptResponseBody body) {
		String str = new String();
		int i = 0;

		str = str.concat(" Session ID [" + header.getSessionID() + "]");
		str = str.concat(" User [" + header.getUsername() + "]");
		str = str.concat(" Password [Not Shown]");
		str = str.concat(" Request Time [" + header.getRequestTime() + "]");
		str = str.concat(" Response Time [" + header.getResponseTime() + "]");
		str = str.concat(" Originator [" + header.getOriginator() + "]");
		str = str.concat(" Service [" + header.getService() + "]");
		for (EncryptResponseType data : body.getResponse()) {
			i++;
			str = str.concat("\n \t\t Response " + i + ": ResultCode [" + data.getResultCode() + "] ResultMessage ["
					+ data.getResultMessage() + "]");
			int j = 0;
			for (EncryptValueType dataVal : data.getValues()) {
				j++;
				str = str.concat("\n \t\t\t Data " + j + ": Value [" + formatData(dataVal.getData()) + "] Key ["
						+ dataVal.getEncryptionKeyID() + "]");
			}
		}
		str = str.concat("\n\tStatus [" + header.getStatus() + "]");
		str = str.concat(" Status Message [" + header.getStatusMessage() + "]");

		return str;
	}
}
