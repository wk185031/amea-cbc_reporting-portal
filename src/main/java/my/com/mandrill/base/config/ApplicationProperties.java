package my.com.mandrill.base.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Properties specific to Base.
 * <p>
 * Properties are configured in the application.yml file.
 * See {@link io.github.jhipster.config.JHipsterProperties} for a good example.
 */
@ConfigurationProperties(prefix = "application", ignoreUnknownFields = false)
public class ApplicationProperties {
    private boolean selfRegistration;
    private boolean languageSelection;

    private final AbsolutePath imageAttachmentBasePath = new AbsolutePath();

	public boolean isLanguageSelection() {
		return languageSelection;
	}

	public void setLanguageSelection(boolean languageSelection) {
		this.languageSelection = languageSelection;
	}

	public boolean isSelfRegistration() {
		return selfRegistration;
	}

	public void setSelfRegistration(boolean selfRegistration) {
		this.selfRegistration = selfRegistration;
	}

    public AbsolutePath getImageAttachmentBasePath() {
        return imageAttachmentBasePath;
    }

    public static class AbsolutePath {

        private String path;

        private String acceptFileBinary;

        private String acceptFileText;

        private int maxSize;

        public String getPath() {
            return path;
        }

        public void setPath(String path) {
            this.path = path;
        }

        public String getAcceptFileBinary() {
            return acceptFileBinary;
        }

        public void setAcceptFileBinary(String acceptFileBinary) {
            this.acceptFileBinary = acceptFileBinary;
        }

        public String getAcceptFileText() {
            return acceptFileText;
        }

        public void setAcceptFileText(String acceptFileText) {
            this.acceptFileText = acceptFileText;
        }

        public int getMaxSize() {
            return maxSize;
        }

        public void setMaxSize(int maxSize) {
            this.maxSize = maxSize;
        }
    }
}
