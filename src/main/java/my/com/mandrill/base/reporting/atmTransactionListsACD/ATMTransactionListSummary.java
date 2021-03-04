package my.com.mandrill.base.reporting.atmTransactionListsACD;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class ATMTransactionListSummary extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ATMTransactionListSummary.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;

	@Override
	public void executePdf(ReportGenerationMgr rgm) {
		logger.debug("In ATMTransactionListSummary.processPdfRecord()");
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
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			writePdfHeader(rgm, contentStream, leading, pagination);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;

			rgm.setBodyQuery(getOnUsBodyQuery());
			rgm.setTrailerQuery(getOnUsTrailerQuery());
			contentStream.showText("FROM ONUS TRANSACTIONS");
			pdfProcessingDetails(rgm, doc, page, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);

			rgm.setBodyQuery(getAcqBodyQuery());
			rgm.setTrailerQuery(getAcqTrailerQuery());
			contentStream.showText("FROM ACQUIRER TRANSACTIONS");
			pdfProcessingDetails(rgm, doc, page, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);

			rgm.setBodyQuery(getIssBodyQuery());
			rgm.setTrailerQuery(getIssTrailerQuery());
			contentStream.showText("FROM ISSUER TRANSACTIONS");
			pdfProcessingDetails(rgm, doc, page, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);

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

	private void pdfProcessingDetails(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In ATMTransactionListSummary.pdfProcessingDetails()");
		try {
			contentStream.newLineAtOffset(0, -leading);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 2;
			writePdfBodyHeader(rgm, contentStream, leading);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 3;
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize);
			pageHeight += 1;
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
			pageHeight += 1;
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Errors in pdfProcessingDetails", e);
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		StringBuilder onUsLine = new StringBuilder();
		StringBuilder issLine = new StringBuilder();
		StringBuilder acqLine = new StringBuilder();

		try {
			pagination++;
			rgm.fileOutputStream = new FileOutputStream(file);
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			preProcessing(rgm);
			separateQuery(rgm);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm, pagination);

			rgm.setBodyQuery(getOnUsBodyQuery());
			rgm.setTrailerQuery(getOnUsTrailerQuery());
			onUsLine.append("FROM ONUS TRANSACTIONS").append(";");
			onUsLine.append(getEol());
			rgm.writeLine(onUsLine.toString().getBytes());
			processingDetails(rgm);

			rgm.setBodyQuery(getAcqBodyQuery());
			rgm.setTrailerQuery(getAcqTrailerQuery());
			acqLine.append("FROM ACQUIRER TRANSACTIONS").append(";");
			acqLine.append(getEol());
			rgm.writeLine(acqLine.toString().getBytes());
			processingDetails(rgm);

			rgm.setBodyQuery(getIssBodyQuery());
			rgm.setTrailerQuery(getIssTrailerQuery());
			issLine.append("FROM ISSUER TRANSACTIONS").append(";");
			issLine.append(getEol());
			rgm.writeLine(issLine.toString().getBytes());
			processingDetails(rgm);

			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException| JSONException e) {
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

	private void processingDetails(ReportGenerationMgr rgm) {
		logger.debug("In ATMTransactionListSummary.processingDetails()");
		try {
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Errors in processingDetails", e);
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ATMTransactionListSummary.preProcessing()");

		if (rgm.getBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_DEO_NAME + "}", "AND TXN.TRL_DEO_NAME = '" + rgm.getInstitution() + "'")
					.replace("AND {" + ReportConstants.PARAM_ISSUER_NAME + "}", "AND TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"));

		}
		if (rgm.getTrailerQuery() != null) {
			rgm.setTrailerQuery(rgm.getTrailerQuery().replace("AND {" + ReportConstants.PARAM_DEO_NAME + "}", "AND TXN.TRL_DEO_NAME = '" + rgm.getInstitution() + "'")
					.replace("AND {" + ReportConstants.PARAM_ISSUER_NAME + "}", "AND TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"));
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In ATMTransactionListSummary.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setOnUsBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", "AND TXN.TRL_ISS_NAME IS NOT NULL"));
			setAcqBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", "AND TXN.TRL_ISS_NAME IS NULL"));
			setIssBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
		if (rgm.getTrailerQuery() != null) {
			setOnUsTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),a
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", "AND TXN.TRL_ISS_NAME IS NOT NULL"));
			setAcqTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", "AND TXN.TRL_ISS_NAME IS NULL"));
			setIssTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In ATMTransactionListSummary.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getGlobalFieldValue(rgm, field));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.isFirstField()) {
					contentStream.showText(String.format("%1$2s", "") + getGlobalFieldValue(rgm, field));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
			}
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In ATMTransactionListSummary.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
				break;
			default:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In ATMTransactionListSummary.execute()");
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
}
