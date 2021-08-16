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

    @Override
    public void executePdf(ReportGenerationMgr rgm) {
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


                for(Map.Entry<String, List<HashMap<String,ReportGenerationFields>>> productMap: productToLineFieldsMap.entrySet()) {
                	if (pageHeight > totalHeight) {
						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
						contentStream = newPage(rgm, doc, contentStream);
					}
                    preProcessingBodyHeader(rgm, productMap.getKey().split(",")[0], productMap.getKey().split(",")[1]);
                    writePdfBodyHeader(rgm, contentStream, leading);
                    pageHeight += 2;

                    // 3. initialize all the grand total to sum by card product
                    int grandTotalActive = 0;
                    int grandTotalInactive = 0;
                    int grandTotalRenewed = 0;
                    int grandTotalReplaced = 0;
                    int grandTotalClosed = 0;
                    int grandTotalTotal = 0;

                    for(HashMap<String,ReportGenerationFields> m: productMap.getValue()) {
                        writePdfBody(rgm, m, contentStream, leading);
                        pageHeight+=2;
                        grandTotalActive += Integer.parseInt(m.get("ACTIVE_CARDS").getValue());
                        grandTotalInactive += Integer.parseInt(m.get("INACTIVE_CARDS").getValue());
                        grandTotalRenewed += Integer.parseInt(m.get("RENEWED_CARDS").getValue());
                        grandTotalReplaced += Integer.parseInt(m.get("REPLACED_CARDS").getValue());
                        grandTotalClosed += Integer.parseInt(m.get("CLOSED_CARDS").getValue());
                        grandTotalTotal += Integer.parseInt(m.get("TOTAL_COUNT").getValue());
                    }
                    contentStream.newLineAtOffset(0, -leading);
                    pageHeight += 2;

                    preProcessingBodyTrailer(rgm, grandTotalActive, grandTotalInactive, grandTotalRenewed, grandTotalReplaced, grandTotalClosed, grandTotalTotal);
                    writePdfTrailer(rgm, lineFieldsMap, contentStream, leading);
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


                for(Map.Entry<String, List<HashMap<String,ReportGenerationFields>>> productMap: productToLineFieldsMap.entrySet()) {
                    preProcessingBodyHeader(rgm, productMap.getKey().split(",")[0], productMap.getKey().split(",")[1]);
                    writeBodyHeader(rgm);

                    // 3. initialize all the grand total to sum by card product
                    int grandTotalActive = 0;
                    int grandTotalInactive = 0;
                    int grandTotalRenewed = 0;
                    int grandTotalReplaced = 0;
                    int grandTotalClosed = 0;
                    int grandTotalTotal = 0;

                    for(HashMap<String,ReportGenerationFields> m: productMap.getValue()) {
                        writeBody(rgm, m);

                        grandTotalActive += Integer.parseInt(m.get("ACTIVE_CARDS").getValue());
                        grandTotalInactive += Integer.parseInt(m.get("INACTIVE_CARDS").getValue());
                        grandTotalRenewed += Integer.parseInt(m.get("RENEWED_CARDS").getValue());
                        grandTotalReplaced += Integer.parseInt(m.get("REPLACED_CARDS").getValue());
                        grandTotalClosed += Integer.parseInt(m.get("CLOSED_CARDS").getValue());
                        grandTotalTotal += Integer.parseInt(m.get("TOTAL_COUNT").getValue());
                    }
                    preProcessingBodyTrailer(rgm, grandTotalActive, grandTotalInactive, grandTotalRenewed, grandTotalReplaced, grandTotalClosed, grandTotalTotal);
                    writeTrailer(rgm, null);
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

    private void preProcessingBodyTrailer(ReportGenerationMgr rgm, int grandTotalActive, int grandTotalInactive, int grandTotalRenewed, int grandTotalReplaced, int grandTotalClosed, int grandTotalTotal)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In TransmittalSlipForNewPins.preProcessingBodyTrailer()");

        ReportGenerationFields totalActive = new ReportGenerationFields("TOTAL_ACTIVE",
            ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalActive));
        ReportGenerationFields totalInactive = new ReportGenerationFields("TOTAL_INACTIVE",
            ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalInactive));
        ReportGenerationFields totalRenewed = new ReportGenerationFields("TOTAL_RENEWED",
            ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalRenewed));
        ReportGenerationFields totalRepalced = new ReportGenerationFields("TOTAL_REPLACED",
            ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalReplaced));
        ReportGenerationFields totalClosed = new ReportGenerationFields("TOTAL_CLOSED",
            ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalClosed));
        ReportGenerationFields totalTotal = new ReportGenerationFields("TOTAL_TOTAL",
            ReportGenerationFields.TYPE_STRING, String.valueOf(grandTotalTotal));

        getGlobalFileFieldsMap().put(totalActive.getFieldName(), totalActive);
        getGlobalFileFieldsMap().put(totalInactive.getFieldName(), totalInactive);
        getGlobalFileFieldsMap().put(totalRenewed.getFieldName(), totalRenewed);
        getGlobalFileFieldsMap().put(totalRepalced.getFieldName(), totalRepalced);
        getGlobalFileFieldsMap().put(totalClosed.getFieldName(), totalClosed);
        getGlobalFileFieldsMap().put(totalTotal.getFieldName(), totalTotal);

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    private void preProcessing(ReportGenerationMgr rgm)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In MonthlyCardbaseReport.preProcessing():" + rgm.getFileNamePrefix());

        // replace {From_Date}/{To_Date}/{DCMS_Schema}/{Iss_Id} to actual value
        rgm.setBodyQuery(rgm.getBodyQuery()
            .replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
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
