package my.com.mandrill.base.reporting.reportProcessor;

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public interface IPdfReportProcessor {
	void processPdfRecord(ReportGenerationMgr rgm) throws ReportGenerationException;
}
