package my.com.mandrill.base.web.rest;

import my.com.mandrill.base.config.ApplicationProperties;
import my.com.mandrill.base.config.DefaultProfileUtil;

import io.github.jhipster.config.JHipsterProperties;

import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Resource to return information about the currently running Spring profiles.
 */
@RestController
@RequestMapping("/api")
public class ProfileInfoResource {

    private final Environment env;

    private final JHipsterProperties jHipsterProperties;

    private final ApplicationProperties applicationProperties;
    
    public ProfileInfoResource(Environment env, JHipsterProperties jHipsterProperties, ApplicationProperties applicationProperties) {
        this.env = env;
        this.jHipsterProperties = jHipsterProperties;
        this.applicationProperties = applicationProperties;
    }

    @GetMapping("/profile-info")
    public ProfileInfoVM getActiveProfiles() {
        String[] activeProfiles = DefaultProfileUtil.getActiveProfiles(env);
        ProfileInfoVM profile = new ProfileInfoVM(activeProfiles, getRibbonEnv(activeProfiles));
        profile.setSelfRegistration(applicationProperties.isSelfRegistration());
        profile.setLanguageSelection(applicationProperties.isLanguageSelection());
        return profile;
    }

    private String getRibbonEnv(String[] activeProfiles) {
        String[] displayOnActiveProfiles = jHipsterProperties.getRibbon().getDisplayOnActiveProfiles();
        if (displayOnActiveProfiles == null) {
            return null;
        }
        List<String> ribbonProfiles = new ArrayList<>(Arrays.asList(displayOnActiveProfiles));
        List<String> springBootProfiles = Arrays.asList(activeProfiles);
        ribbonProfiles.retainAll(springBootProfiles);
        if (!ribbonProfiles.isEmpty()) {
            return ribbonProfiles.get(0);
        }
        return null;
    }

    class ProfileInfoVM {

        private String[] activeProfiles;

        private String ribbonEnv;
        
        private boolean selfRegistration;
        private boolean languageSelection;


		ProfileInfoVM(String[] activeProfiles, String ribbonEnv) {
            this.activeProfiles = activeProfiles;
            this.ribbonEnv = ribbonEnv;
        }

        public String[] getActiveProfiles() {
            return activeProfiles;
        }

        public String getRibbonEnv() {
            return ribbonEnv;
        }
        
        public boolean isSelfRegistration() {
			return selfRegistration;
		}

		public void setSelfRegistration(boolean selfRegistration) {
			this.selfRegistration = selfRegistration;
		}
		
		public boolean isLanguageSelection() {
			return languageSelection;
		}

		public void setLanguageSelection(boolean languageSelection) {
			this.languageSelection = languageSelection;
		}
        
    }
}
