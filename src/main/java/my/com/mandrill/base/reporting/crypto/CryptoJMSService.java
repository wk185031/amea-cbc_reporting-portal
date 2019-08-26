package my.com.mandrill.base.reporting.crypto;

import java.util.GregorianCalendar;
import java.util.Iterator;
import java.util.List;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.ws.Service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CryptoJMSService {

	private final static Logger logger = LoggerFactory.getLogger(CryptoJMSService.class);
	private static volatile CryptoPortType serviceCaller = null;
	private static String serviceUrl;

	/**
	 * Constructor should not be called. Only Static methods should be used.
	 * 
	 * @return Exception
	 * @throws Throwable
	 */
	private CryptoJMSService() {
	}

	/**
	 * Process a list of decrypt byte array requests using the Crypto Server.
	 * 
	 * @param inData
	 *            List of DecryptRequestType objects containing requests to be
	 *            processed.
	 * @return List of processed DecryptResponseType objects
	 */
	public static List<DecryptResponseType> decryptByte(String sessionToken, List<DecryptRequestType> inData) {
		DecryptByteArrayRequest inMsg = new DecryptByteArrayRequest();
		DecryptByteArrayResponse outMsg = null;
		int i = 0;
		Iterator<DecryptRequestType> iteratorReq = inData.iterator();
		while (iteratorReq.hasNext()) {
			inData.get(i).setValue(HexBinaryAdapter.encode(iteratorReq.next().getValue()));
			i++;
		}

		inMsg.setHeader(new CryptoHeaderType());
		inMsg.setBody(new DecryptRequestBody());
		inMsg.getBody().getRequest().addAll(inData);

		outMsg = decryptByteSendRecv(sessionToken, inMsg);

		if (null == outMsg) {
			return null;
		} else {
			List<DecryptResponseType> responseData = outMsg.getBody().getResponse();
			i = 0;
			Iterator<DecryptResponseType> iteratorRsp = responseData.iterator();
			while (iteratorRsp.hasNext()) {
				responseData.get(i).setValue(HexBinaryAdapter.decode(iteratorRsp.next().getValue()));
				i++;
			}
			return responseData;
		}
	}

	/**
	 * Process a list of decrypt string requests using the Crypto Server.
	 * 
	 * @param inData
	 *            List of DecryptRequestType objects containing requests to be
	 *            processed.
	 * @return List of processed DecryptResponseType objects
	 */
	public static List<DecryptResponseType> decryptString(String sessionToken, List<DecryptRequestType> inData) {
		DecryptStringRequest inMsg = new DecryptStringRequest();
		DecryptStringResponse outMsg = null;
		int i = 0;
		Iterator<DecryptRequestType> iteratorReq = inData.iterator();
		while (iteratorReq.hasNext()) {
			inData.get(i).setValue(HexBinaryAdapter.encode(iteratorReq.next().getValue()));
			i++;
		}

		inMsg.setHeader(new CryptoHeaderType());
		inMsg.setBody(new DecryptRequestBody());
		inMsg.getBody().getRequest().addAll(inData);

		outMsg = decryptStringSendRecv(sessionToken, inMsg);

		if (null == outMsg) {
			return null;
		} else {
			List<DecryptResponseType> responseData = outMsg.getBody().getResponse();
			i = 0;
			Iterator<DecryptResponseType> iteratorRsp = responseData.iterator();
			while (iteratorRsp.hasNext()) {
				responseData.get(i).setValue(HexBinaryAdapter.decode(iteratorRsp.next().getValue()));
				i++;
			}
			return responseData;
		}
	}

	/**
	 * Process a list of encrypt string requests using the Crypto Server.
	 * 
	 * @param inData
	 *            List of EncryptRequestType objects containing requests to be
	 *            processed.
	 * @return List of processed EncryptResponseType objects
	 */
	public static List<EncryptResponseType> encryptString(String sessionToken, List<EncryptRequestType> inData) {
		EncryptStringRequest inMsg = new EncryptStringRequest();
		EncryptStringResponse outMsg = null;
		int i = 0, j = 0;
		Iterator<EncryptRequestType> reqIterator = inData.iterator();
		while (reqIterator.hasNext()) {
			inData.get(i).setValue(HexBinaryAdapter.encode(reqIterator.next().getValue()));
			i++;
		}

		inMsg.setHeader(new CryptoHeaderType());
		inMsg.setBody(new EncryptRequestBody());
		inMsg.getBody().getRequest().addAll(inData);

		outMsg = encryptStringSendRecv(sessionToken, inMsg);

		if (null == outMsg) {
			return null;
		} else {
			List<EncryptResponseType> responseData = outMsg.getBody().getResponse();
			i = 0;
			Iterator<EncryptResponseType> respIterator = responseData.iterator();
			while (respIterator.hasNext()) {
				List<EncryptValueType> valueData = respIterator.next().getValues();
				j = 0;
				Iterator<EncryptValueType> valueIterator = valueData.iterator();
				while (valueIterator.hasNext()) {
					responseData.get(i).getValues().get(j)
							.setData(HexBinaryAdapter.decode(valueIterator.next().getData()));
					j++;
				}
				i++;
			}
			return responseData;
		}
	}

	/**
	 * Process a list of encrypt byte array requests using the Crypto Server.
	 * 
	 * @param inData
	 *            List of EncryptRequestType objects containing requests to be
	 *            processed.
	 * @return List of processed EncryptResponseType objects
	 */
	public static List<EncryptResponseType> encryptByte(String sessionToken, List<EncryptRequestType> inData) {
		EncryptByteArrayRequest inMsg = new EncryptByteArrayRequest();
		EncryptByteArrayResponse outMsg = null;
		int i = 0, j = 0;
		Iterator<EncryptRequestType> reqIterator = inData.iterator();
		while (reqIterator.hasNext()) {
			inData.get(i).setValue(HexBinaryAdapter.encode(reqIterator.next().getValue()));
			i++;
		}

		inMsg.setHeader(new CryptoHeaderType());
		inMsg.setBody(new EncryptRequestBody());
		inMsg.getBody().getRequest().addAll(inData);

		outMsg = encryptByteSendRecv(sessionToken, inMsg);

		if (null == outMsg) {
			return null;
		} else {
			List<EncryptResponseType> responseData = outMsg.getBody().getResponse();
			i = 0;
			Iterator<EncryptResponseType> respIterator = responseData.iterator();
			while (respIterator.hasNext()) {
				List<EncryptValueType> valueData = respIterator.next().getValues();
				j = 0;
				Iterator<EncryptValueType> valueIterator = valueData.iterator();
				while (valueIterator.hasNext()) {
					responseData.get(i).getValues().get(j)
							.setData(HexBinaryAdapter.decode(valueIterator.next().getData()));
					j++;
				}
				i++;
			}
			return responseData;
		}
	}

	private static CryptoPortType getCaller() {
		logger.debug("CryptoJMSService.getCaller() : entry : thread=" + Thread.currentThread().getId()
				+ ",serviceCaller=" + serviceCaller);
		if (serviceCaller == null) {
			synchronized (CryptoJMSService.class) {
				if (serviceCaller == null) {
					logger.debug("CryptoJMSService.getCaller() : create : thread=" + Thread.currentThread().getId());

					Service service = Service.create(JMSCryptoService.SERVICE);
					service.addPort(JMSCryptoService.SERVICE, JMSSpecConstants.SOAP_JMS_SPECIFICATION_TRANSPORTID,
							serviceUrl);
					serviceCaller = service.getPort(JMSCryptoService.SERVICE, CryptoPortType.class);
				}
			}
		}
		logger.debug("CryptoJMSService.getCaller() : exit : thread=" + Thread.currentThread().getId()
				+ ",serviceCaller=" + serviceCaller);
		return serviceCaller;
	}

	/**
	 * Set the endpoint URL to connect to service
	 * 
	 * @param url
	 *            endpoint URL of the service
	 * @return None
	 */
	public static void setEndpointUrl(String url) {
		serviceUrl = url;
		serviceCaller = null;
	}

	private static XMLGregorianCalendar getDateTime() {
		GregorianCalendar gc = new GregorianCalendar();
		XMLGregorianCalendar dateTime = null;
		gc.setTimeInMillis(System.currentTimeMillis());
		try {
			dateTime = DatatypeFactory.newInstance().newXMLGregorianCalendar(gc);
		} catch (DatatypeConfigurationException e) {
			logger.warn("Unable to populate request time...");
		}
		return dateTime;
	}

	private static EncryptStringResponse encryptStringSendRecv(String sessionToken, EncryptStringRequest inMsg) {
		EncryptStringResponse outMsg = null;
		inMsg.getHeader().setRequestTime(getDateTime());
		inMsg.getHeader().setSessionID(sessionToken);
		inMsg.getHeader().setService(CryptoServiceConstants.SERVICENAME);
		CryptoPortType caller = getCaller();
		try {
			CryptoMessageLogger.trace(inMsg);
			outMsg = caller.encryptString(inMsg);

			if (outMsg != null) {
				CryptoMessageLogger.trace(outMsg);
			} else {
				logger.debug("Failed to receive a response.");
			}
		} catch (Exception e) {
			logger.error("Exception in receiving a response." + e);
			outMsg = null;
		}
		return outMsg;
	}

	private static EncryptByteArrayResponse encryptByteSendRecv(String sessionToken, EncryptByteArrayRequest inMsg) {
		EncryptByteArrayResponse outMsg = null;
		inMsg.getHeader().setRequestTime(getDateTime());
		inMsg.getHeader().setSessionID(sessionToken);
		inMsg.getHeader().setService(CryptoServiceConstants.SERVICENAME);
		CryptoPortType caller = getCaller();
		try {
			CryptoMessageLogger.trace(inMsg);
			outMsg = caller.encryptByteArray(inMsg);

			if (outMsg != null) {
				CryptoMessageLogger.trace(outMsg);
			} else {
				logger.debug("Failed to receive a response.");
			}
		} catch (Exception e) {
			logger.error("Exception in receiving a response." + e);
			outMsg = null;
		}
		return outMsg;
	}

	private static DecryptByteArrayResponse decryptByteSendRecv(String sessionToken, DecryptByteArrayRequest inMsg) {
		DecryptByteArrayResponse outMsg = null;
		inMsg.getHeader().setRequestTime(getDateTime());
		inMsg.getHeader().setSessionID(sessionToken);
		inMsg.getHeader().setService(CryptoServiceConstants.SERVICENAME);
		CryptoPortType caller = getCaller();
		try {
			CryptoMessageLogger.trace(inMsg);
			outMsg = caller.decryptByteArray(inMsg);
			if (outMsg != null) {
				CryptoMessageLogger.trace(outMsg);
			} else {
				logger.debug("Failed to receive a response.");
			}
		} catch (Exception e) {
			logger.error("Exception in receiving a response." + e);
			outMsg = null;
		}
		return outMsg;
	}

	private static DecryptStringResponse decryptStringSendRecv(String sessionToken, DecryptStringRequest inMsg) {
		DecryptStringResponse outMsg = null;
		inMsg.getHeader().setRequestTime(getDateTime());
		inMsg.getHeader().setSessionID(sessionToken);
		inMsg.getHeader().setService(CryptoServiceConstants.SERVICENAME);
		CryptoPortType caller = getCaller();
		try {
			CryptoMessageLogger.trace(inMsg);
			outMsg = caller.decryptString(inMsg);
			if (outMsg != null) {
				CryptoMessageLogger.trace(outMsg);
			} else {
				logger.debug("Failed to receive a response.");
			}
		} catch (Exception e) {
			logger.error("Exception in receiving a response." + e);
			outMsg = null;
		}
		return outMsg;
	}
}
