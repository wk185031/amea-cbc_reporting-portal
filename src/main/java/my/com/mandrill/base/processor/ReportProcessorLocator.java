package my.com.mandrill.base.processor;

import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.cbc.processor.SimpleReportProcessor;
import my.com.mandrill.base.reporting.newTransactionReports.ListRecyclerTransactionProcessor;
import my.com.mandrill.base.reporting.newTransactionReports.SummaryRecyclerTransactionProcessor;

@Component
public class ReportProcessorLocator {

	private final Logger logger = LoggerFactory.getLogger(ReportProcessorLocator.class);

	private final ListRecyclerTransactionProcessor listRecyclerTransactionProcessor;

	private final SummaryRecyclerTransactionProcessor summaryRecyclerTransactionProcessor;
	
	private final SimpleReportProcessor simpleReportProcessor;

	private Map<String, IReportProcessor> reportProcessorList = new HashMap<>();

	public ReportProcessorLocator(ListRecyclerTransactionProcessor listRecyclerTransactionProcessor,
			SummaryRecyclerTransactionProcessor summaryRecyclerTransactionProcessor, SimpleReportProcessor simpleReportProcessor) {
		this.listRecyclerTransactionProcessor = listRecyclerTransactionProcessor;
		this.summaryRecyclerTransactionProcessor = summaryRecyclerTransactionProcessor;
		this.simpleReportProcessor = simpleReportProcessor;
		
		reportProcessorList.put(listRecyclerTransactionProcessor.getClass().getName(), (IReportProcessor) listRecyclerTransactionProcessor);
		reportProcessorList.put(summaryRecyclerTransactionProcessor.getClass().getName(),
				(IReportProcessor) summaryRecyclerTransactionProcessor);
		reportProcessorList.put(simpleReportProcessor.getClass().getName(), (IReportProcessor) simpleReportProcessor);
	}

	public IReportProcessor locate(String clazz) {
		logger.debug("locate processor: clazz={}, reportProcessorList size={}", clazz, reportProcessorList.size());
		return reportProcessorList.get(clazz);
	}

}
