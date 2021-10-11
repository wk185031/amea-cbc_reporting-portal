package my.com.mandrill.base.domain;

public class JobHistoryDetails {

	String institutionId;
	String reportCategoryId;
	String reportCategory;
	String report;
	String description;
	String searchByDate;
	String transactionStartDate;
	String transactionEndDate;
	String startDateTime;
	String endDateTime;
		
	public JobHistoryDetails(String institutionId, String reportCategoryId, String reportCategory, String report, String description,
			String searchByDate, String transactionStartDate, String transactionEndDate, String startDateTime,
			String endDateTime) {
		this.institutionId = institutionId;
		this.reportCategoryId = reportCategoryId;
		this.reportCategory = reportCategory;
		this.report = report;
		this.description = description;
		this.searchByDate = searchByDate;
		this.transactionStartDate = transactionStartDate;
		this.transactionEndDate = transactionEndDate;
		this.startDateTime = startDateTime;
		this.endDateTime = endDateTime;
	}

	public String getInstitutionId() {
		return institutionId;
	}
	
	public void setInstitutionId(String institutionId) {
		this.institutionId = institutionId;
	}
	
	public String getReportCategoryId() {
		return reportCategoryId;
	}
	
	public void setReportCategoryId(String reportCategoryId) {
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
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getSearchByDate() {
		return searchByDate;
	}
	
	public void setSearchByDate(String searchByDate) {
		this.searchByDate = searchByDate;
	}
	
	public String getTransactionStartDate() {
		return transactionStartDate;
	}
	
	public void setTransactionStartDate(String transactionStartDate) {
		this.transactionStartDate = transactionStartDate;
	}
	
	public String getTransactionEndDate() {
		return transactionEndDate;
	}
	
	public void setTransactionEndDate(String transactionEndDate) {
		this.transactionEndDate = transactionEndDate;
	}
	
	public String getStartDateTime() {
		return startDateTime;
	}
	
	public void setStartDateTime(String startDateTime) {
		this.startDateTime = startDateTime;
	}
	
	public String getEndDateTime() {
		return endDateTime;
	}
	
	public void setEndDateTime(String endDateTime) {
		this.endDateTime = endDateTime;
	}
}
