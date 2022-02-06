package my.com.mandrill.base.processor;

public class ReportGenerationException extends RuntimeException {

	private static final long serialVersionUID = 1L;

	private final String filename;

	public ReportGenerationException(String filename, Throwable e) {
		super(e);
		this.filename = filename;
	}
	
	public ReportGenerationException(String filename) {
		super("Unknown error.");
		this.filename = filename;
	}

	public String getFilename() {
		return filename;
	}
}
