package my.com.mandrill.base.reporting.cashCardReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
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

public class CashCardSuccessfulTransactions extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(CashCardSuccessfulTransactions.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private int channelCount = 0;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In CashCardSuccessfulTransactions.processPdfRecord()");
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
			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			addReportPreProcessingFieldsToGlobalMap(rgm);
			writePdfHeader(rgm, contentStream, leading, pagination);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;
			for (int i = 0; i < 6; i++) {
				preProcessing(rgm, i);
				contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
						pdfFont, fontSize);
				pageHeight += 1;
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

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			for (int i = 0; i < 6; i++) {
				preProcessing(rgm, i);
				executeBodyQuery(rgm);
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

	private void preProcessing(ReportGenerationMgr rgm, int i)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In CashCardSuccessfulTransactions.preProcessing()");
		ReportGenerationFields txnCriteria = null;
		ReportGenerationFields channel = null;
		ReportGenerationFields txnType = new ReportGenerationFields(ReportConstants.PARAM_TXN_TYPE,
				ReportGenerationFields.TYPE_STRING, "TSC.TSC_DESCRIPTION");
		getGlobalFileFieldsMap().put(txnType.getFieldName(), txnType);

		switch (i) {
		case 0:
			channelCount = 0;
			channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL, ReportGenerationFields.TYPE_STRING,
					"'" + ReportConstants.CHINABANK_ATM + "'");
			txnCriteria = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'NDC'");
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
			getGlobalFileFieldsMap().put(txnCriteria.getFieldName(), txnCriteria);
			break;
		case 1:
			channelCount = 0;
			channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL, ReportGenerationFields.TYPE_STRING,
					"'" + ReportConstants.BANCNET_ATM + "'");
			txnCriteria = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ORIGIN_ICH_NAME = 'Bancnet_Interchange' AND TXN.TRL_ACQR_INST_ID NOT IN ('9990', '0000009990')");
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
			getGlobalFileFieldsMap().put(txnCriteria.getFieldName(), txnCriteria);
			break;
		case 2:
			channelCount = 0;
			channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL, ReportGenerationFields.TYPE_STRING,
					"'" + ReportConstants.CHINABANK_EBK + "'");
			txnCriteria = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "TXNC.TRL_ORIGIN_CHANNEL = 'EBK'");
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
			getGlobalFileFieldsMap().put(txnCriteria.getFieldName(), txnCriteria);
			break;
		case 3:
			channelCount = 0;
			channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL, ReportGenerationFields.TYPE_STRING,
					"'" + ReportConstants.BANCNET_EBK + "'");
			txnCriteria = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ORIGIN_ICH_NAME = 'Bancnet_Interchange' AND TXN.TRL_ACQR_INST_ID IN ('9990', '0000009990')");
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
			getGlobalFileFieldsMap().put(txnCriteria.getFieldName(), txnCriteria);
			break;
		case 4:
			channelCount = 0;
			channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL, ReportGenerationFields.TYPE_STRING,
					"'" + ReportConstants.CHINABANK_MBK + "'");
			txnCriteria = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "TXNC.TRL_ORIGIN_CHANNEL = 'MBK'");
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
			getGlobalFileFieldsMap().put(txnCriteria.getFieldName(), txnCriteria);
			break;
		case 5:
			channelCount = 0;
			channel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL, ReportGenerationFields.TYPE_STRING,
					"'" + ReportConstants.CHINABANK_IVR + "'");
			txnCriteria = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "TXNC.TRL_ORIGIN_CHANNEL = 'IVR'");
			getGlobalFileFieldsMap().put(channel.getFieldName(), channel);
			getGlobalFileFieldsMap().put(txnCriteria.getFieldName(), txnCriteria);
			break;
		default:
			break;
		}
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.CHANNEL:
				if (channelCount > 0) {
					fieldsMap.get(field.getFieldName()).setValue("");
					line.append(getFieldValue(rgm, field, fieldsMap));
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
				}
				channelCount++;
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			}
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.CHANNEL:
					if (channelCount > 0) {
						fieldsMap.get(field.getFieldName()).setValue("");
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
					channelCount++;
					break;
				default:
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					break;
				}
			}
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In CashCardSuccessfulTransactions.executePdfBodyQuery()");
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

	protected SortedMap<String, Set<String>> filterByChannel(ReportGenerationMgr rgm) {
		logger.debug("In CashCardSuccessfulTransactions.filterByChannel()");
		String channel = null;
		String txnType = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Set<String>> criteriaMap = new TreeMap<>();
		String query = getBodyQuery(rgm);
		logger.info("Query for filter channel: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.CHANNEL)) {
								channel = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.TRANSACTION_TYPE)) {
								txnType = result.toString();
							}
						}
					}
					if (criteriaMap.get(channel) == null) {
						Set<String> txnTypeList = new HashSet<>();
						txnTypeList.add(txnType);
						criteriaMap.put(channel, txnTypeList);
					} else {
						Set<String> channelList = criteriaMap.get(channel);
						if (channelList == null) {
							Set<String> txnTypeList = new HashSet<>();
							txnTypeList.add(txnType);
							criteriaMap.put(channel, txnTypeList);
						} else {
							Set<String> txnTypeList = channelList;
							txnTypeList.add(txnType);
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
}
