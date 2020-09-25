package my.com.mandrill.base.reporting.dcmsReport;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class TransmittalReleaseReportForAllBranches extends TxtReportProcessor {

    private final Logger logger = LoggerFactory.getLogger(TransmittalReleaseReportForAllBranches.class);

    @Override
    public void processTxtRecord(ReportGenerationMgr rgm) {
        logger.debug("In TransmittalReleaseReportForAllBranches.processTxtRecord()");
        File file = null;
        String txnDate = null;
        String fileLocation = rgm.getFileLocation();

        try {
            if (rgm.isGenerate() == true) {
                txnDate = rgm.getFileDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
            } else {
                txnDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
            }

            if (rgm.errors == 0) {
                if (fileLocation != null) {
                    File directory = new File(fileLocation);
                    if (!directory.exists()) {
                        directory.mkdirs();
                    }
                    file = new File(
                        rgm.getFileLocation() + rgm.getFileNamePrefix() + txnDate + ReportConstants.TXT_FORMAT);
                    execute(rgm, file);
                } else {
                    throw new Exception("Path is not configured.");
                }
            } else {
                throw new Exception(
                    "Errors when generating" + rgm.getFileNamePrefix() + txnDate + ReportConstants.TXT_FORMAT);
            }
        } catch (Exception e) {
            logger.error("Errors in generating " + rgm.getFileNamePrefix() + txnDate + ReportConstants.TXT_FORMAT, e);
        }
    }

    @Override
    protected void execute(ReportGenerationMgr rgm, File file) {
        String branchCode = null;
        try {
            rgm.fileOutputStream = new FileOutputStream(file);
            preProcessing(rgm);
            addReportPreProcessingFieldsToGlobalMap(rgm);
            writeHeader(rgm);
            writeBodyHeader(rgm);
            executeBodyQuery(rgm, branchCode);

            rgm.fileOutputStream.flush();
            rgm.fileOutputStream.close();

        } catch (Exception e) {
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

    private void preProcessing(ReportGenerationMgr rgm)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In TransmittalReleaseReportForAllBranches.preProcessing():" + rgm.getFileNamePrefix());

        rgm.setBodyQuery(rgm.getBodyQuery()
            .replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA+ "}", rgm.getDcmsDbSchema())
            .replace("{" + ReportConstants.PARAM_ISSUER_ID+ "}", rgm.getInstitution().equals("CBC") ? ReportConstants.DCMS_CBC_INSTITUTION : ReportConstants.DCMS_CBS_INSTITUTION));

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    private void preProcessingBodyTrailer(ReportGenerationMgr rgm, int sum)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In TransmittalReleaseReportForAllBranches.preProcessingBodyTrailer()");

        ReportGenerationFields overallTotal = new ReportGenerationFields(ReportConstants.TOTAL,
            ReportGenerationFields.TYPE_STRING, String.valueOf(sum));
        getGlobalFileFieldsMap().put(overallTotal.getFieldName(), overallTotal);

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    @Override
    protected void executeBodyQuery(ReportGenerationMgr rgm, String branchCode) {
        logger.debug("In TransmittalReleaseReportForAllBranches.executeBodyQuery()");
        ResultSet rs = null;
        PreparedStatement ps = null;
        HashMap<String, ReportGenerationFields> fieldsMap = null;
        HashMap<String, ReportGenerationFields> lineFieldsMap = null;
        HashSet<String> branchSet = null;
        String query = getBodyQuery(rgm);
        int grandTotal = 0;
        logger.info("Query for body line export: {}", query);

        if (query != null && !query.isEmpty()) {
            try {
                ps = rgm.connection.prepareStatement(query);
                rs = ps.executeQuery(); //to execute query that has been defined in config
                fieldsMap = rgm.getQueryResultStructure(rs); //to convert retrieved row from db to java object (make process easier)

                while (rs.next()) { //iterate row by row for what query retrieve
                    new StringBuffer();
                    lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
                    for (String key : lineFieldsMap.keySet()) { //to loop each column in row
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

                        // append date to branch code as requirement
                        if(key.equals("BRANCH_CODE")) {
                            field.setValue(field.getValue() + "-" + rgm.getFileDate().format(DateTimeFormatter.ofPattern("MMddyy")));
                        }

                        if(key.equals("TOTAL")) {
                            grandTotal += Integer.valueOf(field.getValue());
                        }
                    }
                    writeBody(rgm, lineFieldsMap);

                }
                preProcessingBodyTrailer(rgm, grandTotal);
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
}
