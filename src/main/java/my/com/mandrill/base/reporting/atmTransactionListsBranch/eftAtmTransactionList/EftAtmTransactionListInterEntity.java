package my.com.mandrill.base.reporting.atmTransactionListsBranch.eftAtmTransactionList;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;

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

public class EftAtmTransactionListInterEntity extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(EftAtmTransactionListInterEntity.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In EftAtmTransactionListInterEntity.processPdfRecord()");
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

			for (SortedMap.Entry<String, Map<String, Map<String, Set<String>>>> branchCodeMap : filterByCriteria(rgm)
					.entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, Map<String, Set<String>>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, terminal);
					writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 4;
					for (SortedMap.Entry<String, Set<String>> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						for (String locationList : terminalMap.getValue()) {
							location = locationList;
							contentStream.showText(ReportConstants.TERMINAL + " " + terminal + " - " + location);
							pageHeight += 1;
							contentStream.newLineAtOffset(0, -leading);
							writePdfBodyHeader(rgm, contentStream, leading);
							pageHeight += 2;
							preProcessing(rgm, branchCode, terminal);
							contentStream = execute(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
									pdfFont, fontSize);
							pageHeight += 1;
						}
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
		logger.debug("In EftAtmTransactionListInterEntity.execute()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String txnQualifier = null;
		String voidCode = null;
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
							} else if (key.equalsIgnoreCase(ReportConstants.TXN_QUALIFIER)) {
								txnQualifier = result.toString();
								field.setValue(result.toString());
							} else if (key.equalsIgnoreCase(ReportConstants.VOID_CODE)) {
								voidCode = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, txnQualifier, voidCode);
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
		logger.debug("In EftAtmTransactionListInterEntity.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In EftAtmTransactionListInterEntity.preProcessing()");
		if (filterByBranchCode != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "TRIM(AST.AST_TERMINAL_ID) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In EftAtmTransactionListInterEntity.writePdfBodyHeader()");
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
}
