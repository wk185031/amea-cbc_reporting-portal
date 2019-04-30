package my.com.mandrill.base.reporting;

public interface IReportProcessor {
	String getBodyQuery(ReportGenerationMgr rgm);

	String getTrailerQuery(ReportGenerationMgr rgm);

	void processPdfRecord(ReportGenerationMgr rgm);
	
	void processCsvTxtRecord(ReportGenerationMgr rgm);
}
