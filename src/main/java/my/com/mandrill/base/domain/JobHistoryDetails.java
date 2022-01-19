package my.com.mandrill.base.domain;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

public class JobHistoryDetails {

	Long institutionId;
	Long reportCategoryId;
	String reportCategory;
	Long reportId;
	String report;
	String description;
	LocalDateTime transactionStartDate;
	LocalDateTime transactionEndDate;
	String frequency;
	Map<String,String> reportStatusMap = new HashMap<String,String>();

	public JobHistoryDetails(Long institutionId, Long reportCategoryId, String reportCategory, Long reportId,
			String report, String description, LocalDateTime transactionStartDate, LocalDateTime transactionEndDate) {
		this.institutionId = institutionId;
		this.reportCategoryId = reportCategoryId;
		this.reportCategory = reportCategory;
		this.report = report;
		this.description = description;
		this.transactionStartDate = transactionStartDate;
		this.transactionEndDate = transactionEndDate;
	}

	public Long getInstitutionId() {
		return institutionId;
	}

	public void setInstitutionId(Long institutionId) {
		this.institutionId = institutionId;
	}

	public Long getReportCategoryId() {
		return reportCategoryId;
	}

	public void setReportCategoryId(Long reportCategoryId) {
		this.reportCategoryId = reportCategoryId;
	}

	public String getReportCategory() {
		return reportCategory;
	}

	public void setReportCategory(String reportCategory) {
		this.reportCategory = reportCategory;
	}

	public String getReport() {
		return report;
	}

	public void setReport(String report) {
		this.report = report;
	}

	public String getDescription() {
		if (description == null) {
			StringBuffer sb = new StringBuffer();
			sb.append("REPORT CATEGORY: ").append(getReportCategory()).append(", REPORT: ").append(getReport())
					.append(", FROM: ").append(transactionStartDate).append(", TO: ").append(transactionEndDate);
			setDescription(sb.toString());
		}
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Map<String, String> getReportStatusMap() {
		return reportStatusMap;
	}

	public void setReportStatusMap(Map<String, String> reportStatusMap) {
		this.reportStatusMap = reportStatusMap;
	}

	public String getFrequency() {
		return frequency;
	}

	public void setFrequency(String frequency) {
		this.frequency = frequency;
	}

	public Long getReportId() {
		return reportId;
	}

	public void setReportId(Long reportId) {
		this.reportId = reportId;
	}

	public LocalDateTime getTransactionStartDate() {
		return transactionStartDate;
	}

	public void setTransactionStartDate(LocalDateTime transactionStartDate) {
		this.transactionStartDate = transactionStartDate;
	}

	public LocalDateTime getTransactionEndDate() {
		return transactionEndDate;
	}

	public void setTransactionEndDate(LocalDateTime transactionEndDate) {
		this.transactionEndDate = transactionEndDate;
	}
	
	public boolean isAllCategory() {
		return getReportCategoryId() == null || getReportCategoryId() <= 0L;
	}
	
	public boolean isAllReport() {
		return getReportId() == null || getReportId() <= 0L;
	}

}
