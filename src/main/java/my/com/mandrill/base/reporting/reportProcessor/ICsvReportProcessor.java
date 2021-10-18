package my.com.mandrill.base.reporting.reportProcessor;

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public interface ICsvReportProcessor {
	void processCsvRecord(ReportGenerationMgr rgm) throws ReportGenerationException;
}
