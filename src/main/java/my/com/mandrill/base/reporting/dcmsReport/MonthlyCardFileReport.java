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
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class MonthlyCardFileReport extends PdfReportProcessor {

    private final Logger logger = LoggerFactory.getLogger(MonthlyCardFileReport.class);
    private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
    private float totalHeight = PDRectangle.A4.getHeight();
    private int pagination = 0;
    private double grandTotalActive = 0.00;
    private double grandTotalBlocked = 0.00;
    private int totalCount = 0;

    @Override
    public void executePdf(ReportGenerationMgr rgm) {
        logger.debug("In MonthlyCardFileReport.processPdfRecord()");

        PDDocument doc = null;
        PDPage page = null;
        PDPageContentStream contentStream = null;
        DecimalFormat formatter = new DecimalFormat("#,##0.00");
        String cardProduct = null;
        String branchCode = null;
        String branchName = null;
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
            contentStream.showText(String.format("") + "==========================================================================================================================================================");
            contentStream.newLineAtOffset(0, -leading);
            writePdfBodyHeader(rgm, contentStream, leading);
            pageHeight += 2;
            contentStream.showText(String.format("") + "==========================================================================================================================================================");
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
        int grandTotalActive = 0;
        int grandTotalInactive = 0;
        int grandTotalRenewed = 0;
        int grandTotalReplaced = 0;
        int grandTotalClosed = 0;
        int grandTotalTotal = 0;
        StringBuilder str = null;
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

                        if(key.equals("ACTIVE_CARDS")){
                            grandTotalActive += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("INACTIVE_CARDS")){
                            grandTotalInactive += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("RENEWED_CARDS")){
                            grandTotalRenewed += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("REPLACED_CARDS")){
                            grandTotalReplaced += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("CLOSED_CARDS")){
                            grandTotalClosed += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("TOTAL_COUNT")){
                            grandTotalTotal += Integer.valueOf(field.getValue());
                        }

                    }
                    writePdfBody(rgm, lineFieldsMap, contentStream, leading);
                }

                    preProcessingBodyTrailer(rgm, grandTotalActive, grandTotalInactive, grandTotalRenewed, grandTotalReplaced, grandTotalClosed, grandTotalTotal);
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

        int grandTotalActive = 0;
        int grandTotalInactive = 0;
        int grandTotalRenewed = 0;
        int grandTotalReplaced = 0;
        int grandTotalClosed = 0;
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
                        if(key.equals("ACTIVE_CARDS")){
                            grandTotalActive += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("INACTIVE_CARDS")){
                            grandTotalInactive += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("RENEWED_CARDS")){
                            grandTotalRenewed += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("REPLACED_CARDS")){
                            grandTotalReplaced += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("CLOSED_CARDS")){
                            grandTotalClosed += Integer.valueOf(field.getValue());
                        }
                        if(key.equals("TOTAL_COUNT")){
                            grandTotalTotal += Integer.valueOf(field.getValue());
                        }
                    }
                    writeBody(rgm, lineFieldsMap);
                }
                preProcessingBodyTrailer(rgm, grandTotalActive, grandTotalInactive, grandTotalRenewed, grandTotalReplaced, grandTotalClosed, grandTotalTotal);
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

    private void preProcessingBodyTrailer(ReportGenerationMgr rgm, int grandTotalActive, int grandTotalInactive, int grandTotalRenewed, int grandTotalReplaced, int grandTotalClosed, int grandTotalTotal)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In MonthlyCardFileReport.preProcessingBodyTrailer()");

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
