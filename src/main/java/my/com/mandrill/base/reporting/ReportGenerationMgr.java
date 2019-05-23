package my.com.mandrill.base.reporting;

import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.HashMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ReportGenerationMgr extends ReportGenerationFields {

	private final Logger logger = LoggerFactory.getLogger(ReportGenerationMgr.class);
	public IReportProcessor reportProcessor;
	public Connection connection;
	public FileOutputStream fileOutputStream;
	public int errors = 0;

	public void run(String url, String username, String password) {
		logger.debug("In ReportGenerationMgr.run()");
		initialiseDBConnection(url, username, password);
		createReportInstance(this);
		this.setFileFormatTmp(this.getFileFormat());

		if (this.getFileFormatTmp().contains(ReportConstants.FILE_PDF)) {
			this.setFileFormat(ReportConstants.FILE_PDF);
			reportProcessor.processPdfRecord(this);
		}
		if (this.getFileFormatTmp().contains(ReportConstants.FILE_CSV)) {
			this.setFileFormat(ReportConstants.FILE_CSV);
			reportProcessor.processCsvTxtRecord(this);
		}
		if (this.getFileFormatTmp().contains(ReportConstants.FILE_TXT)) {
			this.setFileFormat(ReportConstants.FILE_TXT);
			reportProcessor.processCsvTxtRecord(this);
		}
	}

	public void initialiseDBConnection(String url, String username, String password) {
		logger.debug("In ReportGenerationMgr.initialiseDBConnection()");
		try {
			connection = DriverManager.getConnection(url, username, password);
			connection.setAutoCommit(false);
		} catch (Exception e) {
			errors++;
			logger.error("Error establishing database connection for reporting - Error: ", e);
		}
	}

	public void exit() {
		logger.debug("In ReportGenerationMgr.exit()");
		try {
			connection.setAutoCommit(true);
		} catch (Exception e) {
			errors++;
			logger.error("Error closing connection: ", e);
		}
	}

	private void createReportInstance(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.createReportInstance()");
		try {
			Class<?> newClass = Class.forName(rgm.getProcessingClass());
			reportProcessor = (IReportProcessor) newClass.newInstance();
		} catch (Exception e) {
			errors++;
			logger.error("Error creating batch processor instance", e);
		}
	}

	public void writeLine(byte[] bytes) throws IOException {
		fileOutputStream.write(bytes);
	}

	public HashMap<String, ReportGenerationFields> getLineFieldsMap(HashMap<String, ReportGenerationFields> fieldsMap)
			throws JSONException {
		HashMap<String, ReportGenerationFields> lineFieldsMap = new HashMap<String, ReportGenerationFields>();
		for (ReportGenerationFields field : fieldsMap.values()) {
			lineFieldsMap.put(field.getFieldName(), field.clone(this));
		}
		return lineFieldsMap;
	}

	public HashMap<String, ReportGenerationFields> getQueryResultStructure(ResultSet rs)
			throws SQLException, JSONException {
		HashMap<String, Column> dynamicColumns = new HashMap<String, Column>();
		HashMap<String, ReportGenerationFields> fieldsMap = new HashMap<String, ReportGenerationFields>();
		ReportGenerationFields tempField;
		ResultSetMetaData metaData = rs.getMetaData();
		for (int i = 1; i <= metaData.getColumnCount(); i++) {
			Column tempColumn = new Column();
			tempColumn.setName(metaData.getColumnName(i));
			String className = metaData.getColumnClassName(i)
					.substring(metaData.getColumnClassName(i).lastIndexOf('.') + 1);
			tempColumn.setType(className);
			dynamicColumns.put(tempColumn.getColumnName(), tempColumn);
			tempField = this.clone(this);
			String name = metaData.getColumnLabel(i);
			tempField.setFieldName(name);
			tempField.setFieldType(className);
			tempField.setSource(metaData.getColumnName(i));
			fieldsMap.put(name, tempField);
		}
		return fieldsMap;
	}
}
