package my.com.mandrill.base.reporting.glHandoffBlocksheet;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

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

public class GLHandoffBlocksheetBillsPayment extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffBlocksheetBillsPayment.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private boolean firstRecord = false;
	private boolean newGroup = false;
	private boolean endGroup = false;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetBillsPayment.processPdfRecord()");
		PDDocument doc = null;
		PDPage page = null;
		PDPageContentStream contentStream = null;
		PDRectangle pageSize = null;
		PDFont pdfFont = PDType1Font.COURIER;
		float fontSize = 6;
		float leading = 1.5f * fontSize;
		float margin = 30;
		float width = 0.0f;
		float startX = 0.0f;
		float startY = 0.0f;
		String glDescription = null;
		pagination = 0;
		try {
			doc = new PDDocument();
			separateQuery(rgm);
			preProcessing(rgm);

			rgm.setBodyQuery(getCriteriaQuery());
			if (!executeQuery(rgm)) {
				page = new PDPage();
				doc.addPage(page);
				contentStream = new PDPageContentStream(doc, page);
				pageSize = page.getMediaBox();
				width = pageSize.getWidth() - 2 * margin;
				startX = pageSize.getLowerLeftX() + margin;
				startY = pageSize.getUpperRightY() - margin;
				contentStream.setFont(pdfFont, fontSize);
				contentStream.beginText();
				contentStream.newLineAtOffset(startX, startY);
				contentStream.endText();
				contentStream.close();
				saveFile(rgm, doc);
			} else {
				Iterator<String> glDescriptionItr = filterByGlDescription(rgm).iterator();
				while (glDescriptionItr.hasNext()) {
					glDescription = glDescriptionItr.next();
					if (!endGroup && !newGroup) {
						page = new PDPage();
						doc.addPage(page);
						firstRecord = true;
						newGroup = true;
						pagination++;
						pageSize = page.getMediaBox();
						width = pageSize.getWidth() - 2 * margin;
						startX = pageSize.getLowerLeftX() + margin;
						startY = pageSize.getUpperRightY() - margin;
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
					}

					if (endGroup && newGroup) {
						rgm.setBodyQuery(getDebitBodyQuery());
						rgm.setTrailerQuery(getDebitTrailerQuery());
						preProcessing(rgm, glDescription, ReportConstants.DEBIT_IND);
						if (executeQuery(rgm)) {
							endGroup = false;
							pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
							page = new PDPage();
							doc.addPage(page);
							firstRecord = true;
							pagination++;
							contentStream = new PDPageContentStream(doc, page);
							contentStream.setFont(pdfFont, fontSize);
							contentStream.beginText();
							contentStream.newLineAtOffset(startX, startY);
							pdfProcessingDetail(rgm, contentStream, doc, page, pageSize, leading, startX, startY,
									pdfFont, fontSize);
						}

						rgm.setBodyQuery(getCreditBodyQuery());
						rgm.setTrailerQuery(getCreditTrailerQuery());
						preProcessing(rgm, glDescription, ReportConstants.CREDIT_IND);
						if (executeQuery(rgm)) {
							pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
							page = new PDPage();
							doc.addPage(page);
							firstRecord = true;
							pagination++;
							contentStream = new PDPageContentStream(doc, page);
							contentStream.setFont(pdfFont, fontSize);
							contentStream.beginText();
							contentStream.newLineAtOffset(startX, startY);
							pdfProcessingDetail(rgm, contentStream, doc, page, pageSize, leading, startX, startY,
									pdfFont, fontSize);
						}
						endGroup = true;
					} else {
						rgm.setBodyQuery(getDebitBodyQuery());
						rgm.setTrailerQuery(getDebitTrailerQuery());
						preProcessing(rgm, glDescription, ReportConstants.DEBIT_IND);
						if (executeQuery(rgm)) {
							pdfProcessingDetail(rgm, contentStream, doc, page, pageSize, leading, startX, startY,
									pdfFont, fontSize);
						}

						rgm.setBodyQuery(getCreditBodyQuery());
						rgm.setTrailerQuery(getCreditTrailerQuery());
						preProcessing(rgm, glDescription, ReportConstants.CREDIT_IND);
						if (executeQuery(rgm)) {
							pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
							page = new PDPage();
							doc.addPage(page);
							firstRecord = true;
							pagination++;
							contentStream = new PDPageContentStream(doc, page);
							contentStream.setFont(pdfFont, fontSize);
							contentStream.beginText();
							contentStream.newLineAtOffset(startX, startY);
							pdfProcessingDetail(rgm, contentStream, doc, page, pageSize, leading, startX, startY,
									pdfFont, fontSize);
						}
						endGroup = true;
					}
				}
				saveFile(rgm, doc);
			}
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

	private void pdfProcessingDetail(ReportGenerationMgr rgm, PDPageContentStream contentStream, PDDocument doc,
			PDPage page, PDRectangle pageSize, float leading, float startX, float startY, PDFont pdfFont,
			float fontSize) {
		logger.debug("In GLHandoffBlocksheetBillsPayment.pdfProcessingDetail()");
		try {
			writePdfHeader(rgm, contentStream, leading, pagination);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize);
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in pdfProcessingDetail", e);
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String glDescription = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			separateQuery(rgm);
			preProcessing(rgm);

			Iterator<String> glDescriptionItr = filterByGlDescription(rgm).iterator();
			while (glDescriptionItr.hasNext()) {
				glDescription = glDescriptionItr.next();
				firstRecord = true;
				pagination++;
				rgm.setBodyQuery(getDebitBodyQuery());
				rgm.setTrailerQuery(getDebitTrailerQuery());
				preProcessing(rgm, glDescription, ReportConstants.DEBIT_IND);
				if (executeQuery(rgm)) {
					processingDetail(rgm);
				}

				firstRecord = true;
				pagination++;
				rgm.setBodyQuery(getCreditBodyQuery());
				rgm.setTrailerQuery(getCreditTrailerQuery());
				preProcessing(rgm, glDescription, ReportConstants.CREDIT_IND);
				if (executeQuery(rgm)) {
					processingDetail(rgm);
				}
			}
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
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

	private void processingDetail(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetBillsPayment.processingDetail()");
		try {
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in processingDetail", e);
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffBlocksheetBillsPayment.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_GL_DESCRIPTION + "}", "")
					.replace("AND {" + ReportConstants.PARAM_CHANNEL + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByGlDescription, String indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffBlocksheetBillsPayment.preProcessing()");
		if (filterByGlDescription != null && getDebitBodyQuery() != null
				&& indicator.equals(ReportConstants.DEBIT_IND)) {
			ReportGenerationFields glDesc = new ReportGenerationFields(ReportConstants.PARAM_GL_DESCRIPTION,
					ReportGenerationFields.TYPE_STRING,
					"TRIM(GLE.GLE_DEBIT_DESCRIPTION) = '" + filterByGlDescription + "'");
			getGlobalFileFieldsMap().put(glDesc.getFieldName(), glDesc);
		}

		if (filterByGlDescription != null && getCreditBodyQuery() != null
				&& indicator.equals(ReportConstants.CREDIT_IND)) {
			ReportGenerationFields glDesc = new ReportGenerationFields(ReportConstants.PARAM_GL_DESCRIPTION,
					ReportGenerationFields.TYPE_STRING,
					"TRIM(GLE.GLE_CREDIT_DESCRIPTION) = '" + filterByGlDescription + "'");
			getGlobalFileFieldsMap().put(glDesc.getFieldName(), glDesc);
		}

		switch (filterByGlDescription) {
		case ReportConstants.ATM_BILLS_PAYMENT:
			ReportGenerationFields channelAtm = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXNC.TRL_ORIGIN_CHANNEL = 'ATM'");
			getGlobalFileFieldsMap().put(channelAtm.getFieldName(), channelAtm);
			break;
		case ReportConstants.BIR_REMITTANCE:
			ReportGenerationFields channelBir = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "LPAD(TXNC.TRL_BILLER_CODE, 3, '0') = '019'");
			getGlobalFileFieldsMap().put(channelBir.getFieldName(), channelBir);
			break;
		case ReportConstants.BANCNET_EGOV_PHILHEALTH:
			ReportGenerationFields channelPh = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "LPAD(TXNC.TRL_BILLER_CODE, 3, '0') = '063'");
			getGlobalFileFieldsMap().put(channelPh.getFieldName(), channelPh);
			break;
		case ReportConstants.BANCNET_EGOV_PAG_IBIG:
			ReportGenerationFields channelIbig = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "LPAD(TXNC.TRL_BILLER_CODE, 3, '0') = '067'");
			getGlobalFileFieldsMap().put(channelIbig.getFieldName(), channelIbig);
			break;
		case ReportConstants.BANCNET_EGOV_SSS:
			ReportGenerationFields channelSss = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "LPAD(TXNC.TRL_BILLER_CODE, 3, '0') = '065'");
			getGlobalFileFieldsMap().put(channelSss.getFieldName(), channelSss);
			break;
		default:
			break;
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetBillsPayment.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setDebitBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCreditBodyQuery(getCreditBodyQuery().replace(getCreditBodyQuery().substring(
					getCreditBodyQuery().indexOf("GROUP BY"), getCreditBodyQuery().indexOf("ORDER BY")), ""));
			setCriteriaQuery(
					getDebitBodyQuery().replace("TXN.TRL_DEST_STAN \"CODE\",", "").replace("TXN.TRL_DEST_STAN,", "")
							.replace("TXN.TRL_DEST_STAN ASC,", "").replace("TXN.TRL_AMT_TXN \"DEBIT\",", "")
							.replace("TXN.TRL_ACCOUNT_1_ACN_ID \"FROM ACCOUNT NO\",", "")
							.replace("TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,", "").replace("TXN.TRL_AMT_TXN,", "")
							.replace("TXN.TRL_ACCOUNT_1_ACN_ID,", ""));
			setDebitBodyQuery(getDebitBodyQuery().replace(getDebitBodyQuery()
					.substring(getDebitBodyQuery().indexOf("GROUP BY"), getDebitBodyQuery().indexOf("ORDER BY")), ""));
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

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		boolean payable = false;
		boolean bp = false;
		int fieldLength = 0;
		String payableValue = null;
		String bpValue = null;
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (!firstRecord && !payable && !bp) {
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
				default:
					line.append(String.format(getFieldValue(rgm, field, fieldsMap)));
					break;
				}
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					fieldLength += field.getCsvTxtLength();
				}
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NUMBER)) {
					fieldLength += field.getCsvTxtLength();
				}

				switch (field.getFieldName()) {
				case ReportConstants.GL_ACCOUNT_NAME:
					if (getFieldValue(field, fieldsMap).equalsIgnoreCase("Accts. Payable - EGOV - Philhealth")
							|| getFieldValue(field, fieldsMap).equalsIgnoreCase("Accts. Payable - EGOV - Pag-ibig")) {
						line.append(String.format("%1$4s", "") + String.format("%1$-" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap).substring(0, 23)));
						payableValue = getFieldValue(field, fieldsMap).substring(24,
								getFieldValue(field, fieldsMap).length());
						payable = true;
					} else if (getFieldValue(field, fieldsMap)
							.equalsIgnoreCase("Accts. Payable - Bancnet Bills Payment")) {
						line.append(String.format("%1$4s", "") + String.format("%1$-" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap).substring(0, 24)));
						bpValue = getFieldValue(field, fieldsMap).substring(25,
								getFieldValue(field, fieldsMap).length());
						bp = true;
					} else {
						line.append(String.format("%1$4s", "") + getFieldValue(rgm, field, fieldsMap));
					}
					break;
				default:
					line.append(getFieldValue(rgm, field, fieldsMap));
					break;
				}
			}
		}
		line.append(getEol());
		if (payable) {
			payable = false;
			line.append(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + payableValue.length()) + "s", payableValue));
			line.append(getEol());
		}
		if (bp) {
			bp = false;
			line.append(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + bpValue.length()) + "s", bpValue));
			line.append(getEol());
		}
		rgm.writeLine(line.toString().getBytes());
		firstRecord = false;
	}

	@Override
	protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		boolean payable = false;
		boolean bp = false;
		int fieldLength = 0;
		String payableValue = null;
		String bpValue = null;
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (!firstRecord && !payable && !bp) {
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
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
						fieldLength += field.getPdfLength();
					}
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NUMBER)) {
						fieldLength += field.getPdfLength();
					}

					switch (field.getFieldName()) {
					case ReportConstants.GL_ACCOUNT_NAME:
						if (getFieldValue(field, fieldsMap).equalsIgnoreCase("Accts. Payable - EGOV - Philhealth")
								|| getFieldValue(field, fieldsMap)
										.equalsIgnoreCase("Accts. Payable - EGOV - Pag-ibig")) {
							contentStream.showText(
									String.format("%1$4s", "") + String.format("%1$-" + field.getPdfLength() + "s",
											getFieldValue(field, fieldsMap).substring(0, 23)));
							payableValue = getFieldValue(field, fieldsMap).substring(24,
									getFieldValue(field, fieldsMap).length());
							payable = true;
						} else if (getFieldValue(field, fieldsMap)
								.equalsIgnoreCase("Accts. Payable - Bancnet Bills Payment")) {
							contentStream.showText(
									String.format("%1$4s", "") + String.format("%1$-" + field.getPdfLength() + "s",
											getFieldValue(field, fieldsMap).substring(0, 24)));
							bpValue = getFieldValue(field, fieldsMap).substring(25,
									getFieldValue(field, fieldsMap).length());
							bp = true;
						} else {
							contentStream.showText(String.format("%1$4s", "") + getFieldValue(rgm, field, fieldsMap));
						}
						break;
					default:
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
						break;
					}
				}
			}
		}
		if (payable) {
			payable = false;
			contentStream.showText(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + payableValue.length()) + "s", payableValue));
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
		}
		if (bp) {
			bp = false;
			contentStream.showText(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + bpValue.length()) + "s", bpValue));
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
		}
		firstRecord = false;
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In GLHandoffBlocksheetBillsPayment.executePdfBodyQuery()");
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
					if (pageHeight > totalHeight && !endGroup) {
						endGroup = false;
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading);
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

	private boolean executeQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetRecycler.executeQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = getBodyQuery(rgm);
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.connection.prepareStatement(query);
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
			try {
				ps.close();
				rs.close();
			} catch (SQLException e) {
				rgm.errors++;
				logger.error("Error closing DB resources", e);
			}
		}
		return false;
	}
}
