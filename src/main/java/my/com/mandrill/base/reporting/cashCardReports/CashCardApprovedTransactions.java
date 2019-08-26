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
import java.util.Map;
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

public class CashCardApprovedTransactions extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(CashCardApprovedTransactions.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In CashCardApprovedTransactions.processPdfRecord()");
		PDDocument doc = null;
		PDPage page = null;
		PDPageContentStream contentStream = null;
		PDRectangle pageSize = null;
		PDFont pdfFont = PDType1Font.COURIER;
		float fontSize = 6;
		float leading = 1.5f * fontSize;
		float margin = 30;
		float width = 0.0f;
		float startX = 0.0f;
		float startY = 0.0f;
		pagination = 0;
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		String cardProduct = null;
		try {
			doc = new PDDocument();
			preProcessing(rgm);

			if (!executeQuery(rgm)) {
				page = new PDPage();
				doc.addPage(page);
				contentStream = new PDPageContentStream(doc, page);
				pageSize = page.getMediaBox();
				width = pageSize.getWidth() - 2 * margin;
				startX = pageSize.getLowerLeftX() + margin;
				startY = pageSize.getUpperRightY() - margin;
				contentStream.setFont(pdfFont, fontSize);
				contentStream.beginText();
				contentStream.newLineAtOffset(startX, startY);
				contentStream.endText();
				contentStream.close();
				saveFile(rgm, doc);
			} else {
				for (SortedMap.Entry<String, Map<String, TreeMap<String, Map<String, String>>>> branchCodeMap : filterCriteriaForCashCard(
						rgm).entrySet()) {
					branchCode = branchCodeMap.getKey();
					pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
					page = new PDPage();
					doc.addPage(page);
					pagination++;
					contentStream = new PDPageContentStream(doc, page);
					pageSize = page.getMediaBox();
					width = pageSize.getWidth() - 2 * margin;
					startX = pageSize.getLowerLeftX() + margin;
					startY = pageSize.getUpperRightY() - margin;
					contentStream.setFont(pdfFont, fontSize);
					contentStream.beginText();
					contentStream.newLineAtOffset(startX, startY);
					for (SortedMap.Entry<String, TreeMap<String, Map<String, String>>> branchNameMap : branchCodeMap
							.getValue().entrySet()) {
						branchName = branchNameMap.getKey();
						preProcessing(rgm, branchCode, terminal, cardProduct);
						writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
						contentStream.newLineAtOffset(0, -leading);
						pageHeight += 4;
						for (SortedMap.Entry<String, Map<String, String>> terminalMap : branchNameMap.getValue()
								.entrySet()) {
							terminal = terminalMap.getKey();
							for (SortedMap.Entry<String, String> locationMap : terminalMap.getValue().entrySet()) {
								location = locationMap.getKey();
								cardProduct = locationMap.getValue();
								contentStream.showText(ReportConstants.TERMINAL + " " + terminal + " AT " + location);
								pageHeight += 1;
								contentStream.newLineAtOffset(0, -leading);
								contentStream.showText(ReportConstants.CARD_PRODUCT + " - " + cardProduct);
								pageHeight += 1;
								contentStream.newLineAtOffset(0, -leading);
								writePdfBodyHeader(rgm, contentStream, leading);
								pageHeight += 2;
								preProcessing(rgm, branchCode, terminal, cardProduct);
								contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading,
										startX, startY, pdfFont, fontSize);
								pageHeight += 1;
							}
						}
					}
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
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		String cardProduct = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			preProcessing(rgm);

			for (SortedMap.Entry<String, Map<String, TreeMap<String, Map<String, String>>>> branchCodeMap : filterCriteriaForCashCard(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, Map<String, String>>> branchNameMap : branchCodeMap
						.getValue().entrySet()) {
					branchName = branchNameMap.getKey();
					pagination++;
					preProcessing(rgm, branchCode, terminal, cardProduct);
					writeHeader(rgm, pagination, branchCode, branchName);
					for (SortedMap.Entry<String, Map<String, String>> terminalMap : branchNameMap.getValue()
							.entrySet()) {
						terminal = terminalMap.getKey();
						for (SortedMap.Entry<String, String> locationMap : terminalMap.getValue().entrySet()) {
							StringBuilder line = new StringBuilder();
							location = locationMap.getKey();
							cardProduct = locationMap.getValue();
							line.append(ReportConstants.TERMINAL + " " + terminal).append(";").append(" AT " + location)
									.append(";");
							line.append(getEol());
							line.append(ReportConstants.CARD_PRODUCT + " - ").append(";").append(cardProduct)
									.append(";");
							line.append(getEol());
							rgm.writeLine(line.toString().getBytes());
							writeBodyHeader(rgm);
							preProcessing(rgm, branchCode, terminal, cardProduct);
							executeBodyQuery(rgm);
							line = new StringBuilder();
							line.append(getEol());
							rgm.writeLine(line.toString().getBytes());
						}
					}
				}
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
		logger.debug("In CashCardApprovedTransactions.execute()");
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
		logger.debug("In CashCardApprovedTransactions.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", "")
					.replace("AND {" + ReportConstants.PARAM_CARD_PRODUCT + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal,
			String filterByCardProduct) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In CashCardApprovedTransactions.preProcessing()");
		if (filterByBranchCode != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(AST.AST_TERMINAL_ID, -4) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}

		if (filterByCardProduct != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields cardProduct = new ReportGenerationFields(ReportConstants.PARAM_CARD_PRODUCT,
					ReportGenerationFields.TYPE_STRING, "CPD.CPD_NAME = '" + filterByCardProduct + "'");
			getGlobalFileFieldsMap().put(cardProduct.getFieldName(), cardProduct);
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CashCardApprovedTransactions.writeBodyHeader()");
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
		logger.debug("In CashCardApprovedTransactions.writePdfBodyHeader()");
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

	private boolean executeQuery(ReportGenerationMgr rgm) {
		logger.debug("In CashCardApprovedTransactions.executeQuery()");
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
