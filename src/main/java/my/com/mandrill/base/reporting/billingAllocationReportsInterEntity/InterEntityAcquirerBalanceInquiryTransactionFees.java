package my.com.mandrill.base.reporting.billingAllocationReportsInterEntity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.billsPaymentExtractFiles.BillsPaymentExtractFilesSummary;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class InterEntityAcquirerBalanceInquiryTransactionFees extends CsvReportProcessor {
	private final Logger logger = LoggerFactory.getLogger(InterEntityAcquirerBalanceInquiryTransactionFees.class);
	private int pagination = 0;


	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		StringBuilder line = new StringBuilder();
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			preProcessing(rgm);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
			rgm.writeLine(line.toString().getBytes());

			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in generating CSV file", e);
		} finally {
			try {
				if (rgm.fileOutputStream != null) {
					rgm.fileOutputStream.close();
					rgm.exit();
				}
			} catch (IOException e) {
				rgm.errors++;
				logger.error("Error in closing fileOutputStream", e);
			}
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In InterEntityAcquirerBalanceInquiryTransactionFees.preProcessing()");
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}
}
