package my.com.mandrill.base.reporting.bartsFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class CasaTransactionLogFile extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(CasaTransactionLogFile.class);

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addBatchPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			executeBodyQuery(rgm);
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

	@Override
	protected void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CasaTransactionLogFile.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(getEol());
			} else {
				line.append(getGlobalFieldValue(rgm, field));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
					|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
					String amount = getFieldValue(rgm, field, fieldsMap);
					
					DecimalFormat df = new DecimalFormat("0.00");
				    String amountFormatted = df.format(Double.parseDouble(amount.trim()));
					amountFormatted = amountFormatted.replace(".", "");
					amountFormatted = ("00000000000" + amountFormatted).substring(amountFormatted.length());

					line.append(amountFormatted);
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap).replace(' ', '0'));
				}
			} else {
				line.append(getFieldValue(rgm, field, fieldsMap));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}
