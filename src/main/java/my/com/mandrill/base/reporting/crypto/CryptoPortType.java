package my.com.mandrill.base.reporting.crypto;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;

/**
 * This class was generated by Apache CXF 3.0.7
 * 2018-10-08T13:45:09.319+01:00
 * Generated source version: 3.0.7
 * 
 */
@WebService(targetNamespace = "http://jms.crypto.authentic.com/CryptoService", name = "CryptoPortType")
@XmlSeeAlso({my.com.mandrill.base.reporting.crypto.ObjectFactory.class})
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
public interface CryptoPortType {

	@WebMethod(operationName = "DecryptByteArray")
    @WebResult(name = "DecryptByteArrayResponse", targetNamespace = "http://jms.crypto.authentic.com/CryptoService/types", partName = "DecryptResponseBytePart")
    public my.com.mandrill.base.reporting.crypto.DecryptByteArrayResponse decryptByteArray(
        @WebParam(partName = "DecryptRequestBytePart", name = "DecryptByteArrayRequest", targetNamespace = "http://jms.crypto.authentic.com/CryptoService/types")
        my.com.mandrill.base.reporting.crypto.DecryptByteArrayRequest decryptRequestBytePart
    );

    @WebMethod(operationName = "EncryptByteArray")
    @WebResult(name = "EncryptByteArrayResponse", targetNamespace = "http://jms.crypto.authentic.com/CryptoService/types", partName = "EncryptResponseBytePart")
    public my.com.mandrill.base.reporting.crypto.EncryptByteArrayResponse encryptByteArray(
        @WebParam(partName = "EncryptRequestBytePart", name = "EncryptByteArrayRequest", targetNamespace = "http://jms.crypto.authentic.com/CryptoService/types")
        my.com.mandrill.base.reporting.crypto.EncryptByteArrayRequest encryptRequestBytePart
    );

    @WebMethod(operationName = "DecryptString")
    @WebResult(name = "DecryptStringResponse", targetNamespace = "http://jms.crypto.authentic.com/CryptoService/types", partName = "DecryptResponseStringPart")
    public my.com.mandrill.base.reporting.crypto.DecryptStringResponse decryptString(
        @WebParam(partName = "DecryptRequestStringPart", name = "DecryptStringRequest", targetNamespace = "http://jms.crypto.authentic.com/CryptoService/types")
        my.com.mandrill.base.reporting.crypto.DecryptStringRequest decryptRequestStringPart
    );

    @WebMethod(operationName = "EncryptString")
    @WebResult(name = "EncryptStringResponse", targetNamespace = "http://jms.crypto.authentic.com/CryptoService/types", partName = "EncryptResponseStringPart")
    public my.com.mandrill.base.reporting.crypto.EncryptStringResponse encryptString(
        @WebParam(partName = "EncryptRequestStringPart", name = "EncryptStringRequest", targetNamespace = "http://jms.crypto.authentic.com/CryptoService/types")
        my.com.mandrill.base.reporting.crypto.EncryptStringRequest encryptRequestStringPart
    );
}
