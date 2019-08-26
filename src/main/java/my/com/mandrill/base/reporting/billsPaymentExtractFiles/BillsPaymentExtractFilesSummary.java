package my.com.mandrill.base.reporting.billsPaymentExtractFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class BillsPaymentExtractFilesSummary extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(BillsPaymentExtractFilesSummary.class);
	private int pagination = 0;

	@Override
	public void processTxtRecord(ReportGenerationMgr rgm) {
		logger.debug("In BillsPaymentExtractFilesSummary.processTxtRecord()");
		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();

		try {
			if (rgm.isGenerate() == true) {
				txnDate = rgm.getFileDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_04));
			} else {
				txnDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_04));
			}

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}
					file = new File(
							rgm.getFileLocation() + rgm.getFileNamePrefix() + txnDate + ReportConstants.SUM_FORMAT);
					execute(rgm, file);
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception(
						"Errors when generating" + rgm.getFileNamePrefix() + txnDate + ReportConstants.SUM_FORMAT);
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + txnDate + ReportConstants.SUM_FORMAT, e);
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		StringBuilder line = new StringBuilder();
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in generating TXT file", e);
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
