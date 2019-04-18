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
import java.util.Date;
import java.util.HashMap;

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
	public int pagination = 0;

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

	public int getPagination() {
		return pagination;
	}

	public void setPagination(int pagination) {
		this.pagination = pagination;
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
		pagination = 1;
		try {
			doc = new PDDocument();
			PDPage page = new PDPage();
			doc.addPage(page);
			PDPageContentStream contentStream = new PDPageContentStream(doc, page);
			PDFont pdfFont = PDType1Font.COURIER;
			float fontSize = 6;
			float leading = 1.5f * fontSize;
			PDRectangle pageSize = page.getMediaBox();
			float margin = 30;
			float width = pageSize.getWidth() - 2 * margin;
			float startX = pageSize.getLowerLeftX() + margin;
			float startY = pageSize.getUpperRightY() - margin;

			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);
			reportProcessor.writePdfHeader(rgm, contentStream, leading, pagination);
			reportProcessor.writePdfBodyHeader(rgm, contentStream, leading);
			executePdfBodyQuery(doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
			postProcessing(rgm);

			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String txnDate = df.format(rgm.getTxnEndDate());
			if (rgm.getReportCategory().contains(ReportConstants.GL_HANDOFF_FILES)) {
				doc.save(new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + "_" + "001"
						+ ReportConstants.PDF_FORMAT));
			} else {
				doc.save(new File(
						rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.PDF_FORMAT));
			}
			success = 0;
		} catch (IOException | JSONException e) {
			logger.error("Error in generating PDF file", e);
		} finally {
			if (doc != null) {
				try {
					doc.close();
					rgm.exit();
				} catch (IOException e) {
					logger.error("Error in closing PDF file", e);
				}
			}
		}
	}

	private void generateNormalFile() {
		logger.debug("In ReportGenerationMgr.generateNormalFile()");
		File file = null;
		if (this.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_CSV)) {
			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String txnDate = df.format(this.getTxnEndDate());
			if (this.getReportCategory().contains(ReportConstants.GL_HANDOFF_FILES)) {
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
			if (this.getReportCategory().contains(ReportConstants.GL_HANDOFF_FILES)) {
				file = new File(this.getFileLocation() + this.getFileNamePrefix() + "_" + txnDate + "_" + "001"
						+ ReportConstants.TXT_FORMAT);
				glFilesProcessing(file);
			} else {
				file = new File(
						this.getFileLocation() + this.getFileNamePrefix() + "_" + txnDate + ReportConstants.TXT_FORMAT);
				reportsProcessing(file);
			}
		}
		success = 0;
	}

	private void glFilesProcessing(File file) {
		try {
			fileOutputStream = new FileOutputStream(file);
			reportProcessor.preProcessing(this);
			reportProcessor.writeHeader(this);
			reportProcessor.writeBodyHeader(this);
			executeGLBodyQuery();
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
		pagination = 1;
		try {
			fileOutputStream = new FileOutputStream(file);
			reportProcessor.preProcessing(this);
			reportProcessor.writeHeader(this, pagination);
			reportProcessor.writeBodyHeader(this);
			executeReportBodyQuery();
			reportProcessor.postProcessing(this);
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

	private void executeGLBodyQuery() {
		logger.debug("In ReportGenerationMgr.executeGLBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = reportProcessor.getBodyQuery(this);
		logger.info("Query for body line export: {}", query);
		if (query != null && !query.isEmpty()) {
			try {
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
								field.setValue(
										Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
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
					reportProcessor.writeBody(this, lineFieldsMap);
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
	}

	private void executeReportBodyQuery() {
		logger.debug("In ReportGenerationMgr.executeReportBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = reportProcessor.getBodyQuery(this);
		logger.info("Query for body line export: {}", query);
		if (query != null && !query.isEmpty()) {
			try {
				ps = connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = getQueryResultStructure(rs);

				while (rs.next()) {
					if (success > ReportConstants.SUCCESS_THRESHOLD) {
						success = 0;
						pagination++;
						reportProcessor.writeHeader(this, pagination);

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
									field.setValue(
											Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
								} else if (result instanceof oracle.sql.DATE) {
									field.setValue(
											Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
								} else {
									Class clazz = result.getClass();
									field.setValue(result.toString());
								}
							} else {
								field.setValue("");
							}
						}
						reportProcessor.writeBody(this, lineFieldsMap, success, pagination);
						success++;
					} else {
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
									field.setValue(
											Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
								} else if (result instanceof oracle.sql.DATE) {
									field.setValue(
											Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
								} else {
									Class clazz = result.getClass();
									field.setValue(result.toString());
								}
							} else {
								field.setValue("");
							}
						}
						reportProcessor.writeBody(this, lineFieldsMap, success, pagination);
						success++;
					}
				}
				executeTrailerQuery();
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
	}

	private void executePdfBodyQuery(PDDocument doc, PDPageContentStream contentStream, PDRectangle pageSize,
			float leading, float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In ReportGenerationMgr.executePdfBodyLineQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = reportProcessor.getBodyQuery(this);
		logger.info("Query for body line export: {}", query);
		if (query != null && !query.isEmpty()) {
			try {
				ps = connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = getQueryResultStructure(rs);
				lineFieldsMap = getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					if (success > ReportConstants.SUCCESS_THRESHOLD) {
						success = 0;
						PDPage page = new PDPage();
						doc.addPage(page);
						pagination++;
						contentStream.endText();
						contentStream.close();
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
						reportProcessor.writePdfHeader(this, contentStream, leading, pagination);

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
									field.setValue(
											Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
								} else if (result instanceof oracle.sql.DATE) {
									field.setValue(
											Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
								} else {
									Class clazz = result.getClass();
									field.setValue(result.toString());
								}
							} else {
								field.setValue("");
							}
						}
						reportProcessor.writePdfBody(this, lineFieldsMap, contentStream, leading, success, pagination);
						success++;
					} else {
						new StringBuffer();
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
									field.setValue(
											Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
								} else if (result instanceof oracle.sql.DATE) {
									field.setValue(
											Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
								} else {
									Class clazz = result.getClass();
									field.setValue(result.toString());
								}
							} else {
								field.setValue("");
							}
						}
						reportProcessor.writePdfBody(this, lineFieldsMap, contentStream, leading, success, pagination);
						success++;
					}
				}
				executePdfTrailerQuery(doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
				contentStream.endText();
				contentStream.close();
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
	}

	private void postProcessing(ReportGenerationMgr rgm) {
		logger.debug("In ReportGenerationMgr.postProcessing()");
		try {
			reportProcessor.postProcessing(this);
		} catch (Exception e) {
			logger.error("Error trying to do PostProcessing", e);
		}
	}

	private void executeTrailerQuery() {
		logger.debug("In ReportGenerationMgr.executeTrailerLineQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = reportProcessor.getTrailerQuery(this);
		logger.info("Query for trailer line export: {}", query);
		if (query != null && !query.isEmpty()) {
			try {
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
								field.setValue(
										Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
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
	}

	private void executePdfTrailerQuery(PDDocument doc, PDPageContentStream contentStream, PDRectangle pageSize,
			float leading, float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In ReportGenerationMgr.executePdfTrailerLineQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = reportProcessor.getTrailerQuery(this);
		logger.info("Query for trailer line export: {}", query);
		if (query != null && !query.isEmpty()) {
			try {
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
								field.setValue(
										Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
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
					reportProcessor.writePdfTrailer(this, lineFieldsMap, contentStream, leading);
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
	}
}
