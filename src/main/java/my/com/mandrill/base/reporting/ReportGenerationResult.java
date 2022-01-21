package my.com.mandrill.base.reporting;

public class ReportGenerationResult {

	private String reportName;

	private boolean success;

	private String error;

	public String getReportName() {
		return reportName;
	}

	public void setReportName(String reportName) {
		this.reportName = reportName;
	}

	public boolean isSuccess() {
		return success;
	}

	public void setSuccess(boolean success) {
		this.success = success;
	}

	public String getError() {
		return error;
	}

	public void setError(String error) {
		this.error = error;
	}

	public static ReportGenerationResult success(String reportName) {
		ReportGenerationResult result = new ReportGenerationResult();
		result.setReportName(reportName);
		result.setSuccess(true);
		return result;
	}

	public static ReportGenerationResult failed(String reportName, String error) {
		ReportGenerationResult result = new ReportGenerationResult();
		result.setReportName(reportName);
		result.setSuccess(false);
		result.setError(error);
		return result;
	}

	@Override
	public String toString() {
		return "ReportGenerationResult [reportName=" + reportName + ", success=" + success + ", error=" + error + "]";
	}

}
