package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class AtmCashLevel extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(AtmCashLevel.class);

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
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

	@Override
	protected void addReportPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In AtmCashLevel.addPreProcessingFieldsToGlobalMap()");
		if (rgm.isGenerate() == true) {
			String txnStart = rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
					.concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
					.concat(" ").concat(ReportConstants.END_TIME);
			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"ATO.ATO_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND ATO.ATO_TIMESTAMP < TO_DATE('" + txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE
							+ "')");
			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		} else {
			String txnStart = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
					.concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = rgm.getTodayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01))
					.concat(ReportConstants.END_TIME);
			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"ATO.ATO_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND ATO.ATO_TIMESTAMP < TO_DATE('" + txnEnd + "','" + ReportConstants.FORMAT_TXN_DATE
							+ "')");
			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		}
	}
}
