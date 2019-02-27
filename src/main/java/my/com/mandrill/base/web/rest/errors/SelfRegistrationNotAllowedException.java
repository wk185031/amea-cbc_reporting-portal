package my.com.mandrill.base.web.rest.errors;

import org.zalando.problem.AbstractThrowableProblem;
import org.zalando.problem.Status;

public class SelfRegistrationNotAllowedException extends AbstractThrowableProblem {

    public SelfRegistrationNotAllowedException() {
        super(ErrorConstants.SELF_REGISTRATION_NOT_ALLOWED_TYPE, "Self registration is not allowed", Status.BAD_REQUEST);
    }
}