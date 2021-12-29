package my.com.mandrill.base.reporting.dcmsAppRejPendCard;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
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

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class DCMSApproveRejectPendingCardReport extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(DCMSApproveRejectPendingCardReport.class);
	protected float DEFAULT_PAGE_HEIGHT = 10;
	protected float pageHeight = DEFAULT_PAGE_HEIGHT;
	protected float totalHeight = PDRectangle.A4.getWidth();
	protected int pagination = 0;
	protected static String DCMS_ROTATION_NUMBER_KEY = "ROTATION_NUMBER";

	@Override
	public void executePdf(ReportGenerationMgr rgm) throws ReportGenerationException {
		logger.debug("In DCMSApproveRejectPendingCardReport.processPdfRecord(): " + rgm.getFileNamePrefix());
		if (getEncryptionService() == null) {
        	setEncryptionService(rgm.getEncryptionService());
        }
		generateReport(rgm);
	}

	private void generateReport(ReportGenerationMgr rgm) throws ReportGenerationException {
		logger.debug("In DCMSApproveRejectPendingCardReport.generateReport(): " + rgm.getFileNamePrefix());
		pageHeight = DEFAULT_PAGE_HEIGHT;
		totalHeight = PDRectangle.A4.getWidth();
		PDDocument doc = null;
		pagination = 1;

		try {
			preProcessing(rgm);

			doc = new PDDocument();
			PDPage page = new PDPage(new PDRectangle(PDRectangle.A4.getHeight(), PDRectangle.A4.getWidth()));
			doc.addPage(page);
			PDPageContentStream contentStream = new PDPageContentStream(doc, page);
			PDFont pdfFont = PDType1Font.COURIER;
			float fontSize = 6;
			float leading = 1.5f * fontSize;
			PDRectangle pageSize = page.getMediaBox();
			float margin = 30;
			float startX = pageSize.getLowerLeftX() + margin;
			float startY = pageSize.getUpperRightY() - margin;

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			writePdfHeader(rgm, contentStream, leading, pagination);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;

			contentStream.newLineAtOffset(0, -leading);
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize);
			pageHeight += 1;

			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;

			writePdfTrailer(rgm, null, contentStream, leading);

			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 4;

			contentStream.endText();
			contentStream.close();

			saveFile(rgm, doc);
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
			throw new ReportGenerationException("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
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

	protected PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In DCMSApproveRejectPendingCardReport.generateReport(): " + rgm.getFileNamePrefix());
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
				int recordCount = 0;

				if (rs.next()) {
					do {
						if (recordCount > 0 && recordCount % 50 == 0) {
							pageHeight = DEFAULT_PAGE_HEIGHT;
							contentStream.endText();
							contentStream.close();
							page = new PDPage(new PDRectangle(PDRectangle.A4.getHeight(), PDRectangle.A4.getWidth()));
							doc.addPage(page);
							pagination++;
							contentStream = new PDPageContentStream(doc, page);
							contentStream.setFont(pdfFont, fontSize);
							contentStream.beginText();
							contentStream.newLineAtOffset(startX, startY);
							writePdfHeader(rgm, contentStream, leading, pagination);
							contentStream.newLineAtOffset(0, -leading);
							pageHeight += 4;
							contentStream.newLineAtOffset(0, -leading);
							writePdfBodyHeader(rgm, contentStream, leading);
							pageHeight += 2;
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
									field.setValue(
											Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
								} else {
									field.setValue(result.toString());
								}
							} else {
								field.setValue("");
							}
							String keyRotationStr = lineFieldsMap.get(DCMS_ROTATION_NUMBER_KEY).getValue();
							String functionName = lineFieldsMap.get("FUNCTION_NAME").getValue();
													
							if ("FROM_DATA".equals(field.getFieldName()) && field.getValue() != null && !field.getValue().trim().isEmpty()) {
								logger.debug("functionName= {}", functionName);
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution(), keyRotationStr));
							} else if ("TO_DATA".equals(field.getFieldName()) && field.getValue() != null && !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution(), keyRotationStr));
							}
							
						}

						writePdfBodyApprovedRejected(rgm, lineFieldsMap, contentStream, leading);
						pageHeight++;
						recordCount++;
					} while (rs.next());
				} else {
					contentStream.showText(ReportConstants.NO_RECORD);
				}

				addTotalNoOfItemToGlobalParam(recordCount);
				contentStream.newLineAtOffset(0, -leading);
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
	
	protected String extractAccountNumberFromJson(String jsonString, String institutionCode, String keyRotationStr) {
		if (jsonString != null && jsonString.trim().isEmpty()) {
			return jsonString;
		}
//		String keyRotationStr = fieldsMap.get(DCMS_ROTATION_NUMBER_KEY).getValue();
		int keyRotationNumber = 0;
		try {
			if(keyRotationStr!=null){
				keyRotationNumber = Integer.parseInt(keyRotationStr);
			}						
		} catch (NumberFormatException e) {
			logger.warn("Failed to parse value for DCMS_ROTATION_NUMBER_KEY");
		}
		String accountListStr = "";

		try {
			StringBuilder sb = new StringBuilder();
			JsonNode jsonNode = new  ObjectMapper().readTree(jsonString);
			List<String> accountList = jsonNode.findValuesAsText("bacAccountNumber");
			logger.debug("bacAccountNumber = {}", accountList);
			if(accountList.size()>0){
				for (int i=0; i<accountList.size(); i++) {
					if (i > 0) {
						sb.append(",");
					}
					//FIXME: How to retrieve rotation key from BAC_ID without hardcode?
					sb.append(getEncryptionService().decryptDcms(accountList.get(i), institutionCode, keyRotationNumber));
				}			
				accountListStr = sb.toString();
			}
			else{ 
				logger.debug("bacAccountNumber not found");
				return jsonString;
			}
		} catch (Exception e) {
			logger.debug("Failed to decrypt string:{}", jsonString, e);			
		}
		
		return accountListStr;
	}
	
	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {

		String txnStartDate = rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
		String txnEndDate = rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

		logger.debug(
				"In DCMSApproveRejectPendingCardReport.preProcessing: fileNamePrefix={}, txnStartDate={}, txnEndDate={}, dcmsSchema={}, dbLink={}, institution={}",
				rgm.getFileNamePrefix(), txnStartDate, txnEndDate, rgm.getDcmsDbSchema(), rgm.getDbLink(),
				rgm.getInstitution());

		// replace {From_Date}/{To_Date}/{DCMS_Schema}/{Iss_Name} to actual value
		rgm.setBodyQuery(
				rgm.getBodyQuery().replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + txnStartDate + "'")
						.replace("{" + ReportConstants.PARAM_TO_DATE + "}", "'" + txnEndDate + "'")
						.replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA + "}", rgm.getDcmsDbSchema())
						.replace("{" + ReportConstants.PARAM_DB_LINK_DCMS + "}", rgm.getDbLink())
						.replace("{" + ReportConstants.PARAM_ISSUER_NAME + "}",
								rgm.getInstitution().equals("CBC") ? ReportConstants.DCMS_CBC_INSTITUTION
										: ReportConstants.DCMS_CBS_INSTITUTION));

		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			if (getEncryptionService() == null) {
	        	setEncryptionService(rgm.getEncryptionService());
	        }
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			preProcessing(rgm);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			writeTrailer(rgm, null);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | InstantiationException | IllegalAccessException | ClassNotFoundException
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

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.executeBodyQuery()");
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
				int recordCount = 0;

				if (rs.next()) {
					do {
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
									field.setValue(
											Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
								} else {
									field.setValue(result.toString());
								}
							} else {
								field.setValue("");
							}

							String keyRotationStr = lineFieldsMap.get(DCMS_ROTATION_NUMBER_KEY).getValue();
							if ("FROM_DATA".equals(field.getFieldName()) && field.getValue() != null && !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution(), keyRotationStr));
							} else if ("TO_DATA".equals(field.getFieldName()) && field.getValue() != null && !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution(), keyRotationStr));
							} 
						}
						writeBodyApprovedReject(rgm, lineFieldsMap);
						recordCount++;
					} while (rs.next());
				} else {
					rgm.writeLine(ReportConstants.NO_RECORD.getBytes());
					rgm.writeLine(getEol().getBytes());
				}

				addTotalNoOfItemToGlobalParam(recordCount);

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
	
	protected void writeBodyApprovedReject(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {

			if (field.isDecrypt()) {
				decryptValuesApprovedReject(field, fieldsMap, getGlobalFileFieldsMap());
			}

			line.append("\""+ getFieldValue(rgm, field, fieldsMap) + "\"");
			line.append(field.getDelimiter());
			if (field.isEol()) {
				line.append(getEol());
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}

	protected void addTotalNoOfItemToGlobalParam(int count) {
		ReportGenerationFields total = new ReportGenerationFields(ReportConstants.TOTAL,
				ReportGenerationFields.TYPE_NUMBER, String.valueOf(count));
		getGlobalFileFieldsMap().put(total.getFieldName(), total);
	}

	protected void writePdfBodyApprovedRejected(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
					throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			
			if (field.isDecrypt()) {
				decryptValuesApprovedReject(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
			}
		}
	}
}
