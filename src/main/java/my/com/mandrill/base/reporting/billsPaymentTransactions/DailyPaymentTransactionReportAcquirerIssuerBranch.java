package my.com.mandrill.base.reporting.billsPaymentTransactions;

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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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

public class DailyPaymentTransactionReportAcquirerIssuerBranch extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(DailyPaymentTransactionReportAcquirerIssuerBranch.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.processPdfRecord()");
		PDDocument doc = null;
		PDPage page = null;
		PDRectangle pageSize = null;
		PDPageContentStream contentStream = null;
		PDFont pdfFont = PDType1Font.COURIER;
		float fontSize = 6;
		float leading = 1.5f * fontSize;
		float margin = 30;
		float width = 0.0f;
		float startX = 0.0f;
		float startY = 0.0f;
		pagination = 0;
		try {
			doc = new PDDocument();
			String branchCode = null;
			String branchName = null;

			separateQuery(rgm);
			preProcessing(rgm);

			for (SortedMap.Entry<String, String> branchCodeMap : filterByCriteriaByBranch(rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				branchName = branchCodeMap.getValue();
				pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
				page = new PDPage();
				doc.addPage(page);
				pagination++;
				pageSize = page.getMediaBox();
				width = pageSize.getWidth() - 2 * margin;
				startX = pageSize.getLowerLeftX() + margin;
				startY = pageSize.getUpperRightY() - margin;
				contentStream = new PDPageContentStream(doc, page);
				contentStream.setFont(pdfFont, fontSize);
				contentStream.beginText();
				contentStream.newLineAtOffset(startX, startY);

				writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
				pageHeight += 4;
				writePdfBodyHeader(rgm, contentStream, leading);
				pageHeight += 2;
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 1;
				pdfAcqIssDetails(rgm, branchCode, false, doc, page, contentStream, pageSize, leading, startX, startY,
						pdfFont, fontSize);
				pdfIssFromOtherBankDetails(rgm, branchCode, true, doc, page, contentStream, pageSize, leading, startX,
						startY, pdfFont, fontSize);

				contentStream.endText();
				contentStream.close();
			}

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

	private void pdfAcqIssDetails(ReportGenerationMgr rgm, String branchCode, boolean indicator, PDDocument doc,
			PDPage page, PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX,
			float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.pdfAcqIssDetails()");
		try {
			preProcessing(rgm, branchCode, indicator);
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize, indicator);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream.showText("BRANCH AS ACQUIRER/ISSUER");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.showText("FOR THIS BRANCH");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 3;
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in pdfAcqIssDetails", e);
		}
	}

	private void pdfIssFromOtherBankDetails(ReportGenerationMgr rgm, String branchCode, boolean indicator,
			PDDocument doc, PDPage page, PDPageContentStream contentStream, PDRectangle pageSize, float leading,
			float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.pdfIssFromOtherBankDetails()");
		try {
			preProcessing(rgm, branchCode, indicator);
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize, indicator);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream.showText("BRANCH AS ISSUER");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.showText("FROM OTHER BANKS");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 3;
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in pdfIssFromOtherBankDetails", e);
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String branchCode = null;
		String branchName = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			separateQuery(rgm);

			pagination = 0;
			preProcessing(rgm);
			for (SortedMap.Entry<String, String> branchCodeMap : filterByCriteriaByBranch(rgm).entrySet()) {
				pagination++;
				branchCode = branchCodeMap.getKey();
				branchName = branchCodeMap.getValue();
				writeHeader(rgm, pagination, branchCode, branchName);
				writeBodyHeader(rgm);
				acqIssDetails(rgm, branchCode, false);
				issFromOtherBankDetails(rgm, branchCode, true);
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

	private void acqIssDetails(ReportGenerationMgr rgm, String branchCode, boolean indicator) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.acqIssDetails()");
		StringBuilder line = new StringBuilder();
		try {
			preProcessing(rgm, branchCode, indicator);
			executeBodyQuery(rgm, indicator);
			line.append(getEol());
			line.append("BRANCH AS ACQUIRER/ISSUER");
			line.append(getEol());
			line.append("FOR THIS BRANCH");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			executeTrailerQuery(rgm);
			line = new StringBuilder();
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in acqIssDetails", e);
		}
	}

	private void issFromOtherBankDetails(ReportGenerationMgr rgm, String branchCode, boolean indicator) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.issFromOtherBankDetails()");
		StringBuilder line = new StringBuilder();
		try {
			preProcessing(rgm, branchCode, indicator);
			executeBodyQuery(rgm, indicator);
			line.append(getEol());
			line.append("BRANCH AS ISSUER");
			line.append(getEol());
			line.append("FROM OTHER BANKS");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			executeTrailerQuery(rgm);
			line = new StringBuilder();
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in issFromOtherBankDetails", e);
		}
	}

	private SortedMap<String, String> filterByCriteriaByBranch(ReportGenerationMgr rgm) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.filterByCriteriaByBranch()");
		String branchCode = null;
		String branchName = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, String> criteriaMap = new TreeMap<>();
		rgm.setBodyQuery(getCriteriaQuery());
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
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
								branchCode = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								branchName = result.toString();
							}
						}
					}
					criteriaMap.put(branchCode, branchName);
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

	private void separateQuery(ReportGenerationMgr rgm) {
		if (rgm.getBodyQuery() != null) {
			setCriteriaQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_CHANNEL + "}", ""));
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
		}

		if (rgm.getTrailerQuery() != null) {
			setTmpTrailerQuery(rgm.getTrailerQuery());
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.preProcessing()");
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, boolean asIssuer)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.preProcessing()");
		if (!asIssuer) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			rgm.setTrailerQuery(getTmpTrailerQuery());
			ReportGenerationFields channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
		} else {
			rgm.setBodyQuery(rgm.getTmpBodyQuery().replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("ABR.ABR_NAME \"BRANCH NAME\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("AND TXN.TRL_ORIGIN_ICH_NAME = 'NDC+'", ""));
			rgm.setTrailerQuery(getTmpTrailerQuery()
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("AND TXN.TRL_ORIGIN_ICH_NAME = 'NDC+'", ""));
			ReportGenerationFields channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ORIGIN_ICH_NAME = 'Bancnet_Interchange' AND TXN.TRL_ISS_NAME = 'CBC'");
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
		}
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.isFirstField()) {
					contentStream.showText(String.format("%1$7s", "")
							+ String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				} else
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
			}
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.writeBodyHeader()");
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
			case 10:
				line.append(getGlobalFieldValue(field, true));
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
			PDPageContentStream contentStream, float leading, String customData, boolean bancnetIndicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.SUBSCRIBER_ACCT_NUMBER)) {
					if (extractBillerSubn(customData).length() <= 16) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								String.format("%1$" + 16 + "s", extractBillerSubn(customData)).replace(' ', '0')));
					} else {
						contentStream.showText(
								String.format("%1$" + field.getPdfLength() + "s", extractBillerSubn(customData)));
					}
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.TERMINAL:
					if (bancnetIndicator && getFieldValue(field, fieldsMap, true).length() == 8) {
						String terminalId = getFieldValue(field, fieldsMap, true);
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								terminalId.substring(0, 4) + "-" + terminalId.substring(terminalId.length() - 4)));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				case ReportConstants.SEQ_NUMBER:
					if (getFieldValue(field, fieldsMap, true).length() <= 6) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", String
								.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				case ReportConstants.ACCOUNT_NUMBER:
					if (getFieldValue(field, fieldsMap, true).length() <= 16) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", String
								.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				default:
					if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				}
			}
		}
	}

	private void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String customData, boolean bancnetIndicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.SUBSCRIBER_ACCT_NUMBER:
				if (extractBillerSubn(customData).length() <= 16) {
					line.append(String.format("%1$" + 16 + "s", extractBillerSubn(customData)).replace(' ', '0'));
				} else {
					line.append(extractBillerSubn(customData));
				}
				line.append(field.getDelimiter());
				break;
			case ReportConstants.TERMINAL:
				if (bancnetIndicator && getFieldValue(field, fieldsMap, true).length() == 8) {
					String terminalId = getFieldValue(field, fieldsMap, true);
					line.append(terminalId.substring(0, 4) + "-" + terminalId.substring(terminalId.length() - 4));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
				break;
			case ReportConstants.SEQ_NUMBER:
				if (getFieldValue(field, fieldsMap, true).length() <= 6) {
					line.append(
							String.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0'));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
				break;
			case ReportConstants.ACCOUNT_NUMBER:
				if (getFieldValue(field, fieldsMap, true).length() <= 16) {
					line.append(
							String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0'));
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
				}
				line.append(field.getDelimiter());
				break;
			default:
				if (getFieldValue(field, fieldsMap, true) == null) {
					line.append("");
					line.append(field.getDelimiter());
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
					line.append(field.getDelimiter());
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, boolean bancnetIndicator) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.execute()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String customData = null;
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
							} else if (key.equalsIgnoreCase(ReportConstants.CUSTOM_DATA)) {
								customData = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, customData, bancnetIndicator);
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

	private void executeBodyQuery(ReportGenerationMgr rgm, boolean bancnetIndicator) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String customData = null;
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
							} else if (key.equalsIgnoreCase(ReportConstants.CUSTOM_DATA)) {
								customData = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap, customData, bancnetIndicator);
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
	protected void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
					contentStream.newLineAtOffset(0, -leading);
				}
			} else {
				if (field.isFirstField()) {
					contentStream.showText(String.format("%1$3s", "") + String
							.format("%1$-" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
					contentStream.showText(String.format("%" + field.getPdfLength() + "s",
							String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true)))));
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				}
			}
		}
	}

	@Override
	protected void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
				line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
				line.append(field.getDelimiter());
			} else if (getFieldValue(field, fieldsMap, true) == null) {
				line.append("");
				line.append(field.getDelimiter());
			} else {
				line.append(getFieldValue(field, fieldsMap, true));
				line.append(field.getDelimiter());
			}

		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private String extractBillerSubn(String customData) {
		Pattern pattern = Pattern.compile("<([^<>]+)>([^<>]+)</\\1>");
		Matcher matcher = pattern.matcher(customData);
		Map<String, String> map = new HashMap<>();

		while (matcher.find()) {
			String xmlElem = matcher.group();
			String key = xmlElem.substring(1, xmlElem.indexOf('>'));
			String value = xmlElem.substring(xmlElem.indexOf('>') + 1, xmlElem.lastIndexOf('<'));
			map.put(key, value);
			if (map.get(ReportConstants.BILLER_SUBN) != null) {
				return map.get(ReportConstants.BILLER_SUBN);
			}
		}
		return "";
	}
}
