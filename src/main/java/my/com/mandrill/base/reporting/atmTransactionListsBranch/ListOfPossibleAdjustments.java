package my.com.mandrill.base.reporting.atmTransactionListsBranch;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
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

public class ListOfPossibleAdjustments extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ListOfPossibleAdjustments.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private double total = 0.00;

	@Override
	public void executePdf(ReportGenerationMgr rgm) {
		logger.debug("In ListOfPossibleAdjustments.processPdfRecord()");
		generateBranchReport(rgm);
		generateMasterListReport(rgm);
	}

	private void generateBranchReport(ReportGenerationMgr rgm) {
		logger.debug("In ListOfPossibleAdjustments.generateBranchReport()");
		pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
		totalHeight = PDRectangle.A4.getHeight();
		PDDocument doc = null;
		try {
			preProcessing(rgm);

			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				pagination = 1;
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
				String branchCode = null;
				String branchName = null;
				String terminal = null;
				String location = null;

				contentStream.setFont(pdfFont, fontSize);
				contentStream.beginText();
				contentStream.newLineAtOffset(startX, startY);

				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, terminal);
					writePdfHeader(rgm, contentStream, leading, pagination);
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 4;
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						total = 0.00;
						contentStream.showText(ReportConstants.BRANCH + "   : " + branchCode + " " + branchName);
						contentStream.newLineAtOffset(0, -leading);
						contentStream.showText(ReportConstants.TERMINAL + " : " + terminal + " " + location);
						pageHeight += 2;
						contentStream.newLineAtOffset(0, -leading);
						writePdfBodyHeader(rgm, contentStream, leading);
						pageHeight += 2;
						preProcessing(rgm, branchCode, terminal);
						contentStream = execute(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
								pdfFont, fontSize);
						pageHeight += 1;
						writePdfTrailer(rgm, contentStream, leading);
						pageHeight += 1;
						contentStream.newLineAtOffset(0, -leading);
					}
				}
				contentStream.endText();
				contentStream.close();

				saveFile(rgm, doc, branchCode);
			}
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
		} finally {
			if (doc != null) {
				try {
					doc.close();
				} catch (IOException e) {
					rgm.errors++;
					logger.error("Error in closing PDF file", e);
				}
			}
		}
	}

	private void generateMasterListReport(ReportGenerationMgr rgm) {
		logger.debug("In ListOfPossibleAdjustments.generateMasterListReport()");
		pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
		totalHeight = PDRectangle.A4.getHeight();
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
			String branchCode = null;
			String branchName = null;
			String terminal = null;
			String location = null;

			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, terminal);
					writePdfHeader(rgm, contentStream, leading, pagination);
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 4;
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						total = 0.00;
						contentStream.showText(ReportConstants.BRANCH + "   : " + branchCode + " " + branchName);
						contentStream.newLineAtOffset(0, -leading);
						contentStream.showText(ReportConstants.TERMINAL + " : " + terminal + " " + location);
						pageHeight += 2;
						contentStream.newLineAtOffset(0, -leading);
						writePdfBodyHeader(rgm, contentStream, leading);
						pageHeight += 2;
						preProcessing(rgm, branchCode, terminal);
						contentStream = execute(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
								pdfFont, fontSize);
						pageHeight += 1;
						writePdfTrailer(rgm, contentStream, leading);
						pageHeight += 1;
						contentStream.newLineAtOffset(0, -leading);
					}
				}
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

	private PDPageContentStream execute(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In ListOfPossibleAdjustments.execute()");
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
		logger.debug("In ListOfPossibleAdjustments.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery()
					.replace("{" + ReportConstants.PARAM_BRANCH_CODE + "}",
							getBranchQueryStatement(rgm.getInstitution(), "ABR.ABR_CODE"))
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ListOfPossibleAdjustments.preProcessing()");
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
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In ListOfPossibleAdjustments.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getGlobalFieldValue(rgm, field));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.isFirstField()) {
					contentStream.showText(String.format("%1$5s", "") + getGlobalFieldValue(rgm, field));
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
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
					if (getFieldValue(field, fieldsMap).trim().indexOf(",") != -1) {
						total += Double.parseDouble(getFieldValue(field, fieldsMap).trim().replace(",", ""));
					} else {
						total += Double.parseDouble(getFieldValue(field, fieldsMap).trim());
					}
				}
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
			}
		}
	}

	private void writePdfTrailer(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In ListOfPossibleAdjustments.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.TOTAL_AMOUNT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatter.format(total)));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				contentStream.showText(getGlobalFieldValue(rgm, field));
			}
		}
	}
}
