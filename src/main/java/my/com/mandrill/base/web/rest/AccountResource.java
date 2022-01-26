package my.com.mandrill.base.web.rest;

import com.codahale.metrics.annotation.Timed;

import my.com.mandrill.base.config.audit.AuditActionService;
import my.com.mandrill.base.config.audit.AuditActionType;
import my.com.mandrill.base.domain.PasswordHistory;
import my.com.mandrill.base.domain.User;
import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.repository.UserExtraRepository;
import my.com.mandrill.base.repository.UserRepository;
import my.com.mandrill.base.security.SecurityUtils;
import my.com.mandrill.base.service.MailService;
import my.com.mandrill.base.service.UserService;
import my.com.mandrill.base.service.dto.UserDTO;
import my.com.mandrill.base.service.util.E2eEncryptionUtil;
import my.com.mandrill.base.web.rest.errors.*;
import my.com.mandrill.base.web.rest.vm.KeyAndPasswordVM;
import my.com.mandrill.base.web.rest.vm.ManagedUserExtraVM;
import my.com.mandrill.base.web.rest.vm.ManagedUserVM;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * REST controller for managing the current user's account.
 */
@RestController
@RequestMapping("/api")
public class AccountResource {

	private final Logger log = LoggerFactory.getLogger(AccountResource.class);

	private final UserRepository userRepository;

	private final UserExtraRepository userExtraRepository;

	private final PasswordEncoder passwordEncoder;

	private final UserService userService;

	private final MailService mailService;

	private final Environment env;

	private final AuditActionService auditActionService;

	private boolean SELF_REGISTRATION = false;
	private boolean LANGUAGE_SELECTION = false;

	public AccountResource(UserRepository userRepository, UserExtraRepository userExtraRepository,
			UserService userService, MailService mailService, Environment env, PasswordEncoder passwordEncoder,
			AuditActionService auditActionService) {

		this.userRepository = userRepository;
		this.userService = userService;
		this.userExtraRepository = userExtraRepository;
		this.mailService = mailService;
		this.env = env;
		this.passwordEncoder = passwordEncoder;
		this.auditActionService = auditActionService;

		if (this.env.getProperty("application.selfRegistration") != null) {
			SELF_REGISTRATION = Boolean.parseBoolean(this.env.getProperty("application.selfRegistration"));
		}
		if (this.env.getProperty("application.languageSelection") != null) {
			LANGUAGE_SELECTION = Boolean.parseBoolean(this.env.getProperty("application.languageSelection"));
		}
	}

	/**
	 * POST /register : register the user.
	 *
	 * @param managedUserVM the managed user View Model
	 * @throws InvalidPasswordException  400 (Bad Request) if the password is
	 *                                   incorrect
	 * @throws EmailAlreadyUsedException 400 (Bad Request) if the email is already
	 *                                   used
	 * @throws LoginAlreadyUsedException 400 (Bad Request) if the login is already
	 *                                   used
	 */
	@PostMapping("/register")
	@Timed
	@ResponseStatus(HttpStatus.CREATED)
	public void registerAccount(@Valid @RequestBody ManagedUserVM managedUserVM) {
		if (!SELF_REGISTRATION) {
			throw new SelfRegistrationNotAllowedException();
		}

		if (!checkPasswordLength(managedUserVM.getPassword())) {
			throw new InvalidPasswordException();
		}
		userRepository.findOneByLogin(managedUserVM.getLogin().toLowerCase()).ifPresent(u -> {
			throw new LoginAlreadyUsedException();
		});
		userRepository.findOneByEmailIgnoreCase(managedUserVM.getEmail()).ifPresent(u -> {
			throw new EmailAlreadyUsedException();
		});
		User user = userService.registerUser(managedUserVM, managedUserVM.getPassword());
		mailService.sendActivationEmail(user);
	}

	/**
	 * POST /registerExtra : register the user extra.
	 *
	 * @param managedUserExtraVM the managed user View Model
	 * @throws InvalidPasswordException  400 (Bad Request) if the password is
	 *                                   incorrect
	 * @throws EmailAlreadyUsedException 400 (Bad Request) if the email is already
	 *                                   used
	 * @throws LoginAlreadyUsedException 400 (Bad Request) if the login is already
	 *                                   used
	 */
	@PostMapping("/registerExtra")
	@Timed
	@ResponseStatus(HttpStatus.CREATED)
	public void registerAccountExtra(@RequestBody ManagedUserExtraVM managedUserExtraVM) {
		String password = E2eEncryptionUtil.decryptToken(env.getProperty("application.e2eKey"),
				managedUserExtraVM.getPassword());
		String email = E2eEncryptionUtil.decryptToken(env.getProperty("application.e2eKey"),
				managedUserExtraVM.getUser().getEmail());
		String username = E2eEncryptionUtil.decryptToken(env.getProperty("application.e2eKey"),
				managedUserExtraVM.getEncUsername());

		managedUserExtraVM.getUser().setLogin(username);
		managedUserExtraVM.getUser().setEmail(email);
		managedUserExtraVM.setPassword(password);

		if (!SELF_REGISTRATION) {
			throw new SelfRegistrationNotAllowedException();
		}

		if (!checkPasswordLength(password)) {
			throw new InvalidPasswordException();
		}

		userRepository.findOneByLogin(username.toLowerCase()).ifPresent(u -> {
			throw new LoginAlreadyUsedException();
		});
		userRepository.findOneByEmailIgnoreCase(email).ifPresent(u -> {
			throw new EmailAlreadyUsedException();
		});
		User user = userService.registerUser(managedUserExtraVM, password);
		mailService.sendActivationEmail(user);
	}

	/**
	 * GET /activate : activate the registered user.
	 *
	 * @param key the activation key
	 * @throws RuntimeException 500 (Internal Server Error) if the user couldn't be
	 *                          activated
	 */
	@GetMapping("/activate")
	@Timed
	public void activateAccount(@RequestParam(value = "key") String key) {
		Optional<User> user = userService.activateRegistration(key);
		if (!user.isPresent()) {
			throw new InternalServerErrorException("No user was found for this reset key");
		}
	}

	/**
	 * GET /authenticate : check if the user is authenticated, and return its login.
	 *
	 * @param request the HTTP request
	 * @return the login if the user is authenticated
	 */
	@GetMapping("/authenticate")
	@Timed
	public String isAuthenticated(HttpServletRequest request) {
		log.debug("REST request to check if the current user is authenticated");
		return request.getRemoteUser();
	}

	/**
	 * GET /account : get the current user.
	 *
	 * @return the current user
	 * @throws RuntimeException 500 (Internal Server Error) if the user couldn't be
	 *                          returned
	 */
	@GetMapping("/account")
	@Timed
	public UserDTO getAccount() {
		return userService.getUserWithAuthorities().map(UserDTO::new).orElse(null);
	}

	/**
	 * POST /account : update the current user information.
	 *
	 * @param userDTO the current user information
	 * @throws EmailAlreadyUsedException 400 (Bad Request) if the email is already
	 *                                   used
	 * @throws RuntimeException          500 (Internal Server Error) if the user
	 *                                   login wasn't found
	 */
	@PostMapping("/account")
	@Timed
	public void saveAccount(@Valid @RequestBody UserDTO userDTO) {
		final String userLogin = SecurityUtils.getCurrentUserLogin()
				.orElseThrow(() -> new InternalServerErrorException("Current user login not found"));
		Optional<User> existingUser = userRepository.findOneByEmailIgnoreCase(userDTO.getEmail());
		if (existingUser.isPresent() && (!existingUser.get().getLogin().equalsIgnoreCase(userLogin))) {
			throw new EmailAlreadyUsedException();
		}
		Optional<User> user = userRepository.findOneByLogin(userLogin);
		if (!user.isPresent()) {
			throw new InternalServerErrorException("User could not be found");
		}
		userService.updateUser(userDTO.getFirstName(), userDTO.getLastName(), userDTO.getEmail(), userDTO.getLangKey(),
				userDTO.getImageUrl());
	}

	/**
	 * POST /account/change-password : changes the current user's password
	 *
	 * @param password the new password
	 * @throws InvalidPasswordException 400 (Bad Request) if the new password is
	 *                                  incorrect
	 */
	@PostMapping(path = "/account/change-password")
	@Timed
	public void changePassword(@RequestBody String password) {

		String password1 = E2eEncryptionUtil.decryptToken(env.getProperty("application.e2eKey"), password);

		// check password history to not same of recent 5 old password
		final Optional<User> isUser = userService.getUserWithAuthorities();
		
		try {
			
			if (isUser.isPresent()) {
				User user = isUser.get();
				UserExtra userExtra = userExtraRepository.findByUser(user.getId());

				List<PasswordHistory> recentFivePasswordHistories = userExtra.getPasswordHistories().stream()
						.sorted(Comparator.comparing(PasswordHistory::getPasswordChangeTs).reversed()).limit(5)
						.collect(Collectors.toList());

				String newPasswordHash = passwordEncoder.encode(password1);
				for (PasswordHistory ph : recentFivePasswordHistories) {
					if (passwordEncoder.matches(password1, ph.getPasswordHash())) {
						log.debug("New password matched recent 5 password histories.");
	                    throw new InvalidPasswordException();
					}
				}

				userExtra.getPasswordHistories().add(createNewPasswordHistory(newPasswordHash));
				userExtraRepository.save(userExtra);
				
				user.setRetryCount(0);
				user.setActivated(true);
				user.setDeactivateDate(null);
				user.setDeactivateReason(null);
				userRepository.save(user);
			}
			
			if (!checkPasswordLength(password1)) {
				throw new InvalidPasswordException();
			}
			userService.changePassword(password1);
			
			auditActionService.addSuccessEvent(AuditActionType.CHANGE_PASSWORD_SUCCESS, null);
			
		}catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.CHANGE_PASSWORD_FAILED, "test", e);
			throw e;
		}
	}

	/**
	 * POST /account/reset-password/init : Send an email to reset the password of
	 * the user
	 *
	 * @param mail the mail of the user
	 * @throws EmailNotFoundException 400 (Bad Request) if the email address is not
	 *                                registered
	 */
	@PostMapping(path = "/account/reset-password/init")
	@Timed
	public void requestPasswordReset(@RequestBody String mail) {
		mailService
				.sendPasswordResetMail(userService.requestPasswordReset(mail).orElseThrow(EmailNotFoundException::new));
	}

	/**
	 * POST /account/reset-password/finish : Finish to reset the password of the
	 * user
	 *
	 * @param keyAndPassword the generated key and the new password
	 * @throws InvalidPasswordException 400 (Bad Request) if the password is
	 *                                  incorrect
	 * @throws RuntimeException         500 (Internal Server Error) if the password
	 *                                  could not be reset
	 */
	@PostMapping(path = "/account/reset-password/finish")
	@Timed
	public void finishPasswordReset(@RequestBody KeyAndPasswordVM keyAndPassword) {
		String NewKey = E2eEncryptionUtil.decryptToken(env.getProperty("application.e2eKey"), keyAndPassword.getKey());
		String NewPassword = E2eEncryptionUtil.decryptToken(env.getProperty("application.e2eKey"),
				keyAndPassword.getNewPassword());

		try {
			if (!checkPasswordLength(NewPassword)) {
				throw new InvalidPasswordException();
			}
			Optional<User> user = userService.completePasswordReset(NewPassword, NewKey);

			if (!user.isPresent()) {
				throw new InternalServerErrorException("No user was found for this reset key");
			}

			// first password reset need to insert into password_history and
			// user_extra_password_history table
			UserExtra userExtra = userExtraRepository.findByUser(user.get().getId());

			List<PasswordHistory> passwordHistories = userExtra.getPasswordHistories();
			passwordHistories.add(createNewPasswordHistory(passwordEncoder.encode(NewPassword)));
			userExtra.setLoginFlag("N");
			userExtra.setLastLoginTs(Timestamp.valueOf(LocalDateTime.now().minusHours(1L)));

			userExtraRepository.save(userExtra);

			auditActionService.addSuccessEvent(AuditActionType.RESET_PASSWORD_SUCCESS, null);

		} catch (Exception e) {
			auditActionService.addFailedEvent(AuditActionType.RESET_PASSWORD_FAILED, null, e);
			throw e;
		}

	}

	private PasswordHistory createNewPasswordHistory(String passwordHash) {
		PasswordHistory pwHistory = new PasswordHistory();
		pwHistory.setPasswordHash(passwordHash);
		pwHistory.setPasswordChangeTs(Timestamp.valueOf(LocalDateTime.now()));

		return pwHistory;
	}

	private static boolean checkPasswordLength(String password) {
		return !StringUtils.isEmpty(password) && password.length() >= ManagedUserVM.PASSWORD_MIN_LENGTH
				&& password.length() <= ManagedUserVM.PASSWORD_MAX_LENGTH;
	}
}
