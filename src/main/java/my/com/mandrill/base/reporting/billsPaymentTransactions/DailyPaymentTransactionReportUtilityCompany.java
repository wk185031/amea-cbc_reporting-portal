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
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.TreeSet;
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

public class DailyPaymentTransactionReportUtilityCompany extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(DailyPaymentTransactionReportUtilityCompany.class);
	public static final String ATM = "ATM";
	public static final String CDM = "CDM";
	public static final String OB = "OB";
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private double subTotal = 0.00;
	private boolean bancnetIndicator = false;

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
			String channel = null;

			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			writePdfHeader(rgm, contentStream, leading, pagination);
			pageHeight += 4;

			for (SortedMap.Entry<String, Map<String, TreeSet<String>>> billerCodeMap : filterByCriteriaByBiller(rgm)
					.entrySet()) {
				billerCode = billerCodeMap.getKey();
				for (SortedMap.Entry<String, TreeSet<String>> billerMnemMap : billerCodeMap.getValue().entrySet()) {
					subTotal = 0.00;
					billerMnem = billerMnemMap.getKey();
					contentStream.showText("UTILITY COMPANY : " + billerCode + " " + billerMnem);
					pageHeight += 1;
					contentStream.newLineAtOffset(0, -leading);
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 1;
					writePdfBodyHeader(rgm, contentStream, leading);
					pageHeight += 2;
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 1;
					for (String channelMap : billerMnemMap.getValue()) {
						channel = channelMap;
						preProcessing(rgm, channel, billerCode);
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, bancnetIndicator);
					}
				}
				contentStream.newLineAtOffset(0, -leading);
				pageHeight += 1;
				DecimalFormat formatter = new DecimalFormat("#,##0.00");
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
		String channel = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			preProcessing(rgm);
			writeHeader(rgm, pagination);
			for (SortedMap.Entry<String, Map<String, TreeSet<String>>> billerCodeMap : filterByCriteriaByBiller(rgm)
					.entrySet()) {
				StringBuilder subTotalLine = new StringBuilder();
				billerCode = billerCodeMap.getKey();
				for (SortedMap.Entry<String, TreeSet<String>> billerMnemMap : billerCodeMap.getValue().entrySet()) {
					StringBuilder billerLine = new StringBuilder();
					subTotal = 0.00;
					billerMnem = billerMnemMap.getKey();
					billerLine.append("UTILITY COMPANY : " + billerCode + " " + billerMnem);
					billerLine.append(getEol());
					rgm.writeLine(billerLine.toString().getBytes());
					writeBodyHeader(rgm);
					for (String channelMap : billerMnemMap.getValue()) {
						channel = channelMap;
						preProcessing(rgm, channel, billerCode);
						executeBodyQuery(rgm, bancnetIndicator);
					}
				}
				DecimalFormat formatter = new DecimalFormat("#,##0.00");
				subTotalLine.append("SUBTOTAL : ").append(";").append(formatter.format(subTotal)).append(";");
				subTotalLine.append(getEol());
				subTotalLine.append(getEol());
				rgm.writeLine(subTotalLine.toString().getBytes());
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

	private SortedMap<String, Map<String, TreeSet<String>>> filterByCriteriaByBiller(ReportGenerationMgr rgm) {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.filterByCriteriaByBiller()");
		String billerCode = null;
		String billerMnem = null;
		String channel = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, TreeSet<String>>> criteriaMap = new TreeMap<>();
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
							if (key.equalsIgnoreCase(ReportConstants.CHANNEL)) {
								channel = result.toString();
							}
						}
					}
					if (criteriaMap.get(billerCode) == null) {
						Map<String, TreeSet<String>> tmpCriteriaMap = new HashMap<>();
						TreeSet<String> channelList = new TreeSet<>();
						channelList.add(channel);
						tmpCriteriaMap.put(billerMnem, channelList);
						criteriaMap.put(billerCode, tmpCriteriaMap);
					} else {
						Map<String, TreeSet<String>> tmpCriteriaMap = criteriaMap.get(billerCode);
						if (tmpCriteriaMap.get(billerMnem) == null) {
							TreeSet<String> terminalList = new TreeSet<>();
							terminalList.add(channel);
							tmpCriteriaMap.put(billerMnem, terminalList);
						} else {
							Set<String> terminalList = tmpCriteriaMap.get(billerMnem);
							terminalList.add(channel);
						}
					}
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
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BILLER_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_CHANNEL + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByChannel, String filterByBillerCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In ListOfATMWithdrawalsReport.preProcessing()");
		if (filterByBillerCode != null && filterByChannel != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields billerCode = new ReportGenerationFields(ReportConstants.PARAM_BILLER_CODE,
					ReportGenerationFields.TYPE_STRING,
					"NVL(TXN.TRL_BILLER_CODE, '000') = '" + filterByBillerCode + "'");
			getGlobalFileFieldsMap().put(billerCode.getFieldName(), billerCode);

			// TBD
			switch (filterByChannel) {
			case ATM:
				ReportGenerationFields atm = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
						ReportGenerationFields.TYPE_STRING,
						"CTR.CTR_CHANNEL = '" + filterByChannel + "' AND TXN.TRL_ORIGIN_ICH_NAME = 'NDC+'");
				getGlobalFileFieldsMap().put(atm.getFieldName(), atm);
				bancnetIndicator = false;
				break;
			case CDM:
				ReportGenerationFields cdm = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
						ReportGenerationFields.TYPE_STRING,
						"CTR.CTR_CHANNEL = '" + filterByChannel + "' AND TXN.TRL_ORIGIN_ICH_NAME = 'CDM'");
				getGlobalFileFieldsMap().put(cdm.getFieldName(), cdm);
				bancnetIndicator = false;
				break;
			case OB:
				ReportGenerationFields ob = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
						ReportGenerationFields.TYPE_STRING, "CTR.CTR_CHANNEL = '" + filterByChannel
								+ "' AND TXN.TRL_ORIGIN_ICH_NAME = 'Bancnet_Interchange'");
				getGlobalFileFieldsMap().put(ob.getFieldName(), ob);
				bancnetIndicator = true;
				break;
			default:
				bancnetIndicator = false;
				break;
			}
		}
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.writePdfBodyHeader()");
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
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
				if (getFieldValue(field, fieldsMap, true).indexOf(",") != 0) {
					subTotal += Double.parseDouble(getFieldValue(field, fieldsMap, true).replace(",", ""));
				} else {
					subTotal += Double.parseDouble(getFieldValue(field, fieldsMap, true));
				}
			}
			
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.SUBSCRIBER_ACCT_NUMBER)) {
					if (extractBillerSubn(customData).length() <= 16) {
						String formatAccNo = String.format("%1$" + 16 + "s", extractBillerSubn(customData)).replace(' ',
								'0');
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatAccNo));
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
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
				if (getFieldValue(field, fieldsMap, true).indexOf(",") != 0) {
					subTotal += Double.parseDouble(getFieldValue(field, fieldsMap, true).replace(",", ""));
				} else {
					subTotal += Double.parseDouble(getFieldValue(field, fieldsMap, true));
				}
			}
			
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
			PDFont pdfFont, float fontSize, boolean bancnetIncomingIndicator) {
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.execute()");
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, customData, bancnetIncomingIndicator);
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
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.executeBodyQuery()");
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
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.writePdfTrailer()");
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
				if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
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
		logger.debug("In DailyPaymentTransactionReportUtilityCompany.writeTrailer()");
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
