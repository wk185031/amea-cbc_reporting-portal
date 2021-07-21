package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class AtmStations extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(AtmStations.class);

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		StringBuilder line = new StringBuilder();
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			rgm.writeLine(line.toString().getBytes());
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
        } catch (IOException | JSONException | ClassNotFoundException | IllegalAccessException | InstantiationException e) {
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
    	
        // replace AUTH_Schema and DB_LINK_AUTH
        rgm.setBodyQuery(rgm.getBodyQuery()
                .replace("{" + ReportConstants.PARAM_AUTH_DB_SCHEMA+ "}", rgm.getAuthenticDbSchema())
                .replace("{" + ReportConstants.PARAM_DB_LINK_AUTH + "}", rgm.getAuthenticDbLink()));
        
        addBatchPreProcessingFieldsToGlobalMap(rgm);
    }
}

