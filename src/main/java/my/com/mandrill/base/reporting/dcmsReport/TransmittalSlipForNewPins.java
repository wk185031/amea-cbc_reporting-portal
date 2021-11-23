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

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;
import my.com.mandrill.base.service.EncryptionService;

public class TransmittalSlipForNewPins extends TxtReportProcessor {

    private final Logger logger = LoggerFactory.getLogger(TransmittalSlipForNewPins.class);
    
	private EncryptionService encryptionService;
	
    private final PDFont DEFAULT_FONT = PDType1Font.COURIER;
	private final float DEFAULT_FONT_SIZE = 6;
	private final float DEFAULT_MARGIN = 30;
    private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
    private float totalHeight = PDRectangle.A4.getHeight();
    private int pagination = 0;
    
	@Override
	public void executePdf(ReportGenerationMgr rgm) throws ReportGenerationException {
		logger.debug("In TransmittalSlipForNewPins.processPdfRecord(): " + rgm.getFileNamePrefix());
		generateReport(rgm);
	}

	private void generateReport(ReportGenerationMgr rgm) throws ReportGenerationException {
		logger.debug("In TransmittalSlipForNewPins.generateReport(): " + rgm.getFileNamePrefix());
		PDPageContentStream contentStream = null;
		PDFont pdfFont = PDType1Font.COURIER;
		float fontSize = 6;
		float leading = 1.5f * fontSize;
		PDRectangle pageSize = null;
		float margin = 30;
		float width = 0.0f;
		float startX = 0.0f;
		float startY = 0.0f;
		PDDocument doc = null;
		PDPage page = null;
		pagination = 0;

		try {
			preProcessing(rgm);
			doc = new PDDocument();
			
			if (!executeQuery(rgm)) {
				page = new PDPage();
				doc.addPage(page);
				contentStream = new PDPageContentStream(doc, page);
				pageSize = page.getMediaBox();
				width = pageSize.getWidth() - 2 * margin;
				startX = pageSize.getLowerLeftX() + margin;
				startY = pageSize.getUpperRightY() - margin;
				contentStream.setFont(pdfFont, fontSize);
				contentStream.beginText();
				contentStream.newLineAtOffset(startX, startY);
				writePdfHeader(rgm, contentStream, leading, pagination);
				contentStream.newLineAtOffset(0, -leading);
				contentStream.showText(ReportConstants.NO_RECORD);
				contentStream.endText();
				contentStream.close();
				saveFile(rgm, doc);
			} else {	
				contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
						startY, pdfFont, fontSize, width, margin);
				pageHeight += 1;
			}

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
    public void processTxtRecord(ReportGenerationMgr rgm) throws ReportGenerationException {
        logger.debug("In TransmittalSlipForNewPins.processTxtRecord()");
        File file = null;
        String txnDate = null;
        String fileLocation = rgm.getFileLocation();
        String fileName = "";
        if (getEncryptionService() == null) {
        	setEncryptionService(rgm.getEncryptionService());
        }

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
            throw new ReportGenerationException(
					"Errors when generating: " + fileName, e);
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
    
	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, float width, float margin) {
		logger.debug("In TransmittalSlipForNewPins.executePdfBodyQuery()");
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
                if(getEncryptionService() == null) {
                	setEncryptionService(rgm.getEncryptionService());
                }

				if (rs.next()) {
					do {
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
									field.setValue(
											Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
								} else {
									field.setValue(result.toString());
								}
							} else {
								field.setValue("");
							}
						}

						if (branchSet == null) {
							branchSet = new HashSet<String>();
						}

						if (str == null) {
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

						// decrypt first, middle, last name and combine set value for ACCOUNT_NAME
						String encFirstName = lineFieldsMap.get("FIRST_NAME").getValue();
						String encMiddleName = lineFieldsMap.get("MIDDLE_NAME").getValue();
						String encLastName = lineFieldsMap.get("LAST_NAME").getValue();
						String institutionCode = lineFieldsMap.get("INSTITUTION_ID").getValue();
						int rotationNumber = Integer.parseInt(lineFieldsMap.get("ROTATION_NUMBER").getValue());
						
						String decryptFirstName = encryptionService.decryptDcms(encFirstName, institutionCode,
								rotationNumber);
						String decryptMiddleName = encryptionService.decryptDcms(encMiddleName, institutionCode,
								rotationNumber);
						String decryptLastName = encryptionService.decryptDcms(encLastName, institutionCode,
								rotationNumber);

						
						if (decryptFirstName == null) {
							decryptFirstName = encFirstName;
						}
						if (decryptMiddleName == null) {
							decryptMiddleName = encMiddleName;
						}
						if (decryptLastName == null) {
							decryptLastName = encLastName;
						}
						String decryptLastNameTab = decryptLastName.replaceAll("\t", " ");		
						
						lineFieldsMap.get("ACCOUNT_NAME")
								.setValue(decryptFirstName + " " + decryptMiddleName + " " + decryptLastNameTab);

						if (programToLineFieldsMap == null) {
							programToLineFieldsMap = new HashMap<String, List<HashMap<String, ReportGenerationFields>>>();
						}

						if (programToLineFieldsMap.containsKey(str.toString())) {
							programToLineFieldsMap.get(str.toString()).add(lineFieldsMap);
						} else {
							lineFieldsMapList = new ArrayList<>();
							lineFieldsMapList.add(lineFieldsMap);
							programToLineFieldsMap.put(str.toString(), lineFieldsMapList);
						}

						str.setLength(0);

					} while (rs.next());
				} else {
					writePdfHeader(rgm, contentStream, leading, pagination);
    				contentStream.newLineAtOffset(0, -leading);
					contentStream.showText(ReportConstants.NO_RECORD);		
				}
				
                for(String branch: branchSet) {
					page = new PDPage();
					doc.addPage(page);
					pagination++;
					contentStream = new PDPageContentStream(doc, page);
					pageSize = page.getMediaBox();
					width = pageSize.getWidth() - 2 * margin;
					startX = pageSize.getLowerLeftX() + margin;
					startY = pageSize.getUpperRightY() - margin;
					contentStream.setFont(pdfFont, fontSize);
					contentStream.beginText();
					contentStream.newLineAtOffset(startX, startY);

                    int totalCount = 0;
                    preProcessingHeader(rgm, branch.split(",")[0], branch.split(",")[1]);
					writePdfHeader(rgm, contentStream, leading, pagination);
    				contentStream.newLineAtOffset(0, -leading);
                    for(Map.Entry<String, List<HashMap<String,ReportGenerationFields>>> branchProgramMap: programToLineFieldsMap.entrySet()) {
                        if(branchProgramMap.getKey().split(",")[0].equals(branch.split(",")[0])) {
                            preProcessingBodyHeader(rgm, branchProgramMap.getKey().split(",")[1], branchProgramMap.getValue().size());
        					writePdfBodyHeader(rgm, contentStream, leading);
                            for(HashMap<String,ReportGenerationFields> m: branchProgramMap.getValue()) {
                            	float x = 2.5f;
                                writePdfBody(rgm, m, contentStream, x);
            					pageHeight++;
                                totalCount++;
                            }
                        }
                    }
                    if (rgm.getTrailerFields() != null) {
                    	preProcessingBodyTrailer(rgm, branch.split(",")[0], totalCount);
            			writePdfTrailer(rgm, lineFieldsMap, contentStream, leading);
        				pageHeight += 1;
        				contentStream.newLineAtOffset(0, -leading);
                    }
    				contentStream.endText();
    				contentStream.close();
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

    private void preProcessing(ReportGenerationMgr rgm)
        throws InstantiationException, IllegalAccessException, ClassNotFoundException {
        logger.debug("In TransmittalSlipForNewPins.preProcessing():" + rgm.getFileNamePrefix());
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
        String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);

        rgm.setBodyQuery(rgm.getBodyQuery()
            .replace("{" + ReportConstants.PARAM_DCMS_DB_SCHEMA+ "}", rgm.getDcmsDbSchema())
            .replace("{" + ReportConstants.PARAM_DB_LINK_DCMS + "}", rgm.getDbLink())
			.replace("{" + ReportConstants.PARAM_FROM_DATE + "}", "'" + rgm.getTxnStartDate().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
			.replace("{" + ReportConstants.PARAM_TO_DATE + "}", "'" + rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern("dd-MM-yy HH:mm:ss")) + "'")
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
    			pagination = 0;

				if (rs.next()) {
					do {
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
									field.setValue(
											Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
								} else {
									field.setValue(result.toString());
								}
							} else {
								field.setValue("");
							}
						}

						if (branchSet == null) {
							branchSet = new HashSet<String>();
						}

						if (str == null) {
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

						// decrypt first, middle, last name and combine set value for ACCOUNT_NAME
						String encFirstName = lineFieldsMap.get("FIRST_NAME").getValue();
						String encMiddleName = lineFieldsMap.get("MIDDLE_NAME").getValue();
						String encLastName = lineFieldsMap.get("LAST_NAME").getValue();
						String institutionCode = lineFieldsMap.get("INSTITUTION_ID").getValue();
						int rotationNumber = Integer.parseInt(lineFieldsMap.get("ROTATION_NUMBER").getValue());

						String decryptFirstName = encryptionService.decryptDcms(encFirstName, institutionCode,
								rotationNumber);
						String decryptMiddleName = encryptionService.decryptDcms(encMiddleName, institutionCode,
								rotationNumber);
						String decryptLastName = encryptionService.decryptDcms(encLastName, institutionCode,
								rotationNumber);

						if (decryptFirstName == null) {
							decryptFirstName = encFirstName;
						}
						if (decryptMiddleName == null) {
							decryptMiddleName = encMiddleName;
						}
						if (decryptLastName == null) {
							decryptLastName = encLastName;
						}

						lineFieldsMap.get("ACCOUNT_NAME")
								.setValue(decryptFirstName + " " + decryptMiddleName + " " + decryptLastName);

						if (programToLineFieldsMap == null) {
							programToLineFieldsMap = new HashMap<String, List<HashMap<String, ReportGenerationFields>>>();
						}

						if (programToLineFieldsMap.containsKey(str.toString())) {
							programToLineFieldsMap.get(str.toString()).add(lineFieldsMap);
						} else {
							lineFieldsMapList = new ArrayList<>();
							lineFieldsMapList.add(lineFieldsMap);
							programToLineFieldsMap.put(str.toString(), lineFieldsMapList);
						}

						str.setLength(0);
					} while (rs.next());
				} else {
					writeHeader(rgm, pagination);
					rgm.writeLine(ReportConstants.NO_RECORD.getBytes());
					rgm.writeLine(getEol().getBytes());
				}

                // 3. iterate (branch_name,branch_code) set, iterate (branch_name,program_name) map to print by grouping
                for(String branch: branchSet) {
    				pagination++;
                    int totalCount = 0;
                    preProcessingHeader(rgm, branch.split(",")[0], branch.split(",")[1]);
                    writeHeader(rgm, pagination);
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
    
	private boolean executeQuery(ReportGenerationMgr rgm) {
		logger.debug("In TransmittalSlipForNewPins.executeQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = getBodyQuery(rgm);
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.connection.prepareStatement(query);
			rs = ps.executeQuery();

			if (!rs.isBeforeFirst()) {
				return false;
			} else {
				return true;
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
		return false;
	}
	
	public EncryptionService getEncryptionService() {
		return encryptionService;
	}

	public void setEncryptionService(EncryptionService encryptionService) {
		this.encryptionService = encryptionService;
	}

}
