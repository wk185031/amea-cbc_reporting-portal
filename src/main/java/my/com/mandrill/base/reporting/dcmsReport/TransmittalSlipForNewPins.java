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
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class TransmittalSlipForNewPins extends TxtReportProcessor {

    private final Logger logger = LoggerFactory.getLogger(TransmittalSlipForNewPins.class);

    @Override
    public void processTxtRecord(ReportGenerationMgr rgm) {
        logger.debug("In TransmittalSlipForNewPins.processTxtRecord()");
        File file = null;
        String txnDate = null;
        String fileLocation = rgm.getFileLocation();
        String fileName = "";

        try {
            //TODO - Please double check this report need to change or not
            fileName = generateDateRangeOutputFileName(rgm.getFileNamePrefix(),
                rgm.getTxnStartDate(),
                rgm.getReportTxnEndDate(),
                ReportConstants.TXT_FORMAT);

            if (rgm.errors == 0) {
                if (fileLocation != null) {
                    File directory = new File(fileLocation);
                    if (!directory.exists()) {
                        directory.mkdirs();
                    }
                    file = new File(
                        rgm.getFileLocation() + fileName);
                    execute(rgm, file);
                } else {
                    throw new Exception("Path is not configured.");
                }
            } else {
                throw new Exception(
                    "Errors when generating" + fileName);
            }
        } catch (Exception e) {
            logger.error("Errors in generating " + fileName, e);
        }
    }

    @Override
    protected void execute(ReportGenerationMgr rgm, File file) {
        try {
            rgm.fileOutputStream = new FileOutputStream(file);
            preProcessing(rgm);
            executeBodyQuery(rgm);
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
        logger.debug("In TransmittalSlipForNewPins.preProcessing():" + rgm.getFileNamePrefix());
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
        String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);

        rgm.setBodyQuery(rgm.getBodyQuery()
            .replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA+ "}", rgm.getDcmsDbSchema())
            .replace("{" + ReportConstants.PARAM_DB_LINK_DCMS + "}", rgm.getDbLink())
            .replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + txnStart + "'")
            .replace("{" + ReportConstants.PARAM_TO_DATE + "}", "'" + txnEnd + "'")
            .replace("{" + ReportConstants.PARAM_ISSUER_ID+ "}", rgm.getInstitution().equals("CBC") ? ReportConstants.DCMS_CBC_INSTITUTION : ReportConstants.DCMS_CBS_INSTITUTION));

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    private void preProcessingHeader(ReportGenerationMgr rgm, String brcName, String brcCode)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In TransmittalSlipForNewPins.preProcessingHeader()");

        ReportGenerationFields branchName = new ReportGenerationFields(ReportConstants.BRANCH_NAME,
            ReportGenerationFields.TYPE_STRING, brcName);
        ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.BRANCH_CODE,
            ReportGenerationFields.TYPE_STRING, "ATM CARD REF. NO.: " + brcCode + "-" + rgm.getFileDate().format(DateTimeFormatter.ofPattern("MMddyy")));
        getGlobalFileFieldsMap().put(branchName.getFieldName(), branchName);
        getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    private void preProcessingBodyHeader(ReportGenerationMgr rgm, String cardProductName, int size)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In TransmittalSlipForNewPins.preProcessingBodyHeader()");

        ReportGenerationFields cardProduct = new ReportGenerationFields(ReportConstants.CARD_PRODUCT,
            ReportGenerationFields.TYPE_STRING, cardProductName + " TOTAL: ");
        ReportGenerationFields total = new ReportGenerationFields(ReportConstants.TOTAL,
            ReportGenerationFields.TYPE_STRING, String.valueOf(size));
        getGlobalFileFieldsMap().put(cardProduct.getFieldName(), cardProduct);
        getGlobalFileFieldsMap().put(total.getFieldName(), total);


        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    private void preProcessingBodyTrailer(ReportGenerationMgr rgm, String brcName, int size)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In TransmittalSlipForNewPins.preProcessingBodyTrailer()");

        ReportGenerationFields overallTotal = new ReportGenerationFields(ReportConstants.OVERALL_TOTAL,
            ReportGenerationFields.TYPE_STRING, String.valueOf(size));
        getGlobalFileFieldsMap().put(overallTotal.getFieldName(), overallTotal);

        addReportPreProcessingFieldsToGlobalMap(rgm);
    }

    @Override
    protected void executeBodyQuery(ReportGenerationMgr rgm) {
        logger.debug("In TransmittalSlipForNewPins.executeBodyQuery()");
        ResultSet rs = null;
        PreparedStatement ps = null;
        HashMap<String, ReportGenerationFields> fieldsMap = null;
        HashMap<String, ReportGenerationFields> lineFieldsMap = null;
        HashSet<String> branchSet = new HashSet<String>();
        HashMap<String, List<HashMap<String, ReportGenerationFields>>> programToLineFieldsMap = null;
        List< HashMap<String, ReportGenerationFields>> lineFieldsMapList = null;
        String query = getBodyQuery(rgm);
        logger.info("Query for body line export: {}", query);


        if (query != null && !query.isEmpty()) {
            try {
                ps = rgm.connection.prepareStatement(query);
                rs = ps.executeQuery();
                fieldsMap = rgm.getQueryResultStructure(rs);
                StringBuilder str = null;

                while (rs.next()) {
                    new StringBuffer();
                    lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
                    for (String key : lineFieldsMap.keySet()) {
                        ReportGenerationFields field = lineFieldsMap.get(key);
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

                    if(branchSet == null) {
                        branchSet = new HashSet<String>();
                    }

                    if(str == null) {
                        str = new StringBuilder();
                    }

                    // 1. store set with branch_name,branch_code value
                    str.append(lineFieldsMap.get("BRANCH_NAME").getValue());
                    str.append(",");
                    str.append(lineFieldsMap.get("BRANCH_CODE").getValue());
                    branchSet.add(str.toString());

                    // clear StringBuilder to reuse
                    str.setLength(0);

                    // 2. store map with branch_name,program_name key
                    str.append(lineFieldsMap.get("BRANCH_NAME").getValue());
                    str.append(",");
                    str.append(lineFieldsMap.get("PROGRAM_NAME").getValue());

                    if(programToLineFieldsMap == null) {
                        programToLineFieldsMap = new HashMap<String, List<HashMap<String, ReportGenerationFields>>>();
                    }

                    if(programToLineFieldsMap.containsKey(str.toString())) {
                        programToLineFieldsMap.get(str.toString()).add(lineFieldsMap);
                    } else {
                        lineFieldsMapList = new ArrayList<>();
                        lineFieldsMapList.add(lineFieldsMap);
                        programToLineFieldsMap.put(str.toString(), lineFieldsMapList);
                    }

                    str.setLength(0);
                }

                // 3. iterate (branch_name,branch_code) set, iterate (branch_name,program_name) map to print by grouping
                for(String branch: branchSet) {
                    int totalCount = 0;
                    preProcessingHeader(rgm, branch.split(",")[0], branch.split(",")[1]);
                    writeHeader(rgm);
                    for(Map.Entry<String, List<HashMap<String,ReportGenerationFields>>> branchProgramMap: programToLineFieldsMap.entrySet()) {
                        if(branchProgramMap.getKey().split(",")[0].equals(branch.split(",")[0])) {
                            preProcessingBodyHeader(rgm, branchProgramMap.getKey().split(",")[1], branchProgramMap.getValue().size());
                            writeBodyHeader(rgm);
                            for(HashMap<String,ReportGenerationFields> m: branchProgramMap.getValue()) {
                                writeBody(rgm, m);
                                totalCount++;
                            }
                        }
                    }
                    if (rgm.getTrailerFields() != null) {
                    	preProcessingBodyTrailer(rgm, branch.split(",")[0], totalCount);
                        writeTrailer(rgm, null);
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
}
