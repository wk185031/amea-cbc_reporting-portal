package my.com.mandrill.base.web.rest;

import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.repository.UserExtraRepository;
import my.com.mandrill.base.security.jwt.JWTConfigurer;
import my.com.mandrill.base.security.jwt.TokenProvider;
import my.com.mandrill.base.web.rest.vm.LoginVM;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.JsonProperty;

import io.github.jhipster.config.JHipsterProperties;
import io.github.jhipster.web.util.ResponseUtil;

import org.springframework.http.HttpStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import javax.validation.Valid;

/**
 * Controller to authenticate users.
 */
@RestController
@RequestMapping("/api")
public class UserJWTController {

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

        UsernamePasswordAuthenticationToken authenticationToken =
            new UsernamePasswordAuthenticationToken(loginVM.getUsername(), loginVM.getPassword());
        
        // check if concurrent login allowed
        if(env.getProperty(ReportConstants.ALLOW_CONCURRENT_LOGIN).equalsIgnoreCase("true")) {
        	// check if userExtra loginFlag is Y       
            List<UserExtra> userExtraList = userExtraRepository.findByUserLogin(loginVM.getUsername());      
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
        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.add(JWTConfigurer.AUTHORIZATION_HEADER, "Bearer " + jwt);
        return new ResponseEntity<>(new JWTToken(jwt), httpHeaders, HttpStatus.OK);
    }
    
    @PostMapping("/logout")
    @Timed
    public ResponseEntity<JWTToken> logout(@Valid @RequestBody JWTToken jwtToken) {

    	String token = jwtToken.getIdToken();
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
