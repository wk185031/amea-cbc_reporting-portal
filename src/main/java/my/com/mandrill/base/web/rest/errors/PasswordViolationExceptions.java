package my.com.mandrill.base.web.rest.errors;

public class PasswordViolationExceptions {

	public static BadRequestAlertException conflictWithHistory() {
		return new BadRequestAlertException(ErrorConstants.PASSWORD_VIOLATION_TYPE, "You used the password recently. Please choose a different password.", "resetPassword", "error.password.violation.history");
	}

}

