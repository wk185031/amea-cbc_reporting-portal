package my.com.mandrill.base.reporting.cashCardReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

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

public class CashCardDailyTransaction extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(CashCardDailyTransaction.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private final static int ACCOUNT_NAME_MAX_LENGTH = 32;

	@Override
	public void executePdf(ReportGenerationMgr rgm) {
		logger.debug("In CashCardDailyTransaction.processPdfRecord()");
		PDDocument doc = null;
		PDPage page = null;
		PDPageContentStream contentStream = null;
		pagination = 0;
		try {
			doc = new PDDocument();
			preProcessing(rgm);

			if (!executeQuery(rgm)) {
				page = new PDPage();
				doc.addPage(page);
				contentStream = new PDPageContentStream(doc, page);
				PDFont pdfFont = PDType1Font.COURIER;
				float fontSize = 6;
				PDRectangle pageSize = page.getMediaBox();
				float margin = 30;
				float width = pageSize.getWidth() - 2 * margin;
				float startX = pageSize.getLowerLeftX() + margin;
				float startY = pageSize.getUpperRightY() - margin;
				contentStream.setFont(pdfFont, fontSize);
				contentStream.beginText();
				contentStream.newLineAtOffset(startX, startY);
				contentStream.endText();
				contentStream.close();
				saveFile(rgm, doc);
			} else {
				for (String cardProduct : filterByCardProduct(rgm)) {
					pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
					page = new PDPage();
					doc.addPage(page);
					pagination++;
					contentStream = new PDPageContentStream(doc, page);
					PDFont pdfFont = PDType1Font.COURIER;
					float fontSize = 6;
					float leading = 1.5f * fontSize;
					PDRectangle pageSize = page.getMediaBox();
					float margin = 30;
					float width = pageSize.getWidth() - 2 * margin;
					float startX = pageSize.getLowerLeftX() + margin;
					float startY = pageSize.getUpperRightY() - margin;

					contentStream.setFont(pdfFont, fontSize);
					contentStream.beginText();
					contentStream.newLineAtOffset(startX, startY);

					writePdfHeader(rgm, contentStream, leading, pagination, cardProduct);
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 4;
					contentStream.newLineAtOffset(0, -leading);
					writePdfBodyHeader(rgm, contentStream, leading);
					pageHeight += 2;
					preProcessing(rgm, cardProduct);
					contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
							startY, pdfFont, fontSize);
					pageHeight += 1;
					contentStream.endText();
					contentStream.close();
				}
				saveFile(rgm, doc);
			}
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

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			preProcessing(rgm);

			for (String cardProduct : filterByCardProduct(rgm)) {
				StringBuilder line = new StringBuilder();
				pagination++;
				writeHeader(rgm, pagination, cardProduct);
				writeBodyHeader(rgm);
				preProcessing(rgm, cardProduct);
				executeBodyQuery(rgm);
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
			}
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

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In CashCardDailyTransaction.execute()");
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
		logger.debug("In CashCardDailyTransaction.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_CARD_PRODUCT + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByCardProduct)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In CashCardDailyTransaction.preProcessing()");
		if (filterByCardProduct != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields cardProduct = new ReportGenerationFields(ReportConstants.PARAM_CARD_PRODUCT,
					ReportGenerationFields.TYPE_STRING, "CPD.CPD_NAME = '" + filterByCardProduct + "'");
			getGlobalFileFieldsMap().put(cardProduct.getFieldName(), cardProduct);
		}
	}

	protected void writeHeader(ReportGenerationMgr rgm, int pagination, String cardProduct)
			throws IOException, JSONException {
		logger.debug("In CashCardDailyTransaction.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					line.append(String.valueOf(pagination));
				} else {
					line.append(getGlobalFieldValue(rgm, field));
				}
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.CARD_PRODUCT)) {
					line.append(cardProduct);
				} else {
					line.append(getGlobalFieldValue(rgm, field));
				}
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writePdfHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading,
			int pagination, String cardProduct) throws IOException, JSONException {
		logger.debug("In CashCardDailyTransaction.writePdfHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					contentStream.showText(String.valueOf(pagination));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.CARD_PRODUCT)) {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", cardProduct));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
			}
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CashCardDailyTransaction.writeBodyHeader()");
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

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In CashCardDailyTransaction.writePdfBodyHeader()");
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
	protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		int fieldLength = 0;
		boolean accName = false;
		String accNameValue = null;
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.CUSTOMER_ID:
					fieldLength += field.getPdfLength();
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					break;
				case ReportConstants.ATM_CARD_NUMBER:
					fieldLength += field.getPdfLength();
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					break;
				case ReportConstants.FROM_ACCOUNT_NO:
					fieldLength += field.getPdfLength();
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					break;
				case ReportConstants.ACCOUNT_NAME:
					if (getFieldValue(field, fieldsMap).length() > ACCOUNT_NAME_MAX_LENGTH) {
						contentStream.showText(
								getFieldValue(field, fieldsMap).substring(0, 28) + String.format("%1$4s", ""));
						accNameValue = getFieldValue(field, fieldsMap).substring(28,
								getFieldValue(field, fieldsMap).length());
						accName = true;
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
					break;
				default:
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					break;
				}
			}
		}
		if (accName) {
			accName = false;
			contentStream.showText(String.format("%1$" + (fieldLength + accNameValue.length()) + "s", accNameValue));
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
		}
	}

	protected SortedSet<String> filterByCardProduct(ReportGenerationMgr rgm) {
		logger.debug("In CashCardDailyTransaction.filterByCardProduct()");
		String cardProduct = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedSet<String> cardProductList = new TreeSet<>();
		String query = getBodyQuery(rgm);
		logger.info("Query to filter card product: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when getting result", e);
							continue;
						}
						if (result != null) {
							if (key.equalsIgnoreCase(ReportConstants.CARD_PRODUCT)) {
								cardProduct = result.toString();
							}
						}
					}
					cardProductList.add(cardProduct);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the criteria", e);
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
		return cardProductList;
	}

	private boolean executeQuery(ReportGenerationMgr rgm) {
		logger.debug("In CashCardDailyTransaction.executeQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = getBodyQuery(rgm);
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.connection.prepareStatement(query);
			rs = ps.executeQuery();

			if (!rs.isBeforeFirst()) {
				return false;
			} else {
				return true;
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
		return false;
	}
}
