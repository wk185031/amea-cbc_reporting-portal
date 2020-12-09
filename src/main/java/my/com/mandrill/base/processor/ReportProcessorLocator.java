package my.com.mandrill.base.processor;

import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class ReportProcessorLocator {

	private final Logger logger = LoggerFactory.getLogger(ReportProcessorLocator.class);
	
	private final SimpleReportProcessor simpleReportProcessor;

	private Map<String, IReportProcessor> reportProcessorList = new HashMap<>();

	public ReportProcessorLocator(SimpleReportProcessor simpleReportProcessor) {
		this.simpleReportProcessor = simpleReportProcessor;
		logger.debug("add processor:{}", simpleReportProcessor.getClass().getName());
		reportProcessorList.put(simpleReportProcessor.getClass().getName(), (IReportProcessor) simpleReportProcessor);
	}

	public IReportProcessor locate(String clazz) {
		logger.debug("locate processor: clazz={}, reportProcessorList size={}", clazz, reportProcessorList.size());
		return reportProcessorList.get(clazz);
	}

}
