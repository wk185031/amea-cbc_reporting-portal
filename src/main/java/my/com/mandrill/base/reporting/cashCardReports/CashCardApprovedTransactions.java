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

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class CashCardApprovedTransactions extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(CashCardApprovedTransactions.class);

	private float DEFAULT_MARGIN = 30;

	private float DEFAULT_FONT_SIZE = 6;

	private float DEFAULT_LEADING = 1.5f * DEFAULT_FONT_SIZE;

	private int lineCounter = 0;

	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	String[] CASH_CARD_PRODUCTS = new String[] { "EMV CASH CARD", "EMV CASH CARD-CORP" };
	private static final String TXN_GROUP_ONUS = "FROM ONUS TRANSACTIONS";
	private static final String TXN_GROUP_IE = "FROM INTER-ENTITY TRANSACTIONS";
	private static final String TXN_GROUP_ISSUING = "FROM ISSUING TRANSACTIONS";

	private static final String KEY_BRANCH = "BRANCH CODE";
	private static final String KEY_TXN_GROUP = "TRANSACTION GROUP";
	private static final String KEY_TERMINAL = "TERMINAL";
	private static final String KEY_CARD_PRODUCT = "CARD PRODUCT";

	@Override
	public void executePdf(ReportGenerationMgr rgm) throws ReportGenerationException {
		PDDocument doc = null;
		PDPageContentStream contentStream = null;

		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;

		try {
			addReportPreProcessingFieldsToGlobalMap(rgm);
			String query = getBodyQuery(rgm);
			logger.debug("execute query:{}", query);
			Map<String, String> groupingField = new HashMap<String, String>();
			doc = new PDDocument();

			if (query != null && !query.trim().isEmpty()) {
				try {
					ps = rgm.getConnection().prepareStatement(query);
					rs = ps.executeQuery();
					fieldsMap = rgm.getQueryResultStructure(rs);
					lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

					if (rs.next()) {
						do {
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
										field.setValue(Long
												.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
									} else if (result instanceof oracle.sql.DATE) {
										field.setValue(
												Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
									} else {
										field.setValue(result.toString());
									}
								} else {
									field.setValue("");
								}

							}
							contentStream = writeRowData(rgm, doc, lineFieldsMap, groupingField, contentStream);
							if (getLineCounter() >= getMaxLinePerPage()) {
								contentStream = newPage(doc, contentStream, rgm, groupingField.get(KEY_BRANCH), "");
							}

						} while (rs.next());
					} else {
						contentStream = newPage(doc, contentStream, rgm, "", "");
						writeNoRecordFound(contentStream);
						incrementLineCounter();
					}
					contentStream.endText();
					contentStream.close();
					saveFile(rgm, doc);

				} catch (Exception e) {
					rgm.errors++;
					logger.error("Error trying to execute the body query", e);
					throw new ReportGenerationException("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
				} finally {
					try {
						doc.close();
					} catch (Exception e) {
						logger.error("Error closing doc", e);
					}
					rgm.cleanUpDbResource(ps, rs);
				}
			}
		} finally {
			if (doc != null) {
				try {
					doc.close();
				} catch (Exception e) {
					logger.warn("Failed to close document.");
				}

			}
			rgm.exit();
		}
	}

	private PDPageContentStream newPage(PDDocument doc, PDPageContentStream contentStream, ReportGenerationMgr rgm,
			String branchCode, String branchName) throws Exception {
		if (contentStream != null) {
			contentStream.endText();
			contentStream.close();
		}

		PDPage page = new PDPage();
		doc.addPage(page);
		logger.debug("create new page: {}", doc.getNumberOfPages());

		contentStream = new PDPageContentStream(doc, page);
		contentStream.setFont(PDType1Font.COURIER, DEFAULT_FONT_SIZE);
		contentStream.beginText();
		contentStream.newLineAtOffset(page.getMediaBox().getLowerLeftX() + DEFAULT_MARGIN,
				page.getMediaBox().getUpperRightY() - DEFAULT_MARGIN);

		contentStream = writeReportHeader(rgm, doc, contentStream, branchCode, branchName);
		resetLineCounter();
		return contentStream;
	}

	private PDPageContentStream writeReportHeader(ReportGenerationMgr rgm, PDDocument doc,
			PDPageContentStream contentStream, String branchCode, String branchName) throws Exception {
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					contentStream = writeText(rgm, contentStream, String.valueOf(doc.getNumberOfPages()));
				} else {
					contentStream = writeText(rgm, contentStream, getGlobalFieldValue(rgm, field));
				}
				contentStream = writeText(rgm, contentStream, null);
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					contentStream = writeText(rgm, contentStream,
							String.format("%1$-" + field.getPdfLength() + "s", branchCode));
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
					contentStream = writeText(rgm, contentStream,
							String.format("%1$-" + field.getPdfLength() + "s", branchName));
				} else {
					contentStream = writeText(rgm, contentStream, getGlobalFieldValue(rgm, field));
				}
			}
		}
		contentStream = writeText(rgm, contentStream, null);
		contentStream = writeText(rgm, contentStream, null);
		return contentStream;
	}

	private PDPageContentStream writeText(ReportGenerationMgr rgm, PDPageContentStream contentStream, String text)
			throws Exception {
		if (text == null) {
			contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
		} else {
			contentStream.showText(text);
		}
		return contentStream;
	}

//	@Override
//	public void executePdf(ReportGenerationMgr rgm) {
//		logger.debug("In CashCardApprovedTransactions.processPdfRecord()");
//		PDDocument doc = null;
//		PDPage page = null;
//		PDPageContentStream contentStream = null;
//		PDRectangle pageSize = null;
//		PDFont pdfFont = PDType1Font.COURIER;
//		float fontSize = 6;
//		float leading = 1.5f * fontSize;
//		float margin = 30;
//		float width = 0.0f;
//		float startX = 0.0f;
//		float startY = 0.0f;
//		pagination = 0;
//		String branchCode = null;
//		String branchName = null;
//		String terminal = null;
//		String location = null;
//		String cardProduct = null;
//		try {
//			doc = new PDDocument();
//			preProcessing(rgm);
//
//			if (!executeQuery(rgm)) {
//				page = new PDPage();
//				doc.addPage(page);
//				contentStream = new PDPageContentStream(doc, page);
//				pageSize = page.getMediaBox();
//				width = pageSize.getWidth() - 2 * margin;
//				startX = pageSize.getLowerLeftX() + margin;
//				startY = pageSize.getUpperRightY() - margin;
//				contentStream.setFont(pdfFont, fontSize);
//				contentStream.beginText();
//				contentStream.newLineAtOffset(startX, startY);
//				contentStream.endText();
//				contentStream.close();
//				saveFile(rgm, doc);
//			} else {
//				for (SortedMap.Entry<String, Map<String, TreeMap<String, Map<String, String>>>> branchCodeMap : filterCriteriaForCashCard(
//						rgm).entrySet()) {
//					branchCode = branchCodeMap.getKey();
//					pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
//					page = new PDPage();
//					doc.addPage(page);
//					pagination++;
//					contentStream = new PDPageContentStream(doc, page);
//					pageSize = page.getMediaBox();
//					width = pageSize.getWidth() - 2 * margin;
//					startX = pageSize.getLowerLeftX() + margin;
//					startY = pageSize.getUpperRightY() - margin;
//					contentStream.setFont(pdfFont, fontSize);
//					contentStream.beginText();
//					contentStream.newLineAtOffset(startX, startY);
//
//					for (SortedMap.Entry<String, TreeMap<String, Map<String, String>>> branchNameMap : branchCodeMap
//							.getValue().entrySet()) {
//						branchName = branchNameMap.getKey();
//						// preProcessing(rgm, branchCode, terminal, null);
//						writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
//						contentStream.newLineAtOffset(0, -leading);
//						pageHeight += 4;
//
//						for (String txnGroup : TRANSACTION_GROUPS) {
//							overwriteTransactionGroupCondition(rgm, txnGroup);
//							contentStream.showText(txnGroup);
//							contentStream.newLineAtOffset(0, -leading);
//							pageHeight += 1;
//														
//							for (SortedMap.Entry<String, Map<String, String>> terminalMap : branchNameMap.getValue()
//									.entrySet()) {
//								terminal = terminalMap.getKey();
//								for (SortedMap.Entry<String, String> locationMap : terminalMap.getValue().entrySet()) {
//									location = locationMap.getKey();
//									cardProduct = locationMap.getValue();
//									contentStream
//											.showText(ReportConstants.TERMINAL + " " + terminal + " AT " + location);
//									pageHeight += 1;
//									contentStream.newLineAtOffset(0, -leading);
//									for (String cardProd : CASH_CARD_PRODUCTS) {
//										contentStream.showText(ReportConstants.CARD_PRODUCT + " - " + cardProd);
//										pageHeight += 1;
//										contentStream.newLineAtOffset(0, -leading);
//										writePdfBodyHeader(rgm, contentStream, leading);
//										pageHeight += 2;
//										float initialPageHeight = pageHeight;
//										preProcessing(rgm, branchCode, terminal, cardProd);
//										contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize,
//												leading, startX, startY, pdfFont, fontSize);
//										if (pageHeight <= initialPageHeight) {
//											contentStream.showText("** NO RECORDS FOUND **");
//											contentStream.newLineAtOffset(0, -leading);
//											contentStream.newLineAtOffset(0, -leading);
//											pageHeight += 1;
//										}
//										pageHeight += 1;
//									}
//								}
//							}
//						}
//					}
//
//					contentStream.endText();
//					contentStream.close();
//				}
//				saveFile(rgm, doc);
//			}
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
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;

		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			String query = getBodyQuery(rgm);
			logger.debug("execute query:{}", query);
			Map<String, String> groupingField = new HashMap<String, String>();

			if (query != null && !query.trim().isEmpty()) {
				try {
					ps = rgm.getConnection().prepareStatement(query);
					rs = ps.executeQuery();
					fieldsMap = rgm.getQueryResultStructure(rs);
					lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

					if (rs.next()) {
						do {
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
										field.setValue(Long
												.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
									} else if (result instanceof oracle.sql.DATE) {
										field.setValue(
												Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
									} else {
										field.setValue(result.toString());
									}
								} else {
									field.setValue("");
								}

							}
							writeRowData(rgm, lineFieldsMap, groupingField);

						} while (rs.next());
					} else {
						rgm.writeLine(ReportConstants.NO_RECORD.getBytes());
					}

				} catch (Exception e) {
					rgm.errors++;
					logger.error("Error trying to execute the body query", e);
				} finally {
					rgm.cleanUpDbResource(ps, rs);
				}
			}
		} catch (Exception e) {
			logger.error("Failed to write file.", e);
			throw new RuntimeException(e);
		} finally {

			try {
				if (rgm.fileOutputStream != null) {
					rgm.fileOutputStream.flush();
					rgm.fileOutputStream.close();
				}
			} catch (Exception e) {
				logger.warn("Failed to close document.");
			}

		}
	}

//	@Override
//	protected void execute(ReportGenerationMgr rgm, File file) {
//		String branchCode = null;
//		String branchName = null;
//		String terminal = null;
//		String location = null;
//		String cardProduct = null;
//
//		try {
//			rgm.fileOutputStream = new FileOutputStream(file);
//			pagination = 0;
//			rgm.setBodyQuery(rgm.getFixBodyQuery());
//			preProcessing(rgm);
//
//			for (SortedMap.Entry<String, Map<String, TreeMap<String, Map<String, String>>>> branchCodeMap : filterCriteriaForCashCard(
//					rgm).entrySet()) {
//				branchCode = branchCodeMap.getKey();
//				for (SortedMap.Entry<String, TreeMap<String, Map<String, String>>> branchNameMap : branchCodeMap
//						.getValue().entrySet()) {
//					branchName = branchNameMap.getKey();
//					pagination++;
//					preProcessing(rgm, branchCode, terminal, cardProduct);
//					writeHeader(rgm, pagination, branchCode, branchName);
//
//					for (String txnGroup : TRANSACTION_GROUPS) {
//						overwriteTransactionGroupCondition(rgm, txnGroup);
//						for (SortedMap.Entry<String, Map<String, String>> terminalMap : branchNameMap.getValue()
//								.entrySet()) {
//							terminal = terminalMap.getKey();
//							for (SortedMap.Entry<String, String> locationMap : terminalMap.getValue().entrySet()) {
//
//								location = locationMap.getKey();
//								cardProduct = locationMap.getValue();
//
//								for (String cardProd : CASH_CARD_PRODUCTS) {
//									StringBuilder line = new StringBuilder();
//									line.append(ReportConstants.TERMINAL + " " + terminal).append(";")
//											.append(" AT " + location).append(";");
//									line.append(ReportConstants.CARD_PRODUCT + " - ").append(";").append(cardProd)
//											.append(";");
//									line.append(getEol());
//									rgm.writeLine(line.toString().getBytes());
//									writeBodyHeader(rgm);
//									preProcessing(rgm, branchCode, terminal, cardProd);
//									int count = executeBodyQueryWithCount(rgm);
//									if (count == 0) {
//										rgm.writeLine("** NO RECORDS FOUND **".getBytes());
//										rgm.writeLine(getEol().getBytes());
//									}
//									rgm.writeLine(getEol().getBytes());
//									rgm.writeLine(getEol().getBytes());
//								}
//							}
//						}
//					}
//				}
//			}
//			rgm.fileOutputStream.flush();
//			rgm.fileOutputStream.close();
//		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
//				| JSONException e) {
//			rgm.errors++;
//			logger.error("Error in generating CSV file", e);
//		} finally {
//			try {
//				if (rgm.fileOutputStream != null) {
//					rgm.fileOutputStream.close();
//					rgm.exit();
//				}
//			} catch (IOException e) {
//				rgm.errors++;
//				logger.error("Error in closing fileOutputStream", e);
//			}
//		}
//	}

	protected void writeRowData(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			Map<String, String> groupingField) throws Exception {
		Map<String, String> groupFieldToUpdate = new HashMap<>();

		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isGroup()) {
				String value = getFieldValue(rgm, field, fieldsMap).trim();

				if (groupingField.containsKey(field.getFieldName())
						&& groupingField.get(field.getFieldName()).equals(value)) {
					// Same group. Do nothing
				} else {
					if (KEY_BRANCH.equals(field.getFieldName())) {
						pagination++;
						writeHeader(rgm, pagination, field.getValue(), "");
						groupingField.remove(KEY_TXN_GROUP);
						groupingField.remove(KEY_TERMINAL);						
						groupingField.remove(KEY_CARD_PRODUCT);
					} else if (KEY_TXN_GROUP.equals(field.getFieldName())) {
						rgm.writeLine(field.getValue().getBytes());
						rgm.writeLine(getEol().getBytes());
						groupingField.remove(KEY_TERMINAL);						
						groupingField.remove(KEY_CARD_PRODUCT);
					} else {
						rgm.writeLine((field.getFieldName() + " - " + field.getValue()).getBytes());
						rgm.writeLine(getEol().getBytes());
						
						if (KEY_TERMINAL.equals(field.getFieldName())) {
							groupingField.remove(KEY_CARD_PRODUCT);
						}
						
						if (KEY_CARD_PRODUCT.equals(field.getFieldName())) {
							rgm.writeLine(getEol().getBytes());
							writeBodyHeader(rgm);
						}											
					}

					groupFieldToUpdate.put(field.getFieldName(), value);
				}

			} else {
				setBody(true);
				setBodyHeader(false);
				if (field.isDecrypt()) {
					decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
				}

				String fieldValue = getFieldValue(rgm, field, fieldsMap);
				line.append("\"" + fieldValue + "\"");
				line.append(field.getDelimiter());
				if (field.isEol()) {
					line.append(getEol());
				}

			}
		}
		rgm.writeLine(line.toString().getBytes());

		groupingField.putAll(groupFieldToUpdate);
	}

	protected PDPageContentStream writeRowData(ReportGenerationMgr rgm, PDDocument doc,
			HashMap<String, ReportGenerationFields> fieldsMap, Map<String, String> groupingField,
			PDPageContentStream contentStream) throws Exception {

		Map<String, String> groupFieldToUpdate = new HashMap<>();

		List<ReportGenerationFields> fields = extractBodyFields(rgm);

		boolean addNewLineInGroup = true;
		for (ReportGenerationFields field : fields) {
			if (field.isGroup()) {
				String value = getFieldValue(rgm, field, fieldsMap).trim();

				if (groupingField.containsKey(field.getFieldName())
						&& groupingField.get(field.getFieldName()).equals(value)) {
					// Same group. Do nothing
				} else {
					if (KEY_BRANCH.equals(field.getFieldName())) {
						contentStream = newPage(doc, contentStream, rgm, field.getValue(), "");
					} else {
						if (groupingField.containsKey(field.getFieldName()) && addNewLineInGroup) {
							// Add new line if have record previously
							contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
							incrementLineCounter(1);
							addNewLineInGroup = false;
						}
						if (KEY_BRANCH.equals(field.getFieldName())) {
							pagination++;
							writeHeader(rgm, pagination, field.getValue(), "");
							groupingField.remove(KEY_TXN_GROUP);
							groupingField.remove(KEY_TERMINAL);						
							groupingField.remove(KEY_CARD_PRODUCT);
						} else if (KEY_TXN_GROUP.equals(field.getFieldName())) {						
							contentStream.showText(field.getValue());
							contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
							incrementLineCounter(1);
							groupingField.remove(KEY_TERMINAL);						
							groupingField.remove(KEY_CARD_PRODUCT);
						} else {
							contentStream.showText(field.getFieldName() + " - " + field.getValue());
							contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
							incrementLineCounter(1);
							
							if (KEY_TERMINAL.equals(field.getFieldName())) {
								groupingField.remove(KEY_CARD_PRODUCT);
							}
							
							if (KEY_CARD_PRODUCT.equals(field.getFieldName())) {
								contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
								writePdfBodyHeader(rgm, contentStream, DEFAULT_LEADING);
								incrementLineCounter(3);
							}
						}
					}
					groupFieldToUpdate.put(field.getFieldName(), value);
				}

			} else {
				setBody(true);
				setBodyHeader(false);
				if (field.isDecrypt()) {
					decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
				}

				String fieldValue = getFieldValue(rgm, field, fieldsMap);
				if (field.isEol()) {
					contentStream.showText(fieldValue);
					contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
					incrementLineCounter(1);
				} else {
					contentStream.showText(fieldValue);
				}
			}
		}

		groupingField.putAll(groupFieldToUpdate);
		return contentStream;
	}

	private void writeNoRecordFound(PDPageContentStream stream) throws Exception {
		stream.setFont(PDType1Font.COURIER, DEFAULT_FONT_SIZE);
		stream.newLineAtOffset(0, -DEFAULT_LEADING);
		stream.showText(ReportConstants.NO_RECORD);
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

		int i = 0;
		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					i++;
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
				rgm.cleanUpDbResource(ps, rs);
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
					.replace("AND {" + ReportConstants.PARAM_CARD_PRODUCT + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TRANSACTION_GROUP + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void overwriteTransactionGroupCondition(ReportGenerationMgr rgm, String transactionGroup) {
		StringBuilder sb = null;
		switch (transactionGroup) {
		case TXN_GROUP_ONUS:
			sb = new StringBuilder();
			sb.append("(TXN.TRL_DEO_NAME = '").append(rgm.getInstitution())
					.append("' OR LPAD(TXN.TRL_ACQR_INST_ID, '0', 10) = '")
					.append("CBC".equals(rgm.getInstitution()) ? "0000000010" : "0000000112").append("')")
					.append(" AND LPAD(TXN.TRL_FRD_REV_INST_ID, '0', 10) != '")
					.append("CBC".equals(rgm.getInstitution()) ? "0000000112" : "0000000010").append("'");
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields onUsCriteria = new ReportGenerationFields(ReportConstants.PARAM_TRANSACTION_GROUP,
					ReportGenerationFields.TYPE_STRING, sb.toString());
			getGlobalFileFieldsMap().put(onUsCriteria.getFieldName(), onUsCriteria);
			break;
		case TXN_GROUP_IE:
			sb = new StringBuilder();
			sb.append("(TXN.TRL_DEO_NAME = '").append("CBC".equals(rgm.getInstitution()) ? "CBS" : rgm.getInstitution())
					.append("' OR LPAD(TXN.TRL_ACQR_INST_ID, '0', 10) = '")
					.append("CBC".equals(rgm.getInstitution()) ? "0000000112" : "0000000010").append("'")
					.append(" OR LPAD(TXN.TRL_FRD_REV_INST_ID, '0', 10) = '")
					.append("CBC".equals(rgm.getInstitution()) ? "0000000010" : "0000000112").append("')");
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields ieCriteria = new ReportGenerationFields(ReportConstants.PARAM_TRANSACTION_GROUP,
					ReportGenerationFields.TYPE_STRING, sb.toString());
			getGlobalFileFieldsMap().put(ieCriteria.getFieldName(), ieCriteria);
			break;

		case TXN_GROUP_ISSUING:
			sb = new StringBuilder();
			sb.append("TXNC.TRL_ORIGIN_CHANNEL = 'BNT'")
					.append(" AND LPAD(TXN.TRL_ACQR_INST_ID, '0', 10) not in ('0000000010', '0000000112')");
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields issuingCriteria = new ReportGenerationFields(ReportConstants.PARAM_TRANSACTION_GROUP,
					ReportGenerationFields.TYPE_STRING, sb.toString());
			getGlobalFileFieldsMap().put(issuingCriteria.getFieldName(), issuingCriteria);
			break;
		default:
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields field = new ReportGenerationFields(ReportConstants.PARAM_TRANSACTION_GROUP,
					ReportGenerationFields.TYPE_STRING, "");
			getGlobalFileFieldsMap().put(field.getFieldName(), field);
			break;
		}

	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByTerminal,
			String filterByCardProduct) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In CashCardApprovedTransactions.preProcessing()");
		if (filterByBranchCode != null && rgm.getTmpBodyQuery() != null) {
			// rgm.setBodyQuery(rgm.getTmpBodyQuery().replace("AND {" +
			// ReportConstants.PARAM_TERMINAL + "}", ""));
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "BRC.BRC_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

		if (filterByTerminal != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING,
					"SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) = '" + filterByTerminal + "'");
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
			rgm.cleanUpDbResource(ps, rs);
		}
		return false;
	}

	private void incrementLineCounter() {
		lineCounter++;
	}

	private void incrementLineCounter(int counterToAdd) {
		lineCounter += counterToAdd;
	}

	private void resetLineCounter() {
		lineCounter = 0;
	}

	private int getLineCounter() {
		return lineCounter;
	}

	private int getMaxLinePerPage() {
		return 70;
	}
}
