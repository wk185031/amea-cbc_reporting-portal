package my.com.mandrill.base.reporting.usec;

import java.util.EnumSet;

public class UsecConstants {

	public static final String RESOURCE_TYPE_MENU = "MENU";
	public static final String RESOURCE_TYPE_FUNCTION = "FUNCTION";
	public static final String AUTH_OK = "SUCCESS";
	public static final String AUTH_FAILED = "FAILED";
	public static final String AUTH_OK_PSWD_CHANGE = "SUCCESS_PWD_CHANGE";

	public enum ApplicationType {
		DESKTOP, POS, CMS, CONSOLE, ATM_MONITOR;

		protected static final EnumSet<ApplicationType> WebApps = EnumSet.of(POS, CMS, ATM_MONITOR);

		public boolean isWebApp() {
			return WebApps.contains(this);
		}

		public static ApplicationType find(String type) {
			for (ApplicationType data : ApplicationType.values()) {
				if (data.name().equals(type)) {
					return data;
				}
			}

			return DESKTOP;
		}
	}

	public enum PermissionAccessType {
		NO("NO", false, false, false, false, false), RO("RO", false, true, false, false, false), ALL("FULL", true, true,
				true, true, true);

		private String name;
		private boolean create;
		private boolean read;
		private boolean update;
		private boolean delete;
		private boolean execute;

		PermissionAccessType() {

		}

		PermissionAccessType(String name, boolean isCreateAllowed, boolean isReadAllowed, boolean isUpdateAllowd,
				boolean isDeleteAllowed, boolean isExecutable) {
			this.name = name;
			this.create = isCreateAllowed;
			this.read = isReadAllowed;
			this.update = isUpdateAllowd;
			this.delete = isDeleteAllowed;
			this.execute = isExecutable;
		}

		public static PermissionAccessType find(String permission) {
			for (PermissionAccessType type : values()) {
				if (type.getName().equals(permission)) {
					return type;
				}
			}

			return NO;
		}

		/**
		 * @return Returns the name.
		 */
		public String getName() {
			return name;
		}

		/**
		 * @return Returns the create.
		 */
		public boolean isCreate() {
			return create;
		}

		/**
		 * @return Returns the read.
		 */
		public boolean isRead() {
			return read;
		}

		/**
		 * @return Returns the update.
		 */
		public boolean isUpdate() {
			return update;
		}

		/**
		 * @return Returns the delete.
		 */
		public boolean isDelete() {
			return delete;
		}

		/**
		 * @return Returns the execute.
		 */
		public boolean isExecute() {
			return execute;
		}

		@Override
		public String toString() {
			return getName();
		}
	}

	public enum UserStatusType {
		INACTIVE("INACTIVE", false), ACTIVE("ACTIVE", true), LOCKED("LOCKED", false), SUSPENDED("SUSPENDED",
				false), REMOVED("REMOVED", false);

		private String name;
		private boolean active;

		UserStatusType(String name, boolean active) {
			this.name = name;
			this.active = active;
		}

		public static UserStatusType find(String status) {
			for (UserStatusType type : values()) {
				if (type.getName().equals(status)) {
					return type;
				}
			}

			return INACTIVE;
		}

		public void setName(String name) {
			this.name = name;
		}

		public void setActive(boolean active) {
			this.active = active;
		}

		public String getName() {
			return this.name;
		}

		public boolean isActive() {
			return this.active;
		}

		@Override
		public String toString() {
			return getName();
		}
	}
}
