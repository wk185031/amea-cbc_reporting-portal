package my.com.mandrill.base.web.rest.vm;

import my.com.mandrill.base.service.dto.UserExtraDTO;

import javax.validation.constraints.Size;

/**
 * View Model extending the UserExtraDTO, which is meant to be used in the user management UI.
 */
public class ManagedUserExtraVM extends UserExtraDTO {

    public static final int PASSWORD_MIN_LENGTH = 4;

    public static final int PASSWORD_MAX_LENGTH = 100;

    private String encUsername;
    
    @Size(min = PASSWORD_MIN_LENGTH, max = PASSWORD_MAX_LENGTH)
    private String password;

    public ManagedUserExtraVM() {
        // Empty constructor needed for Jackson.
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getEncUsername() {
		return encUsername;
	}

	public void setEncUsername(String encUsername) {
		this.encUsername = encUsername;
	}

	@Override
    public String toString() {
        return "ManagedUserExtraVM{" +
            "} " + super.toString();
    }
}
