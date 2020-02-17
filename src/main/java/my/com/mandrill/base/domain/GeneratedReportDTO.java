package my.com.mandrill.base.domain;

import java.util.List;

/**
 * A DTO representing auto generated reports
 */
public class GeneratedReportDTO {

	private ReportCategory reportCategory;
	private String reportDate;
	private List<String> reportList;

	public GeneratedReportDTO(ReportCategory reportCategory, String reportDate, List<String> reportList) {
		super();
		this.reportCategory = reportCategory;
		this.reportDate = reportDate;
		this.reportList = reportList;
	}

	public GeneratedReportDTO() {
		this.reportCategory = null;
		this.reportDate = null;
		this.reportList = null;
	}

	public ReportCategory getReportCategory() {
		return reportCategory;
	}

	public void setReportCategory(ReportCategory reportCategory) {
		this.reportCategory = reportCategory;
	}

	public String getReportDate() {
		return reportDate;
	}

	public void setReportDate(String reportDate) {
		this.reportDate = reportDate;
	}

	public List<String> getReportList() {
		return reportList;
	}

	public void setReportList(List<String> reportList) {
		this.reportList = reportList;
	}
	
	@Override
	public String toString() {
		return "GeneratedReportDTO [reportDate=" + reportDate + "]";
	}

}
