package my.com.mandrill.base.reporting.glHandoffFinalProofSheet;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.ArrayList;
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

public class GLHandoffFinalProofSheetInterEntity extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffFinalProofSheetInterEntity.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private double total = 0.00;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.processPdfRecord()");
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
			String glDescription = null;
			String branchCode = null;

			separateQuery(rgm);
			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			writePdfHeader(rgm, contentStream, leading, pagination);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;

			Iterator<String> glDescriptionItr = filterByGlDescription(rgm).iterator();

			while (glDescriptionItr.hasNext()) {
				glDescription = glDescriptionItr.next();
				if (glDescription.equalsIgnoreCase(ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL)) {
					preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
					rgm.setBodyQuery(getAcquirerDebitBodyQuery());
					contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
							startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.DEBIT_IND);
					preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
					Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
					while (branchCodeItr.hasNext()) {
						branchCode = branchCodeItr.next();
						preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
						rgm.setBodyQuery(getAcquirerCreditBodyQuery());
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.CREDIT_IND);
					}
				} else {
					preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
					rgm.setBodyQuery(getDebitBodyQuery());
					contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
							startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.DEBIT_IND);
					preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
					rgm.setBodyQuery(getCreditBodyQuery());
					contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
							startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.CREDIT_IND);
				}
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
		try {
			String glDescription = null;
			String branchCode = null;
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			total = 0.00;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			separateQuery(rgm);
			preProcessing(rgm);

			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			Iterator<String> glDescriptionItr = filterByGlDescription(rgm).iterator();
			while (glDescriptionItr.hasNext()) {
				glDescription = glDescriptionItr.next();
				if (glDescription.equalsIgnoreCase(ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL)) {
					preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
					rgm.setBodyQuery(getAcquirerDebitBodyQuery());
					executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
					preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
					Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
					while (branchCodeItr.hasNext()) {
						branchCode = branchCodeItr.next();
						preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
						rgm.setBodyQuery(getAcquirerCreditBodyQuery());
						executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
					}
				} else {
					preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
					rgm.setBodyQuery(getDebitBodyQuery());
					executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
					preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
					rgm.setBodyQuery(getCreditBodyQuery());
					executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
				}
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
	protected List<String> filterByGlDescription(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.filterByGlDescription()");
		String glDescription = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		List<String> glDescriptionList = new ArrayList<>();
		rgm.setBodyQuery(getCriteriaQuery());
		String query = getBodyQuery(rgm);
		logger.info("Query to filter gl description: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.TRAN_PARTICULAR)) {
								glDescription = result.toString();
							}
						}
					}
					glDescriptionList.add(glDescription);
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
		return glDescriptionList;
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_GL_DESCRIPTION + "}", "")
					.replace("AND {" + ReportConstants.PARAM_CHANNEL + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByGlDescription, String filterByBranchCode,
			String indicator) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.preProcessing()");
		if (filterByGlDescription != null && getDebitBodyQuery() != null && getAcquirerDebitBodyQuery() != null
				&& indicator.equals(ReportConstants.DEBIT_IND)) {
			ReportGenerationFields glDesc = new ReportGenerationFields(ReportConstants.PARAM_GL_DESCRIPTION,
					ReportGenerationFields.TYPE_STRING,
					"TRIM(GLE.GLE_DEBIT_DESCRIPTION) = '" + filterByGlDescription + "'");
			getGlobalFileFieldsMap().put(glDesc.getFieldName(), glDesc);
		}

		if (filterByGlDescription != null && getCreditBodyQuery() != null && getAcquirerCreditBodyQuery() != null
				&& indicator.equals(ReportConstants.CREDIT_IND)) {
			if (filterByGlDescription.equalsIgnoreCase(ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL)) {
				ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
						ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
				getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			}
			ReportGenerationFields glDesc = new ReportGenerationFields(ReportConstants.PARAM_GL_DESCRIPTION,
					ReportGenerationFields.TYPE_STRING,
					"TRIM(GLE.GLE_CREDIT_DESCRIPTION) = '" + filterByGlDescription + "'");
			getGlobalFileFieldsMap().put(glDesc.getFieldName(), glDesc);
		}

		// TBC
		switch (filterByGlDescription) {
		case ReportConstants.INTER_ENTITY_AP_ATM_WITHDRAWAL:
			ReportGenerationFields channelAP = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'CBS_Bridge'");
			getGlobalFileFieldsMap().put(channelAP.getFieldName(), channelAP);
			break;
		case ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL:
			ReportGenerationFields channelAR = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ORIGIN_ICH_NAME = 'NDC+' AND TXN.TRL_DEST_ICH_NAME = 'CBS_Bridge'");
			getGlobalFileFieldsMap().put(channelAR.getFieldName(), channelAR);
			break;
		case ReportConstants.INTER_ENTITY_FUND_TRANSFER_DR:
			ReportGenerationFields channelDR = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ORIGIN_ICH_NAME IN ('NDC+', 'Authentic_Service') AND TXN.TRL_DEST_ICH_NAME = 'CBS_Bridge'");
			getGlobalFileFieldsMap().put(channelDR.getFieldName(), channelDR);
			break;
		case ReportConstants.INTER_ENTITY_FUND_TRANSFER_CR:
			ReportGenerationFields channelCR = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ORIGIN_ICH_NAME IN ('CBS_Bridge', 'Authentic_Service')");
			getGlobalFileFieldsMap().put(channelCR.getFieldName(), channelCR);
			break;
		default:
			ReportGenerationFields defaultChannel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'NDC+'");
			getGlobalFileFieldsMap().put(defaultChannel.getFieldName(), defaultChannel);
			break;
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.separateDebitCreditquery()");
		if (rgm.getBodyQuery() != null) {
			setAcquirerDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("\"BRANCH CODE\",", "").replace("ABR.ABR_CODE", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("\"BRANCH CODE\" ASC,", ""));
			setAcquirerCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("\"BRANCH CODE\",", "").replace("ABR.ABR_CODE", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("\"BRANCH CODE\" ASC,", ""));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, "").replace("\"BRANCH CODE\",", "")
					.replace("ABR.ABR_CODE", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("\"BRANCH CODE\" ASC,", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
			setCriteriaQuery(getDebitBodyQuery());
		}
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String glDescription, String branchCode, String indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.DEBITS)) {
				if (getFieldValue(field, fieldsMap, true).indexOf(",") != 0) {
					total += Double.parseDouble(getFieldValue(field, fieldsMap, true).replace(",", ""));
				} else {
					total += Double.parseDouble(getFieldValue(field, fieldsMap, true));
				}
			}

			switch (field.getFieldName()) {
			case ReportConstants.BRANCH_CODE:
				if (!(glDescription.equalsIgnoreCase(ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL)
						&& indicator.equals(ReportConstants.CREDIT_IND))) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", "5008"));
				} else {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
				}
				break;
			case ReportConstants.GL_ACCOUNT_NUMBER:
				if (branchCode != null && glDescription.equalsIgnoreCase(ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL)
						&& indicator.equals(ReportConstants.CREDIT_IND)) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							branchCode + getFieldValue(field, fieldsMap, true)));
				} else {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
				}
				break;
			case ReportConstants.GL_ACCOUNT_NAME:
				line.append(String.format("%1$5s", "")
						+ String.format("%1$-" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap, true)));
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
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeTrailer(ReportGenerationMgr rgm)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					line.append(String.format("%" + field.getCsvTxtLength() + "s", " ").replace(' ',
							getGlobalFieldValue(field, true).charAt(0)));
				} else if (field.getFieldName().contains(ReportConstants.TOTAL_CREDIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatter.format(total)));
				} else if (getGlobalFieldValue(field, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
				}
				line.append(getEol());
			} else {
				if (field.getFieldName().contains(ReportConstants.TOTAL_DEBIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatter.format(total)));
				} else if (getGlobalFieldValue(field, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
							field.getDefaultValue().charAt(0)));
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				}
				contentStream.newLineAtOffset(0, -leading);
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
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.DEBITS)) {
				if (getFieldValue(field, fieldsMap, true).indexOf(",") != 0) {
					total += Double.parseDouble(getFieldValue(field, fieldsMap, true).replace(",", ""));
				} else {
					total += Double.parseDouble(getFieldValue(field, fieldsMap, true));
				}
			}

			switch (field.getFieldName()) {
			case ReportConstants.BRANCH_CODE:
				if (!(glDescription.equalsIgnoreCase(ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL)
						&& indicator.equals(ReportConstants.CREDIT_IND))) {
					contentStream.showText(String.format("%1$" + field.getCsvTxtLength() + "s", "5008"));
				} else {
					contentStream.showText(String.format("%1$" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
				}
				break;
			case ReportConstants.GL_ACCOUNT_NUMBER:
				if (branchCode != null && glDescription.equalsIgnoreCase(ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL)
						&& indicator.equals(ReportConstants.CREDIT_IND)) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
							branchCode + getFieldValue(field, fieldsMap, true)));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				}
				break;
			case ReportConstants.GL_ACCOUNT_NAME:
				contentStream.showText(String.format("%1$5s", "")
						+ String.format("%1$-" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				break;
			default:
				if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				}
				break;
			}
		}
		contentStream.newLineAtOffset(0, -leading);
	}

	private void writePdfTrailer(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
							getGlobalFieldValue(field, true).charAt(0)));
				} else if (field.getFieldName().contains(ReportConstants.TOTAL_CREDIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatter.format(total)));
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getGlobalFieldValue(field, true)));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.getFieldName().contains(ReportConstants.TOTAL_DEBIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatter.format(total)));
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getGlobalFieldValue(field, true)));
				}
			}
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, String glDescription, String branchCode, String indicator) {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.executePdfBodyQuery()");
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, glDescription, branchCode, indicator);
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
