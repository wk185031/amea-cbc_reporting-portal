package my.com.mandrill.base.reporting.dcmsControlReport;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
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

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class DCMSControlReport extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(DCMSControlReport.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private static final String EMBOSSED_RECORDS_REPORT_ID_PREFIX = "EMBPINML";
	private static final String PIN_MAILER_REPORT_ID_PREFIX = "EFPINML";
	private static final String EMBOSSED_RECORDS_FILE_NAME_PREFIX = "Control Report for Embossed Records";
		
	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In DCMSControlReport.processPdfRecord(): " + rgm.getFileNamePrefix());
		generateReport(rgm);
	}

	private void generateReport(ReportGenerationMgr rgm) {
		logger.debug("In DCMSControlReport.generateReport(): " + rgm.getFileNamePrefix());
		pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
		totalHeight = PDRectangle.A4.getHeight();
		PDDocument doc = null;
		pagination = 1;

		try {
			preProcessing(rgm);

			doc = new PDDocument();
			PDPage page = new PDPage();
			doc.addPage(page);
			PDPageContentStream contentStream = new PDPageContentStream(doc, page);
			PDFont pdfFont = PDType1Font.COURIER;
			float fontSize = 6;
			float leading = 1.5f * fontSize;
			PDRectangle pageSize = page.getMediaBox();
			float margin = 30;
			float startX = pageSize.getLowerLeftX() + margin;
			float startY = pageSize.getUpperRightY() - margin;

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			writePdfHeader(rgm, contentStream, leading, pagination);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;

			contentStream.newLineAtOffset(0, -leading);
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
					startY, pdfFont, fontSize);
			pageHeight += 1;

			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;

			writePdfTrailer(rgm, null, contentStream, leading);

			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;

			contentStream.endText();
			contentStream.close();

			saveFile(rgm, doc);
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
		} finally {
			if (doc != null) {
				try {
					doc.close();
					rgm.exit();
				} catch (IOException e) {
					rgm.errors++;
					logger.error("Error in closing PDF file", e);
				}
			}
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In DCMSControlReport.generateReport(): " + rgm.getFileNamePrefix());
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					if (pageHeight > totalHeight) {
						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
						contentStream.endText();
						contentStream.close();
						page = new PDPage();
						doc.addPage(page);
						pagination++;
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
					}

					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
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
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writePdfBody(rgm, lineFieldsMap, contentStream, leading);
					pageHeight++;
				}
				contentStream.newLineAtOffset(0, -leading);
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				try {
					ps.close();
					rs.close();
				} catch (SQLException e) {
					rgm.errors++;
					logger.error("Error closing DB resources", e);
				}
			}
		}
		return contentStream;
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In DCMSControlReport.preProcessing():" + rgm.getFileNamePrefix());
		
		// replace {From_Date}/{To_Date}/{DCMS_Schema}/{Iss_Name} to actual value
		rgm.setBodyQuery(rgm.getBodyQuery()
				.replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + rgm.getTxnStartDate().atStartOfDay().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
				.replace("{" + ReportConstants.PARAM_TO_DATE + "}", "'" + rgm.getTxnEndDate().atTime(LocalTime.MAX).format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
				.replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA+ "}", rgm.getDcmsDbSchema())
				.replace("{" + ReportConstants.PARAM_ISSUER_NAME+ "}", rgm.getInstitution().equals("CBC") ? ReportConstants.DCMS_CBC_INSTITUTION : ReportConstants.DCMS_CBS_INSTITUTION));

		// add report id to global map
		ReportGenerationFields reportId = new ReportGenerationFields(ReportConstants.REPORT_ID,
				ReportGenerationFields.TYPE_STRING, 
				((rgm.getFileNamePrefix().equals(EMBOSSED_RECORDS_FILE_NAME_PREFIX) ? EMBOSSED_RECORDS_REPORT_ID_PREFIX : PIN_MAILER_REPORT_ID_PREFIX) 
						+ LocalDateTime.now().format(DateTimeFormatter.ofPattern("MMdd"))));
		getGlobalFileFieldsMap().put(reportId.getFieldName(), reportId);
		
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			preProcessing(rgm);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			writeTrailer(rgm, null);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | InstantiationException | IllegalAccessException | ClassNotFoundException | JSONException e) {
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
}
