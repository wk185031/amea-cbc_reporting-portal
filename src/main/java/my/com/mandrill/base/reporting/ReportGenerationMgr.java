package my.com.mandrill.base.reporting;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ReportGenerationMgr extends ReportGenerationFields {

	private final Logger logger = LoggerFactory.getLogger(ReportGenerationMgr.class);
	public IReportProcessor reportProcessor;
	public Connection connection;
	public FileOutputStream fileOutputStream;
	public int success = 0;
	public int errors = 0;

	public int getSuccess() {
		return success;
	}

	public void setSuccess(int success) {
		this.success = success;
	}

	public int getErrors() {
		return errors;
	}

	public void setErrors(int errors) {
		this.errors = errors;
	}

	public void run(String url, String username, String password) {
		logger.debug("In ReportGenerationMgr.run()");
		initialiseDBConnection(url, username, password);
		createReportInstance(this);
		this.setFileFormatTmp(this.getFileFormat());

		if (this.getFileFormatTmp().contains(ReportConstants.FILE_PDF)) {
			this.setFileFormat(ReportConstants.FILE_PDF);
			generatePdfFile(this);
		}
		if (this.getFileFormatTmp().contains(ReportConstants.FILE_CSV)) {
			this.setFileFormat(ReportConstants.FILE_CSV);
			generateNormalFile();
		}
		if (this.getFileFormatTmp().contains(ReportConstants.FILE_TXT)) {
			this.setFileFormat(ReportConstants.FILE_TXT);
			generateNormalFile();
		}
	}

	public void initialiseDBConnection(String url, String username, String password) {
		logger.debug("In ReportGenerationMgr.initialiseDBConnection()");
		try {
			connection = DriverManager.getConnection(url, username, password);
			connection.setAutoCommit(false);
		} catch (Exception e) {
			logger.error("Error establishing database connection for reporting - Error: ", e);
		}
	}

	public void exit() {
		logger.debug("In ReportGenerationMgr.exit()");
		try {
			connection.setAutoCommit(true);
		} catch (Exception e) {
			logger.error("Error closing connection: ", e);
		}
	}

	private void createReportInstance(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.createReportInstance()");
		try {
			Class<?> newClass = Class.forName(rgm.getProcessingClass());
			reportProcessor = (IReportProcessor) newClass.newInstance();
		} catch (Exception e) {
			logger.error("Error creating batch processor instance", e);
		}
	}

	public void writeLine(byte[] bytes) throws IOException {
		fileOutputStream.write(bytes);
	}

	private void generatePdfFile(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.generatePdfFile()");
		PDDocument doc = null;
		try {
			doc = new PDDocument();
			PDPage page = new PDPage();
			doc.addPage(page);
			PDPageContentStream contentStream = new PDPageContentStream(doc, page);
			PDFont pdfFont = PDType1Font.TIMES_ROMAN;
			float fontSize = 6;
			float leading = 1.5f * fontSize;
			PDRectangle mediabox = page.getMediaBox();
			float margin = 35;
			float width = mediabox.getWidth() - 2 * margin;
			float startX = mediabox.getLowerLeftX() + margin;
			float startY = mediabox.getUpperRightY() - margin;

			preProcessing(this);
			postProcessing(this);

			List<String> printHeaderLine = printHeaderLine(this, pdfFont, fontSize, leading, margin, width, startX,
					startY);
			List<String> printBodyHeaderLine = printBodyHeaderLine(this, pdfFont, fontSize, leading, margin, width,
					startX, startY);
			List<String> printBodyLine = printBodyLine(this, pdfFont, fontSize, leading, margin, width, startX, startY);
			List<String> printTrailerLine = printTrailerLine(this, pdfFont, fontSize, leading, margin, width, startX,
					startY);

			contentStream.beginText();
			contentStream.setFont(pdfFont, fontSize);
			contentStream.newLineAtOffset(startX, startY - 1);

			for (String headerLine : printHeaderLine) {
				contentStream.showText(headerLine);
				contentStream.newLineAtOffset(0, -leading);
			}
			for (String bodyHeaderLine : printBodyHeaderLine) {
				contentStream.showText(bodyHeaderLine);
				contentStream.newLineAtOffset(0, -leading);
			}
			for (String bodyLine : printBodyLine) {
				contentStream.showText(bodyLine);
				contentStream.newLineAtOffset(0, -leading);
			}
			for (String trailerLine : printTrailerLine) {
				contentStream.showText(trailerLine);
				contentStream.newLineAtOffset(0, -leading);
			}
			contentStream.endText();
			contentStream.close();

			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String txnDate = df.format(this.getTxnEndDate());
			if (this.getReportCategory().contains("GL")) {
				doc.save(new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + "_" + "001"
						+ ReportConstants.PDF_FORMAT));
			} else {
				doc.save(new File(
						rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.PDF_FORMAT));
			}
		} catch (IOException e) {
			logger.error("Error in generating PDF file", e);
		} finally {
			if (doc != null) {
				try {
					doc.close();
					exit();
				} catch (IOException e) {
					logger.error("Error in closing PDF file", e);
				}
			}
		}

		logger.debug("The number of successfully exported items is {} ", success);
		logger.debug("The number of errors during the export process is {}", errors);
	}

	private void generateNormalFile() {
		logger.debug("In ReportGenerationMgr.generateNormalFile()");
		File file = null;
		if (this.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_CSV)) {
			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String txnDate = df.format(this.getTxnEndDate());
			if (this.getReportCategory().contains("GL")) {
				file = new File(this.getFileLocation() + this.getFileNamePrefix() + "_" + txnDate + "_" + "001"
						+ ReportConstants.CSV_FORMAT);
				glFilesProcessing(file);
			} else {
				file = new File(
						this.getFileLocation() + this.getFileNamePrefix() + "_" + txnDate + ReportConstants.CSV_FORMAT);
				reportsProcessing(file);
			}
		}
		if (this.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_TXT)) {
			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String txnDate = df.format(this.getTxnEndDate());
			if (this.getReportCategory().contains("GL")) {
				file = new File(this.getFileLocation() + this.getFileNamePrefix() + "_" + txnDate + "_" + "001"
						+ ReportConstants.TXT_FORMAT);
				glFilesProcessing(file);
			} else {
				file = new File(
						this.getFileLocation() + this.getFileNamePrefix() + "_" + txnDate + ReportConstants.TXT_FORMAT);
				reportsProcessing(file);
			}
		}

		logger.debug("The number of successfully exported items is {} ", success);
		logger.debug("The number of errors during the export process is {}", errors);
	}

	private void glFilesProcessing(File file) {
		try {
			fileOutputStream = new FileOutputStream(file);
			reportProcessor.preProcessing(this);
			reportProcessor.writeHeader(this);
			reportProcessor.writeBodyHeaderLine(this);
			executeBodyLineQuery();
			reportProcessor.postProcessing(this);
			reportProcessor.writeTrailer(this);
			fileOutputStream.flush();
			fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			logger.error("Error in generating GL file", e);
		} finally {
			try {
				if (fileOutputStream != null) {
					fileOutputStream.close();
					exit();
				}
			} catch (IOException e) {
				logger.error("Error in closing fileOutputStream", e);
			}
		}
	}

	private void reportsProcessing(File file) {
		try {
			fileOutputStream = new FileOutputStream(file);
			reportProcessor.preProcessing(this);
			reportProcessor.writeHeader(this);
			reportProcessor.writeBodyHeaderLine(this);
			executeBodyLineQuery();
			reportProcessor.postProcessing(this);
			executeTrailerLineQuery();
			fileOutputStream.flush();
			fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			logger.error("Error in generating CSV/TXT file", e);
		} finally {
			try {
				if (fileOutputStream != null) {
					fileOutputStream.close();
					exit();
				}
			} catch (IOException e) {
				logger.error("Error in closing fileOutputStream", e);
			}
		}
	}

	private HashMap<String, ReportGenerationFields> getLineFieldsMap(HashMap<String, ReportGenerationFields> fieldsMap)
			throws JSONException {
		HashMap<String, ReportGenerationFields> lineFieldsMap = new HashMap<String, ReportGenerationFields>();
		for (ReportGenerationFields field : fieldsMap.values()) {
			lineFieldsMap.put(field.getFieldName(), field.clone(this));
		}
		return lineFieldsMap;
	}

	private HashMap<String, ReportGenerationFields> getQueryResultStructure(ResultSet rs)
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

	private void preProcessing(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.preProcessing()");
		try {
			reportProcessor.preProcessing(this);
		} catch (Exception e) {
			logger.error("Error trying to do PreProcessing", e);
		}
	}

	private String writePdfHeader(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.writePdfHeader()");
		String headerLine = "";
		try {
			headerLine = reportProcessor.writePdfHeader(rgm);
		} catch (Exception e) {
			logger.error("Error trying to write the header", e);
		}
		return headerLine;
	}

	private String writePdfBodyHeader(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.writePdfBodyHeader()");
		String bodyHeaderLine = "";
		try {
			bodyHeaderLine = reportProcessor.writePdfBodyHeaderLine(rgm);
		} catch (Exception e) {
			logger.error("Error trying to write the header", e);
		}
		return bodyHeaderLine;
	}

	private void executeBodyLineQuery() {
		logger.debug("In ReportGenerationMgr.executeBodyLineQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		try {
			String query = reportProcessor.getQuery(this);
			logger.info("Query for body line export: {}", query);
			ps = connection.prepareStatement(query);
			rs = ps.executeQuery();
			fieldsMap = getQueryResultStructure(rs);

			while (rs.next()) {
				new StringBuffer();
				lineFieldsMap = getLineFieldsMap(fieldsMap);
				for (String key : lineFieldsMap.keySet()) {
					ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
					Object result;
					try {
						result = rs.getObject(field.getSource());
					} catch (SQLException e) {
						errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}
					if (result != null) {
						if (result instanceof Date) {
							field.setValue(Long.toString(((Date) result).getTime()));
						} else if (result instanceof oracle.sql.TIMESTAMP) {
							field.setValue(Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
						} else if (result instanceof oracle.sql.DATE) {
							field.setValue(Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
						} else {
							Class clazz = result.getClass();
							field.setValue(result.toString());
						}
					} else {
						field.setValue("");
					}
				}
				reportProcessor.writeBodyLine(this, lineFieldsMap);
				success++;
			}
		} catch (Exception e) {
			logger.error("Error trying to execute the body line export query", e);
		} finally {
			try {
				ps.close();
				rs.close();
			} catch (SQLException e) {
				logger.error("Error closing DB resources", e);
			}
		}
	}

	private String executePdfBodyLineQuery() {
		logger.debug("In ReportGenerationMgr.executePdfBodyLineQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		try {
			String query = reportProcessor.getQuery(this);
			logger.info("Query for body line export: {}", query);
			ps = connection.prepareStatement(query);
			rs = ps.executeQuery();
			fieldsMap = getQueryResultStructure(rs);

			while (rs.next()) {
				new StringBuffer();
				lineFieldsMap = getLineFieldsMap(fieldsMap);
				for (String key : lineFieldsMap.keySet()) {
					ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
					Object result;
					try {
						result = rs.getObject(field.getSource());
					} catch (SQLException e) {
						errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}
					if (result != null) {
						if (result instanceof Date) {
							field.setValue(Long.toString(((Date) result).getTime()));
						} else if (result instanceof oracle.sql.TIMESTAMP) {
							field.setValue(Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
						} else if (result instanceof oracle.sql.DATE) {
							field.setValue(Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
						} else {
							Class clazz = result.getClass();
							field.setValue(result.toString());
						}
					} else {
						field.setValue("");
					}
				}
				writePdfBody(this, lineFieldsMap);
				success++;
			}
		} catch (Exception e) {
			logger.error("Error trying to execute the body line export query", e);
		} finally {
			try {
				ps.close();
				rs.close();
			} catch (SQLException e) {
				logger.error("Error closing DB resources", e);
			}
		}
		return writePdfBody(this, lineFieldsMap);
	}

	private String writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> lineFieldsMap) {
		logger.debug("In ReportGenerationMgr.writePdfBody()");
		String bodyLine = "";
		try {
			bodyLine = reportProcessor.writePdfBodyLine(rgm, lineFieldsMap);
		} catch (Exception e) {
			errors++;
			logger.error("An error was encountered when trying to write a line", e);
		}
		return bodyLine;
	}

	private void postProcessing(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.postProcessing()");
		try {
			reportProcessor.postProcessing(this);
		} catch (Exception e) {
			logger.error("Error trying to do PostProcessing", e);
		}
	}

	private void executeTrailerLineQuery() {
		logger.debug("In ReportGenerationMgr.executeTrailerLineQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		try {
			String query = reportProcessor.getQuery(this);
			// logger.info("\t\t Query for trailer line export: {}", query);
			ps = connection.prepareStatement(query);
			rs = ps.executeQuery();
			fieldsMap = getQueryResultStructure(rs);

			while (rs.next()) {
				new StringBuffer();
				lineFieldsMap = getLineFieldsMap(fieldsMap);
				for (String key : lineFieldsMap.keySet()) {
					ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
					Object result;
					try {
						result = rs.getObject(field.getSource());
					} catch (SQLException e) {
						errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}
					if (result != null) {
						if (result instanceof Date) {
							field.setValue(Long.toString(((Date) result).getTime()));
						} else if (result instanceof oracle.sql.TIMESTAMP) {
							field.setValue(Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
						} else if (result instanceof oracle.sql.DATE) {
							field.setValue(Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
						} else {
							Class clazz = result.getClass();
							field.setValue(result.toString());
						}
					} else {
						field.setValue("");
					}
				}
				reportProcessor.writeTrailer(this, lineFieldsMap);
				success++;
			}
		} catch (Exception e) {
			logger.error("Error trying to execute the export query ", e);
		} finally {
			try {
				ps.close();
				rs.close();
			} catch (SQLException e) {
				logger.error("Error closing DB resources", e);
			}
		}
	}

	private String executePdfTrailerLineQuery() {
		logger.debug("In ReportGenerationMgr.executePdfTrailerLineQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		try {
			String query = reportProcessor.getQuery(this);
			// logger.info("\t\t Query for trailer line export: {}", query);
			ps = connection.prepareStatement(query);
			rs = ps.executeQuery();
			fieldsMap = getQueryResultStructure(rs);

			while (rs.next()) {
				new StringBuffer();
				lineFieldsMap = getLineFieldsMap(fieldsMap);
				for (String key : lineFieldsMap.keySet()) {
					ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
					Object result;
					try {
						result = rs.getObject(field.getSource());
					} catch (SQLException e) {
						errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}
					if (result != null) {
						if (result instanceof Date) {
							field.setValue(Long.toString(((Date) result).getTime()));
						} else if (result instanceof oracle.sql.TIMESTAMP) {
							field.setValue(Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
						} else if (result instanceof oracle.sql.DATE) {
							field.setValue(Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
						} else {
							Class clazz = result.getClass();
							field.setValue(result.toString());
						}
					} else {
						field.setValue("");
					}
				}
				writePdfTrailer(this, lineFieldsMap);
				success++;
			}
		} catch (Exception e) {
			logger.error("Error trying to execute the export query ", e);
		} finally {
			try {
				ps.close();
				rs.close();
			} catch (SQLException e) {
				logger.error("Error closing DB resources", e);
			}
		}
		return writePdfTrailer(this, lineFieldsMap);
	}

	private String writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> lineFieldsMap) {
		logger.debug("In ReportGenerationMgr.writePdfTrailer()");
		String trailerLine = "";
		try {
			trailerLine = reportProcessor.writePdfTrailer(rgm, lineFieldsMap);
		} catch (Exception e) {
			errors++;
			logger.error("An error was encountered when trying to write a line", e);
		}
		return trailerLine;
	}

	private List<String> printHeaderLine(ReportGenerationMgr rgm, PDFont pdfFont, float fontSize, float leading,
			float margin, float width, float startX, float startY) {
		logger.debug("In ReportGenerationMgr.printHeaderLine()");
		List<String> lines = new ArrayList<String>();
		try {
			String headerLine = writePdfHeader(rgm);
			int lastSpace = -1;
			while (headerLine.length() > 0) {
				int spaceIndex = headerLine.indexOf(' ', lastSpace + 1);
				if (spaceIndex < 0) {
					spaceIndex = headerLine.length();
				}
				String subString = headerLine.substring(0, spaceIndex);
				float size = fontSize * pdfFont.getStringWidth(subString) / 1000;
				// System.out.printf("'%s' - %f of %f\n", subString, size, width);
				if (size > width) {
					if (lastSpace < 0) {
						lastSpace = spaceIndex;
					}
					subString = headerLine.substring(0, lastSpace);
					lines.add(subString);
					headerLine = headerLine.substring(lastSpace).trim();
					// System.out.printf("'%s' is line\n", subString);
					lastSpace = -1;
				} else if (spaceIndex == headerLine.length()) {
					lines.add(headerLine);
					// System.out.printf("'%s' is line\n", headerLine);
					headerLine = "";
				} else {
					lastSpace = spaceIndex;
				}
			}
		} catch (IOException e) {
			logger.error("Error printing header line for PDF", e);
		}
		return lines;
	}

	private List<String> printBodyHeaderLine(ReportGenerationMgr rgm, PDFont pdfFont, float fontSize, float leading,
			float margin, float width, float startX, float startY) {
		logger.debug("In ReportGenerationMgr.printBodyHeaderLine()");
		List<String> lines = new ArrayList<String>();
		try {
			String bodyHeaderLine = writePdfBodyHeader(rgm);
			int lastSpace = -1;
			while (bodyHeaderLine.length() > 0) {
				int spaceIndex = bodyHeaderLine.indexOf(' ', lastSpace + 1);
				if (spaceIndex < 0) {
					spaceIndex = bodyHeaderLine.length();
				}
				String subString = bodyHeaderLine.substring(0, spaceIndex);
				float size = fontSize * pdfFont.getStringWidth(subString) / 1000;
				// System.out.printf("'%s' - %f of %f\n", subString, size, width);
				if (size > width) {
					if (lastSpace < 0) {
						lastSpace = spaceIndex;
					}
					subString = bodyHeaderLine.substring(0, lastSpace);
					lines.add(subString);
					bodyHeaderLine = bodyHeaderLine.substring(lastSpace).trim();
					// System.out.printf("'%s' is line\n", subString);
					lastSpace = -1;
				} else if (spaceIndex == bodyHeaderLine.length()) {
					lines.add(bodyHeaderLine);
					// System.out.printf("'%s' is line\n", bodyHeaderLine);
					bodyHeaderLine = "";
				} else {
					lastSpace = spaceIndex;
				}
			}
		} catch (IOException e) {
			logger.error("Error printing body header line for PDF", e);
		}
		return lines;
	}

	private List<String> printBodyLine(ReportGenerationMgr rgm, PDFont pdfFont, float fontSize, float leading,
			float margin, float width, float startX, float startY) {
		logger.debug("In ReportGenerationMgr.printBodyLine()");
		List<String> lines = new ArrayList<String>();
		try {
			String bodyLine = executePdfBodyLineQuery();
			int lastSpace = -1;
			while (bodyLine.length() > 0) {
				int spaceIndex = bodyLine.indexOf(' ', lastSpace + 1);
				if (spaceIndex < 0) {
					spaceIndex = bodyLine.length();
				}
				String subString = bodyLine.substring(0, spaceIndex);
				float size = fontSize * pdfFont.getStringWidth(subString) / 1000;
				// System.out.printf("'%s' - %f of %f\n", subString, size, width);
				if (size > width) {
					if (lastSpace < 0) {
						lastSpace = spaceIndex;
					}
					subString = bodyLine.substring(0, lastSpace);
					lines.add(subString);
					bodyLine = bodyLine.substring(lastSpace).trim();
					// System.out.printf("'%s' is line\n", subString);
					lastSpace = -1;
				} else if (spaceIndex == bodyLine.length()) {
					lines.add(bodyLine);
					// System.out.printf("'%s' is line\n", bodyLine);
					bodyLine = "";
				} else {
					lastSpace = spaceIndex;
				}
			}
		} catch (IOException e) {
			logger.error("Error printing body line for PDF", e);
		}
		return lines;
	}

	private List<String> printTrailerLine(ReportGenerationMgr rgm, PDFont pdfFont, float fontSize, float leading,
			float margin, float width, float startX, float startY) {
		logger.debug("In ReportGenerationMgr.printTrailerLine()");
		List<String> lines = new ArrayList<String>();
		try {
			String trailerLine = executePdfTrailerLineQuery();
			int lastSpace = -1;
			while (trailerLine.length() > 0) {
				int spaceIndex = trailerLine.indexOf(' ', lastSpace + 1);
				if (spaceIndex < 0) {
					spaceIndex = trailerLine.length();
				}
				String subString = trailerLine.substring(0, spaceIndex);
				float size = fontSize * pdfFont.getStringWidth(subString) / 1000;
				// System.out.printf("'%s' - %f of %f\n", subString, size, width);
				if (size > width) {
					if (lastSpace < 0) {
						lastSpace = spaceIndex;
					}
					subString = trailerLine.substring(0, lastSpace);
					lines.add(subString);
					trailerLine = trailerLine.substring(lastSpace).trim();
					// System.out.printf("'%s' is line\n", subString);
					lastSpace = -1;
				} else if (spaceIndex == trailerLine.length()) {
					lines.add(trailerLine);
					// System.out.printf("'%s' is line\n", trailerLine);
					trailerLine = "";
				} else {
					lastSpace = spaceIndex;
				}
			}
		} catch (IOException e) {
			logger.error("Error printing trailer line for PDF", e);
		}
		return lines;
	}
}
