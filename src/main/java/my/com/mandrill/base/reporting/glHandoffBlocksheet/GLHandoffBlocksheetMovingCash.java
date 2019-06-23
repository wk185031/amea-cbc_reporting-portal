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

public class GLHandoffBlocksheetMovingCash extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffBlocksheetMovingCash.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private boolean firstRecord = false;
	private boolean newGroup = false;
	private boolean endGroup = false;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetMovingCash.processPdfRecord()");
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
		pagination = 0;
		try {
			doc = new PDDocument();
			String glDescription = null;
			String branchCode = null;

			separateQuery(rgm);
			preProcessing(rgm);

			Iterator<String> glDescriptionItr = filterByGlDescription(rgm).iterator();

			while (glDescriptionItr.hasNext()) {
				glDescription = glDescriptionItr.next();
				if (!endGroup && !newGroup) {
					page = new PDPage();
					doc.addPage(page);
					firstRecord = true;
					newGroup = true;
					pagination++;
					contentStream = new PDPageContentStream(doc, page);
					pageSize = page.getMediaBox();
					width = pageSize.getWidth() - 2 * margin;
					startX = pageSize.getLowerLeftX() + margin;
					startY = pageSize.getUpperRightY() - margin;
					contentStream.setFont(pdfFont, fontSize);
					contentStream.beginText();
					contentStream.newLineAtOffset(startX, startY);
				}

				if (endGroup && newGroup) {
					endGroup = false;
					if (glDescription.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
							|| glDescription.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL)) {
						preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
						Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
						while (branchCodeItr.hasNext()) {
							branchCode = branchCodeItr.next();
							pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
							page = new PDPage();
							doc.addPage(page);
							firstRecord = true;
							pagination++;
							contentStream = new PDPageContentStream(doc, page);
							contentStream.setFont(pdfFont, fontSize);
							contentStream.beginText();
							contentStream.newLineAtOffset(startX, startY);
							rgm.setBodyQuery(getAcquirerDebitBodyQuery());
							rgm.setTrailerQuery(getAcquirerDebitTrailerQuery());
							pdfDebitDetail(rgm, glDescription, branchCode, contentStream, doc, page, pageSize, leading,
									startX, startY, pdfFont, fontSize);

							pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
							page = new PDPage();
							doc.addPage(page);
							firstRecord = true;
							pagination++;
							contentStream = new PDPageContentStream(doc, page);
							contentStream.setFont(pdfFont, fontSize);
							contentStream.beginText();
							contentStream.newLineAtOffset(startX, startY);
							rgm.setBodyQuery(getAcquirerCreditBodyQuery());
							rgm.setTrailerQuery(getAcquirerCreditTrailerQuery());
							pdfCreditDetail(rgm, glDescription, branchCode, contentStream, doc, page, pageSize, leading,
									startX, startY, pdfFont, fontSize);
						}
						endGroup = true;
					} else {
						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
						page = new PDPage();
						doc.addPage(page);
						firstRecord = true;
						pagination++;
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
						rgm.setBodyQuery(getDebitBodyQuery());
						rgm.setTrailerQuery(getDebitTrailerQuery());
						pdfDebitDetail(rgm, glDescription, branchCode, contentStream, doc, page, pageSize, leading,
								startX, startY, pdfFont, fontSize);

						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
						page = new PDPage();
						doc.addPage(page);
						firstRecord = true;
						pagination++;
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
						rgm.setBodyQuery(getCreditBodyQuery());
						rgm.setTrailerQuery(getCreditTrailerQuery());
						pdfCreditDetail(rgm, glDescription, branchCode, contentStream, doc, page, pageSize, leading,
								startX, startY, pdfFont, fontSize);
						endGroup = true;
					}
				} else {
					rgm.setBodyQuery(getDebitBodyQuery());
					rgm.setTrailerQuery(getDebitTrailerQuery());
					pdfDebitDetail(rgm, glDescription, branchCode, contentStream, doc, page, pageSize, leading, startX,
							startY, pdfFont, fontSize);

					pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
					page = new PDPage();
					doc.addPage(page);
					firstRecord = true;
					pagination++;
					contentStream = new PDPageContentStream(doc, page);
					contentStream.setFont(pdfFont, fontSize);
					contentStream.beginText();
					contentStream.newLineAtOffset(startX, startY);
					rgm.setBodyQuery(getCreditBodyQuery());
					rgm.setTrailerQuery(getCreditTrailerQuery());
					pdfCreditDetail(rgm, glDescription, branchCode, contentStream, doc, page, pageSize, leading, startX,
							startY, pdfFont, fontSize);
					endGroup = true;
				}
			}

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

	private void pdfDebitDetail(ReportGenerationMgr rgm, String glDescription, String branchCode,
			PDPageContentStream contentStream, PDDocument doc, PDPage page, PDRectangle pageSize, float leading,
			float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In GLHandoffBlocksheetMovingCash.pdfDebitDetail()");
		try {
			preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
			writePdfHeader(rgm, contentStream, leading, pagination);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize, glDescription, branchCode, ReportConstants.DEBIT_IND);
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in pdfDebitDetail", e);
		}
	}

	private void pdfCreditDetail(ReportGenerationMgr rgm, String glDescription, String branchCode,
			PDPageContentStream contentStream, PDDocument doc, PDPage page, PDRectangle pageSize, float leading,
			float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In GLHandoffBlocksheetMovingCash.pdfCreditDetail()");
		try {
			preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
			writePdfHeader(rgm, contentStream, leading, pagination);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize, glDescription, branchCode, ReportConstants.CREDIT_IND);
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in pdCreditDetail", e);
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String glDescription = null;
		String branchCode = null;
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
				if (glDescription.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
						|| glDescription.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL)) {
					preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
					Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
					while (branchCodeItr.hasNext()) {
						branchCode = branchCodeItr.next();
						firstRecord = true;
						pagination++;
						rgm.setBodyQuery(getAcquirerDebitBodyQuery());
						rgm.setTrailerQuery(getAcquirerDebitTrailerQuery());
						debitDetail(rgm, glDescription, branchCode);

						firstRecord = true;
						pagination++;
						rgm.setBodyQuery(getAcquirerCreditBodyQuery());
						rgm.setTrailerQuery(getAcquirerCreditTrailerQuery());
						creditDetail(rgm, glDescription, branchCode);
					}
				} else {
					firstRecord = true;
					pagination++;
					rgm.setBodyQuery(getDebitBodyQuery());
					rgm.setTrailerQuery(getDebitTrailerQuery());
					debitDetail(rgm, glDescription, branchCode);

					firstRecord = true;
					pagination++;
					rgm.setBodyQuery(getCreditBodyQuery());
					rgm.setTrailerQuery(getCreditTrailerQuery());
					creditDetail(rgm, glDescription, branchCode);
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

	private void debitDetail(ReportGenerationMgr rgm, String glDescription, String branchCode) {
		logger.debug("In GLHandoffBlocksheetMovingCash.debitDetail()");
		try {
			preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
			executeTrailerQuery(rgm);
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in debitDetail", e);
		}
	}

	private void creditDetail(ReportGenerationMgr rgm, String glDescription, String branchCode) {
		logger.debug("In GLHandoffBlocksheetMovingCash.creditDetail()");
		try {
			preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
			executeTrailerQuery(rgm);
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in creditDetail", e);
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffBlocksheetMovingCash.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_GL_DESCRIPTION + "}", "")
					.replace("AND {" + ReportConstants.PARAM_CHANNEL + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByGlDescription, String filterByBranchCode,
			String indicator) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffBlocksheetMovingCash.preProcessing()");
		if (filterByGlDescription != null && getAcquirerDebitBodyQuery() != null && getAcquirerCreditBodyQuery() != null
				&& (filterByGlDescription.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
						|| filterByGlDescription.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL))) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

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

		// TBC
		switch (filterByGlDescription) {
		case ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL:
			ReportGenerationFields channelPTM = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'NDC+'");
			getGlobalFileFieldsMap().put(channelPTM.getFieldName(), channelPTM);
			break;
		case ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL:
			ReportGenerationFields channelEC = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'NDC+'");
			getGlobalFileFieldsMap().put(channelEC.getFieldName(), channelEC);
			break;
		case ReportConstants.MBK_PAY_TO_MOBILE_OB_DEPOSIT:
			ReportGenerationFields channelMBK = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'Authentic_Service'");
			getGlobalFileFieldsMap().put(channelMBK.getFieldName(), channelMBK);
			break;
		default:
			ReportGenerationFields defaultChannel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ORIGIN_ICH_NAME = 'NDC+' AND TXN.TRL_DEST_ICH_NAME = 'CBS_Bridge'");
			getGlobalFileFieldsMap().put(defaultChannel.getFieldName(), defaultChannel);
			break;
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetMovingCash.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setAcquirerDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("AND GLA.GLA_NAME != 'ACD Inter-Entity IBFT SVC Bridge'", ""));
			setAcquirerDebitBodyQuery(getAcquirerDebitBodyQuery()
					.replace(getAcquirerDebitBodyQuery().substring(getAcquirerDebitBodyQuery().indexOf("GROUP BY"),
							getAcquirerDebitBodyQuery().indexOf("ORDER BY")), ""));
			setAcquirerCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, "")
					.replace("AND GLA.GLA_NAME != 'Accts. Payable - Inter-Entity IBFT Tfee'", ""));
			setAcquirerCreditBodyQuery(getAcquirerCreditBodyQuery()
					.replace(getAcquirerCreditBodyQuery().substring(getAcquirerCreditBodyQuery().indexOf("GROUP BY"),
							getAcquirerCreditBodyQuery().indexOf("ORDER BY")), ""));
			setDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, "").replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
			setCreditBodyQuery(getCreditBodyQuery().replace(getCreditBodyQuery().substring(
					getCreditBodyQuery().indexOf("GROUP BY"), getCreditBodyQuery().indexOf("ORDER BY")), ""));
			setCriteriaQuery(getDebitBodyQuery().replace("TXN.TRL_DEST_STAN \"CODE\",", "")
					.replace("TXN.TRL_DEST_STAN,", "").replace("TXN.TRL_DEST_STAN ASC,", "")
					.replace(
							"CASE WHEN GLA.GLA_NAME = 'ACD Inter-Entity IBFT SVC Bridge' THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) ELSE TXN.TRL_AMT_TXN END AS \"DEBIT\",",
							"")
					.replace("TXN.TRL_ACCOUNT_1_ACN_ID \"ACCOUNT NUMBER\",", "").replace("TXN.TRL_AMT_TXN,", "")
					.replace("TXN.TRL_ISS_CHARGE_AMT,", "").replace("TXN.TRL_ACCOUNT_1_ACN_ID,", ""));
			setDebitBodyQuery(getDebitBodyQuery().replace(getDebitBodyQuery()
					.substring(getDebitBodyQuery().indexOf("GROUP BY"), getDebitBodyQuery().indexOf("ORDER BY")), ""));
		}

		if (rgm.getTrailerQuery() != null) {
			setAcquirerDebitTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("AND GLA.GLA_NAME != 'ACD Inter-Entity IBFT SVC Bridge'", ""));
			setAcquirerCreditTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, "")
					.replace("AND GLA.GLA_NAME != 'Accts. Payable - Inter-Entity IBFT Tfee'", ""));
			setDebitTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
			setCreditTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, "").replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String glDescription, String branchCode, String indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		boolean payable = false;
		boolean acdIbft = false;
		int fieldLength = 0;
		String payableValue = null;
		String acdIbftValue = null;
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (!firstRecord && !payable && !acdIbft) {
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
					switch (field.getFieldName()) {
					case ReportConstants.CODE:
						if (getFieldValue(field, fieldsMap, true).length() <= 6) {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s", String
									.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
						} else {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						break;
					case ReportConstants.ACCOUNT_NUMBER:
						if (getFieldValue(field, fieldsMap, true).length() <= 16) {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ',
											'0')));
						} else {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						break;
					default:
						if (getFieldValue(field, fieldsMap, true) == null) {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
						} else {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						break;
					}
					break;
				}
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.BRANCH_CODE:
					if (!glDescription.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
							&& !glDescription.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL)) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", "5008"));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					fieldLength += field.getCsvTxtLength();
					break;
				case ReportConstants.GL_ACCOUNT_NUMBER:
					if (branchCode != null
							&& (glDescription.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
									|| glDescription.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL))) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								branchCode + getFieldValue(field, fieldsMap, true)));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					fieldLength += field.getCsvTxtLength();
					break;
				case ReportConstants.GL_ACCOUNT_NAME:
					if (getFieldValue(field, fieldsMap, true).contains("Payable")) {
						line.append(String.format("%1$4s", "") + String.format("%1$-" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true).substring(0, 23)));
						payableValue = getFieldValue(field, fieldsMap, true).substring(23,
								getFieldValue(field, fieldsMap, true).length());
						payable = true;
					} else if (getFieldValue(field, fieldsMap, true).contains("ACD Inter-Entity IBFT")) {
						line.append(String.format("%1$4s", "") + String.format("%1$-" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true).substring(0, 21)));
						acdIbftValue = getFieldValue(field, fieldsMap, true).substring(22,
								getFieldValue(field, fieldsMap, true).length());
						acdIbft = true;
					} else {
						line.append(String.format("%1$4s", "") + String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				case ReportConstants.CODE:
					if (getFieldValue(field, fieldsMap, true).length() <= 6) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", String
								.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				case ReportConstants.ACCOUNT_NUMBER:
					if (getFieldValue(field, fieldsMap, true).length() <= 16) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", String
								.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				default:
					if (getFieldValue(field, fieldsMap, true) == null) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
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
		if (acdIbft) {
			acdIbft = false;
			line.append(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + acdIbftValue.length()) + "s", acdIbftValue));
			line.append(getEol());
		}
		rgm.writeLine(line.toString().getBytes());
		firstRecord = false;
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In GLHandoffBlocksheetMovingCash.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
							field.getDefaultValue().charAt(0)));
					contentStream.newLineAtOffset(0, -leading);
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
					contentStream.newLineAtOffset(0, -leading);
				}
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				}
			}
		}
	}

	private void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, String glDescription, String branchCode, String indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		boolean payable = false;
		boolean acdIbft = false;
		int fieldLength = 0;
		String payableValue = null;
		String acdIbftValue = null;
		for (ReportGenerationFields field : fields) {
			if (!firstRecord && !payable && !acdIbft) {
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
						if (getFieldValue(field, fieldsMap, true) == null) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						contentStream.newLineAtOffset(0, -leading);
					} else {
						switch (field.getFieldName()) {
						case ReportConstants.CODE:
							if (getFieldValue(field, fieldsMap, true).length() <= 6) {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										String.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true))
												.replace(' ', '0')));
							} else {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										getFieldValue(field, fieldsMap, true)));
							}
							break;
						case ReportConstants.ACCOUNT_NUMBER:
							if (getFieldValue(field, fieldsMap, true).length() <= 16) {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true))
												.replace(' ', '0')));
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
					break;
				}
			} else {
				if (field.isEol()) {
					if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					contentStream.newLineAtOffset(0, -leading);
				} else {
					switch (field.getFieldName()) {
					case ReportConstants.BRANCH_CODE:
						if (!glDescription.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
								&& !glDescription.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL)) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", "5008"));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						fieldLength += field.getPdfLength();
						break;
					case ReportConstants.GL_ACCOUNT_NUMBER:
						if (branchCode != null && (glDescription
								.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
								|| glDescription.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL))) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									branchCode + getFieldValue(field, fieldsMap, true)));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						fieldLength += field.getPdfLength();
						break;
					case ReportConstants.GL_ACCOUNT_NAME:
						if (getFieldValue(field, fieldsMap, true).contains("Payable")) {
							contentStream.showText(
									String.format("%1$4s", "") + String.format("%1$-" + field.getPdfLength() + "s",
											getFieldValue(field, fieldsMap, true).substring(0, 23)));
							payableValue = getFieldValue(field, fieldsMap, true).substring(23,
									getFieldValue(field, fieldsMap, true).length());
							payable = true;
						} else if (getFieldValue(field, fieldsMap, true).contains("ACD Inter-Entity IBFT")) {
							contentStream.showText(
									String.format("%1$4s", "") + String.format("%1$-" + field.getPdfLength() + "s",
											getFieldValue(field, fieldsMap, true).substring(0, 21)));
							acdIbftValue = getFieldValue(field, fieldsMap, true).substring(22,
									getFieldValue(field, fieldsMap, true).length());
							acdIbft = true;
						} else {
							contentStream.showText(String.format("%1$4s", "") + String
									.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
						}
						break;
					case ReportConstants.CODE:
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
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ',
											'0')));
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
		if (payable) {
			payable = false;
			contentStream.showText(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + payableValue.length()) + "s", payableValue));
			contentStream.newLineAtOffset(0, -leading);
		}
		if (acdIbft) {
			acdIbft = false;
			contentStream.showText(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + acdIbftValue.length()) + "s", acdIbftValue));
			contentStream.newLineAtOffset(0, -leading);
		}
		firstRecord = false;
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, String glDescription, String branchCode, String indicator) {
		logger.debug("In GLHandoffBlocksheetMovingCash.executePdfBodyQuery()");
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, glDescription, branchCode, indicator);
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
}