package my.com.mandrill.base.reporting.glHandoffFinalProofSheet;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
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
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class GLHandoffFinalProofSheetRecycler extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffFinalProofSheetRecycler.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private double debitTotal = 0.00;
	private double creditTotal = 0.00;

	@Override
	public void executePdf(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetRecycler.processPdfRecord()");
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

			separateQuery(rgm);
			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			writePdfHeader(rgm, contentStream, leading, pagination);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;

			Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
			
			if(!branchCodeItr.hasNext()) {
				contentStream.setFont(pdfFont, fontSize);
				contentStream.newLineAtOffset(0, -leading);
				contentStream.showText("**NO TRANSACTIONS FOR THE DAY**");
				contentStream.newLineAtOffset(0, -leading);
			}

			while (branchCodeItr.hasNext()) {
				branchCode = branchCodeItr.next();
				preProcessing(rgm, branchCode);
				rgm.setBodyQuery(getDebitBodyQuery());
				contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
						pdfFont, fontSize, branchCode);
				rgm.setBodyQuery(getCreditBodyQuery());
				contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
						pdfFont, fontSize, branchCode);
			}

			writePdfTrailer(rgm, contentStream, leading);
			pageHeight += 1;
			contentStream.endText();
			contentStream.close();

			saveFile(rgm, doc);
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Error in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
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
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			debitTotal = 0.00;
			creditTotal = 0.00;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			separateQuery(rgm);
			preProcessing(rgm);

			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
			
			if(!branchCodeItr.hasNext()) {
				StringBuilder line = new StringBuilder();
				line.append(getEol());
				line.append("**NO TRANSACTIONS FOR THE DAY**");
				line.append(getEol());
				rgm.writeLine(line.toString().getBytes());
			}
			
			while (branchCodeItr.hasNext()) {
				branchCode = branchCodeItr.next();
				preProcessing(rgm, branchCode);
				rgm.setBodyQuery(getDebitBodyQuery());
				executeBodyQuery(rgm, branchCode);
				rgm.setBodyQuery(getCreditBodyQuery());
				executeBodyQuery(rgm, branchCode);
			}
			writeTrailer(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in generating TXT file", e);
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

	@Override
	protected SortedSet<String> filterByBranchCode(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetRecycler.filterByBranchCode()");
		String branchCode = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedSet<String> branchCodeList = new TreeSet<>();
		rgm.setBodyQuery(getCriteriaQuery());
		String query = getBodyQuery(rgm);
		logger.info("Query for filter branch code: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
								branchCode = result.toString();
							}
						}
					}
					branchCodeList.add(branchCode);
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
		return branchCodeList;
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffFinalProofSheetRecycler.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffFinalProofSheetRecycler.preProcessing()");
		if (filterByBranchCode != null && getDebitBodyQuery() != null && getCreditBodyQuery() != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetRecycler.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setDebitBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCriteriaQuery(getDebitBodyQuery());
		}
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String branchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.DEBITS)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					debitTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					debitTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.CREDITS)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					creditTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					creditTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}

			switch (field.getFieldName()) {
			case ReportConstants.GL_ACCOUNT_NUMBER:
				if(getFieldValue(field, fieldsMap).length() < ReportConstants.GL_ACCOUNT_NUMBER_MAX_LENGTH) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							branchCode + getFieldValue(field, fieldsMap)));
				} else {				
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap)));
				}			
				break;
			case ReportConstants.GL_ACCOUNT_NAME:
				line.append(String.format("%1$5s", "")
						+ String.format("%1$-" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap)));
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeTrailer(ReportGenerationMgr rgm)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetRecycler.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.TOTAL_CREDIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatter.format(creditTotal)));
				} else {
					line.append(getGlobalFieldValue(rgm, field));
				}
				line.append(getEol());
			} else {
				if (field.getFieldName().contains(ReportConstants.TOTAL_DEBIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatter.format(debitTotal)));
				} else {
					line.append(getGlobalFieldValue(rgm, field));
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, String branchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.DEBITS)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					debitTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					debitTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.CREDITS)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					creditTotal += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					creditTotal += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}

			switch (field.getFieldName()) {
			case ReportConstants.GL_ACCOUNT_NUMBER:
				if(getFieldValue(field, fieldsMap).length() < ReportConstants.GL_ACCOUNT_NUMBER_MAX_LENGTH) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
							branchCode + getFieldValue(field, fieldsMap)));
				} else {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
							getFieldValue(field, fieldsMap)));
				}
				
				break;
			case ReportConstants.GL_ACCOUNT_NAME:
				contentStream.showText(String.format("%1$5s", "")
						+ String.format("%1$-" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap)));
				break;
			default:
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				break;
			}
		}
		contentStream.newLineAtOffset(0, -leading);
	}

	private void writePdfTrailer(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetRecycler.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.TOTAL_CREDIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatter.format(creditTotal)));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.getFieldName().contains(ReportConstants.TOTAL_DEBIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatter.format(debitTotal)));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
			}
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, String branchCode) {
		logger.debug("In GLHandoffFinalProofSheetRecycler.executePdfBodyQuery()");
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
						page = new PDPage();
						doc.addPage(page);
						pagination++;
						contentStream.endText();
						contentStream.close();
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
						writePdfHeader(rgm, contentStream, leading, pagination);
						pageHeight += 4;
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, branchCode);
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
