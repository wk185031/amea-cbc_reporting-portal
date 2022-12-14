package my.com.mandrill.base.reporting.dcmsAppRejPendCard;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
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

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class DCMSApproveRejectPendingCardReport extends PdfReportProcessor {

	private final static Logger logger = LoggerFactory.getLogger(DCMSApproveRejectPendingCardReport.class);
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
				ps = rgm.getConnection().prepareStatement(query);
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

							if ("CRD_NUMBER_ENC".equals(field.getFieldName()) && field.getValue() != null
									&& !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromCifResponse(field.getValue()));
							}

							String keyRotationStr = fieldsMap.get(DCMS_ROTATION_NUMBER_KEY).getValue();
							if ("FROM_DATA".equals(field.getFieldName()) && field.getValue() != null
									&& !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution(),
										keyRotationStr));

							} else if ("TO_DATA".equals(field.getFieldName()) && field.getValue() != null
									&& !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution(),
										keyRotationStr));
							}
						}

						populateClientName(lineFieldsMap);
						String auditLog = null;
						try {
							auditLog = rs.getString("AUDIT_LOG");
							if (auditLog != null && !auditLog.trim().isEmpty()) {
								populateFromAndToData(lineFieldsMap, auditLog);
							}
						} catch (SQLException e) {
							// DO nothing. No audit log available
						} catch (Exception e) {
							logger.warn("Failed to retrieve from and to data:{}", auditLog, e);
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
				rgm.cleanAllDbResource(ps, rs);
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
			if (keyRotationStr != null && !keyRotationStr.isEmpty()) {
				keyRotationNumber = Integer.parseInt(keyRotationStr);
			}
		} catch (NumberFormatException e) {
			logger.warn("Failed to parse value for DCMS_ROTATION_NUMBER_KEY: {}", keyRotationNumber);
		}
		String accountListStr = "";

		try {
			StringBuilder sb = new StringBuilder();
			// FIXME: How to only parse for Account Linking/Delinking
			if (jsonString.contains("bacAccountNumber")) {
				JsonNode jsonNode = new ObjectMapper().readTree(jsonString);
				List<String> accountList = jsonNode.findValuesAsText("bacAccountNumber");
				logger.debug("bacAccountNumber = {}", accountList);
				if (accountList.size() > 0) {
					for (int i = 0; i < accountList.size(); i++) {
						if (i > 0) {
							sb.append(",");
						}
						// FIXME: How to retrieve rotation key from BAC_ID without hardcode?
						sb.append(getEncryptionService().decryptDcms(accountList.get(i), institutionCode,
								keyRotationNumber));
					}
					accountListStr = sb.toString();
				}
			} else {
				logger.debug("bacAccountNumber not found");
				return jsonString;
			}
		} catch (Exception e) {
			logger.warn("Failed to decrypt string:{}", jsonString);
			// return jsonString;
		}

		return accountListStr;
	}

	protected String extractAccountNumberFromCifResponse(String jsonString) {
		if (jsonString != null && jsonString.trim().isEmpty()) {
			return jsonString;
		}

		String accNo = "";

		try {

			if (jsonString.contains("bacAccountNumber")) {
				JsonNode jsonBac = new ObjectMapper().readTree(jsonString);

//				logger.debug("jsonString: {}", jsonString);
//				logger.debug("jsonBac: {}", jsonBac);

				if (jsonBac.isArray()) {
//					logger.debug("jsonBac is Array");
					for (final JsonNode objNode : jsonBac) {
						int bacOverallDefault = objNode.get("bacOverallDefault").asInt();

//						logger.debug("bacOverallDefault: {}", bacOverallDefault);
						if (bacOverallDefault == 1) {
							return objNode.get("bacAccountNumber").asText();
						}
					}
				} else {
					int bacOverallDefault = jsonBac.get("bacOverallDefault").asInt();
					if (bacOverallDefault == 1) {
						return jsonBac.get("bacAccountNumber").asText();
					}
//					logger.debug("bacOverallDefault: {}", bacOverallDefault);
				}
			} else {
				logger.debug("bankAccountCollection not found");
				return jsonString;
			}
		} catch (Exception e) {
			logger.warn("Failed to extractAccountNumberFromCifResponse:{}", jsonString);
			// return jsonString;
		}

		return accNo;
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {

		String txnStartDate = rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
		String txnEndDate = rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
		
		String txnStartDateUTC = rgm.getTxnStartDate().atZone(ZoneId.of(ReportConstants.TimeZone.MANILA)).withZoneSameInstant(ZoneId.of(ReportConstants.TimeZone.UTC)).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
		String txnEndDateUTC = rgm.getTxnEndDate().atZone(ZoneId.of(ReportConstants.TimeZone.MANILA)).withZoneSameInstant(ZoneId.of(ReportConstants.TimeZone.UTC)).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

		logger.debug(
				"In DCMSApproveRejectPendingCardReport.preProcessing: fileNamePrefix={}, txnStartDate={}, txnEndDate={}, dcmsSchema={}, dbLink={}, institution={}",
				rgm.getFileNamePrefix(), txnStartDate, txnEndDate, rgm.getDcmsDbSchema(), rgm.getDbLink(),
				rgm.getInstitution());

		// replace {From_Date}/{To_Date}/{DCMS_Schema}/{Iss_Name} to actual value
		rgm.setBodyQuery(
				rgm.getBodyQuery().replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + txnStartDate + "'")
						.replace("{" + ReportConstants.PARAM_TO_DATE + "}", "'" + txnEndDate + "'")
						.replace("{" + ReportConstants.PARAM_FROM_DATE_UTC + "}", "'" + txnStartDateUTC + "'")
						.replace("{" + ReportConstants.PARAM_TO_DATE_UTC + "}", "'" + txnEndDateUTC + "'")
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
				ps = rgm.getConnection().prepareStatement(query);
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
							if ("CRD_NUMBER_ENC".equals(field.getFieldName()) && field.getValue() != null
									&& !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromCifResponse(field.getValue()));
							}

							String keyRotationStr = lineFieldsMap.get(DCMS_ROTATION_NUMBER_KEY).getValue();
							if ("FROM_DATA".equals(field.getFieldName()) && field.getValue() != null
									&& !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution(),
										keyRotationStr));

							} else if ("TO_DATA".equals(field.getFieldName()) && field.getValue() != null
									&& !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution(),
										keyRotationStr));
							}
						}

						populateClientName(lineFieldsMap);
						String auditLog = null;
						try {
							auditLog = rs.getString("AUDIT_LOG");
							if (auditLog != null && !auditLog.trim().isEmpty()) {
								populateFromAndToData(lineFieldsMap, auditLog);
							}
						} catch (SQLException e) {
							// DO nothing. No audit log available
						} catch (Exception e) {
							logger.warn("Failed to retrieve from and to data:{}", auditLog, e);
						}
						
						if (auditLog != null && !auditLog.trim().isEmpty()) {
							populateFromAndToData(lineFieldsMap, auditLog);
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
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}

	private void populateClientName(HashMap<String, ReportGenerationFields> lineFieldsMap) {
		if (!lineFieldsMap.containsKey("FUNCTION_NAME")) {
			return;
		}

		String functionName = lineFieldsMap.get("FUNCTION_NAME").getValue();
		if ("FETCH CIF".equals(functionName)) {
			String encClientName = lineFieldsMap.get("CLIENT_NAME").getValue();
			String clientName = null;
			String rotationNumberStr = lineFieldsMap.get("ROTATION_NUMBER").getValue();
			int rotationNumber = (rotationNumberStr == null || rotationNumberStr.trim().isEmpty()) ? 1
					: Integer.parseInt(rotationNumberStr);

			if (encClientName.contains("|")) {
				String[] clientNames = encClientName.split("\\|");
				clientName = concatName(clientNames[0], clientNames[1], lineFieldsMap.get("INSTITUTION_ID").getValue(),
						rotationNumber);
			} else {
				clientName = concatName(encClientName, null, lineFieldsMap.get("INSTITUTION_ID").getValue(),
						rotationNumber);
			}

			lineFieldsMap.get("CLIENT_NAME").setValue(clientName);
		}
	}

	private void populateFromAndToData(HashMap<String, ReportGenerationFields> lineFieldsMap, String auditLog) {
		String functionName = null;
		if (lineFieldsMap.containsKey("FUNCTION_NAME")) {
			functionName = lineFieldsMap.get("FUNCTION_NAME").getValue();
		} else if (lineFieldsMap.containsKey("FUNCTIONNAME")) {
			functionName = lineFieldsMap.get("FUNCTIONNAME").getValue();
		}

		if (functionName == null) {
			return;
		}

		switch (functionName) {
		case ReportConstants.SupportFunction.WITHHELD_RENEWAL:
		case ReportConstants.SupportFunction.CC_WITHHELD_RENEWAL:
			retrieveFromAndToFromAuditLog(lineFieldsMap, auditLog, "ALLOWED_RENEWAL");
			break;
		default:
			// do nothing
			break;
		}
	}

	private static void retrieveFromAndToFromAuditLog(HashMap<String, ReportGenerationFields> lineFieldsMap,
			String auditLog, String colName) {
		String predicate = "$..CHANGE[?(@.COL == '" + colName + "')]";
		List<Map<String, String>> dataList = JsonPath.parse(auditLog).read(predicate);
		if (!dataList.isEmpty()) {
			String from = dataList.get(0).get("OLD_VALUE");
			String to = dataList.get(0).get("NEW_VALUE");
			lineFieldsMap.get("FROM_DATA").setValue(from);
			lineFieldsMap.get("TO_DATA").setValue(to);
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

			line.append("\"" + getFieldValue(rgm, field, fieldsMap) + "\"");
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

	protected void writePdfBodyApprovedRejected(ReportGenerationMgr rgm,
			HashMap<String, ReportGenerationFields> fieldsMap, PDPageContentStream contentStream, float leading)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {

			if (field.isDecrypt()) {
				decryptValuesApprovedReject(field, fieldsMap, getGlobalFileFieldsMap());
			}

			String value = getFieldValue(rgm, field, fieldsMap);
			if (value != null) {
				value = value.replaceAll("[\\n\\t ]", " ");
			}
			if (field.isEol()) {
				contentStream.showText(value);
				contentStream.newLineAtOffset(0, -leading);
			} else {
				contentStream.showText(value);
			}
		}
	}

	private String concatName(String encFirstName, String encLastName, String institutionCode, int rotationNumber) {
		logger.debug("concatName: encFirstName={}, encLastName={}, institutionCode={}, rotationNumber={}", encFirstName,
				encLastName, institutionCode, rotationNumber);

		String decryptFirstName = null;
		if (encFirstName != null) {
			decryptFirstName = getEncryptionService().decryptDcms(encFirstName, institutionCode, rotationNumber);
		}

		String decryptLastName = null;
		if (encLastName != null) {
			decryptLastName = getEncryptionService().decryptDcms(encLastName, institutionCode, rotationNumber);
		}

		if (decryptFirstName == null) {
			decryptFirstName = encFirstName;
		}

		if (decryptLastName == null) {
			decryptLastName = encLastName;
		}

		return decryptFirstName + " " + decryptLastName;
	}

	public static void main(String[] args) {
		String auditLog = "[{\"DATE\":\"2022-02-21 16:54:07\",\"DESCRIPTION\":\"Request status is PENDING_APPROVAL\",\"Client Name\":\"ATM SIT 4 .\",\"CHANGE\":[{\"COL\":\"ALLOWED_RENEWAL\",\"NEW_VALUE\":\"No\",\"OLD_VALUE\":\"Yes\"}],\"username\":\"cbcmaker\"},{\"DATE\":\"2022-02-21 16:56:31\",\"DESCRIPTION\":\"Request status changed from PENDING_APPROVAL to COMPLETED\",\"Client Name\":\"ATM SIT 4 .\",\"CHANGE\":[{\"COL\":\"ALLOWED_RENEWAL\",\"NEW_VALUE\":\"No\",\"OLD_VALUE\":\"Yes\"}],\"username\":\"cbcchecker\"}]";
		String auditLog2 = "[{\"DATE\":\"2022-01-14 04:27:52\",\"DESCRIPTION\":\"Request status is PENDING_APPROVAL\",\"Client Name\":\"R00334456 R00334456\",\"username\":\"cbcmaker\"},{\"DATE\":\"2022-01-14 04:32:55\",\"DESCRIPTION\":\"Request status changed from PENDING_APPROVAL to REJECTED\",\"Client Name\":\"R00334456 R00334456\",\"username\":\"cbcchecker\"}]";

		retrieveFromAndToFromAuditLog(null, auditLog2, "ALLOWED_RENEWAL");
	}
}
