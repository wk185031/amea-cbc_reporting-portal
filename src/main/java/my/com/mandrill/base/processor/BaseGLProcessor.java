package my.com.mandrill.base.processor;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

public class BaseGLProcessor extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(BaseGLProcessor.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private boolean endBranch = false;
	private static final float DEFAULT_FONT_SIZE = 6;
	private static final float DEFAULT_LEADING = 1.5f * DEFAULT_FONT_SIZE;
	private static final float DEFAULT_MARGIN = 30;
	private static final PDFont DEFAULT_FONT = PDType1Font.COURIER;
	private static final int MAX_RECORD_PER_PAGE = 65;

	@Override
	public void executePdf(ReportGenerationMgr rgm) throws ReportGenerationException {
		logger.debug("In GLHandoffBlocksheetCashCard.processPdfRecord()");
		PDDocument doc = new PDDocument();
		PDPageContentStream contentStream = null;
		pagination = 0;

		ResultSet rs = null;
		PreparedStatement ps = null;
		int recordCount = 0;
		int pageCount = 1;
		String lastDebitCreditFlag = null;
		addReportPreProcessingFieldsToGlobalMap(rgm);
		String query = getBodyQuery(rgm);
		logger.info("Execute query: {}", query);

		try {
			contentStream = newPage(rgm, doc, DEFAULT_FONT, DEFAULT_FONT_SIZE, DEFAULT_MARGIN, pageCount);
			pageCount++;

			ps = rgm.getConnection().prepareStatement(query);
			rs = ps.executeQuery();
			HashMap<String, ReportGenerationFields> fieldsMap = rgm.getQueryResultStructure(rs);
			HashMap<String, ReportGenerationFields> lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

			String currentDebitCreditFlag = null;
			boolean newGroup = true;
			if (rs.next()) {
				Map<String, BigDecimal> summaryTotal = new HashMap<String, BigDecimal>();
				summaryTotal.put(ReportConstants.TOTAL_DEBIT, BigDecimal.ZERO);
				summaryTotal.put(ReportConstants.TOTAL_CREDIT, BigDecimal.ZERO);
				do {
					String branchCode = "";
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
						if (ReportConstants.BRANCH_CODE.equals(field.getFieldName())) {
							branchCode = field.getValue();
						}
					}
					currentDebitCreditFlag = rs.getString(ReportConstants.DEBIT_CREDIT);

					if (recordCount >= MAX_RECORD_PER_PAGE) {
						contentStream.endText();
						contentStream.close();
						contentStream = newPage(rgm, doc, DEFAULT_FONT, DEFAULT_FONT_SIZE, DEFAULT_MARGIN, pageCount);
						pageCount++;
						recordCount = 0;
					}

					if (currentDebitCreditFlag.equals(lastDebitCreditFlag)) {
						newGroup = false;
					} else {
						if (lastDebitCreditFlag != null) {
							writePdfTrailer(rgm, lineFieldsMap, contentStream, DEFAULT_LEADING, summaryTotal);
							contentStream.endText();
							contentStream.close();
							contentStream = newPage(rgm, doc, DEFAULT_FONT, DEFAULT_FONT_SIZE, DEFAULT_MARGIN,
									pageCount);
							pageCount++;
						}
						newGroup = true;
						lastDebitCreditFlag = currentDebitCreditFlag;
						// reset total
						summaryTotal.put(ReportConstants.TOTAL_DEBIT, BigDecimal.ZERO);
						summaryTotal.put(ReportConstants.TOTAL_CREDIT, BigDecimal.ZERO);
					}
					writePdfBody(rgm, lineFieldsMap, contentStream, DEFAULT_LEADING, branchCode, newGroup,
							summaryTotal);
					recordCount++;
				} while (rs.next());
				writePdfTrailer(rgm, lineFieldsMap, contentStream, DEFAULT_LEADING, summaryTotal);
			} else {
				writeNoRecordFound(contentStream);
			}
			contentStream.endText();
			contentStream.close();
			saveFile(rgm, doc);
		} catch (SQLException e) {
			logger.error("Failed to fetch records.", e);
			throw new ReportGenerationException("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
		} catch (Exception ie) {
			logger.error("Failed to write file.", ie);
			throw new ReportGenerationException("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, ie);
		} finally {
			try {
				rgm.cleanAllDbResource(ps, rs);
				if (doc != null) {
					doc.close();
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error closing DB resources", e);
			}
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {

		ResultSet rs = null;
		PreparedStatement ps = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			rgm.setBodyQuery(rgm.getFixBodyQuery());

			
			int recordCount = 0;
			int pageCount = 1;
			String lastDebitCreditFlag = null;
			addReportPreProcessingFieldsToGlobalMap(rgm);
			String query = getBodyQuery(rgm);
			ps = rgm.getConnection().prepareStatement(query);
			rs = ps.executeQuery();
			HashMap<String, ReportGenerationFields> fieldsMap = rgm.getQueryResultStructure(rs);
			HashMap<String, ReportGenerationFields> lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

			String currentDebitCreditFlag = null;
			boolean newGroup = true;

			writeHeader(rgm, pageCount);
			writeBodyHeader(rgm);
			pageCount++;

			if (rs.next()) {
				Map<String, BigDecimal> summaryTotal = new HashMap<String, BigDecimal>();
				summaryTotal.put(ReportConstants.TOTAL_DEBIT, BigDecimal.ZERO);
				summaryTotal.put(ReportConstants.TOTAL_CREDIT, BigDecimal.ZERO);
				do {
					String branchCode = "";
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
						if (ReportConstants.BRANCH_CODE.equals(field.getFieldName())) {
							branchCode = field.getValue();
						}
					}
					currentDebitCreditFlag = rs.getString(ReportConstants.DEBIT_CREDIT);

					if (recordCount >= MAX_RECORD_PER_PAGE) {
						writeHeader(rgm, pageCount);
						writeBodyHeader(rgm);
						pageCount++;
						recordCount = 0;
					}

					if (currentDebitCreditFlag.equals(lastDebitCreditFlag)) {
						newGroup = false;
					} else {
						if (lastDebitCreditFlag != null) {
							writeTxtTrailer(rgm, lineFieldsMap, DEFAULT_LEADING, summaryTotal);
							writeHeader(rgm, pageCount);
							writeBodyHeader(rgm);
							pageCount++;
						}
						newGroup = true;
						lastDebitCreditFlag = currentDebitCreditFlag;
						// reset total
						summaryTotal.put(ReportConstants.TOTAL_DEBIT, BigDecimal.ZERO);
						summaryTotal.put(ReportConstants.TOTAL_CREDIT, BigDecimal.ZERO);
					}

					writeBody(rgm, lineFieldsMap, branchCode, newGroup, summaryTotal);
					recordCount++;
				} while (rs.next());
				writeTxtTrailer(rgm, lineFieldsMap, DEFAULT_LEADING, summaryTotal);
			} else {
				StringBuilder line = new StringBuilder();
				line.append(getEol());
				line.append(ReportConstants.NO_RECORD);
				rgm.writeLine(line.toString().getBytes());
			}
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (Exception e) {
			logger.error("Failed to generate report.", e);
			throw new RuntimeException(e);
		} finally {
			rgm.cleanAllDbResource(ps, rs);
		}
		
	}

	protected void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, Map<String, BigDecimal> summaryTotal)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In PdfReportProcessor.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (summaryTotal.containsKey(field.getFieldName())) {
				field.setDefaultValue(summaryTotal.get(field.getFieldName()).toString());
			}
			contentStream.showText(getFieldValue(rgm, field, fieldsMap));

			if (field.isEol()) {
				contentStream.newLineAtOffset(0, -leading);
			}
		}
	}

	protected void writeTxtTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			float leading, Map<String, BigDecimal> summaryTotal)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In PdfReportProcessor.writePdfTrailer()");
		StringBuilder line = new StringBuilder();
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (summaryTotal.containsKey(field.getFieldName())) {
				field.setDefaultValue(summaryTotal.get(field.getFieldName()).toString());
			}
			line.append(getFieldValue(rgm, field, fieldsMap));
			if (field.isEol()) {
				line.append(getEol());
			}
		}
		line.append(getEol());
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private PDPageContentStream newPage(ReportGenerationMgr rgm, PDDocument doc, PDFont pdfFont, float fontSize,
			float margin, int pageCount) throws IOException, JSONException {
		PDPage page;
		PDRectangle pageSize;
		float startX;
		float startY;
		page = new PDPage();
		doc.addPage(page);
		PDPageContentStream contentStream = new PDPageContentStream(doc, page);
		pageSize = page.getMediaBox();
		startX = pageSize.getLowerLeftX() + margin;
		startY = pageSize.getUpperRightY() - margin;
		contentStream.setFont(pdfFont, fontSize);
		contentStream.beginText();
		contentStream.newLineAtOffset(startX, startY);

		writePdfHeader(rgm, contentStream, DEFAULT_LEADING, pageCount);
		contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
		writePdfBodyHeader(rgm, contentStream, DEFAULT_LEADING);

		return contentStream;
	}

	@Override
	protected SortedSet<String> filterByBranchCode(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetAcquirer.filterByBranchCode()");
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
				ps = rgm.getConnection().prepareStatement(query);
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
				rgm.cleanAllDbResource(ps, rs);
			}
		}
		return branchCodeList;
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffBlocksheetCashCard.preProcessing()");
		if (filterByBranchCode != null && rgm.getBodyQuery() != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "CRDC.CRD_BRANCH_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}
	}

	private void pdfProcessingDetail(ReportGenerationMgr rgm, String branchCode, PDPageContentStream contentStream,
			PDDocument doc, PDPage page, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In GLHandoffBlocksheetCashCard.pdfProcessingDetail()");
		try {
			// preProcessing(rgm, branchCode);
			writePdfHeader(rgm, contentStream, leading, pagination);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize, branchCode);
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in pdfProcessingDetail", e);
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, String branchCode) {
		logger.debug("In GLHandoffBlocksheetAcquirer.executePdfBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					if (pageHeight > totalHeight && !endBranch) {
						endBranch = false;
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
						contentStream.newLineAtOffset(0, -leading);
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, branchCode, false, null);
					pageHeight++;
				}
				pageHeight += 1;
				executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
				pageHeight += 1;
				contentStream.endText();
				contentStream.close();
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
		return contentStream;
	}

	private void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, String branchCode, boolean isNewGroup,
			Map<String, BigDecimal> summaryTotal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		String overflowAccName = null;
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (!isNewGroup) {
				switch (field.getFieldName()) {
				case ReportConstants.BRANCH_CODE:
				case ReportConstants.GL_ACCOUNT_NUMBER:
				case ReportConstants.GL_ACCOUNT_NAME:
				case ReportConstants.DESCRIPTION:
					if (field.isEol()) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
							contentStream.showText(
									String.format("%1$4s", "") + String.format("%1$" + field.getPdfLength() + "s", ""));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						}
					}
					break;
				case ReportConstants.DEBIT:
					String debitVal = getFieldValue(rgm, field, fieldsMap).replace(",", "").trim();
					BigDecimal totalDebit = new BigDecimal(debitVal).add(summaryTotal.get(ReportConstants.TOTAL_DEBIT));
					summaryTotal.put(ReportConstants.TOTAL_DEBIT, totalDebit);
					contentStream.showText(field.format(rgm, false, false, true, false));
					break;
				case ReportConstants.CREDIT:
					String creditVal = getFieldValue(rgm, field, fieldsMap).replace(",", "").trim();
					BigDecimal totalCredit = new BigDecimal(creditVal)
							.add(summaryTotal.get(ReportConstants.TOTAL_CREDIT));
					summaryTotal.put(ReportConstants.TOTAL_CREDIT, totalCredit);
					contentStream.showText(field.format(rgm, false, false, true, false));
					break;
				default:
					if (field.isEol()) {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
					break;
				}
			} else {
				if (field.isEol()) {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					switch (field.getFieldName()) {
					case ReportConstants.GL_ACCOUNT_NUMBER:
						if (getFieldValue(field, fieldsMap).length() < 14) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									branchCode + getFieldValue(field, fieldsMap)));
						} else {
							contentStream.showText(
									String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap)));
						}
						break;
					case ReportConstants.GL_ACCOUNT_NAME:
						String value = getFieldValue(field, fieldsMap);
						if (value != null && value.length() > field.getPdfLength()) {
							overflowAccName = value.substring(value.length() - 6);
							contentStream.showText(
									String.format("%1$4s", "") + String.format("%1$" + field.getPdfLength() + "s",
											getFieldValue(rgm, field, fieldsMap).substring(0, value.length() - 6)));
						} else {
							contentStream.showText(String.format("%1$4s", "") + String
									.format("%1$" + field.getPdfLength() + "s", getFieldValue(rgm, field, fieldsMap)));
						}
						break;
					case ReportConstants.DEBIT:
						String debitVal = getFieldValue(rgm, field, fieldsMap).replace(",", "").trim();
						BigDecimal totalDebit = new BigDecimal(debitVal)
								.add(summaryTotal.get(ReportConstants.TOTAL_DEBIT));
						summaryTotal.put(ReportConstants.TOTAL_DEBIT, totalDebit);
						contentStream.showText(field.format(rgm, false, false, true, false));
						break;
					case ReportConstants.CREDIT:
						String creditVal = getFieldValue(rgm, field, fieldsMap).replace(",", "").trim();
						BigDecimal totalCredit = new BigDecimal(creditVal)
								.add(summaryTotal.get(ReportConstants.TOTAL_CREDIT));
						summaryTotal.put(ReportConstants.TOTAL_CREDIT, totalCredit);
						contentStream.showText(field.format(rgm, false, false, true, false));
						break;
					default:
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
						break;
					}
				}
			}
		}
		if (overflowAccName != null && overflowAccName.length() > 0) {
			contentStream.showText(String.format("%1$28s", "") + overflowAccName);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			overflowAccName = null;
		}
		// firstRecord = false;
	}

	private void processingDetail(ReportGenerationMgr rgm, String branchCode) {
		logger.debug("In GLHandoffBlocksheetAcquirer.processingDetail()");
		try {
			// preProcessing(rgm, branchCode);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, branchCode);
			executeTrailerQuery(rgm);
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in processingDetail", e);
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffBlocksheetCashCard.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetCashCard.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setDebitBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCriteriaQuery(getDebitBodyQuery());
		}

		if (rgm.getTrailerQuery() != null) {
			setDebitTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setCreditTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}

	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String branchCode, boolean newGroup, Map<String, BigDecimal> summaryTotal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		String overflowAccName = null;
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (!newGroup) {
				switch (field.getFieldName()) {
				case ReportConstants.BRANCH_CODE:
				case ReportConstants.GL_ACCOUNT_NUMBER:
				case ReportConstants.GL_ACCOUNT_NAME:
				case ReportConstants.DESCRIPTION:
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
						line.append(
								String.format("%1$4s", "") + String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					}
					break;
				case ReportConstants.DEBIT:
					String debitVal = getFieldValue(rgm, field, fieldsMap).replace(",", "").trim();
					BigDecimal totalDebit = new BigDecimal(debitVal).add(summaryTotal.get(ReportConstants.TOTAL_DEBIT));
					summaryTotal.put(ReportConstants.TOTAL_DEBIT, totalDebit);
					line.append(field.format(rgm, false, false, true, false));
					break;
				case ReportConstants.CREDIT:
					String creditVal = getFieldValue(rgm, field, fieldsMap).replace(",", "").trim();
					BigDecimal totalCredit = new BigDecimal(creditVal)
							.add(summaryTotal.get(ReportConstants.TOTAL_CREDIT));
					summaryTotal.put(ReportConstants.TOTAL_CREDIT, totalCredit);
					line.append(field.format(rgm, false, false, true, false));
					break;
				default:
					line.append(getFieldValue(rgm, field, fieldsMap));
					break;
				}
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.GL_ACCOUNT_NUMBER:
					if (getFieldValue(field, fieldsMap).length() < 14) {
						line.append(
								String.format("%1$" + field.getCsvTxtLength() + "s", branchCode + field.getValue()));
					} else {
						line.append(
								String.format("%1$" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap)));
					}

					break;
				case ReportConstants.GL_ACCOUNT_NAME:
					String value = getFieldValue(field, fieldsMap);
					if (value != null && value.length() > field.getPdfLength()) {
						overflowAccName = value.substring(value.length() - 6);
						line.append(String.format("%1$4s", "") + String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(rgm, field, fieldsMap).substring(0, value.length() - 6)));
					} else {
						line.append(String.format("%1$4s", "") + String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(rgm, field, fieldsMap)));
					}
					break;
				case ReportConstants.DEBIT:
					String debitVal = getFieldValue(rgm, field, fieldsMap).replace(",", "").trim();
					BigDecimal totalDebit = new BigDecimal(debitVal).add(summaryTotal.get(ReportConstants.TOTAL_DEBIT));
					summaryTotal.put(ReportConstants.TOTAL_DEBIT, totalDebit);
					line.append(field.format(rgm, false, false, true, false));
					break;
				case ReportConstants.CREDIT:
					String creditVal = getFieldValue(rgm, field, fieldsMap).replace(",", "").trim();
					BigDecimal totalCredit = new BigDecimal(creditVal)
							.add(summaryTotal.get(ReportConstants.TOTAL_CREDIT));
					summaryTotal.put(ReportConstants.TOTAL_CREDIT, totalCredit);
					line.append(field.format(rgm, false, false, true, false));
					break;
				default:
					line.append(getFieldValue(rgm, field, fieldsMap));
					break;
				}
			}
		}
		line.append(getEol());
		if (overflowAccName != null && overflowAccName.length() > 0) {
			line.append(String.format("%1$28s", "") + overflowAccName);
			line.append(getEol());
			overflowAccName = null;
		}
		rgm.writeLine(line.toString().getBytes());
		// firstRecord = false;
	}

	private boolean executeQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetCashCard.executeQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = getBodyQuery(rgm);
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.getConnection().prepareStatement(query);
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
			rgm.cleanAllDbResource(ps, rs);
		}
		return false;
	}

	private void writeNoRecordFound(PDPageContentStream stream) throws Exception {
		stream.setFont(PDType1Font.COURIER, DEFAULT_FONT_SIZE);
		stream.newLineAtOffset(0, -DEFAULT_LEADING);
		stream.showText(ReportConstants.NO_RECORD);
	}
}
