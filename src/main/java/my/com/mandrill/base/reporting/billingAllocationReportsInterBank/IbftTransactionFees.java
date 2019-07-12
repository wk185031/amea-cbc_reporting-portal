package my.com.mandrill.base.reporting.billingAllocationReportsInterBank;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class IbftTransactionFees extends CsvReportProcessor {
	private final Logger logger = LoggerFactory.getLogger(IbftTransactionFees.class);
	private int pagination = 0;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			preProcessing(rgm);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
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
	
	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In PosTransactionFees.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In IbftTransactionFees.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}
}