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

import my.com.mandrill.base.reporting.reportProcessor.ICsvReportProcessor;
import my.com.mandrill.base.reporting.reportProcessor.IPdfReportProcessor;
import my.com.mandrill.base.reporting.reportProcessor.ITxtReportProcessor;

public class ReportGenerationMgr extends ReportGenerationFields {

	private final Logger logger = LoggerFactory.getLogger(ReportGenerationMgr.class);
	public IPdfReportProcessor pdfReportProcessor;
	public ICsvReportProcessor csvReportProcessor;
	public ITxtReportProcessor txtReportProcessor;
	public Connection connection;
	public FileOutputStream fileOutputStream;
	public int errors = 0;
	private String fixBodyQuery;
	private String fixTrailerQuery;

	public String getFixBodyQuery() {
		return fixBodyQuery;
	}

	public void setFixBodyQuery(String fixBodyQuery) {
		this.fixBodyQuery = fixBodyQuery;
	}

	public String getFixTrailerQuery() {
		return fixTrailerQuery;
	}

	public void setFixTrailerQuery(String fixTrailerQuery) {
		this.fixTrailerQuery = fixTrailerQuery;
	}

	public void run(String url, String username, String password) {
		logger.debug("In ReportGenerationMgr.run()");
		errors = 0;
		this.setFileFormatTmp(this.getFileFormat());
		setFixBodyQuery(getBodyQuery());
		setFixTrailerQuery(getTrailerQuery());

		if (this.getFileFormatTmp().contains(ReportConstants.FILE_PDF)) {
			initialiseDBConnection(url, username, password);
			this.setFileFormat(ReportConstants.FILE_PDF);
			createPdfReportInstance(this);
			pdfReportProcessor.processPdfRecord(this);
		}
		if (this.getFileFormatTmp().contains(ReportConstants.FILE_CSV)) {
			initialiseDBConnection(url, username, password);
			this.setFileFormat(ReportConstants.FILE_CSV);
			createCsvReportInstance(this);
			csvReportProcessor.processCsvRecord(this);
		}
		if (this.getFileFormatTmp().contains(ReportConstants.FILE_TXT)) {
			initialiseDBConnection(url, username, password);
			this.setFileFormat(ReportConstants.FILE_TXT);
			createTxtReportInstance(this);
			txtReportProcessor.processTxtRecord(this);
		}
	}

	public void initialiseDBConnection(String url, String username, String password) {
		logger.debug("In ReportGenerationMgr.initialiseDBConnection()");
		try {
			connection = DriverManager.getConnection(url, username, password);
			connection.setAutoCommit(false);
		} catch (Exception e) {
			errors++;
			logger.error("Error in establishing database connection: ", e);
		}
	}

	public void exit() {
		logger.debug("In ReportGenerationMgr.exit()");
		try {
			connection.setAutoCommit(true);
			if (connection != null) {
				logger.debug("Close db connection...");
				connection.close();
			}
		} catch (Exception e) {
			errors++;
			logger.error("Error in closing connection: ", e);
		}
	}

	private void createPdfReportInstance(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.createPdfReportInstance()");
		try {
			Class<?> newClass = Class.forName(rgm.getProcessingClass());
			pdfReportProcessor = (IPdfReportProcessor) newClass.newInstance();
		} catch (Exception e) {
			errors++;
			logger.error("Error creating pdf report instance", e);
		}
	}

	private void createCsvReportInstance(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.createCsvReportInstance()");
		try {
			Class<?> newClass = Class.forName(rgm.getProcessingClass());
			csvReportProcessor = (ICsvReportProcessor) newClass.newInstance();
		} catch (Exception e) {
			errors++;
			logger.error("Error creating csv report instance", e);
		}
	}

	private void createTxtReportInstance(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.createTxtReportInstance()");
		try {
			Class<?> newClass = Class.forName(rgm.getProcessingClass());
			txtReportProcessor = (ITxtReportProcessor) newClass.newInstance();
		} catch (Exception e) {
			errors++;
			logger.error("Error creating txt report instance", e);
		}
	}

	public void writeLine(byte[] bytes) throws IOException {
		fileOutputStream.write(bytes);
	}

	public HashMap<String, ReportGenerationFields> getLineFieldsMap(HashMap<String, ReportGenerationFields> fieldsMap)
			throws JSONException {
		HashMap<String, ReportGenerationFields> lineFieldsMap = new HashMap<String, ReportGenerationFields>();
		for (ReportGenerationFields field : fieldsMap.values()) {
			lineFieldsMap.put(field.getFieldName(), field.clone());
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
			tempField = this.clone();
			String name = metaData.getColumnLabel(i);
			tempField.setFieldName(name);
			tempField.setFieldType(className);
			tempField.setSource(metaData.getColumnName(i));
			fieldsMap.put(name, tempField);
		}
		return fieldsMap;
	}
}
