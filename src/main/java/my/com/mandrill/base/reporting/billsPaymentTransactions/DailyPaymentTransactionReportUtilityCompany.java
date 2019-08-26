package my.com.mandrill.base.reporting.billsPaymentTransactions;

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

public class DailyPaymentTransactionReportUtilityCompany extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(DailyPaymentTransactionReportUtilityCompany.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private double subTotal = 0.00;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.processPdfRecord()");
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
			String billerCode = null;
			String billerMnem = null;
			DecimalFormat formatter = new DecimalFormat("#,##0.00");

			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			writePdfHeader(rgm, contentStream, leading, pagination);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;

			for (SortedMap.Entry<String, String> billerCodeMap : filterByCriteriaByBiller(rgm).entrySet()) {
				billerCode = billerCodeMap.getKey();
				billerMnem = billerCodeMap.getValue();
				subTotal = 0.00;
				contentStream.showText("UTILITY COMPANY : " + billerCode + " " + billerMnem);
				pageHeight += 1;
				contentStream.newLineAtOffset(0, -leading);
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 1;
				writePdfBodyHeader(rgm, contentStream, leading);
				pageHeight += 2;
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 1;
				preProcessing(rgm, billerCode);
				contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
						pdfFont, fontSize);
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 1;
				contentStream.showText(String.format("%1$82s", "SUBTOTAL : ") + String.format("%1$13s", "")
						+ String.format("%1$33s", formatter.format(subTotal)));
				pageHeight += 1;
				contentStream.newLineAtOffset(0, -leading);
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 1;
			}
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
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
		String billerCode = null;
		String billerMnem = null;
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			preProcessing(rgm);
			writeHeader(rgm, pagination);
			for (SortedMap.Entry<String, String> billerCodeMap : filterByCriteriaByBiller(rgm).entrySet()) {
				billerCode = billerCodeMap.getKey();
				billerMnem = billerCodeMap.getValue();
				StringBuilder billerLine = new StringBuilder();
				subTotal = 0.00;
				billerLine.append("UTILITY COMPANY : " + billerCode + " " + billerMnem);
				billerLine.append(getEol());
				rgm.writeLine(billerLine.toString().getBytes());
				writeBodyHeader(rgm);
				preProcessing(rgm, billerCode);
				executeBodyQuery(rgm);
				billerLine = new StringBuilder();
				billerLine.append(";").append(";").append(";").append(";").append(";").append("SUBTOTAL : ").append(";")
						.append(";").append(formatter.format(subTotal)).append(";");
				billerLine.append(getEol());
				billerLine.append(getEol());
				rgm.writeLine(billerLine.toString().getBytes());
			}
			executeTrailerQuery(rgm);

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

	private SortedMap<String, String> filterByCriteriaByBiller(ReportGenerationMgr rgm) {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.filterByCriteriaByBiller()");
		String billerCode = null;
		String billerMnem = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter criteria: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.BP_BILLER_CODE)) {
								billerCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BP_BILLER_MNEM)) {
								billerMnem = result.toString();
							}
						}
					}
					criteriaMap.put(billerCode, billerMnem);
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
		return criteriaMap;
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BILLER_CODE + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBillerCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.preProcessing()");
		if (filterByBillerCode != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields billerCode = new ReportGenerationFields(ReportConstants.PARAM_BILLER_CODE,
					ReportGenerationFields.TYPE_STRING,
					"LPAD(TXN.TRL_BILLER_CODE, 3, '0') = '" + filterByBillerCode + "'");
			getGlobalFileFieldsMap().put(billerCode.getFieldName(), billerCode);
		}
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getGlobalFieldValue(rgm, field));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.isFirstField()) {
					contentStream.showText(String.format("%1$7s", "") + getGlobalFieldValue(rgm, field));
				} else
					contentStream.showText(getGlobalFieldValue(rgm, field));
			}
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, String channel)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					subTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					subTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}

			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.TERMINAL:
					if (channel.equals(ReportConstants.OB) && getFieldValue(field, fieldsMap).trim().length() == 8) {
						String terminalId = getFieldValue(field, fieldsMap).trim();
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								terminalId.substring(0, 4) + "-" + terminalId.substring(terminalId.length() - 4)));
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
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap, String channel)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					subTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					subTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}

			switch (field.getFieldName()) {
			case ReportConstants.TERMINAL:
				if (channel.equals(ReportConstants.OB) && getFieldValue(field, fieldsMap).length() == 8) {
					String terminalId = getFieldValue(field, fieldsMap);
					line.append(terminalId.substring(0, 4) + "-" + terminalId.substring(terminalId.length() - 4));
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
				}
				line.append(field.getDelimiter());
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.execute()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String channel = null;
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
							} else if (key.equalsIgnoreCase(ReportConstants.CHANNEL)) {
								channel = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, channel);
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

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String channel = null;
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);

				while (rs.next()) {
					new StringBuffer();
					lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
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
							} else if (key.equalsIgnoreCase(ReportConstants.CHANNEL)) {
								channel = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap, channel);
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
	}

	@Override
	protected void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			line.append(getFieldValue(rgm, field, fieldsMap));
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}
