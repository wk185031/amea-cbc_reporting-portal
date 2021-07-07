package my.com.mandrill.base.reporting.bartsFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class SwitTransactionLogFile extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(SwitTransactionLogFile.class);

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
		logger.debug("In SwitTransactionLogFile.writeHeader()");
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
					if(amount.contains(".")) {
						amount = amount.trim().replace(".", "");
						amount = ("00000000000" + amount).substring(amount.length());
					}else {
						amount = amount.replace(' ', '0').concat("00");
					}
					line.append(amount);
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
