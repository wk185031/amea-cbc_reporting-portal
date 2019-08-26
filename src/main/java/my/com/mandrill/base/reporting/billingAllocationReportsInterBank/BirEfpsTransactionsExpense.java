package my.com.mandrill.base.reporting.billingAllocationReportsInterBank;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class BirEfpsTransactionsExpense extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(BirEfpsTransactionsExpense.class);

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException e) {
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
}