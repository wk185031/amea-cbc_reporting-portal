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

import my.com.mandrill.base.processor.ReportGenerationException;
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
	private String ie_ins_name = "CBS";
	private String ie_ins_id = "0000000112";
	private String ins_id = "0000000010";

	@Override
	public void executePdf(ReportGenerationMgr rgm) throws ReportGenerationException {
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

			if (rgm.getInstitution().equalsIgnoreCase("CBS")) {
				ie_ins_name = "CBC";
				ie_ins_id = "0000000010";
				ins_id = "0000000112";
			}

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

			Iterator<String> glDescriptionItr = filterByGlDescription(rgm).iterator();

			while (glDescriptionItr.hasNext()) {
				glDescription = glDescriptionItr.next();

				rgm.setBodyQuery(getDebitBodyQuery());
				preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
				contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
						pdfFont, fontSize, glDescription, ReportConstants.DEBIT_IND);

				rgm.setBodyQuery(getCreditBodyQuery());
				preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
				contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
						pdfFont, fontSize, glDescription, ReportConstants.CREDIT_IND);
//					}
			}

			writePdfTrailer(rgm, contentStream, leading);
			pageHeight += 1;
			contentStream.endText();
			contentStream.close();

			saveFile(rgm, doc);
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Error in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
			throw new ReportGenerationException(
					"Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
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

			if (rgm.getInstitution().equalsIgnoreCase("CBS")) {
				ie_ins_name = "CBC";
				ie_ins_id = "0000000010";
				ins_id = "0000000112";
			}

			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			Iterator<String> glDescriptionItr = filterByGlDescription(rgm).iterator();

			while (glDescriptionItr.hasNext()) {
				glDescription = glDescriptionItr.next();

				rgm.setBodyQuery(getDebitBodyQuery());
				preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
				executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);

				rgm.setBodyQuery(getCreditBodyQuery());
				preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
				executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
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
				rgm.cleanAllDbResource(ps, rs);
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
		case ReportConstants.INTER_ENTITY_SERVICE_CHARGE:
		case ReportConstants.INTER_ENTITY_AP_ATM_WITHDRAWAL:
			ReportGenerationFields channelAP = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"(TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL)) AND TXN.TRL_ISS_NAME = '"
							+ rgm.getInstitution() + "'  AND (TXN.TRL_DEO_NAME = '" + ie_ins_name
							+ "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ie_ins_id + "')");
			getGlobalFileFieldsMap().put(channelAP.getFieldName(), channelAP);
			break;
		case ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL:
			ReportGenerationFields channelAR = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"(TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL)) AND TXN.TRL_ISS_NAME = '"
							+ ie_ins_name + "'  AND (TXN.TRL_DEO_NAME = '" + rgm.getInstitution()
							+ "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ins_id + "')");
			getGlobalFileFieldsMap().put(channelAR.getFieldName(), channelAR);
			break;
		case ReportConstants.INTER_ENTITY_IBFT_CHARGE:
		case ReportConstants.INTER_ENTITY_FUND_TRANSFER_DR:
			ReportGenerationFields channelDR = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
//					"TXN.TRL_TSC_CODE IN (40,42,48) AND TXN.TRL_ISS_NAME = '" + rgm.getInstitution()
//							+ "' AND (((TXN.TRL_DEO_NAME = '" + rgm.getInstitution()
//							+ "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ins_id + "')"
//							+ " AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ie_ins_id + "') OR "
//							+ "((TXN.TRL_DEO_NAME = '" + ie_ins_name + "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '"
//							+ ie_ins_id + "')" + " AND (LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') IN ('" + ie_ins_id + "')"
////							+ "','" + ins_id + "')"
//							+ "OR (TXN.TRL_FRD_REV_INST_ID IS NULL AND TXN.TRL_TSC_CODE = 40)))) ");
					"TXN.TRL_TSC_CODE IN (40,42,48) AND TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"
					+ "AND (TXN.TRL_DEO_NAME IN ( '" + rgm.getInstitution() + "','" + ie_ins_name + "')"
					+ " OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') IN ('" + ins_id + "','" + ie_ins_id + "'))"
					+ " AND (LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0')) IN ('" + ie_ins_id + "')");

			getGlobalFileFieldsMap().put(channelDR.getFieldName(), channelDR);
			break;
		case ReportConstants.INTER_ENTITY_FUND_TRANSFER_CR:
			ReportGenerationFields channelCR = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, 
//					"TXN.TRL_TSC_CODE IN (40, 42, 44, 48) "
////					+ " AND ((TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"
////					+ " AND (TXN.TRL_DEO_NAME = '" + ie_ins_name + "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ie_ins_id + "') "
////					+ " AND (LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ins_id + "' OR (TXN.TRL_FRD_REV_INST_ID IS NULL AND TXN.TRL_TSC_CODE = 40)))"
////					+ " OR ("
//					+ " AND TXN.TRL_ISS_NAME = '" + ie_ins_name + "'"
//					+ " AND (TXN.TRL_DEO_NAME IN ('" + rgm.getInstitution() + "' , '" + ie_ins_name + "') OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') IN ('" + ie_ins_id + "','" + ins_id + "'))"
//					+ " AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ins_id + "'");
////							+ ")");
					"TXN.TRL_TSC_CODE IN (40,42,48) AND TXN.TRL_ISS_NAME = '" + ie_ins_name + "'"
							+ "AND (TXN.TRL_DEO_NAME IN ( '" + rgm.getInstitution() + "','" + ie_ins_name + "')"
							+ " OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') IN ('" + ins_id + "','" + ie_ins_id + "'))"
							+ " AND (LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0')) IN ('" + ins_id + "')");
			getGlobalFileFieldsMap().put(channelCR.getFieldName(), channelCR);
			rgm.setBodyQuery(rgm.getBodyQuery().replace("TXN.TRL_ACCOUNT_1_ACN_ID", "TXN.TRL_ACCOUNT_2_ACN_ID"));
			break;
		default:
			ReportGenerationFields defaultChannel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_TSC_CODE = 31 AND TXN.TRL_ISS_NAME = '" + rgm.getInstitution()
							+ "'  AND (TXN.TRL_DEO_NAME = '" + ie_ins_name
							+ "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ie_ins_id + "')");
			getGlobalFileFieldsMap().put(defaultChannel.getFieldName(), defaultChannel);
			break;
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.separateDebitCreditquery()");
		if (rgm.getBodyQuery() != null) {
			setDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
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
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					total += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					total += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}

			switch (field.getFieldName()) {
			case ReportConstants.BRANCH_CODE:
				if ((branchCode != null
						&& glDescription.equalsIgnoreCase(ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL)
						&& indicator.equals(ReportConstants.CREDIT_IND))) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", branchCode));
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
				}
				break;
			case ReportConstants.GL_ACCOUNT_NUMBER:
				if (branchCode != null && glDescription.equalsIgnoreCase(ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL)
						&& indicator.equals(ReportConstants.CREDIT_IND)) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							branchCode + getFieldValue(field, fieldsMap)));
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
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
		logger.debug("In GLHandoffFinalProofSheetInterEntity.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.TOTAL_CREDIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatter.format(total)));
				} else {
					line.append(getGlobalFieldValue(rgm, field));
				}
				line.append(getEol());
			} else {
				if (field.getFieldName().contains(ReportConstants.TOTAL_DEBIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatter.format(total)));
				} else {
					line.append(getGlobalFieldValue(rgm, field));
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, String glDescription, String indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.DEBITS)) {
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					total += Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					total += Double.parseDouble(getFieldValue(field, fieldsMap));
				}
			}

			switch (field.getFieldName()) {
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
		logger.debug("In GLHandoffFinalProofSheetInterEntity.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.TOTAL_CREDIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatter.format(total)));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.getFieldName().contains(ReportConstants.TOTAL_DEBIT)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatter.format(total)));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
			}
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, String glDescription, String indicator) {
		logger.debug("In GLHandoffFinalProofSheetInterEntity.executePdfBodyQuery()");
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
						logger.debug("field.getValue():" + field.getValue());
					}
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, glDescription, indicator);
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
}
