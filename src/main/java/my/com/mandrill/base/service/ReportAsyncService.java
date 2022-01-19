package my.com.mandrill.base.service;

import java.util.concurrent.TimeUnit;

import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import my.com.mandrill.base.processor.IReportProcessor;
import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.processor.ReportProcessorLocator;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

@Service
public class ReportAsyncService {

	private final Logger log = LoggerFactory.getLogger(ReportAsyncService.class);
	
	@Autowired
	private ReportProcessorLocator reportProcessLocator;
	
	@Autowired
	private DataSource dataSource;
	
	@Async
	public void runReport(ReportGenerationMgr reportGenerationMgr) throws ReportGenerationException {
		log.debug("runReport start [jobId={}, report={}] ", reportGenerationMgr.getJobId(),
				reportGenerationMgr.getFileName());
		IReportProcessor reportProcessor = reportProcessLocator.locate(reportGenerationMgr.getProcessingClass());

		long start = System.nanoTime();
		if (reportProcessor != null) {
			log.debug("runReport with processor: {}", reportProcessor);
			reportProcessor.process(reportGenerationMgr);
		} else {
			reportGenerationMgr.run(dataSource);
		}

		log.debug("runReport end [jobId={}, report={}] ELAPSED TIME - {}s : ", reportGenerationMgr.getJobId(),
				reportGenerationMgr.getFileName(), TimeUnit.NANOSECONDS.toSeconds(System.nanoTime() - start));
	}
	
}
