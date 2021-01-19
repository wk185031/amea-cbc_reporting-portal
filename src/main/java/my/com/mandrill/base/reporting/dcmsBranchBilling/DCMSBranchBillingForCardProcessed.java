package my.com.mandrill.base.reporting.dcmsBranchBilling;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
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

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class DCMSBranchBillingForCardProcessed extends PdfReportProcessor {
	private final Logger logger = LoggerFactory.getLogger(DCMSBranchBillingForCardProcessed.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
		
	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In DCMSBranchBillingForCardProcessed.processPdfRecord()");
		generateReport(rgm);
	}

	private void generateReport(ReportGenerationMgr rgm) {
		logger.debug("In DCMSBranchBillingForCardProcessed.generateReport()");
		pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
		totalHeight = PDRectangle.A4.getHeight();
		PDDocument doc = null;
		pagination = 1;

		try {
			preProcessing(rgm);

			doc = new PDDocument();
			PDPage page = new PDPage();
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
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
					startY, pdfFont, fontSize);
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

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In DCMSBranchBillingForCardProcessed.executePdfBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		HashMap<String, List<HashMap<String, ReportGenerationFields>>> branchToLineFieldsMap = new HashMap<String, List<HashMap<String, ReportGenerationFields>>>();
		List<HashMap<String, ReportGenerationFields>> lineFieldsMapList = null;
		String branchCode = null;
		String branchName = null;
		StringBuilder str = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);

				while (rs.next()) {
					lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
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
					
					if(str == null) {
                    	str = new StringBuilder();
                    }
					
					branchCode = lineFieldsMap.get(ReportConstants.BRANCH_CODE).getValue();
					branchName = lineFieldsMap.get(ReportConstants.BRANCH_NAME).getValue();
					
					str.append(branchCode);
					str.append(",");
					str.append(branchName);
					
					if(branchToLineFieldsMap.containsKey(str.toString())) {
						branchToLineFieldsMap.get(str.toString()).add(lineFieldsMap);
                    } else {
                    	lineFieldsMapList = new ArrayList<HashMap<String, ReportGenerationFields>>();
                    	lineFieldsMapList.add(lineFieldsMap);
                    	branchToLineFieldsMap.put(str.toString(), lineFieldsMapList);
                    }
					
					str.setLength(0);  
				}
				
				for(Map.Entry<String, List<HashMap<String,ReportGenerationFields>>> branchProgramMap: branchToLineFieldsMap.entrySet()) {
					preProcessingBodyHeader(rgm, branchProgramMap.getKey().split(",")[0], branchProgramMap.getKey().split(",")[1]);
					writePdfBodyHeader(rgm, contentStream, leading);
					pageHeight += 2;
					
					for(HashMap<String,ReportGenerationFields> m: branchProgramMap.getValue()) {
						writePdfBody(rgm, m, contentStream, leading);
						pageHeight++;
        			} 
					contentStream.newLineAtOffset(0, -leading);
					pageHeight += 2;
				}
				
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

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In DCMSBranchBillingForCardProcessed.preProcessing():" + rgm.getFileNamePrefix());
		
		// replace {From_Date}/{To_Date}/{DCMS_Schema}/{Iss_Id} to actual value
		rgm.setBodyQuery(rgm.getBodyQuery()
				.replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
				.replace("{" + ReportConstants.PARAM_TO_DATE + "}", "'" + rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
				.replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA+ "}", rgm.getDcmsDbSchema())
				.replace("{" + ReportConstants.PARAM_DB_LINK_DCMS + "}", rgm.getDbLink())
				.replace("{" + ReportConstants.PARAM_ISSUER_ID+ "}", rgm.getInstitution().equals("CBC") ? ReportConstants.DCMS_CBC_INSTITUTION : ReportConstants.DCMS_CBS_INSTITUTION));
		
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			preProcessing(rgm);
			executeBodyQuery(rgm);
			writeTrailer(rgm, null);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | InstantiationException | IllegalAccessException | ClassNotFoundException | JSONException e) {
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
		HashMap<String, List<HashMap<String, ReportGenerationFields>>> branchToLineFieldsMap = new HashMap<String, List<HashMap<String, ReportGenerationFields>>>();
		List<HashMap<String, ReportGenerationFields>> lineFieldsMapList = null;
		String branchCode = null;
		String branchName = null;
		StringBuilder str = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);

				while (rs.next()) {
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
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}

					if(str == null) {
                    	str = new StringBuilder();
                    }
					
					branchCode = lineFieldsMap.get(ReportConstants.BRANCH_CODE).getValue();
					branchName = lineFieldsMap.get(ReportConstants.BRANCH_NAME).getValue();
					
					str.append(branchCode);
					str.append(",");
					str.append(branchName);
					
					if(branchToLineFieldsMap.containsKey(str.toString())) {
						branchToLineFieldsMap.get(str.toString()).add(lineFieldsMap);
                    } else {
                    	lineFieldsMapList = new ArrayList<>();
                    	lineFieldsMapList.add(lineFieldsMap);
                    	branchToLineFieldsMap.put(str.toString(), lineFieldsMapList);
                    }	
					
					str.setLength(0);  
				}
				
				for(Map.Entry<String, List<HashMap<String,ReportGenerationFields>>> branchProgramMap: branchToLineFieldsMap.entrySet()) {
					preProcessingBodyHeader(rgm, branchProgramMap.getKey().split(",")[0], branchProgramMap.getKey().split(",")[1]);
					writeBodyHeader(rgm);
					
					for(HashMap<String,ReportGenerationFields> m: branchProgramMap.getValue()) {
						writeBody(rgm, m);
        			}    
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

	private void preProcessingBodyHeader(ReportGenerationMgr rgm, String brcCode, String brcName)
    		throws InstantiationException, IllegalAccessException, ClassNotFoundException {
    	logger.debug("In DCMSBranchBillingForCardProcessed.preProcessingBodyHeader()");

    	ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.BRANCH_CODE,
    			ReportGenerationFields.TYPE_STRING, brcCode);
    	ReportGenerationFields branchName = new ReportGenerationFields(ReportConstants.BRANCH_NAME,
    			ReportGenerationFields.TYPE_STRING, brcName);
    	
    	getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
    	getGlobalFileFieldsMap().put(branchName.getFieldName(), branchName);
    }
}
