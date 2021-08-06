package my.com.mandrill.base.reporting.atmTransactionListsBranch;

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

public class ATMWithdrawalsSummaryReport extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(ATMWithdrawalsSummaryReport.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;

	@Override
	public void executePdf(ReportGenerationMgr rgm) {
		logger.debug("In ATMWithdrawalsSummaryReport.processPdfRecord()");
		if (rgm.getTrailerQuery() != null) {
			setTmpTrailerQuery(rgm.getTrailerQuery()
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}","")
//					.replace("{" + ReportConstants.PARAM_BRANCH_CODE + "}",
//							getBranchQueryStatement(rgm.getInstitution(), "ABR.ABR_CODE"))
					.replace("AND {" + ReportConstants.PARAM_BRANCH_NAME + "}", ""));
		}
		generateBranchReport(rgm);
		generateMasterListReport(rgm);
	}

	private void generateBranchReport(ReportGenerationMgr rgm) {
		logger.debug("In ATMWithdrawalsSummaryReport.generateBranchReport()");
		pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
		totalHeight = PDRectangle.A4.getHeight();
		PDDocument doc = null;
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
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

				contentStream.setFont(pdfFont, fontSize);
				contentStream.beginText();
				contentStream.newLineAtOffset(startX, startY);

				writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 4;
				writePdfBodyHeader(rgm, contentStream, leading);
				pageHeight += 2;

				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					contentStream.showText(branchCode + "           " + branchName);
					pageHeight += 1;
					contentStream.newLineAtOffset(0, -leading);
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						preProcessing(rgm, branchCode, terminal, branchName);
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, location);
						pageHeight += 1;
					}
					executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont,
							fontSize, false);
					pageHeight += 1;
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 1;
				}
				rgm.setTrailerQuery(rgm.getTrailerQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_NAME + "}", ""));
				executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize,
						true);
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
		logger.debug("In ATMWithdrawalsSummaryReport.generateMasterListReport()");
		pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
		totalHeight = PDRectangle.A4.getHeight();
		PDDocument doc = null;
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
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

			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;

			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					contentStream.showText(branchCode + "           " + branchName);
					pageHeight += 1;
					contentStream.newLineAtOffset(0, -leading);
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						preProcessing(rgm, branchCode, terminal, branchName);
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, location);
						pageHeight += 1;
					}
					executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont,
							fontSize, false);
					pageHeight += 1;
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 1;
				}
			}
			rgm.setTrailerQuery(getTmpTrailerQuery());
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize, true);
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

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ATMWithdrawalsSummaryReport.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery()
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}","")
//					.replace("{" + ReportConstants.PARAM_BRANCH_CODE + "}",
//							getBranchQueryStatement(rgm.getInstitution(), "ABR.ABR_CODE"))
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal, String filterByBranchName)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ATMWithdrawalsSummaryReport.preProcessing()");
		if (rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(AST.AST_TERMINAL_ID, -4) = '" + filterByTerminal + "'");
			ReportGenerationFields branchName = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_NAME,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_NAME = '" + filterByBranchName + "'");

			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
			getGlobalFileFieldsMap().put(branchName.getFieldName(), branchName);
		}
	}

	@Override
	protected void writePdfHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading,
			int pagination, String branchCode, String branchName) throws IOException, JSONException {
		logger.debug("In PdfReportProcess.writePdfHeader()");
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
				contentStream.showText(getGlobalFieldValue(rgm, field));
			}
		}
	}

	private void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, String location)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (!field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
						contentStream.showText(String.format("%1$4s", "")
								+ String.format("%1$-" + field.getPdfLength() + "s", location));
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
				} else {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				}
			}
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, String location) {
		logger.debug("In ATMWithdrawalsSummaryReport.executePdfBodyQuery()");
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, location);
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

	private void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, boolean overallTotal)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In ATMWithdrawalsSummaryReport.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (overallTotal && field.getFieldName().equalsIgnoreCase(ReportConstants.SUB_TOTAL)) {
					contentStream.showText(
							String.format("%1$-" + field.getPdfLength() + "s", ReportConstants.OVERALL_TOTAL));
				} else {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				}
			}
		}
	}

	private void executePdfTrailerQuery(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream,
			PDRectangle pageSize, float leading, float startX, float startY, PDFont pdfFont, float fontSize,
			boolean overallTotal) {
		logger.debug("In ATMWithdrawalsSummaryReport.executePdfTrailerQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

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
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writePdfTrailer(rgm, lineFieldsMap, contentStream, leading, overallTotal);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
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
}
