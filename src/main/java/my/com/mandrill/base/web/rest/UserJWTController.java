package my.com.mandrill.base.web.rest;

import java.util.logging.Level;
import java.util.logging.Logger;

import javax.validation.Valid;

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

import my.com.mandrill.base.security.jwt.CustomAuthenticationProvider;
import my.com.mandrill.base.security.jwt.JWTConfigurer;
import my.com.mandrill.base.security.jwt.TokenProvider;
import my.com.mandrill.base.web.rest.vm.LoginVM;

/**
 * Controller to authenticate users.
 */
@RestController
@RequestMapping("/api")
public class UserJWTController {
	private final static Logger logger = Logger.getLogger(UserJWTController.class.getName());

    private final TokenProvider tokenProvider;

    private final AuthenticationManager authenticationManager;
    
    private final CustomAuthenticationProvider customAuthenticationProvider;

    public UserJWTController(TokenProvider tokenProvider, AuthenticationManager authenticationManager, CustomAuthenticationProvider customAuthenticationProvider) {
        this.tokenProvider = tokenProvider;
        this.authenticationManager = authenticationManager;
        this.customAuthenticationProvider = customAuthenticationProvider;
    }

    @PostMapping("/authenticate")
    @Timed
    public ResponseEntity<JWTToken> authorize(@Valid @RequestBody LoginVM loginVM) {

//    	logger.log(Level.INFO, "\n\nRunning this old method\n\n");

        UsernamePasswordAuthenticationToken authenticationToken =
            new UsernamePasswordAuthenticationToken(loginVM.getUsername(), loginVM.getPassword());

       Authentication authentication = this.customAuthenticationProvider.authenticate(authenticationToken);
       SecurityContextHolder.getContext().setAuthentication(authentication);
       boolean rememberMe = (loginVM.isRememberMe() == null) ? false : loginVM.isRememberMe();
       String jwt = tokenProvider.createToken(authentication, rememberMe);
       HttpHeaders httpHeaders = new HttpHeaders();
       httpHeaders.add(JWTConfigurer.AUTHORIZATION_HEADER, "Bearer " + jwt);
       return new ResponseEntity<>(new JWTToken(jwt), httpHeaders, HttpStatus.OK);
    }

    /**
     * Object to return as body in JWT Authentication.
     */
    static class JWTToken {

        private String idToken;

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
