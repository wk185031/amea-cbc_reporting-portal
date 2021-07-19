package my.com.mandrill.base.web.rest;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.JsonProperty;

import io.github.jhipster.config.JHipsterProperties;
import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.repository.UserExtraRepository;
import my.com.mandrill.base.security.jwt.JWTConfigurer;
import my.com.mandrill.base.security.jwt.TokenProvider;
import my.com.mandrill.base.service.util.E2eEncryptionUtil;
import my.com.mandrill.base.web.rest.vm.LoginVM;

/**
 * Controller to authenticate users.
 */
@RestController
@RequestMapping("/api")
public class UserJWTController {
	
	private final Logger log = LoggerFactory.getLogger(UserJWTController.class);

    private final TokenProvider tokenProvider;

    private final AuthenticationManager authenticationManager;
    
    private final UserExtraRepository userExtraRepository;
    
    private final JHipsterProperties jHipsterProperties;
    
    @Autowired
	private Environment env;

    public UserJWTController(TokenProvider tokenProvider, AuthenticationManager authenticationManager, UserExtraRepository userExtraRepository, JHipsterProperties jHipsterProperties) {
        this.tokenProvider = tokenProvider;
        this.authenticationManager = authenticationManager;
        this.userExtraRepository = userExtraRepository;
        this.jHipsterProperties = jHipsterProperties;
    }

    @PostMapping("/authenticate")
    @Timed
    public ResponseEntity<JWTToken> authorize(@Valid @RequestBody LoginVM loginVM) {

    	String username = E2eEncryptionUtil.decryptToken(env.getProperty("application.e2eKey"), loginVM.getUsername());
    	String password = E2eEncryptionUtil.decryptToken(env.getProperty("application.e2eKey"), loginVM.getPassword());

        UsernamePasswordAuthenticationToken authenticationToken =
            new UsernamePasswordAuthenticationToken(username, password);
        
        // check if concurrent login allowed
        if(env.getProperty(ReportConstants.ALLOW_CONCURRENT_LOGIN).equalsIgnoreCase("true")) {
        	// check if userExtra loginFlag is Y       
            List<UserExtra> userExtraList = userExtraRepository.findByUserLogin(username);      
            UserExtra userExtra = userExtraList.get(0);
            
            LocalDateTime lastLoginPlusTokenValidityPeriod = userExtra.getLastLoginTs().toLocalDateTime().plusSeconds(jHipsterProperties.getSecurity().getAuthentication().getJwt().getTokenValidityInSeconds());
            
            if (null != userExtra && null != userExtra.getLoginFlag() && (userExtra.getLoginFlag().equalsIgnoreCase("Y") && LocalDateTime.now().isBefore(lastLoginPlusTokenValidityPeriod))) {
            	return new ResponseEntity<>(HttpStatus.CONFLICT);
            }
            
            userExtra.setLoginFlag("Y");
            userExtra.setLastLoginTs(Timestamp.valueOf(LocalDateTime.now()));
            userExtraRepository.save(userExtra);
        }        

        Authentication authentication = this.authenticationManager.authenticate(authenticationToken);
        SecurityContextHolder.getContext().setAuthentication(authentication);
        boolean rememberMe = (loginVM.isRememberMe() == null) ? false : loginVM.isRememberMe();        
        String jwt = tokenProvider.createToken(authentication, rememberMe);

        String encJwt = E2eEncryptionUtil.encryptEcb(env.getProperty("application.e2eKey"), jwt);
        
        log.debug("------------------jwt = {}", jwt);
        log.debug("------------------encJwt = {}", encJwt);
        
        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.add(JWTConfigurer.AUTHORIZATION_HEADER, "Bearer " + encJwt);
        return new ResponseEntity<>(new JWTToken(encJwt), httpHeaders, HttpStatus.OK);
    }
    
    @PostMapping("/logout")
    @Timed
    public ResponseEntity<JWTToken> logout(@Valid @RequestBody JWTToken jwtToken) {

    	String encToken = jwtToken.getIdToken();
    	String token = E2eEncryptionUtil.decryptEcb(env.getProperty("application.e2eKey"), encToken);
    	Authentication authentication = tokenProvider.getAuthentication(token);

    	// check if concurrent login allowed
        if(env.getProperty(ReportConstants.ALLOW_CONCURRENT_LOGIN).equalsIgnoreCase("true")) {

        	List<UserExtra> userExtraList = userExtraRepository.findByUserLogin(authentication.getName());       
        	UserExtra userExtra = userExtraList.get(0);

        	if (userExtra != null) {
        		userExtra.setLoginFlag("N");
        		userExtraRepository.save(userExtra);
        	} 
        }
    	
    	return new ResponseEntity<>(HttpStatus.OK);
    }

    /**
     * Object to return as body in JWT Authentication.
     */
    static class JWTToken {

        private String idToken;
        
        JWTToken() {}

        JWTToken(String idToken) {
            this.idToken = idToken;
        }

        @JsonProperty("id_token")
        String getIdToken() {
            return idToken;
        }

        void setIdToken(String idToken) {
            this.idToken = idToken;
        }
    }
}
