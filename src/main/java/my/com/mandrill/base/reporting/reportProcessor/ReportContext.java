package my.com.mandrill.base.reporting.reportProcessor;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import my.com.mandrill.base.reporting.ReportGenerationFields;

public class ReportContext {

	private String currentBranch;

	private String currentTerminal;

	private boolean writeBodyHeader = true;

	private int totalRecord = 0;

	private String query;

	private Map<String, ReportGenerationFields> predefinedDataMap = new HashMap<>();

	private Map<String, String> currentGroupMap = new HashMap<>();

	private Map<String, BigDecimal> subTotal = new HashMap<>();

	private Map<String, BigDecimal> overallTotal = new HashMap<>();

	public String getCurrentBranch() {
		return currentBranch;
	}

	public void setCurrentBranch(String currentBranch) {
		this.currentBranch = currentBranch;
	}

	public String getCurrentTerminal() {
		return currentTerminal;
	}

	public void setCurrentTerminal(String currentTerminal) {
		this.currentTerminal = currentTerminal;
	}

	public int getTotalRecord() {
		return totalRecord;
	}

	public void setTotalRecord(int totalRecord) {
		this.totalRecord = totalRecord;
	}

	public Map<String, String> getCurrentGroupMap() {
		return currentGroupMap;
	}

	public void setCurrentGroupMap(Map<String, String> currentGroupMap) {
		this.currentGroupMap = currentGroupMap;
	}

	public boolean isGroupChange(String groupKey, String groupValue) {
		return !currentGroupMap.containsKey(groupKey) || !currentGroupMap.get(groupKey).equals(groupValue);
	}

	public boolean isWriteBodyHeader() {
		return writeBodyHeader;
	}

	public void setWriteBodyHeader(boolean writeBodyHeader) {
		this.writeBodyHeader = writeBodyHeader;
	}

	public Map<String, ReportGenerationFields> getPredefinedDataMap() {
		return predefinedDataMap;
	}

	public void setPredefinedDataMap(Map<String, ReportGenerationFields> predefinedDataMap) {
		this.predefinedDataMap = predefinedDataMap;
	}

	public String getQuery() {
		return query;
	}

	public void setQuery(String query) {
		this.query = query;
	}

	public Map<String, BigDecimal> getSubTotal() {
		return subTotal;
	}

	public void setSubTotal(Map<String, BigDecimal> subTotal) {
		this.subTotal = subTotal;
	}

	public Map<String, BigDecimal> getOverallTotal() {
		return overallTotal;
	}

	public void setOverallTotal(Map<String, BigDecimal> overallTotal) {
		this.overallTotal = overallTotal;
	}
}
