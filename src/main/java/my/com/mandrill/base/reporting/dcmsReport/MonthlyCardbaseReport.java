package my.com.mandrill.base.reporting.dcmsReport;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class MonthlyCardbaseReport extends PdfReportProcessor {

    private final Logger logger = LoggerFactory.getLogger(MonthlyCardbaseReport.class);
    private final PDFont DEFAULT_FONT = PDType1Font.COURIER;
	private final PDRectangle DEFAULT_PAGE_LAYOUT = PDRectangle.A4;
	private final float DEFAULT_FONT_SIZE = 6;
	private final float DEFAULT_MARGIN = 30;
    
    private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
    private float totalHeight = PDRectangle.A4.getHeight();
    private int pagination = 0;

    private static final String EXCEED_CARDS = "EXCEED_CARDS";
    private static final String UNUSUAL_CARDS = "UNUSUAL_CARDS";
    private static final String ACTIVE_CARDS = "ACTIVE_CARDS";
    private static final String INACTIVE_CARDS = "INACTIVE_CARDS";
    private static final String STOLEN_CARDS = "STOLEN_CARDS";
    private static final String LOST_CARDS = "LOST_CARDS";
    private static final String DAMAGED_CARDS = "DAMAGED_CARDS";
    private static final String BLOCKED_CARDS = "BLOCKED_CARDS";
    private static final String REPLACED_CARDS = "REPLACED_CARDS";
    private static final String CLOSED_CARDS = "CLOSED_CARDS";
    private static final String CAPTURED_CARDS = "CAPTURED_CARDS";
    private static final String SUSPICIOUS_CARDS = "SUSPICIOUS_CARDS";
    private static final String TOTAL_COUNT = "TOTAL_COUNT";
    
//    private static final String 
    
    @Override
    public void executePdf(ReportGenerationMgr rgm) throws ReportGenerationException {
        logger.debug("In MonthlyCardbaseReport.processPdfRecord()");

        PDDocument doc = null;
        PDPage page = null;
        PDPageContentStream contentStream = null;

        pagination = 1;
        try {
            preProcessing(rgm);
            doc = new PDDocument();
            page = new PDPage();
            doc.addPage(page);
            contentStream = new PDPageContentStream(doc, page);
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

            writePdfHeader(rgm, contentStream, leading, pagination);
            contentStream.newLineAtOffset(0, -leading);
            pageHeight += 4;
            contentStream.newLineAtOffset(0, -leading);

            contentStream.newLineAtOffset(0, -leading);
            pageHeight += 1;
            contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
                startY, pdfFont, fontSize);
//            contentStream.newLineAtOffset(0, -leading);
//            pageHeight += 1;
//            contentStream.showText(String.format(" ") + "==========================================================================================================================================================");
//            contentStream.newLineAtOffset(0, -leading);
//            pageHeight += 1;
            contentStream.newLineAtOffset(0, -leading);
            contentStream.showText(String.format("%1$56s", "") + "*** END OF REPORT ***");
            contentStream.newLineAtOffset(0, -leading);
            pageHeight += 1;

            contentStream.newLineAtOffset(0, -leading);
            executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
            pageHeight += 1;

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


    @Override
    protected void execute(ReportGenerationMgr rgm, File file) {
        StringBuilder line = new StringBuilder();

        try {
            rgm.fileOutputStream = new FileOutputStream(file);
            pagination = 1;
            preProcessing(rgm);
            writeHeader(rgm, pagination);
            executeBodyQuery(rgm);

            line.append(";").append(";").append("*** END OF REPORT ***");
            line.append(getEol());
            line.append(getEol());
            rgm.writeLine(line.toString().getBytes());
            rgm.fileOutputStream.flush();
            rgm.fileOutputStream.close();
        } catch (IOException | InstantiationException | IllegalAccessException | ClassNotFoundException  | JSONException e) {
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

    private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
                                                    PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
                                                    PDFont pdfFont, float fontSize) {
        logger.debug("In MonthlyCardbaseReport.executePdfBodyQuery()");
        ResultSet rs = null;
        PreparedStatement ps = null;
        HashMap<String, ReportGenerationFields> fieldsMap = null;
        HashMap<String, ReportGenerationFields> lineFieldsMap = null;
        String query = getBodyQuery(rgm);
        // 1. initialize collection to use to sort the query data by card type
        HashMap<String, List<HashMap<String, ReportGenerationFields>>> productToLineFieldsMap = null;
        List<HashMap<String, ReportGenerationFields>> lineFieldsMapList = null;
        String productCode = null;
        String productName = null;
        StringBuilder str = null;
        logger.info("Query for body line export: {}", query);

        if (query != null && !query.isEmpty()) {
            try {
                ps = rgm.connection.prepareStatement(query);
                rs = ps.executeQuery();
                fieldsMap = rgm.getQueryResultStructure(rs);
                
                logger.info("Query for body line export: fieldsMap {}"+ fieldsMap);
                
                while (rs.next()) {
                    lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
                    if (pageHeight > totalHeight) {
						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
						contentStream = newPage(rgm, doc, contentStream);
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

                    // 2. add list of lineFieldsMap into product map
                    if(productToLineFieldsMap == null) {
                        productToLineFieldsMap = new HashMap<String, List<HashMap<String, ReportGenerationFields>>>();
                    }

                    if(str == null) {
                        str = new StringBuilder();
                    }

                    productCode = lineFieldsMap.get(ReportConstants.PRODUCT_CODE).getValue();
                    productName = lineFieldsMap.get(ReportConstants.PRODUCT_NAME).getValue();

                    str.append(productCode);
                    str.append(",");
                    str.append(productName);

                    if(productToLineFieldsMap.containsKey(str.toString())) {
                        productToLineFieldsMap.get(str.toString()).add(lineFieldsMap);
                    } else {
                        lineFieldsMapList = new ArrayList<>();
                        lineFieldsMapList.add(lineFieldsMap);
                        productToLineFieldsMap.put(str.toString(), lineFieldsMapList);
                    }

                    str.setLength(0);
                }
                
                //if no data
                if(productToLineFieldsMap == null){
                	return contentStream;
                }
                
                for(Map.Entry<String, List<HashMap<String,ReportGenerationFields>>> productMap: productToLineFieldsMap.entrySet()) {
                	
                	if (pageHeight > totalHeight) {
						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
						contentStream = newPage(rgm, doc, contentStream);
					}
                	
                    preProcessingBodyHeader(rgm, productMap.getKey().split(",")[0], productMap.getKey().split(",")[1]);
                                        
                    boolean isSummary = false;
                    
                    if(productMap.getKey().split(",")[0].equals("Z")){
                    	writePdfBodyHeaderMonthlyCardSummary(rgm, contentStream, leading);
                    	isSummary = true;
                    }
                    else{
                    	 writePdfBodyHeader(rgm, contentStream, leading);
                    }
                   
                    pageHeight += 2;

                    // 3. initialize all the grand total to sum by card product
                    int grandTotalExceed = 0;
                    int grandTotalUnusual = 0;
                    int grandTotalActive = 0;
                    int grandTotalInactive = 0;
                    int grandTotalStolen = 0;
                    int grandTotalLost = 0;
                    int grandTotalDamaged = 0;
                    int grandTotalBlocked = 0;
                    int grandTotalReplaced = 0;
                    int grandTotalClosed = 0;
                    int grandTotalCaptured = 0;
                    int grandTotalSuspicious = 0;
                    int grandTotalTotal = 0;

                    for(HashMap<String,ReportGenerationFields> m: productMap.getValue()) {
                    	if (pageHeight > totalHeight) {
    						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
    						contentStream = newPage(rgm, doc, contentStream);
    					}
                    	if(isSummary){
                    		writePdfBodySummary(rgm, m, contentStream, leading);
                    	}
                    	else{
                    		 writePdfBody(rgm, m, contentStream, leading);
                    	}                       
                        pageHeight+=2;
                        grandTotalExceed += Integer.parseInt(m.get(EXCEED_CARDS).getValue());
                        grandTotalUnusual += Integer.parseInt(m.get(UNUSUAL_CARDS).getValue());
                        grandTotalActive += Integer.parseInt(m.get(ACTIVE_CARDS).getValue());
                        grandTotalInactive += Integer.parseInt(m.get(INACTIVE_CARDS).getValue());
                        grandTotalStolen += Integer.parseInt(m.get(STOLEN_CARDS).getValue());
                        grandTotalLost += Integer.parseInt(m.get(LOST_CARDS).getValue());
                        grandTotalDamaged += Integer.parseInt(m.get(DAMAGED_CARDS).getValue());
                        grandTotalBlocked += Integer.parseInt(m.get(BLOCKED_CARDS).getValue());
                        grandTotalReplaced += Integer.parseInt(m.get(REPLACED_CARDS).getValue());
                        grandTotalClosed += Integer.parseInt(m.get(CLOSED_CARDS).getValue());
                        grandTotalCaptured += Integer.parseInt(m.get(CAPTURED_CARDS).getValue());
                        grandTotalSuspicious += Integer.parseInt(m.get(SUSPICIOUS_CARDS).getValue());
                        grandTotalTotal += Integer.parseInt(m.get(TOTAL_COUNT).getValue());
                    }
                    contentStream.newLineAtOffset(0, -leading);
                    pageHeight += 2;

                    preProcessingBodyTrailer(rgm, grandTotalExceed, grandTotalUnusual, grandTotalActive, grandTotalInactive, grandTotalStolen, grandTotalLost, grandTotalDamaged, 
                    		grandTotalBlocked, grandTotalReplaced, grandTotalClosed, grandTotalCaptured, grandTotalSuspicious, grandTotalTotal);
                    if(isSummary){
                    	writePdfTrailerMonthlyCardSummary(rgm, lineFieldsMap, contentStream, leading);
                    }
                    else{
                    	writePdfTrailer(rgm, lineFieldsMap, contentStream, leading);
                    }                    
                    contentStream.newLineAtOffset(0, -leading);
                    pageHeight += 2;
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
    
    protected void writePdfBodyHeaderMonthlyCardSummary(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In MonthlyCardbaseReport.writePdfBodyHeaderMonthlyCard()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
						
			boolean isExclude = false;
			if(field.getFieldName()!=null){
				if(field.getFieldName().equals("CARD TYPE")){
					field.setDefaultValue("SUMMARY MONTHLY CARD BASE ");
				}
				else if(field.getFieldName().equals("PRODUCT_CODE")){
					field.setDefaultValue("REPORT");
				}
				else if(field.getFieldName().equals("BRANCH CODE") || field.getFieldName().equals("CD")){
					isExclude = true;
				}
				else if(field.getFieldName().equals("BRANCH NAME")){
					field.setDefaultValue("PRODUCT CODE");
				}				
			}
			
			if(!isExclude){
				if (field.isEol()) {
					contentStream.showText(getGlobalFieldValue(rgm, field));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
			}
		}
	}
    
    protected void writePdfBodySummary(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
					throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
						
			boolean isExclude = false;
			if(field.getFieldName()!=null && field.getFieldName().equals("BRANCH_CODE")){
				isExclude = true;
			}
			if(!isExclude){
				if (field.isDecrypt()) {
					decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
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
    
    protected void writePdfTrailerMonthlyCardSummary(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
					throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In PdfReportProcessor.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			boolean isExclude = false;
			if(field.getFieldName()!=null && field.getFieldName().equals("filler1")){
				isExclude = true;
			}
			if(!isExclude){
				if (field.isEol()) {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				}
			}
		}
	}
    
    private PDPageContentStream newPage(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream)
			throws Exception {

		if (contentStream != null) {
			contentStream.endText();
			contentStream.close();
		}

		PDPage page = new PDPage();
		doc.addPage(page);
		contentStream = new PDPageContentStream(doc, page);
		contentStream.setFont(DEFAULT_FONT, DEFAULT_FONT_SIZE);
		contentStream.beginText();
		contentStream.newLineAtOffset(page.getMediaBox().getLowerLeftX() + DEFAULT_MARGIN,
				page.getMediaBox().getUpperRightY() - DEFAULT_MARGIN);
		pagination++;
		pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
		writePdfHeader(rgm, contentStream, 1.5f * DEFAULT_FONT_SIZE, pagination);
		return contentStream;
	}

    protected void executeBodyQuery(ReportGenerationMgr rgm) {
        logger.debug("In CsvReportProcessor.executeBodyQuery()");
        ResultSet rs = null;
        PreparedStatement ps = null;
        HashMap<String, ReportGenerationFields> fieldsMap = null;
        HashMap<String, ReportGenerationFields> lineFieldsMap = null;
        String query = getBodyQuery(rgm);
        // 1. initialize collection to use to sort the query data by card type
        HashMap<String, List<HashMap<String, ReportGenerationFields>>> productToLineFieldsMap = null;
        List<HashMap<String, ReportGenerationFields>> lineFieldsMapList = null;
        String productCode = null;
        String productName = null;
        StringBuilder str = null;
        int grandTotal = 0;
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
                            } else {
                                field.setValue(result.toString());
                            }
                        } else {
                            field.setValue("");
                        }
                    }

                    // 2. add list of lineFieldsMap into product map
                    if(productToLineFieldsMap == null) {
                        productToLineFieldsMap = new HashMap<String, List<HashMap<String, ReportGenerationFields>>>();
                    }

                    if(str == null) {
                        str = new StringBuilder();
                    }

                    productCode = lineFieldsMap.get(ReportConstants.PRODUCT_CODE).getValue();
                    productName = lineFieldsMap.get(ReportConstants.PRODUCT_NAME).getValue();

                    str.append(productCode);
                    str.append(",");
                    str.append(productName);

                    if(productToLineFieldsMap.containsKey(str.toString())) {
                        productToLineFieldsMap.get(str.toString()).add(lineFieldsMap);
                    } else {
                        lineFieldsMapList = new ArrayList<>();
                        lineFieldsMapList.add(lineFieldsMap);
                        productToLineFieldsMap.put(str.toString(), lineFieldsMapList);
                    }

                    str.setLength(0);
                }

                //if no data
                if(productToLineFieldsMap != null){
                	
                	for(Map.Entry<String, List<HashMap<String,ReportGenerationFields>>> productMap: productToLineFieldsMap.entrySet()) {
                        preProcessingBodyHeader(rgm, productMap.getKey().split(",")[0], productMap.getKey().split(",")[1]);
                        
                        boolean isSummary = false;
                        
                        if(productMap.getKey().split(",")[0].equals("Z")){
                        	writeBodyHeaderMonthlyCardSummary(rgm);
                        	isSummary = true;
                        }
                        else{
                        	 writeBodyHeader(rgm);
                        }
                        
                        // 3. initialize all the grand total to sum by card product
                        int grandTotalExceed = 0;
                        int grandTotalUnusual = 0;
                        int grandTotalActive = 0;
                        int grandTotalInactive = 0;
                        int grandTotalStolen = 0;
                        int grandTotalLost = 0;
                        int grandTotalDamaged = 0;
                        int grandTotalBlocked = 0;
                        int grandTotalReplaced = 0;
                        int grandTotalClosed = 0;
                        int grandTotalCaptured = 0;
                        int grandTotalSuspicious = 0;
                        int grandTotalTotal = 0;

                        for(HashMap<String,ReportGenerationFields> m: productMap.getValue()) {
                        	
                        	if(isSummary){
                        		writeBodyMonthlyCardSummary(rgm, m);
                        	}
                        	else{
                        		writeBody(rgm, m);
                        	}
                        	
                            grandTotalExceed += Integer.parseInt(m.get(EXCEED_CARDS).getValue());
                            grandTotalUnusual += Integer.parseInt(m.get(UNUSUAL_CARDS).getValue());
                            grandTotalActive += Integer.parseInt(m.get(ACTIVE_CARDS).getValue());
                            grandTotalInactive += Integer.parseInt(m.get(INACTIVE_CARDS).getValue());
                            grandTotalStolen += Integer.parseInt(m.get(STOLEN_CARDS).getValue());
                            grandTotalLost += Integer.parseInt(m.get(LOST_CARDS).getValue());
                            grandTotalDamaged += Integer.parseInt(m.get(DAMAGED_CARDS).getValue());
                            grandTotalBlocked += Integer.parseInt(m.get(BLOCKED_CARDS).getValue());
                            grandTotalReplaced += Integer.parseInt(m.get(REPLACED_CARDS).getValue());
                            grandTotalClosed += Integer.parseInt(m.get(CLOSED_CARDS).getValue());
                            grandTotalCaptured += Integer.parseInt(m.get(CAPTURED_CARDS).getValue());
                            grandTotalSuspicious += Integer.parseInt(m.get(SUSPICIOUS_CARDS).getValue());
                            grandTotalTotal += Integer.parseInt(m.get(TOTAL_COUNT).getValue());
                        }
                        preProcessingBodyTrailer(rgm, grandTotalExceed, grandTotalUnusual, grandTotalActive, grandTotalInactive, grandTotalStolen, grandTotalLost, grandTotalDamaged, 
                        		grandTotalBlocked, grandTotalReplaced, grandTotalClosed, grandTotalCaptured, grandTotalSuspicious, grandTotalTotal);
                        
                        if(isSummary){
                        	writeBodyMonthlyCardSummary(rgm, null);
                        }
                        else{
                        	writeTrailer(rgm, null);
                        }                    
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
    
    protected void writeBodyHeaderMonthlyCardSummary(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CsvReportProcessor.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			
			boolean isExclude = false;
			if(field.getFieldName()!=null){
				if(field.getFieldName().equals("CARD TYPE")){
					field.setDefaultValue("SUMMARY MONTHLY CARD BASE ");
				}
				else if(field.getFieldName().equals("PRODUCT_CODE")){
					field.setDefaultValue("REPORT");
				}
				else if(field.getFieldName().equals("BRANCH CODE") || field.getFieldName().equals("CD")){
					isExclude = true;
				}
				else if(field.getFieldName().equals("BRANCH NAME")){
					field.setDefaultValue("PRODUCT CODE");
				}				
			}
			if(!isExclude){
				if(field.isEol()) {
					line.append("\"" + getFieldValue(rgm, field, null) + "\"");
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append("\"" + getFieldValue(rgm, field, null) + "\"");
					line.append(field.getDelimiter());
				}
			}
		}
		rgm.writeLine(line.toString().getBytes());
	}
    
	protected void writeBodyMonthlyCardSummary(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			boolean isExclude = false;
			if(field.getFieldName()!=null && field.getFieldName().equals("BRANCH_CODE")){
				isExclude = true;
			}
			if(!isExclude){
				if (field.isDecrypt()) {
					decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
				}

				line.append("\""+ getFieldValue(rgm, field, fieldsMap) + "\"");
				line.append(field.getDelimiter());
				if (field.isEol()) {
					line.append(getEol());
				}
			}
		}
		//line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
	
	protected void writeTrailerMonthlyCardSummary(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In CsvReportProcessor.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			
			boolean isExclude = false;
			if(field.getFieldName()!=null && field.getFieldName().equals("filler1")){
				isExclude = true;
			}
			if(!isExclude){
				if (field.isEol()) {
					if (field.getFieldName().contains(ReportConstants.LINE)) {
						line.append(getEol());
					} else {
						line.append("\"" + getFieldValue(rgm, field, fieldsMap) + "\"");
						line.append(field.getDelimiter());
						line.append(getEol());
					}
				} else {
					line.append("\"" + getFieldValue(rgm, field, fieldsMap) + "\"");
					line.append(field.getDelimiter());
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

    private void preProcessingBodyTrailer(ReportGenerationMgr rgm, int grandTotalExceed, int grandTotalUnusual, int grandTotalActive, int grandTotalInactive, int grandTotalStolen, int grandTotalLost, int grandTotalDamaged, 
    		int grandTotalBlocked, int grandTotalReplaced, int grandTotalClosed, int grandTotalCaptured, int grandTotalSuspicious, int grandTotalTotal)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In MonthlyCardbaseReport.preProcessingBodyTrailer()");

        ReportGenerationFields totalExceed = new ReportGenerationFields("TOTAL_EXCEED",
                ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalExceed));
            ReportGenerationFields totalUnsual = new ReportGenerationFields("TOTAL_UNUSUAL",
                ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalUnusual));
            ReportGenerationFields totalActive = new ReportGenerationFields("TOTAL_ACTIVE",
                ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalActive));
            ReportGenerationFields totalInactive = new ReportGenerationFields("TOTAL_INACTIVE",
                ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalInactive));
            ReportGenerationFields totalStolen = new ReportGenerationFields("TOTAL_STOLEN",
                ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalStolen));
            ReportGenerationFields totalLost = new ReportGenerationFields("TOTAL_LOST",
                    ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalLost));
            ReportGenerationFields totalDamaged = new ReportGenerationFields("TOTAL_DAMAGED",
                    ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalDamaged));
            ReportGenerationFields totalBlocked = new ReportGenerationFields("TOTAL_BLOCKED",
                        ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalBlocked));
            ReportGenerationFields totalReplaced = new ReportGenerationFields("TOTAL_REPLACED",
                    ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalReplaced));
            ReportGenerationFields totalClosed = new ReportGenerationFields("TOTAL_CLOSED",
                    ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalClosed));
            ReportGenerationFields totalCaptured = new ReportGenerationFields("TOTAL_CAPTURED",
                    ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalCaptured));
            ReportGenerationFields totalSuspicious = new ReportGenerationFields("TOTAL_SUSPICIOUS",
                    ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalSuspicious));
            ReportGenerationFields totalTotal = new ReportGenerationFields("TOTAL_TOTAL",
                ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalTotal));

            getGlobalFileFieldsMap().put(totalExceed.getFieldName(), totalExceed);
            getGlobalFileFieldsMap().put(totalUnsual.getFieldName(), totalUnsual);
            getGlobalFileFieldsMap().put(totalActive.getFieldName(), totalActive);
            getGlobalFileFieldsMap().put(totalInactive.getFieldName(), totalInactive);
            getGlobalFileFieldsMap().put(totalStolen.getFieldName(), totalStolen);
            getGlobalFileFieldsMap().put(totalLost.getFieldName(), totalLost);
            getGlobalFileFieldsMap().put(totalDamaged.getFieldName(), totalDamaged);
            getGlobalFileFieldsMap().put(totalBlocked.getFieldName(), totalBlocked);
            getGlobalFileFieldsMap().put(totalReplaced.getFieldName(), totalReplaced);
            getGlobalFileFieldsMap().put(totalClosed.getFieldName(), totalClosed);
            getGlobalFileFieldsMap().put(totalCaptured.getFieldName(), totalCaptured);
            getGlobalFileFieldsMap().put(totalSuspicious.getFieldName(), totalSuspicious);
            getGlobalFileFieldsMap().put(totalTotal.getFieldName(), totalTotal);

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    private void preProcessing(ReportGenerationMgr rgm)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In MonthlyCardbaseReport.preProcessing():" + rgm.getFileNamePrefix());

        // replace {From_Date}/{To_Date}/{DCMS_Schema}/{Iss_Id} to actual value
        rgm.setBodyQuery(rgm.getBodyQuery()
//            .replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
            .replace("{" + ReportConstants.PARAM_TO_DATE + "}", "'" + rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
            .replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA+ "}", rgm.getDcmsDbSchema())
            .replace("{" + ReportConstants.PARAM_DB_LINK_DCMS + "}", rgm.getDbLink())
            .replace("{" + ReportConstants.PARAM_ISSUER_ID+ "}", rgm.getInstitution().equals("CBC") ? ReportConstants.DCMS_CBC_INSTITUTION : ReportConstants.DCMS_CBS_INSTITUTION));

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    private void preProcessingBodyHeader(ReportGenerationMgr rgm, String prodCode, String prodName)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In MonthlyCardbaseReport.preProcessingHeader()");

        ReportGenerationFields cardProductCode = new ReportGenerationFields(ReportConstants.PRODUCT_CODE,
            ReportGenerationFields.TYPE_STRING, prodCode);
        ReportGenerationFields cardProductName = new ReportGenerationFields(ReportConstants.PRODUCT_NAME,
            ReportGenerationFields.TYPE_STRING, prodName);
        getGlobalFileFieldsMap().put(cardProductCode.getFieldName(), cardProductCode);
        getGlobalFileFieldsMap().put(cardProductName.getFieldName(), cardProductName);

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

}
