package my.com.mandrill.base.reporting;

public class ReportGenerationResult {

	private String reportName;

	private boolean success;

	private String error;

	long elapsedTimeInSec;

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

	public long getElapsedTimeInSec() {
		return elapsedTimeInSec;
	}

	public void setElapsedTimeInSec(long elapsedTimeInSec) {
		this.elapsedTimeInSec = elapsedTimeInSec;
	}

	public static ReportGenerationResult success(String reportName, long elapsedTimeInSec) {
		ReportGenerationResult result = new ReportGenerationResult();
		result.setReportName(reportName);
		result.setSuccess(true);
		result.setElapsedTimeInSec(elapsedTimeInSec);
		return result;
	}

	public static ReportGenerationResult failed(String reportName, String error, long elapsedTimeInSec) {
		ReportGenerationResult result = new ReportGenerationResult();
		result.setReportName(reportName);
		result.setSuccess(false);
		result.setError(error);
		result.setElapsedTimeInSec(elapsedTimeInSec);
		return result;
	}

	@Override
	public String toString() {
		return "ReportGenerationResult [reportName=" + reportName + ", success=" + success + ", error=" + error + "]";
	}

}
