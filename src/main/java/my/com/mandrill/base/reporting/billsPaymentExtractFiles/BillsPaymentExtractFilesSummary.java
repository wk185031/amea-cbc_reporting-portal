package my.com.mandrill.base.reporting.billsPaymentExtractFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class BillsPaymentExtractFilesSummary extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(BillsPaymentExtractFilesSummary.class);
	private int pagination = 0;

	@Override
	public void processTxtRecord(ReportGenerationMgr rgm) throws ReportGenerationException {
		logger.debug("In BillsPaymentExtractFilesSummary.processTxtRecord()");
		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();

		try {
			if (rgm.isGenerate() == true) {
				txnDate = rgm.getFileDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
			} else {
				txnDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
			}

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}
					
					separateQuery(rgm);
					
					file = new File(
							rgm.getFileLocation() + rgm.getFileNamePrefix() + txnDate + "_02" + ReportConstants.SUM_FORMAT);
					
					setQuery(rgm, getCashCardBodyQuery(), getCashCardTrailerQuery());
					
					execute(rgm, file);
					
					file = new File(
							rgm.getFileLocation() + rgm.getFileNamePrefix() + txnDate + "_01" + ReportConstants.SUM_FORMAT);
					
					setQuery(rgm, getAtmCardBodyQuery(), getAtmCardTrailerQuery());
					
					execute(rgm, file);
					
					rgm.fileOutputStream.flush();
					rgm.fileOutputStream.close();
					
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception(
						"Errors when generating" + rgm.getFileNamePrefix() + txnDate + ReportConstants.SUM_FORMAT);
			}
			
		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + txnDate + ReportConstants.SUM_FORMAT, e);
			throw new ReportGenerationException(
					"Errors when generating" + rgm.getFileNamePrefix() + txnDate + ReportConstants.SUM_FORMAT, e);
		}finally {
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
			
		} catch (IOException | JSONException e) {
			throw new ReportGenerationException(file.getName(), e);
//			rgm.errors++;
//			logger.error("Error in generating TXT file", e);
		} 
	}
	
	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In BillsPaymentExtractFilesSummary.separateQuery()");
		
		if (rgm.getBodyQuery() != null) {
			setCashCardBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setAtmCardBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
		
		if (rgm.getTrailerQuery() != null) {
			setCashCardTrailerQuery(rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setAtmCardTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
		
	}
	
	private void setQuery(ReportGenerationMgr rgm, String bodyQuery, String trailerQuery) {

		rgm.setBodyQuery(bodyQuery);
		rgm.setTrailerQuery(trailerQuery);

	}
}
