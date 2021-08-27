package my.com.mandrill.base.reporting.dcmsReport;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.json.JSONException;
import org.slf4j.LoggerFactory;
import org.slf4j.Logger;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class MonthlyCardFileReport extends PdfReportProcessor {

    private final Logger logger = LoggerFactory.getLogger(MonthlyCardFileReport.class);
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
        
    @Override
    public void executePdf(ReportGenerationMgr rgm) {
        logger.debug("In MonthlyCardFileReport.processPdfRecord()");

        PDDocument doc = null;
        PDPage page = null;
        PDPageContentStream contentStream = null;
        DecimalFormat formatter = new DecimalFormat("#,##0.00");
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
            contentStream.showText(String.format("") + "=============================================================================================================================================================");
            contentStream.newLineAtOffset(0, -leading);
            writePdfBodyHeader(rgm, contentStream, leading);
            pageHeight += 2;
            contentStream.showText(String.format("") + "=============================================================================================================================================================");
            contentStream.newLineAtOffset(0, -leading);
            pageHeight += 1;
            contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
                startY, pdfFont, fontSize);
            pageHeight += 1;
//            contentStream.showText(String.format("") + "==========================================================================================================================================================");
//            contentStream.newLineAtOffset(0, -leading);

            contentStream.newLineAtOffset(0, -leading);
            contentStream.showText(String.format("%1$56s", "") + "*** END OF REPORT ***");
            contentStream.newLineAtOffset(0, -leading);
            pageHeight += 1;

//            executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
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

            writeBodyHeader(rgm);
            line.append(getEol());
            rgm.writeLine(line.toString().getBytes());
            executeBodyQuery(rgm);

            line.append(";").append(";").append(";").append("*** END OF REPORT ***");
            line.append(getEol());
            line.append(getEol());
            rgm.writeLine(line.toString().getBytes());
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

    private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
                                                    PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
                                                    PDFont pdfFont, float fontSize) {
        logger.debug("In MonthlyCardFileReport.execute()");
        ResultSet rs = null;
        PreparedStatement ps = null;
        HashMap<String, ReportGenerationFields> fieldsMap = null;
        HashMap<String, ReportGenerationFields> lineFieldsMap = null;
        String query = getBodyQuery(rgm);
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

                        if(key.equals(EXCEED_CARDS)){
                        	grandTotalExceed += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(UNUSUAL_CARDS)){
                            grandTotalUnusual += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(ACTIVE_CARDS)){
                            grandTotalActive += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(INACTIVE_CARDS)){
                            grandTotalInactive += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(STOLEN_CARDS)){
                            grandTotalStolen += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(LOST_CARDS)){
                            grandTotalLost += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(DAMAGED_CARDS)){
                            grandTotalDamaged += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(BLOCKED_CARDS)){
                            grandTotalBlocked += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(REPLACED_CARDS)){
                            grandTotalReplaced += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(CLOSED_CARDS)){
                            grandTotalClosed += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(CAPTURED_CARDS)){
                            grandTotalCaptured += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(SUSPICIOUS_CARDS)){
                            grandTotalSuspicious += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(TOTAL_COUNT)){
                            grandTotalTotal += Integer.valueOf(field.getValue());
                        }
                    }
                    writePdfBody(rgm, lineFieldsMap, contentStream, leading);
                }

                    preProcessingBodyTrailer(rgm, grandTotalExceed, grandTotalUnusual, grandTotalActive, grandTotalInactive, grandTotalStolen, grandTotalLost, grandTotalDamaged, 
                    		grandTotalBlocked, grandTotalReplaced, grandTotalClosed, grandTotalCaptured, grandTotalSuspicious, grandTotalTotal);
                    writePdfTrailer(rgm, lineFieldsMap, contentStream, leading);

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

    protected void executeBodyQuery(ReportGenerationMgr rgm) {
        logger.debug("In MonthlyCardFileReport.executeBodyQuery()");
        ResultSet rs = null;
        PreparedStatement ps = null;
        HashMap<String, ReportGenerationFields> fieldsMap = null;
        HashMap<String, ReportGenerationFields> lineFieldsMap = null;
        String query = getBodyQuery(rgm);
        StringBuilder str = null;

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
                        if(key.equals(EXCEED_CARDS)){
                        	grandTotalExceed += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(UNUSUAL_CARDS)){
                            grandTotalUnusual += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(ACTIVE_CARDS)){
                            grandTotalActive += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(INACTIVE_CARDS)){
                            grandTotalInactive += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(STOLEN_CARDS)){
                            grandTotalStolen += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(LOST_CARDS)){
                            grandTotalLost += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(DAMAGED_CARDS)){
                            grandTotalDamaged += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(BLOCKED_CARDS)){
                            grandTotalBlocked += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(REPLACED_CARDS)){
                            grandTotalReplaced += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(CLOSED_CARDS)){
                            grandTotalClosed += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(CAPTURED_CARDS)){
                            grandTotalCaptured += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(SUSPICIOUS_CARDS)){
                            grandTotalSuspicious += Integer.valueOf(field.getValue());
                        }
                        if(key.equals(TOTAL_COUNT)){
                            grandTotalTotal += Integer.valueOf(field.getValue());
                        }
                    }
                    writeBody(rgm, lineFieldsMap);
                }
                preProcessingBodyTrailer(rgm, grandTotalExceed, grandTotalUnusual, grandTotalActive, grandTotalInactive, grandTotalStolen, grandTotalLost, grandTotalDamaged, 
                		grandTotalBlocked, grandTotalReplaced, grandTotalClosed, grandTotalCaptured, grandTotalSuspicious, grandTotalTotal);
                writeTrailer(rgm, null);
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

    private void preProcessing(ReportGenerationMgr rgm)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In MonthlyCardFileReport.preProcessing():" + rgm.getFileNamePrefix());

        LocalDate date = rgm.getTxnStartDate().toLocalDate();

        // replace {From_Date}/{To_Date}/{DCMS_Schema}/{Iss_Id} to actual value
        rgm.setBodyQuery(rgm.getBodyQuery()
            .replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + date.withDayOfMonth(1).atStartOfDay().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
            .replace("{" + ReportConstants.PARAM_TO_DATE + "}", "'" + date.withDayOfMonth(date.lengthOfMonth()).atTime(LocalTime.MAX).format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
            .replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA+ "}", rgm.getDcmsDbSchema())
            .replace("{" + ReportConstants.PARAM_DB_LINK_DCMS + "}", rgm.getDbLink())
            .replace("{" + ReportConstants.PARAM_ISSUER_ID+ "}", rgm.getInstitution().equals("CBC") ? ReportConstants.DCMS_CBC_INSTITUTION : ReportConstants.DCMS_CBS_INSTITUTION));

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    private void preProcessingBodyTrailer(ReportGenerationMgr rgm, int grandTotalExceed, int grandTotalUnusual, int grandTotalActive, int grandTotalInactive, int grandTotalStolen, int grandTotalLost, int grandTotalDamaged, 
    		int grandTotalBlocked, int grandTotalReplaced, int grandTotalClosed, int grandTotalCaptured, int grandTotalSuspicious, int grandTotalTotal)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In MonthlyCardFileReport.preProcessingBodyTrailer()");

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

    @Override
    protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
                                PDPageContentStream contentStream, float leading)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
        List<ReportGenerationFields> fields = extractBodyFields(rgm);
        int fieldLength = 0;

        for (ReportGenerationFields field : fields) {
            if (field.isDecrypt()) {
                decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
            }

            if (field.isEol()) {
                contentStream.showText(getFieldValue(rgm, field, fieldsMap));
                contentStream.newLineAtOffset(0, -leading);
            }
            else {
                switch (field.getFieldName()) {
                    case ReportConstants.BRANCH_CODE:
                    case ReportConstants.BRANCH_NAME:
                        fieldLength += field.getPdfLength();
                        contentStream.showText(getFieldValue(rgm, field, fieldsMap));
                        break;
                    default:
                        contentStream.showText(getFieldValue(rgm, field, fieldsMap));
                        break;
                }
            }
        }
    }

    @Override
    protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
        List<ReportGenerationFields> fields = extractBodyFields(rgm);
        StringBuilder line = new StringBuilder();

        for (ReportGenerationFields field : fields) {
            if (field.isDecrypt()) {
                decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
            }

            switch (field.getFieldName()) {
                case ReportConstants.BRANCH_CODE:
                case ReportConstants.BRANCH_NAME:
                    line.append(getFieldValue(rgm, field, fieldsMap));
                    line.append((field.getDelimiter()));
                    break;
                default:
                    line.append(getFieldValue(rgm, field, fieldsMap));
                    line.append(field.getDelimiter());
                    break;
            }
        }
        line.append(getEol());
        rgm.writeLine(line.toString().getBytes());
    }

}
