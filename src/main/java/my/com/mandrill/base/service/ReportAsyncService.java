package my.com.mandrill.base.service;

import java.util.concurrent.CompletableFuture;
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
import my.com.mandrill.base.reporting.ReportGenerationResult;

@Service
public class ReportAsyncService {

	private final Logger log = LoggerFactory.getLogger(ReportAsyncService.class);

	@Autowired
	private ReportProcessorLocator reportProcessLocator;

	@Autowired
	private DataSource dataSource;

	@Async
	public CompletableFuture<ReportGenerationResult> runReport(ReportGenerationMgr reportGenerationMgr) {
		log.debug("runReport-{}: START [report={}] ", reportGenerationMgr.getJobId(),
				reportGenerationMgr.getFileName());
		IReportProcessor reportProcessor = reportProcessLocator.locate(reportGenerationMgr.getProcessingClass());

		long start = System.nanoTime();
		try {
			if (reportProcessor != null) {
				log.debug("runReport with processor: {}", reportProcessor);
				reportProcessor.process(reportGenerationMgr);
			} else {
				reportGenerationMgr.run(dataSource);
			}
		} catch (ReportGenerationException e) {
			long elapsedTime = TimeUnit.NANOSECONDS.toSeconds(System.nanoTime() - start);
			log.debug("runReport-{}: FAILED [reportName={}] ELAPSED TIME - {}s",
					reportGenerationMgr.getJobId(), reportGenerationMgr.getFileName(), elapsedTime, e);
			return CompletableFuture.completedFuture(
					ReportGenerationResult.failed(reportGenerationMgr.getFileName(), e.getMessage(), elapsedTime));
		}

		long elapsedTime = TimeUnit.NANOSECONDS.toSeconds(System.nanoTime() - start);
		log.debug("runReport-{}: END [reportName={}] ELAPSED TIME - {}s", reportGenerationMgr.getJobId(),
				reportGenerationMgr.getFileName(), elapsedTime);
		return CompletableFuture
				.completedFuture(ReportGenerationResult.success(reportGenerationMgr.getFileName(), elapsedTime));
	}

}
