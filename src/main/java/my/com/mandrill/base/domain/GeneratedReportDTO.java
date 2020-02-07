package my.com.mandrill.base.domain;

import java.util.List;

/**
 * A DTO representing auto generated reports
 */
public class GeneratedReportDTO {

	private String date;
	private List<String> reportList;

	public GeneratedReportDTO(String date, List<String> reportList) {
		super();
		this.date = date;
		this.reportList = reportList;
	}

	public GeneratedReportDTO() {
		this.date = null;
		this.reportList = null;
	}

	public String getDate() {
		return date;
	}

	public void setDate(String date) {
		this.date = date;
	}

	public List<String> getReportList() {
		return reportList;
	}

	public void setReportList(List<String> reportList) {
		this.reportList = reportList;
	}
	
	@Override
	public String toString() {
		return "GeneratedReportDTO [date=" + date + ", reportList=" + reportList + "]";
	}

}
