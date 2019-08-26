package my.com.mandrill.base.reporting.security;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import my.com.mandrill.base.domain.LocalWebService;
import my.com.mandrill.base.reporting.crypto.CryptoJMSService;
import my.com.mandrill.base.reporting.crypto.CryptoServiceConstants;
import my.com.mandrill.base.reporting.crypto.DecryptRequestType;
import my.com.mandrill.base.reporting.crypto.DecryptResponseType;
import my.com.mandrill.base.reporting.crypto.EncryptRequestType;
import my.com.mandrill.base.reporting.crypto.EncryptResponseType;
import my.com.mandrill.base.reporting.crypto.EncryptValueType;
import my.com.mandrill.base.reporting.security.SecureCrypt.ByteArrayCrypt;
import my.com.mandrill.base.reporting.security.SecureCrypt.StringCrypt;
import my.com.mandrill.base.repository.LocalWebServiceRepository;

@Service
public class RemoteEncryptionService implements SecureEncryptionService {

	private final Logger logger = LoggerFactory.getLogger(RemoteEncryptionService.class);
	private final LocalWebServiceRepository localWebServiceRepository;

	public RemoteEncryptionService(LocalWebServiceRepository localWebServiceRepository) {
		this.localWebServiceRepository = localWebServiceRepository;
	}

	/**
	 * Initialize the encryption service.
	 */
	public void load() {
		try {
			LocalWebService cryptoService = localWebServiceRepository
					.findByServiceName(SSLKeyConstants.CRYPTO_LOCAL_WEB_SERVICENAME);
			CryptoJMSService.setEndpointUrl(cryptoService.getQueueName());
		} catch (Throwable e) {
			logger.error("Failed to get Local Web Service Information.", e);
		}
	}

	/**
	 * Identifies whether the encryption service has been successfully initialised
	 * or not.
	 * 
	 * @return <code>true</code> if initialised, <code>false</code> otherwise.
	 */
	public boolean isOk() {
		return true;
	}

	/**
	 * Identifies whether the encryption service is currently running and able to
	 * service encryption and decryption requests.
	 * 
	 * @return <code>true</code> if running, <code>false</code> otherwise.
	 */
	public boolean isRunning() {
		boolean result = false;
		try {
			result = encryptForAll("000000").size() > 0;
		} catch (Exception e) {
			logger.error("Exception: ", e);
		}
		return result;
	}

	/**
	 * Encrypt the specified data using the specified encryptor.
	 * 
	 * @param data
	 *            The data to encrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The encrypted data or the original data if the encryption service is
	 *         unavailable.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public ByteArrayCrypt encrypt(byte[] data, int keyIndex) throws Exception {
		List<byte[]> byteList = new ArrayList<byte[]>();
		List<Integer> keyIdxList = new ArrayList<Integer>();
		byteList.add(data);
		keyIdxList.add(keyIndex);
		return (encryptByteList(byteList, keyIdxList)).get(0);
	}

	/**
	 * Encrypt the specified list of data using the specified list of encryptors.
	 * 
	 * @param dataList
	 *            The list of data to encrypt.
	 * @param keyIdxList
	 *            The list of index of the encryptor to use. This list is a
	 *            one-to-one mapping with the list specified in 'dataList'.
	 * @return The list of encrypted datas or the original data if the encryption
	 *         service is unavailable. This list is a one-to-one mapping with the
	 *         list specified in 'dataList' and 'keyIdxList'.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public List<ByteArrayCrypt> encryptByteList(List<byte[]> dataList, List<Integer> keyIdxList) {
		List<EncryptRequestType> requests = new ArrayList<EncryptRequestType>();
		int i = 0;
		for (byte[] data : dataList) {
			EncryptRequestType request = new EncryptRequestType();
			request.setValue(data);
			request.setEncryptionKeyID(keyIdxList.get(i));
			requests.add(request);
			i++;
		}

		List<EncryptResponseType> responses = CryptoJMSService.encryptByte(getSessionToken(), requests);
		List<ByteArrayCrypt> valueList = new ArrayList<ByteArrayCrypt>();
		i = 0;
		if (responses != null && !responses.isEmpty() && responses.get(0) != null) {
			for (EncryptResponseType response : responses) {
				if (response.getValues() != null && !response.getValues().isEmpty()
						&& response.getValues().get(0) != null) {
					EncryptValueType value = response.getValues().get(0);
					valueList.add(new ByteArrayCrypt(value.getData(), value.getEncryptionKeyID(),
							response.getResultCode().equals(CryptoServiceConstants.RESPONSECODE_SUCCESS)));
				} else {
					valueList.add(
							new ByteArrayCrypt(dataList.get(i), SecurityManagerService.getFallbackKeyIndex(), false));
				}
				i++;
			}
		}
		return valueList;
	}

	/**
	 * Decrypt the specified data using the specified encryptor.
	 * 
	 * @param data
	 *            The data to decrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The decrypted data or the original data if the encryption service is
	 *         unavailable.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	public ByteArrayCrypt decrypt(byte[] data, int keyIndex) throws Exception {
		List<byte[]> byteList = new ArrayList<byte[]>();
		List<Integer> keyIdxList = new ArrayList<Integer>();
		byteList.add(data);
		keyIdxList.add(keyIndex);
		return (decryptByteList(byteList, keyIdxList)).get(0);
	}

	/**
	 * Decrypt the specified list of data using the specified list of encryptors.
	 * 
	 * @param dataList
	 *            The list of data to decrypt.
	 * @param keyIdxList
	 *            The list of index of the encryptor to use. This list is a
	 *            one-to-one mapping with the list specified in 'dataList'.
	 * @return The list of decrypted data or the original data if the encryption
	 *         service is unavailable. This list is a one-to-one mapping with the
	 *         list specified in 'dataList' and 'keyIdxList'.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	public List<ByteArrayCrypt> decryptByteList(List<byte[]> dataList, List<Integer> keyIdxList) throws Exception {
		List<DecryptRequestType> requests = new ArrayList<DecryptRequestType>();
		int i = 0;
		for (byte[] data : dataList) {
			DecryptRequestType request = new DecryptRequestType();
			request.setValue(data);
			request.setEncryptionKeyID(keyIdxList.get(i));
			requests.add(request);
			i++;
		}

		List<DecryptResponseType> responses = CryptoJMSService.decryptByte(getSessionToken(), requests);
		List<ByteArrayCrypt> valueList = new ArrayList<ByteArrayCrypt>();
		i = 0;
		if (responses != null && !responses.isEmpty() && responses.get(0) != null) {
			for (DecryptResponseType response : responses) {
				if (response.getValue() != null) {
					valueList.add(new ByteArrayCrypt(response.getValue(), response.getEncryptionKeyID(),
							response.getResultCode().equals(CryptoServiceConstants.RESPONSECODE_SUCCESS)));
				} else {
					valueList.add(
							new ByteArrayCrypt(dataList.get(i), SecurityManagerService.getFallbackKeyIndex(), false));
				}
				i++;
			}
		}
		return valueList;
	}

	/**
	 * Encrypt the specified string using the specified encryptor.
	 * 
	 * @param string
	 *            The string to encrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The encrypted string or original string if the encryption service is
	 *         unavailable.
	 */
	public StringCrypt encrypt(String encString, int keyIndex) throws Exception {
		List<String> stringList = new ArrayList<String>();
		List<Integer> keyIdxList = new ArrayList<Integer>();
		stringList.add(encString);
		keyIdxList.add(keyIndex);
		return (encryptStringList(stringList, keyIdxList)).get(0);
	}

	/**
	 * Encrypt the specified list of strings using the specified list of encryptors.
	 * 
	 * @param encList
	 *            The list of strings to encrypt.
	 * @param keyIdxList
	 *            The list of index of the encryptor to use. This list is a
	 *            one-to-one mapping with the list specified in 'encList'.
	 * @return The encrypted string or original string if the encryption service is
	 *         unavailable. This list is a one-to-one mapping with the list
	 *         specified in 'encList' and 'keyIdxList'.
	 */
	public List<StringCrypt> encryptStringList(List<String> encList, List<Integer> keyIdxList) throws Exception {
		List<EncryptRequestType> requests = new ArrayList<EncryptRequestType>();
		int i = 0;
		for (String str : encList) {
			EncryptRequestType request = new EncryptRequestType();
			request.setValue((str).getBytes("UTF-8"));
			request.setEncryptionKeyID(keyIdxList.get(i));
			requests.add(request);
			i++;
		}

		List<EncryptResponseType> responses = CryptoJMSService.encryptString(getSessionToken(), requests);
		List<StringCrypt> valueList = new ArrayList<StringCrypt>();
		i = 0;
		if (responses != null && !responses.isEmpty() && responses.get(0) != null) {
			for (EncryptResponseType response : responses) {
				if (response.getValues() != null && !response.getValues().isEmpty()
						&& response.getValues().get(0) != null) {
					EncryptValueType value = response.getValues().get(0);
					valueList.add(new StringCrypt(new String(value.getData(), "UTF-8"), value.getEncryptionKeyID(),
							response.getResultCode().equals(CryptoServiceConstants.RESPONSECODE_SUCCESS)));
				} else {
					valueList.add(new StringCrypt(encList.get(i), SecurityManagerService.getFallbackKeyIndex(), false));
				}
				i++;
			}
		}
		return valueList;
	}

	/**
	 * Decrypt the specified string using the specified encryptor.
	 * 
	 * @param string
	 *            The string to decrypt.
	 * @param keyIndex
	 *            The index of the encryptor to use.
	 * @return The decrypted string or original string if the encryption service is
	 *         unavailable.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	public StringCrypt decrypt(String string, int keyIndex) throws Exception {
		List<String> stringList = new ArrayList<String>();
		List<Integer> keyIdxList = new ArrayList<Integer>();
		stringList.add(string);
		keyIdxList.add(keyIndex);
		return (decryptStringList(stringList, keyIdxList)).get(0);
	}

	/**
	 * Decrypt the specified list of strings using the specified list of encryptors.
	 * 
	 * @param stringList
	 *            The list of strings to decrypt.
	 * @param keyIdxList
	 *            The list of index of the encryptor to use. This list is a
	 *            one-to-one mapping with the list specified in 'stringList'.
	 * @return The list of decrypted string or original string if the encryption
	 *         service is unavailable. This list is a one-to-one mapping with the
	 *         list specified in 'stringList' and 'keyIdxList'.
	 * @throws Exception
	 *             Thrown if an error occurs during the decryption.
	 */
	public List<StringCrypt> decryptStringList(List<String> stringList, List<Integer> keyIdxList) throws Exception {
		List<DecryptRequestType> requests = new ArrayList<DecryptRequestType>();
		int i = 0;
		for (String str : stringList) {
			DecryptRequestType request = new DecryptRequestType();
			request.setValue((str).getBytes("UTF-8"));
			request.setEncryptionKeyID(keyIdxList.get(i));
			requests.add(request);
			i++;
		}

		List<DecryptResponseType> responses = CryptoJMSService.decryptString(getSessionToken(), requests);
		List<StringCrypt> valueList = new ArrayList<StringCrypt>();
		i = 0;
		if (responses != null && !responses.isEmpty() && responses.get(0) != null) {
			for (DecryptResponseType response : responses) {
				if (response.getValue() != null) {
					valueList.add(
							new StringCrypt(new String(response.getValue(), "UTF-8"), response.getEncryptionKeyID(),
									response.getResultCode().equals(CryptoServiceConstants.RESPONSECODE_SUCCESS)));
				} else {
					valueList.add(
							new StringCrypt(stringList.get(i), SecurityManagerService.getFallbackKeyIndex(), false));
				}
				i++;
			}
		}
		return valueList;
	}

	/**
	 * Get the encrypted version of the specified data encrypted using each of the
	 * available encryptors.
	 * 
	 * @param data
	 *            The data to encrypt.
	 * @return The encrypted versions.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public List<ByteArrayCrypt> encryptForAll(byte[] data) throws Exception {
		List<ByteArrayCrypt> results = new ArrayList<ByteArrayCrypt>();
		List<EncryptRequestType> requests = new ArrayList<EncryptRequestType>();
		EncryptRequestType request = new EncryptRequestType();
		request.setValue(data);
		request.setEncryptionKeyID(-1);
		requests.add(request);

		List<EncryptResponseType> responses = CryptoJMSService.encryptByte(getSessionToken(), requests);
		if (responses != null && responses.get(0) != null && responses.get(0).getValues() != null
				&& !responses.get(0).getValues().isEmpty()) {
			EncryptResponseType response = responses.get(0);
			for (EncryptValueType value : response.getValues()) {
				results.add(new ByteArrayCrypt(value.getData(), value.getEncryptionKeyID(),
						response.getResultCode().equals(CryptoServiceConstants.RESPONSECODE_SUCCESS)));
			}
		}
		return results;
	}

	/**
	 * Get the encrypted version of the specified string encrypted using each of the
	 * available encryptors.
	 * 
	 * @param string
	 *            The string to encrypt.
	 * @return The encrypted versions.
	 * @throws Exception
	 *             Thrown if an error occurs during the encryption.
	 */
	public List<StringCrypt> encryptForAll(String string) throws Exception {
		List<StringCrypt> results = new ArrayList<StringCrypt>();
		List<EncryptRequestType> requests = new ArrayList<EncryptRequestType>();
		EncryptRequestType request = new EncryptRequestType();
		request.setValue(string.getBytes("UTF-8"));
		request.setEncryptionKeyID(-1);
		requests.add(request);

		List<EncryptResponseType> responses = CryptoJMSService.encryptString(getSessionToken(), requests);
		if (responses != null && responses.get(0) != null && responses.get(0).getValues() != null
				&& !responses.get(0).getValues().isEmpty()) {
			EncryptResponseType response = responses.get(0);
			for (EncryptValueType value : response.getValues()) {
				results.add(new StringCrypt(new String(value.getData(), "UTF-8"), value.getEncryptionKeyID(),
						response.getResultCode().equals(CryptoServiceConstants.RESPONSECODE_SUCCESS)));
			}
		}
		return results;
	}

	/**
	 * Get the current user authentication session token.
	 * 
	 * @return The session token.
	 */
	private String getSessionToken() {
		String token = "";
		try {
			token = UsecClient.getInstance().getSessionToken();
		} catch (Exception e) {
			logger.error("Failed to get current session token.", e);
		}
		return token;
	}
}
