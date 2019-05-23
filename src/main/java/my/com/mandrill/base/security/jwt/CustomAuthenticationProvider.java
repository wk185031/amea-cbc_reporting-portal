package my.com.mandrill.base.security.jwt;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.springframework.beans.factory.annotation.Configurable;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.stereotype.Service;

import com.authentic.usec.UsecServiceAccessor;
import com.authentic.usec.usecservice.AuthenticationResultType;
import com.authentic.usec.usecservice.UserCredentialType;

@Service
@Configurable
public class CustomAuthenticationProvider implements AuthenticationProvider    {

	private final static Logger logger = Logger.getLogger(CustomAuthenticationProvider.class.getName());

	@Override
	public Authentication authenticate(Authentication authentication) throws AuthenticationException {
		
		InetAddress ipAddress;
		try {
			ipAddress = InetAddress.getLocalHost();
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
		String username = authentication.getName();
	    String password = authentication.getCredentials().toString();
	    
	    UserCredentialType credential = new UserCredentialType();
    	credential.setApplicationType("Reporting");
    	credential.setIpAddress(ipAddress.getHostAddress());
    	credential.setMachineName(ipAddress.getHostName());
    	credential.setUserName(username);
    	credential.setUserGroup("reporting");
    	credential.setPassword(password);
    	credential.setOsUserName("authentic");
    	
//    	logger.log(Level.INFO, "\n\nRunning this custom method\n\n");
//    	
//    	logger.log(Level.INFO, "\n\nUsername: " + credential.getUserName() + "\n\n");
//    	logger.log(Level.INFO, "\n\nPassword: " + credential.getPassword() + "\n\n");
//    	logger.log(Level.INFO, "\n\nIP Address: " + credential.getIpAddress() + "\n\n");
//    	logger.log(Level.INFO, "\n\nMachine Name: " + credential.getMachineName() + "\n\n");

    	AuthenticationResultType result = UsecServiceAccessor.authenticateUser(credential, true);
	    
	    if (result.getStatus().equalsIgnoreCase("SUCCESS")) {
	    	return new UsernamePasswordAuthenticationToken(username, password, new ArrayList<>());
	    } else {
	    	return null;
        }
	}

	@Override
	public boolean supports(Class<?> authentication) {
		return authentication.equals(
		          UsernamePasswordAuthenticationToken.class);
	}
}