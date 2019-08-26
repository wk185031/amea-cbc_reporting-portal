package my.com.mandrill.base.reporting.cashCardReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

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

public class CashCardBalance extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(CashCardBalance.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private double balanceTotal = 0.00;
	private double overallTotal = 0.00;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In CashCardBalance.processPdfRecord()");
		PDDocument doc = null;
		PDPage page = null;
		PDPageContentStream contentStream = null;
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		String cardProduct = null;
		String branchCode = null;
		String branchName = null;
		pagination = 1;
		try {
			doc = new PDDocument();
			page = new PDPage();
			doc.addPage(page);
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

			preProcessing(rgm);
			writePdfHeader(rgm, contentStream, leading, pagination);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;
			contentStream.newLineAtOffset(0, -leading);

			for (SortedMap.Entry<String, TreeMap<String, String>> cardProductMap : filterByCardProduct(rgm)
					.entrySet()) {
				overallTotal = 0.00;
				cardProduct = cardProductMap.getKey();
				contentStream.showText(ReportConstants.CARD_PRODUCT + " - " + cardProduct);
				contentStream.newLineAtOffset(0, -leading);
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 2;
				for (SortedMap.Entry<String, String> branchCodeMap : cardProductMap.getValue().entrySet()) {
					balanceTotal = 0.00;
					branchCode = branchCodeMap.getKey();
					branchName = branchCodeMap.getValue();
					contentStream.showText(ReportConstants.BRANCH + ": " + branchCode + " " + branchName);
					contentStream.newLineAtOffset(0, -leading);
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 2;
					writePdfBodyHeader(rgm, contentStream, leading);
					pageHeight += 2;
					preProcessing(rgm, cardProduct, branchCode);
					contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
							startY, pdfFont, fontSize);
					contentStream.showText(String.format("%1$126s", "TOTAL: ")
							+ String.format("%1$28s", formatter.format(balanceTotal)));
					overallTotal += balanceTotal;
					pageHeight += 1;
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 1;
				}
				contentStream.showText(String.format("%1$154s", "________________"));
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 1;
				contentStream.showText(ReportConstants.CARD_PRODUCT + " - " + cardProduct + " OVER-ALL TOTAL: "
						+ String.format("%1$84s", "GRAND TOTAL: ")
						+ String.format("%1$28s", formatter.format(overallTotal)));
				contentStream.newLineAtOffset(0, -leading);
				contentStream.newLineAtOffset(0, -leading);
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 3;
			}
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

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		String cardProduct = null;
		String branchCode = null;
		String branchName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			preProcessing(rgm);
			writeHeader(rgm, pagination);

			for (SortedMap.Entry<String, TreeMap<String, String>> cardProductMap : filterByCardProduct(rgm)
					.entrySet()) {
				overallTotal = 0.00;
				cardProduct = cardProductMap.getKey();
				StringBuilder line = new StringBuilder();
				line.append(ReportConstants.CARD_PRODUCT + " - ").append(";").append(cardProduct);
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
				for (SortedMap.Entry<String, String> branchCodeMap : cardProductMap.getValue().entrySet()) {
					balanceTotal = 0.00;
					branchCode = branchCodeMap.getKey();
					branchName = branchCodeMap.getValue();
					line = new StringBuilder();
					line.append(ReportConstants.BRANCH + ": ").append(";").append(branchCode).append(";")
							.append(branchName);
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
					writeBodyHeader(rgm);
					preProcessing(rgm, cardProduct, branchCode);
					executeBodyQuery(rgm);
					line = new StringBuilder();
					line.append(";").append(";").append(";").append(";").append("TOTAL:").append(";")
							.append(formatter.format(balanceTotal));
					overallTotal += balanceTotal;
					line.append(getEol());
					line.append(getEol());
					rgm.writeLine(line.toString().getBytes());
				}
				line = new StringBuilder();
				line.append(ReportConstants.CARD_PRODUCT + " - " + cardProduct + " OVER-ALL TOTAL: ").append(";")
						.append(";").append(";").append(";").append("GRAND TOTAL:").append(";")
						.append(formatter.format(overallTotal));
				line.append(getEol());
				line.append(getEol());
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
		logger.debug("In CashCardBalance.execute()");
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

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In CashCardBalance.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_CARD_PRODUCT + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByCardProduct, String filterByBranchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In CashCardBalance.preProcessing()");
		if (filterByCardProduct != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
			ReportGenerationFields cardProduct = new ReportGenerationFields(ReportConstants.PARAM_CARD_PRODUCT,
					ReportGenerationFields.TYPE_STRING, "CPD.CPD_NAME = '" + filterByCardProduct + "'");
			getGlobalFileFieldsMap().put(cardProduct.getFieldName(), cardProduct);
		}

		if (filterByBranchCode != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "CRD.CRD_CUSTOM_DATA = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CashCardBalance.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			line.append(getGlobalFieldValue(rgm, field));
			line.append(field.getDelimiter());
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

			if (field.getFieldName().equalsIgnoreCase(ReportConstants.BALANCE)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					balanceTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					balanceTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}
			line.append(getFieldValue(rgm, field, fieldsMap));
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
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

			if (field.getFieldName().equalsIgnoreCase(ReportConstants.BALANCE)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					balanceTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					balanceTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
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
				case ReportConstants.CUSTOMER_NAME:
					if (getFieldValue(field, fieldsMap).length() > 37) {
						contentStream.showText(
								getFieldValue(field, fieldsMap).substring(0, 37) + String.format("%1$3s", ""));
						accNameValue = getFieldValue(field, fieldsMap).substring(37,
								getFieldValue(field, fieldsMap).length());
						accName = true;
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
					break;
				case ReportConstants.CARD_PRODUCT:
					contentStream
							.showText(String.format(String.format("%1$7s", "") + getFieldValue(rgm, field, fieldsMap)));
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

	protected SortedMap<String, TreeMap<String, String>> filterByCardProduct(ReportGenerationMgr rgm) {
		logger.debug("In CashCardBalance.filterByCardProduct()");
		String cardProduct = null;
		String branchCode = null;
		String branchName = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, TreeMap<String, String>> cardProductMap = new TreeMap<>();
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
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
								branchCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								branchName = result.toString();
							}
						}
					}
					if (cardProductMap.get(cardProduct) == null) {
						TreeMap<String, String> branchCodeMap = new TreeMap<>();
						branchCodeMap.put(branchCode, branchName);
						cardProductMap.put(cardProduct, branchCodeMap);
					} else {
						TreeMap<String, String> branchCodeMap = cardProductMap.get(cardProduct);
						branchCodeMap.put(branchCode, branchName);
					}
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
		return cardProductMap;
	}
}
