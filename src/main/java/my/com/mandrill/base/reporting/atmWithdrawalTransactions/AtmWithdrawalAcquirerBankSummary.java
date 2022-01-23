package my.com.mandrill.base.reporting.atmWithdrawalTransactions;

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

public class AtmWithdrawalAcquirerBankSummary extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(AtmWithdrawalAcquirerBankSummary.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private boolean branchDetails = false;
	private boolean bankDetails = false;

//	@Override
//	public void executePdf(ReportGenerationMgr rgm) {
//		logger.debug("In AtmWithdrawalAcquirerBankSummary.processPdfRecord()");
//		PDDocument doc = null;
//		pagination = 1;
//		try {
//			doc = new PDDocument();
//			PDPage page = new PDPage();
//			doc.addPage(page);
//			PDPageContentStream contentStream = new PDPageContentStream(doc, page);
//			PDFont pdfFont = PDType1Font.COURIER;
//			float fontSize = 6;
//			float leading = 1.5f * fontSize;
//			PDRectangle pageSize = page.getMediaBox();
//			float margin = 30;
//			float width = pageSize.getWidth() - 2 * margin;
//			float startX = pageSize.getLowerLeftX() + margin;
//			float startY = pageSize.getUpperRightY() - margin;
//			String branchCode = null;
//			String branchName = null;
//			String terminal = null;
//			String location = null;
//
//			preProcessingInstitution(rgm);
//			separateQuery(rgm);
//			preProcessing(rgm);
//
//			contentStream.setFont(pdfFont, fontSize);
//			contentStream.beginText();
//			contentStream.newLineAtOffset(startX, startY);
//
//			bankDetails = false;
//			writePdfHeader(rgm, contentStream, leading, pagination);
//			contentStream.newLineAtOffset(0, -leading);
//			pageHeight += 4;
//			writeBranchPdfBodyHeader(rgm, contentStream, leading);
//			pageHeight += 2;
//
//			rgm.setBodyQuery(getCriteriaQuery());
//			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
//					rgm).entrySet()) {
//				branchCode = branchCodeMap.getKey();
//				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
//						.entrySet()) {
//					branchDetails = true;
//					branchName = branchNameMap.getKey();
//					preProcessing(rgm, branchCode, terminal);
//					rgm.setBodyQuery(getBranchDetailBodyQuery());
//					contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
//							startY, pdfFont, fontSize, branchDetails, bankDetails, branchName, location);
//					pageHeight += 1;
//					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
//						terminal = terminalMap.getKey();
//						location = terminalMap.getValue();
//						branchDetails = false;
//						rgm.setBodyQuery(getBranchBodyQuery());
//						preProcessing(rgm, branchCode, terminal);
//						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
//								startY, pdfFont, fontSize, branchDetails, bankDetails, branchName, location);
//						pageHeight += 1;
//					}
//				}
//			}
//			rgm.setTrailerQuery(getBranchTrailerQuery());
//			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize,
//					bankDetails);
//			pageHeight += 1;
//			contentStream.newLineAtOffset(0, -leading);
//			contentStream.newLineAtOffset(0, -leading);
//			pageHeight += 1;
//			contentStream.showText(String.format("%1$56s", "") + "*** END OF REPORT ***");
//			contentStream.endText();
//			contentStream.close();
//
//			bankDetails = true;
//			pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
//			page = new PDPage();
//			doc.addPage(page);
//			pagination++;
//			contentStream = new PDPageContentStream(doc, page);
//			contentStream.setFont(pdfFont, fontSize);
//			contentStream.beginText();
//			contentStream.newLineAtOffset(startX, startY);
//			writePdfHeader(rgm, contentStream, leading, pagination);
//			contentStream.newLineAtOffset(0, -leading);
//			pageHeight += 4;
//			writeBankPdfBodyHeader(rgm, contentStream, leading);
//			pageHeight += 2;
//			rgm.setBodyQuery(getBankBodyQuery());
//			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
//					pdfFont, fontSize, branchDetails, bankDetails, branchName, location);
//			rgm.setTrailerQuery(getBankTrailerQuery());
//			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize,
//					bankDetails);
//			pageHeight += 1;
//			contentStream.newLineAtOffset(0, -leading);
//			pageHeight += 1;
//			contentStream.showText(String.format("%1$56s", "") + "*** END OF REPORT ***");
//			contentStream.endText();
//			contentStream.close();
//
//			saveFile(rgm, doc);
//		} catch (Exception e) {
//			rgm.errors++;
//			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
//		} finally {
//			if (doc != null) {
//				try {
//					doc.close();
//					rgm.exit();
//				} catch (IOException e) {
//					rgm.errors++;
//					logger.error("Error in closing PDF file", e);
//				}
//			}
//		}
//	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		String location = null;
		StringBuilder line = new StringBuilder();
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			preProcessingInstitution(rgm);
			separateQuery(rgm);
			preProcessing(rgm);
			bankDetails = false;
			writeHeader(rgm, pagination);
			writeBranchBodyHeader(rgm);
			rgm.setBodyQuery(getCriteriaQuery());
			for (SortedMap.Entry<String, Map<String, TreeMap<String, String>>> branchCodeMap : filterCriteriaByBranch(
					rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, TreeMap<String, String>> branchNameMap : branchCodeMap.getValue()
						.entrySet()) {
					branchDetails = true;
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, terminal);
					rgm.setBodyQuery(getBranchDetailBodyQuery());
					executeBodyQuery(rgm, bankDetails, branchName, location);
					for (SortedMap.Entry<String, String> terminalMap : branchNameMap.getValue().entrySet()) {
						terminal = terminalMap.getKey();
						location = terminalMap.getValue();
						branchDetails = false;
						rgm.setBodyQuery(getBranchBodyQuery());
						preProcessing(rgm, branchCode, terminal);
						executeBodyQuery(rgm, bankDetails, branchName, location);
					}
				}
			}
			rgm.setTrailerQuery(getBranchTrailerQuery());
			executeTrailerQuery(rgm, bankDetails);
			line.append("*** END OF REPORT ***");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());

			bankDetails = true;
			line = new StringBuilder();
			line.append(getEol());
			pagination++;
			writeHeader(rgm, pagination);
			writeBankBodyHeader(rgm);
			rgm.setBodyQuery(getBankBodyQuery());
			executeBodyQuery(rgm, bankDetails, branchName, location);
			rgm.setTrailerQuery(getBankTrailerQuery());
			executeTrailerQuery(rgm, bankDetails);
			line.append("*** END OF REPORT ***");
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());

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
	
	private void preProcessingInstitution(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.preProcessingInstitution()");
		if (rgm.getBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_DEO_NAME + "}", "AND TXN.TRL_DEO_NAME = '" + rgm.getInstitution() + "'"));
		}

		if (rgm.getTrailerQuery() != null) {
			rgm.setTrailerQuery(rgm.getTrailerQuery().replace("AND {" + ReportConstants.PARAM_DEO_NAME + "}", "AND TXN.TRL_DEO_NAME = '" + rgm.getInstitution() + "'"));
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setBranchBodyQuery(
					rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setBankBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setBranchDetailBodyQuery(getBranchBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", "")
					.replace("SUBSTR(AST.AST_TERMINAL_ID, -4) \"TERMINAL\",", "").replace("\"TERMINAL\",", "")
					.replace("\"TERMINAL\" ASC", "")
					.replace(
							getBranchBodyQuery().substring(getBranchBodyQuery().indexOf("GROUP BY"),
									getBranchBodyQuery().indexOf("ORDER BY")),
							"GROUP BY \"BRANCH CODE\", \"BRANCH NAME\" ")
					.replace("\"BRANCH NAME\" ASC,", "\"BRANCH NAME\" ASC"));
			setCriteriaQuery(getBranchBodyQuery());
		}

		if (rgm.getTrailerQuery() != null) {
			setBranchTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setBankTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.preProcessing()");
		if (filterByBranchCode != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null) {
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "SUBSTR(AST.AST_TERMINAL_ID, -4) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}

	private void writeBranchBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBranchBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 7:
			case 8:
			case 9:
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
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBankBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBankBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 19:
			case 20:
			case 21:
			case 22:
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

	private void writeBranchPdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBranchPdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
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
				if (field.isEol()) {
					contentStream.showText(getGlobalFieldValue(rgm, field));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
				break;
			}
		}
	}

	private void writeBankPdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBankPdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
				if (field.isEol()) {
					contentStream.showText(getGlobalFieldValue(rgm, field));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
				break;
			default:
				break;
			}
		}
	}

	private void writeBranchBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String branchName, String location)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 24:
			case 25:
			case 26:
			case 27:
				break;
			default:
				if (branchDetails) {
					if (!field.getFieldName().equalsIgnoreCase(ReportConstants.TERMINAL)
							&& !field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
						if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
							line.append(branchName);
						} else {
							line.append(getFieldValue(rgm, field, fieldsMap));
						}
						line.append(field.getDelimiter());
					} else {
						line.append("");
						line.append(field.getDelimiter());
					}
				} else {
					if (!field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)
							&& !field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
						if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
							line.append(location);
						} else {
							line.append(getFieldValue(rgm, field, fieldsMap));
						}
						line.append(field.getDelimiter());
					} else {
						line.append("");
						line.append(field.getDelimiter());
					}
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBankBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 24:
			case 25:
			case 26:
			case 27:
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.NET_SETTLEMENT)) {
					line.append(getFieldValue(rgm, field, fieldsMap) + " DR");
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
				}
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBranchPdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, boolean branchDetails, String branchName, String location)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 24:
			case 25:
			case 26:
			case 27:
				break;
			default:
				if (field.isEol()) {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					if (branchDetails) {
						if (!field.getFieldName().equalsIgnoreCase(ReportConstants.TERMINAL)
								&& !field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
							if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", branchName));
							} else {
								contentStream.showText(getFieldValue(rgm, field, fieldsMap));
							}
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						}
					} else {
						if (!field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)
								&& !field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
							if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", location));
							} else {
								contentStream.showText(getFieldValue(rgm, field, fieldsMap));
							}
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						}
					}
				}
				break;
			}
		}
	}

	private void writeBankPdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 24:
			case 25:
			case 26:
			case 27:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.NET_SETTLEMENT)) {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap) + " DR");
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				}
				break;
			default:
				break;
			}
		}
	}

	private void executeBodyQuery(ReportGenerationMgr rgm, boolean bankDetails, String branchName, String location) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.executeBodyQuery()");
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
					if (bankDetails) {
						writeBankBody(rgm, lineFieldsMap);
					} else {
						writeBranchBody(rgm, lineFieldsMap, branchName, location);
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, boolean branchDetails, boolean bankDetails, String branchName,
			String location) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.executePdfBodyQuery()");
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
					if (bankDetails) {
						writeBankPdfBody(rgm, lineFieldsMap, contentStream, leading);
					} else {
						writeBranchPdfBody(rgm, lineFieldsMap, contentStream, leading, branchDetails, branchName,
								location);
					}
					pageHeight++;
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
		return contentStream;
	}

	private void writeBranchTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBranchTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		String total = null;
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
				break;
			default:
				if (field.isEol()) {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
						total = getFieldValue(rgm, field, fieldsMap);
					}
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
						line.append(total);
					} else {
						line.append(getFieldValue(rgm, field, fieldsMap));
					}
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBankTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBankTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 17:
			case 18:
			case 19:
			case 20:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.NET_SETTLEMENT)) {
						line.append(getFieldValue(rgm, field, fieldsMap) + " DR");
						line.append(field.getDelimiter());
					} else {
						line.append(getFieldValue(rgm, field, fieldsMap));
						line.append(field.getDelimiter());
						line.append(getEol());
					}
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
					line.append(field.getDelimiter());
				}
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBranchPdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBranchPdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		String total = null;
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
				break;
			default:
				if (field.isEol()) {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
						total = getFieldValue(field, fieldsMap);
					}
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", total));
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
				}
				break;
			}
		}
	}

	private void writeBankPdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBankPdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
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
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.NET_SETTLEMENT)) {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap) + " DR");
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				}
				break;
			default:
				break;
			}
		}
	}

	private void executeTrailerQuery(ReportGenerationMgr rgm, boolean bankDetails) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.executeTrailerQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
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
					if (bankDetails) {
						writeBankTrailer(rgm, lineFieldsMap);
					} else {
						writeBranchTrailer(rgm, lineFieldsMap);
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}

	private void executePdfTrailerQuery(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream,
			PDRectangle pageSize, float leading, float startX, float startY, PDFont pdfFont, float fontSize,
			boolean bankDetails) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.executePdfTrailerQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
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
					if (bankDetails) {
						writeBankPdfTrailer(rgm, lineFieldsMap, contentStream, leading);
					} else {
						writeBranchPdfTrailer(rgm, lineFieldsMap, contentStream, leading);
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}
}
