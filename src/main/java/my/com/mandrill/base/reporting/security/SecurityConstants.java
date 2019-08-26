package my.com.mandrill.base.reporting.security;

public class SecurityConstants {

	private SecurityConstants() {
	}

	/**
	 * Security parameter set category.
	 */
	public enum Category {

		SYSTEM("system"), CUSTOM("custom"), DATA("data"), FALLBACK("fallback");

		private final String value;

		Category(final String value) {
			this.value = value;
		}

		public String getName() {
			return value;
		}
	}

	/**
	 * Security parameter set status.
	 */
	public enum Status {

		ACTIVE("active"), INACTIVE("inactive");

		private final String value;

		Status(final String value) {
			this.value = value;
		}

		public String getName() {
			return value;
		}
	}

	/**
	 * Secure field format.
	 */
	public enum Format {

		CLEAR("clear"), ENCRYPTED("encrypted"), MASKED("masked");

		private final String value;

		Format(final String value) {
			this.value = value;
		}

		public String getName() {
			return value;
		}
	}

	/**
	 * Fail validation.
	 */
	public enum Validation {

		SHUTDOWN("shutdown"), WARN("warn");

		private final String value;

		Validation(final String value) {
			this.value = value;
		}

		public String getName() {
			return value;
		}
	}
}
