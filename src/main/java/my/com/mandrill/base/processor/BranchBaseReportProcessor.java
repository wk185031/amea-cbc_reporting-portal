package my.com.mandrill.base.processor;

import java.io.File;
import java.io.FileOutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.persistence.EntityManager;
import javax.persistence.Query;
import javax.sql.DataSource;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.SpringContext;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.repository.SystemConfigurationRepository;
import my.com.mandrill.base.service.util.CriteriaParamsUtil;
import my.com.mandrill.base.writer.CsvWriter;

public abstract class BranchBaseReportProcessor extends BaseReportProcessor {
	
	private final Logger logger = LoggerFactory.getLogger(BranchBaseReportProcessor.class);
	
	protected float DEFAULT_MARGIN = 30;

	protected float DEFAULT_FONT_SIZE = 6;

	protected float DEFAULT_LEADING = 1.5f * DEFAULT_FONT_SIZE;

	protected final String GROUP_FIELD_BRANCH = "BRANCH_CODE";

	protected final String GROUP_FIELD_TERMINAL = "TERMINAL";

	private int lineCounter = 0;
	
	@Autowired
	private DataSource datasource;
	
	@Autowired
	private CsvWriter csvWriter;
	
	/*
	 * Parent method to execute both CSV and PDF generation
	 */
	@Override
	public void process(ReportGenerationMgr rgm) throws ReportGenerationException {
		List<Branch> branches = getAllBranchByInstitution(rgm.getInstitution());
		
		String institution = rgm.getInstitution() == null ? "'CBC'" : rgm.getInstitution();
		rgm.setBodyQuery(CriteriaParamsUtil.replaceInstitution(rgm.getBodyQuery(), institution, ReportConstants.VALUE_DEO_NAME,
				ReportConstants.VALUE_INTER_DEO_NAME,ReportConstants.VALUE_ISSUER_NAME, ReportConstants.VALUE_INTER_ISSUER_NAME, 
				ReportConstants.VALUE_ACQUIRER_NAME, ReportConstants.VALUE_INTER_ACQUIRER_NAME, ReportConstants.VALUE_GLA_INST, 
				ReportConstants.VALUE_ACQR_INST_ID, ReportConstants.VALUE_INTER_ACQR_INST_ID, ReportConstants.VALUE_RECV_INST_ID,
				ReportConstants.VALUE_INTER_RECV_INST_ID));
		
		generateCSV(rgm, branches, institution);
//		generatePDF(rgm, branches);
	}
	
	/*
	 * PDF code
	 */
	protected void generatePDF(ReportGenerationMgr rgm, List<Branch> branches) throws ReportGenerationException {
		List<String> writtenFilePath = new ArrayList<>();

		PDDocument masterDoc = null;
		PDDocument branchDoc = null;

		PDPageContentStream masterStream = null;
		PDPageContentStream branchStream = null;

		try {
			masterDoc = new PDDocument();

			Connection conn = null;
			PreparedStatement ps = null;
			ResultSet rs = null;
			addReportPreProcessingFieldsToGlobalMap(rgm);

			for (Branch b : branches) {
				logger.debug("Process transaction for branch={}", b.getAbr_code());

				try {
					branchDoc = new PDDocument();
					masterStream = newPage(masterDoc, masterStream, rgm, b.getAbr_code(), b.getAbr_name());
					branchStream = newPage(branchDoc, branchStream, rgm, b.getAbr_code(), b.getAbr_name());
					Map<String, String> groupingField = new HashMap<String, String>();
					groupingField.put(GROUP_FIELD_BRANCH, b.getAbr_code());
					String bodyQuery = replaceBodyQueryCriteria(rgm, b.getAbr_code());
					HashMap<String, ReportGenerationFields> fieldsMap = null;
					HashMap<String, ReportGenerationFields> lineFieldsMap = null;

					boolean noRecordFound = true;

					if (bodyQuery != null && !bodyQuery.trim().isEmpty()) {
						logger.debug("Generate report with body Query = {}", bodyQuery);
						conn = datasource.getConnection();
						ps = conn.prepareStatement(bodyQuery);
						rs = ps.executeQuery();
						fieldsMap = rgm.getQueryResultStructure(rs);
						lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

						if (rs.next()) {
							do {
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
											field.setValue(Long.toString(
													((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
										} else if (result instanceof oracle.sql.DATE) {
											field.setValue(Long
													.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
										} else {
											field.setValue(result.toString());
										}
									} else {
										field.setValue("");
									}
								}
								writeRowData(rgm, masterDoc, branchDoc, lineFieldsMap, groupingField, b.getAbr_code(),
										b.getAbr_name(), masterStream, branchStream);
								if (getLineCounter() >= getMaxLinePerPage()) {
									masterStream = newPage(masterDoc, masterStream, rgm, b.getAbr_code(),
											b.getAbr_name());
									branchStream = newPage(branchDoc, branchStream, rgm, b.getAbr_code(),
											b.getAbr_name());
								}
								noRecordFound = false;

							} while (rs.next());
						} else {
							writeNoRecordFound(masterStream, branchStream);
							incrementLineCounter();
							noRecordFound = true;
						}
					}

					if (!noRecordFound) {
						String terminal = groupingField.get("TERMINAL").substring(0, 4);
						logger.debug("Write summary for last terminal:{}", terminal);
						writeTrailerSummary(rgm, masterDoc, branchDoc, groupingField, b.getAbr_code(), b.getAbr_name(),
								masterStream, branchStream);
					}

					branchStream = endDocument(branchStream);
					branchStream = null;

					String branchDocPath = writeFile(rgm, branchDoc, b.getAbr_code());
					writtenFilePath.add(branchDocPath);
				} finally {
					rgm.cleanAllDbResource(ps, rs, conn);
				}
			}
			masterStream = endDocument(masterStream);
			masterStream = null;
			String masterDocPath = writeFile(rgm, masterDoc, null);
			writtenFilePath.add(masterDocPath);

		} catch (Exception e) {
			logger.error("Failed to generate report. Remove generated files.", e);
			cleanAllFilesOnError(writtenFilePath);
			writtenFilePath = new ArrayList<>();
			throw new ReportGenerationException(rgm.getFileName(), e);
		}			
	}
	
	protected PDPageContentStream newPage(PDDocument doc, PDPageContentStream contentStream, ReportGenerationMgr rgm,
			String branchCode, String branchName) throws Exception {
		if (contentStream != null) {
			contentStream.endText();
			contentStream.close();
		}

		PDPage page = new PDPage();
		doc.addPage(page);
		logger.debug("create new page: {}", doc.getNumberOfPages());

		contentStream = new PDPageContentStream(doc, page);
		contentStream.setFont(PDType1Font.COURIER, DEFAULT_FONT_SIZE);
		contentStream.beginText();
		contentStream.newLineAtOffset(page.getMediaBox().getLowerLeftX() + DEFAULT_MARGIN,
				page.getMediaBox().getUpperRightY() - DEFAULT_MARGIN);

		contentStream = writeReportHeader(rgm, doc, contentStream, branchCode, branchName);
		resetLineCounter();
		return contentStream;
	}
	
	protected PDPageContentStream writeReportHeader(ReportGenerationMgr rgm, PDDocument doc,
			PDPageContentStream contentStream, String branchCode, String branchName) throws Exception {
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					contentStream = writeText(rgm, doc, contentStream, String.valueOf(doc.getNumberOfPages()),
							branchCode, branchName);
				} else {
					contentStream = writeText(rgm, doc, contentStream, getGlobalFieldValue(rgm, field), branchCode,
							branchName);
				}
				contentStream = writeText(rgm, doc, contentStream, null, branchCode, branchName);
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					contentStream = writeText(rgm, doc, contentStream,
							String.format("%1$-" + field.getPdfLength() + "s", branchCode), branchCode, branchName);
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
					contentStream = writeText(rgm, doc, contentStream,
							String.format("%1$-" + field.getPdfLength() + "s", branchName), branchCode, branchName);
				} else {
					contentStream = writeText(rgm, doc, contentStream, getGlobalFieldValue(rgm, field), branchCode,
							branchName);
				}
			}
		}
		contentStream = writeText(rgm, doc, contentStream, null, branchCode, branchName);
		contentStream = writeText(rgm, doc, contentStream, null, branchCode, branchName);
		return contentStream;
	}
	
	protected PDPageContentStream writeText(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream,
			String text, String branchCode, String branchName) throws Exception {
		if (text == null) {
			contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
		} else {
			contentStream.showText(text);
		}
		return contentStream;
	}
	
	protected void writeRowData(ReportGenerationMgr rgm, PDDocument masterDoc, PDDocument branchDoc,
			HashMap<String, ReportGenerationFields> fieldsMap, Map<String, String> groupingField, String branchCode,
			String branchName, PDPageContentStream masterStream, PDPageContentStream branchStream) throws Exception {

		Map<String, String> groupFieldToUpdate = new HashMap<>();

		List<ReportGenerationFields> fields = extractBodyFields(rgm);

		for (Map.Entry<String, String> entry : groupingField.entrySet()) {
			ReportGenerationFields result = fields.stream().filter(field -> entry.getKey().equals(field.getFieldName()))
					.findAny().orElse(null);

			if (result != null) {
				String value = getFieldValue(rgm, result, fieldsMap).trim();
				if (value != null && !value.equals(entry.getValue())) {
					logger.debug("write trailer summary.");
					writeTrailerSummary(rgm, masterDoc, branchDoc, groupingField, branchCode, branchName, masterStream,
							branchStream);
					break;
				}
			}
		}

		for (ReportGenerationFields field : fields) {
			if (field.isGroup()) {
				String value = getFieldValue(rgm, field, fieldsMap).trim();
				if (groupingField.containsKey(field.getFieldName())
						&& groupingField.get(field.getFieldName()).equals(value)) {
					// Same group. Do nothing
				} else {
					if (getLowestLevelGroupField().equals(field.getFieldName())) {
						masterStream = writeBodyHeader(rgm, masterDoc, masterStream, field.getFieldName(), value,
								branchCode, branchName, false);
						branchStream = writeBodyHeader(rgm, branchDoc, branchStream, field.getFieldName(), value,
								branchCode, branchName, false);
						incrementLineCounter(getNoOfRowForBodyHeader());

						masterStream = writeColumnHeader(rgm, masterDoc, masterStream, branchCode, branchName);
						branchStream = writeColumnHeader(rgm, branchDoc, branchStream, branchCode, branchName);
						incrementLineCounter(getNoOfRowForColumnHeader());

					} else {
						masterStream = writeBodyHeader(rgm, masterDoc, masterStream, field.getFieldName(), value,
								branchCode, branchName, true);
						branchStream = writeBodyHeader(rgm, branchDoc, branchStream, field.getFieldName(), value,
								branchCode, branchName, true);
						incrementLineCounter(getNoOfRowForBodyHeader());
					}

					groupFieldToUpdate.put(field.getFieldName(), value);
				}

			} else {
				setBody(true);
				setBodyHeader(false);
				if (field.isDecrypt()) {
					decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
				}

				String fieldValue = getFieldValue(rgm, field, fieldsMap);
				if (field.isEol()) {
					masterStream = writeText(rgm, masterDoc, masterStream, fieldValue,
							branchCode, branchName);
					masterStream = writeText(rgm, masterDoc, masterStream, null, branchCode, branchName);

					branchStream = writeText(rgm, branchDoc, branchStream, fieldValue,
							branchCode, branchName);
					branchStream = writeText(rgm, branchDoc, branchStream, null, branchCode, branchName);

					// Same counter for master and branch
					incrementLineCounter();
					incrementLineCounter();
				} else {
					masterStream = writeText(rgm, masterDoc, masterStream, fieldValue,
							branchCode, branchName);
					branchStream = writeText(rgm, branchDoc, branchStream, fieldValue,
							branchCode, branchName);
				}
			}
		}

		groupingField.putAll(groupFieldToUpdate);
	}
	
	protected PDPageContentStream writeBodyHeader(ReportGenerationMgr rgm, PDDocument doc,
			PDPageContentStream contentStream, String label, String value, String branchCode, String branchName,
			boolean skipColumnHeader) throws Exception {
		contentStream = writeText(rgm, doc, contentStream, null, branchCode, branchName);
		contentStream = writeText(rgm, doc, contentStream, label + " " + value, branchCode, branchName);
		contentStream = writeText(rgm, doc, contentStream, null, branchCode, branchName);

		return contentStream;
	}
	
	protected PDPageContentStream writeColumnHeader(ReportGenerationMgr rgm, PDDocument doc,
			PDPageContentStream contentStream, String branchCode, String branchName) throws Exception {
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream = writeText(rgm, doc, contentStream, getGlobalFieldValue(rgm, field), branchCode,
						branchName);
				contentStream = writeText(rgm, doc, contentStream, null, branchCode, branchName);
			} else {
				if (field.isFirstField()) {
					contentStream = writeText(rgm, doc, contentStream, getGlobalFieldValue(rgm, field), branchCode,
							branchName);
				} else {
					contentStream = writeText(rgm, doc, contentStream, getGlobalFieldValue(rgm, field), branchCode,
							branchName);
				}
			}
		}
		return contentStream;
	}
	
	protected void writeNoRecordFound(PDPageContentStream... streams) throws Exception {
		for (PDPageContentStream s : streams) {
			s.setFont(PDType1Font.COURIER, DEFAULT_FONT_SIZE);
			s.newLineAtOffset(0, -DEFAULT_LEADING);
			s.showText(ReportConstants.NO_RECORD);
		}
	}
	
	protected void writeTrailerSummary(ReportGenerationMgr rgm, PDDocument masterDoc, PDDocument branchDoc,
			Map<String, String> groupingField, String branchCode, String branchName, PDPageContentStream masterStream,
			PDPageContentStream branchStream) {

		if (rgm.getTrailerQuery() == null || rgm.getTrailerQuery().trim().isEmpty()) {
			logger.debug("No trailer query. Skip write trailer summary.");
			return;
		}

		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = replaceTrailerQueryCriteria(rgm, groupingField);
		logger.debug("writeTrailerSummary: query={}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
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
					writeBodyTrailer(rgm, masterDoc, masterStream, lineFieldsMap, extractTrailerFields(rgm), branchCode,
							branchName);
					writeBodyTrailer(rgm, branchDoc, branchStream, lineFieldsMap, extractTrailerFields(rgm), branchCode,
							branchName);
					incrementLineCounter(getNoOfRowForTrailer());

				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}
	
	protected void writeBodyTrailer(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream,
			HashMap<String, ReportGenerationFields> fieldsMap, List<ReportGenerationFields> trailerFields,
			String branchCode, String branchName) throws Exception {
		logger.debug("write body trailer.");
		for (ReportGenerationFields field : trailerFields) {
			if (field.isEol()) {
				contentStream = writeText(rgm, doc, contentStream, getFieldValue(rgm, field, fieldsMap), branchCode,
						branchName);
				contentStream = writeText(rgm, doc, contentStream, null, branchCode, branchName);
			} else {
				contentStream = writeText(rgm, doc, contentStream, getFieldValue(rgm, field, fieldsMap), branchCode,
						branchName);
			}
		}
		contentStream = writeText(rgm, doc, contentStream, null, branchCode, branchName);
		contentStream = writeText(rgm, doc, contentStream, null, branchCode, branchName);
	}
	
	protected String replaceTrailerQueryCriteria(ReportGenerationMgr rgm, Map<String, String> groupingField) {

		String originalQuery = rgm.getTrailerQuery();
		for (Map.Entry<String, String> entry : groupingField.entrySet()) {
			String placeHolder = entry.getKey();
			String value = entry.getValue();

			if (GROUP_FIELD_TERMINAL.equals(placeHolder) && value.length() > 4) {
				value = value.substring(0, 4);
				rgm.setTrailerQuery(rgm.getTrailerQuery().replace("{" + entry.getKey() + "}", "'" + value + "'"));
			} else {
				rgm.setTrailerQuery(
						rgm.getTrailerQuery().replace("{" + entry.getKey() + "}", "'" + entry.getValue() + "'"));
			}
		}
		String updatedQuery = getTrailerQuery(rgm);
		rgm.setTrailerQuery(originalQuery);
		return updatedQuery;
	}

	protected String replaceBodyQueryCriteria(ReportGenerationMgr rgm, String branchCode) {
		ReportGenerationFields branchCodeField = new ReportGenerationFields(GROUP_FIELD_BRANCH,
				ReportGenerationFields.TYPE_STRING, "'" + branchCode + "'");
		getGlobalFileFieldsMap().put(branchCodeField.getFieldName(), branchCodeField);
		
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);
		
		ReportGenerationFields txnStartField = new ReportGenerationFields(ReportConstants.PARAM_TXN_START_TS,
				ReportGenerationFields.TYPE_STRING, "'" + txnStart + "'");
		getGlobalFileFieldsMap().put(txnStartField.getFieldName(), txnStartField);
		
		ReportGenerationFields txnEndField = new ReportGenerationFields(ReportConstants.PARAM_TXN_END_TS,
				ReportGenerationFields.TYPE_STRING, "'" + txnEnd + "'");
		getGlobalFileFieldsMap().put(txnEndField.getFieldName(), txnEndField);
		
		return getBodyQuery(rgm);
	}
	
	protected PDPageContentStream endDocument(PDPageContentStream contentStream) throws Exception {
		logger.debug("end document.");
		contentStream.endText();
		contentStream.close();
		return contentStream;
	}
	
	protected String writeFile(ReportGenerationMgr rgm, PDDocument doc, String branchCode) throws Exception {
		String fileAbsolutePath = getFileAbsolutePath(rgm.getFileBaseDirectory(), rgm.getReportCategory(), branchCode,
				rgm.getFileNamePrefix(), rgm.getTxnStartDate(), rgm.getReportTxnEndDate(), ReportConstants.PDF_FORMAT);

		try {
			if (rgm.errors == 0) {
				File out = new File(fileAbsolutePath);
				if (!out.getParentFile().exists()) {
					out.getParentFile().mkdirs();
				}
				doc.save(out);
			}
		} finally {
			if (doc != null) {
				try {
					doc.close();
				} catch (Exception e) {
					logger.warn("Failed to close document.", e);
				}

			}
		}

		return fileAbsolutePath;
	}
	
	protected void cleanAllFilesOnError(List<String> fileToClear) {
		for (String filePath : fileToClear) {
			try {
				Files.deleteIfExists(Paths.get(filePath));
			} catch (Exception e) {
				logger.warn("Failed to delete file: {}", filePath);
			}
		}
	}
	
	protected String getLowestLevelGroupField() {
		return GROUP_FIELD_TERMINAL;
	}

	protected void incrementLineCounter() {
		lineCounter++;
	}

	protected void incrementLineCounter(int counterToAdd) {
		lineCounter += counterToAdd;
	}

	protected void resetLineCounter() {
		lineCounter = 0;
	}

	protected int getLineCounter() {
		return lineCounter;
	}

	protected int getNoOfRowForTrailer() {
		// Interim solution to determine counter to increase to avoid duplicate for
		// master and branch stream.
		// Should be dynamic based on configuration
		return 1;
	}

	protected int getNoOfRowForColumnHeader() {
		// Interim solution to determine counter to increase to avoid duplicate for
		// master and branch stream.
		// Should be dynamic based on configuration
		return 2;
	}

	protected int getNoOfRowForBodyHeader() {
		// Interim solution to determine counter to increase to avoid duplicate for
		// master and branch stream.
		// Should be dynamic based on configuration
		return 1;
	}
	
	protected int getMaxLinePerPage() {
		return 120;
	}

	/*
	 * CSV code
	 */
	protected void generateCSV(ReportGenerationMgr rgm, List<Branch> branches, String institution) throws ReportGenerationException {
		FileOutputStream outBranch = null;
		FileOutputStream outMaster = null;
		
		Connection conn = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
			
		File branchOutputFile = null;
		File masterOutputFile = null;
		
		try {
			
			ReportContext currentContext = new ReportContext();
			currentContext.setTxnEndDateTime(rgm.getTxnEndDate());
			currentContext.setPredefinedFieldMap(initPredefinedFieldMap(rgm));
			currentContext.setDataMap(initDataMap(rgm));

			rgm.setBodyQuery(CriteriaParamsUtil.replaceBranchFilterCriteria(rgm.getBodyQuery(), institution));
			rgm.setTrailerQuery(CriteriaParamsUtil.replaceBranchFilterCriteria(rgm.getBodyQuery(), institution));

			masterOutputFile = createEmptyReportFile(rgm, null); 
			outMaster = new FileOutputStream(masterOutputFile);

			logger.debug("Execute query: {}", currentContext.getQuery());
			
			for (Branch b : branches) {
				logger.debug("Process transaction for branch={}", b.getAbr_code());
				try {
					currentContext.setQuery(replaceBodyQueryCriteria(rgm, currentContext.getPredefinedFieldMap(), b));
					conn = datasource.getConnection();
					ps = conn.prepareStatement(currentContext.getQuery());
					rs = ps.executeQuery();

					branchOutputFile = createEmptyReportFile(rgm, b.getAbr_code());
					outBranch = new FileOutputStream(branchOutputFile);

					presetBranchCodeAndName(currentContext.getPredefinedFieldMap(), b);
					writeReportHeader(outMaster, rgm.getHeaderFields(), currentContext.getPredefinedFieldMap());
					writeReportHeader(outBranch, rgm.getHeaderFields(), currentContext.getPredefinedFieldMap());

					if (rs.next()) {
						do {
							List<ReportGenerationFields> bodyFields = mapResultsetToField(extractBodyFields(rgm.getBodyFields()),
									rs);

							preProcessBodyHeader(currentContext, bodyFields, outMaster, outBranch);
							writeBodyHeader(currentContext, extractBodyHeaderFields(rgm.getBodyFields()), outMaster, outBranch);

							preProcessBodyData(currentContext, bodyFields, outMaster, outBranch);
							writeBodyData(currentContext, bodyFields, outMaster, outBranch);
													
						} while (rs.next());	
						
						writeBodyTrailer(currentContext, extractBodyFields(rgm.getBodyFields()), outMaster, outBranch);
						writeReportTrailer(currentContext, parseFieldConfig(rgm.getTrailerFields()), outMaster, outBranch);
						
						postReportGeneration(branchOutputFile);
						
						csvWriter.writeLine(outMaster, "\r\n");
					} else {
						csvWriter.writeLine(outMaster, "**NO TRANSACTIONS FOR THE DAY** \r\n");
						csvWriter.writeLine(outMaster, "\r\n");
						csvWriter.writeLine(outBranch, "**NO TRANSACTIONS FOR THE DAY** \r\n");
						csvWriter.writeLine(outMaster, "\r\n");
					}
					logger.debug("Report generation complete for branch [{}]. File={}", b.getAbr_code(), branchOutputFile.getAbsolutePath());
					outBranch.close();
				} finally {
					rgm.cleanAllDbResource(ps, rs, conn);
				}
				
			}					
			
			logger.debug("Report generation complete for master. File={}", masterOutputFile.getAbsolutePath());
			postReportGeneration(masterOutputFile);
			
			outMaster.close();

		} catch (Exception e) {
			logger.debug("Failed to process file: {}", masterOutputFile.getAbsolutePath(), e);
			if (masterOutputFile != null && masterOutputFile.exists()) {
				try {
					masterOutputFile.delete();
				} catch (Exception e1) {
					logger.warn("Failed to delete failed report.", e1);
				}
			}
			throw new ReportGenerationException(masterOutputFile.getName(), e);
		} 
	}
	
	abstract protected void preProcessBodyHeader(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream outMaster, FileOutputStream outBranch) throws Exception;
	
	protected void writeBodyHeader(ReportContext context, List<ReportGenerationFields> bodyHeaderFields,
			FileOutputStream outMaster, FileOutputStream outBranch) throws Exception {
		if (context.isWriteBodyHeader()) {
			csvWriter.writeLine(outMaster, bodyHeaderFields, null);
			csvWriter.writeLine(outBranch, bodyHeaderFields, null);
			context.setWriteBodyHeader(false);
		}
	}
	
	abstract protected void preProcessBodyData(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream outMaster, FileOutputStream outBranch) throws Exception;
	
	protected void writeBodyData(ReportContext context, List<ReportGenerationFields> bodyFields, FileOutputStream outMaster, FileOutputStream outBranch)
			throws Exception {

		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : bodyFields) {
			if (field.isGroup()) {
				handleGroupFieldInBody(context, field, line);
			} else {
				String fieldValue = getFormattedFieldValue(field, context);
				
				if (ReportGenerationFields.TYPE_NUMBER.equals(field.getFieldType())
						|| ReportGenerationFields.TYPE_DECIMAL.equals(field.getFieldType())) {
					line.append("\"" + fieldValue + "\"");
					addToSumField(context, field);
				} else {
					line.append(fieldValue);
				}
				line.append(field.getDelimiter());

				if (field.isEol()) {
					line.append(CsvWriter.EOL);
				}
			}
		}

		csvWriter.writeLine(outMaster, line.toString());
		csvWriter.writeLine(outBranch, line.toString());
		context.setTotalRecord(context.getTotalRecord() + 1);
	}
	
	abstract protected void writeBodyTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream outMaster, FileOutputStream outBranch) throws Exception;
	
	protected void writeReportTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream outMaster, FileOutputStream outBranch) {

	}
	
	public List<Branch> getAllBranchByInstitution(String institutionCode) {
		SystemConfigurationRepository configRepo = SpringContext.getBean(SystemConfigurationRepository.class);
		String configName = institutionCode.toLowerCase().concat(".branch.prefix");
		SystemConfiguration config = configRepo.findByName(configName);
		
		if (config != null) {
			StringBuilder stmtBuilder = new StringBuilder();
			for (String prefix : config.getConfig().split(",")) {
				if (stmtBuilder.length() > 0) {
					stmtBuilder.append(" OR");
				}
				stmtBuilder.append(" id like '").append(prefix).append("%'");
			}
			
			EntityManager em = SpringContext.getBean(EntityManager.class);
			Query q = em.createQuery("select b from Branch b where" + stmtBuilder.toString() + " order by id");
			return q.getResultList();		
		}
		return new ArrayList<>();
	}
	
	protected String getFileAbsolutePath(String rootPath, String category, String branchCode, String filePrefix,
			LocalDateTime txnStartDate, LocalDateTime txnEndDate, String format) {
		String basePath = rootPath + File.separator + (branchCode == null ? "MAIN" : branchCode) + File.separator
				+ category;
		String prefix = branchCode == null ? filePrefix : (filePrefix + "_" + branchCode);
		String fileName = generateDateRangeOutputFileName(prefix, txnStartDate, txnEndDate, format);
		return basePath + File.separator + fileName;

	}
	
	protected File createEmptyReportFile(ReportGenerationMgr rgm, String branchCode) {
       
        String fileName = getFileAbsolutePath(rgm.getFileBaseDirectory(), rgm.getReportCategory(), branchCode,
				rgm.getFileNamePrefix(), rgm.getTxnStartDate(), rgm.getReportTxnEndDate(), ReportConstants.CSV_FORMAT);

        File file = new File(fileName);
        
        File reportPath = new File(file.getParent());
        if (!reportPath.exists()) {
			reportPath.mkdirs();
		}

		return file;
	}
	
	protected String replaceBodyQueryCriteria(ReportGenerationMgr rgm, Map<String, ReportGenerationFields> predefinedMap, Branch branch) {
		ReportGenerationFields branchCodeField = new ReportGenerationFields(GROUP_FIELD_BRANCH,
				ReportGenerationFields.TYPE_STRING, "'" + branch.getAbr_code() + "'");
		predefinedMap.put(branchCodeField.getFieldName(), branchCodeField);
				
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);
		
		ReportGenerationFields txnStartField = new ReportGenerationFields(ReportConstants.PARAM_TXN_START_TS,
				ReportGenerationFields.TYPE_STRING, "'" + txnStart + "'");
		predefinedMap.put(txnStartField.getFieldName(), txnStartField);
		
		ReportGenerationFields txnEndField = new ReportGenerationFields(ReportConstants.PARAM_TXN_END_TS,
				ReportGenerationFields.TYPE_STRING, "'" + txnEnd + "'");
		predefinedMap.put(txnEndField.getFieldName(), txnEndField);
		
		return getBodyQuery(rgm, predefinedMap);
	}
	
	public String getBodyQuery(ReportGenerationMgr rgm, Map<String, ReportGenerationFields> predefinedMap) {
		String query = rgm.getBodyQuery();
		StringBuffer sb = new StringBuffer();
		if (query != null) {
			Pattern p = Pattern.compile("[{]\\w+,*\\w*[}]");
			Matcher m = p.matcher(query);
			while (m.find()) {
				
				String paramName = m.group().substring(1, m.group().length() - 1);
				if (predefinedMap.containsKey(paramName)) {
					String value = predefinedMap.get(paramName).format();
					logger.debug("Replace parameter[{}] with value[{}]", paramName, value);
					m.appendReplacement(sb, value);
				} else {
					rgm.errors++;
					logger.error("No field defined for parameter: {}", paramName);
				}

			}
			m.appendTail(sb);
		} else {
			logger.debug("*** Body query is null or empty");
		}
		return sb.toString();
	}
	
	protected void writeReportHeader(FileOutputStream out, String headerFieldConfig,
			Map<String, ReportGenerationFields> predefinedDataMap, Branch branch) throws Exception {
		csvWriter.writeLine(out, parseFieldConfig(headerFieldConfig), predefinedDataMap);
		csvWriter.writeLine(out, CsvWriter.EOL);
	}
	
	protected Map<String, ReportGenerationFields> presetBranchCodeAndName(Map<String, ReportGenerationFields> predefinedDataMap, Branch branch) {
		ReportGenerationFields branchCodeValue = new ReportGenerationFields(ReportConstants.BRANCH_CODE,
				ReportGenerationFields.TYPE_STRING, branch.getAbr_code());
		ReportGenerationFields branchNameValue = new ReportGenerationFields(ReportConstants.BRANCH_NAME,
				ReportGenerationFields.TYPE_STRING, branch.getAbr_name());
		
		predefinedDataMap.put(branchCodeValue.getFieldName(), branchCodeValue);
		predefinedDataMap.put(branchNameValue.getFieldName(), branchNameValue);
		
		return predefinedDataMap;
	}
	
	protected void writeBodyData(ReportContext context, List<ReportGenerationFields> bodyFields, FileOutputStream out, boolean skipAmountSum)
			throws Exception {

		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : bodyFields) {
			if (field.isGroup()) {
				handleGroupFieldInBody(context, field, line);
			} else {
				String fieldValue = getFormattedFieldValue(field, context);
				
				if (ReportGenerationFields.TYPE_NUMBER.equals(field.getFieldType())
						|| ReportGenerationFields.TYPE_DECIMAL.equals(field.getFieldType())) {
					line.append("\"" + fieldValue + "\"");
					
					if(!skipAmountSum) {
						addToSumField(context, field);
					}					
				} else {
					line.append(fieldValue);
				}
				line.append(field.getDelimiter());

				if (field.isEol()) {
					line.append(CsvWriter.EOL);
				}
			}
		}

		csvWriter.writeLine(out, line.toString());
		context.setTotalRecord(context.getTotalRecord() + 1);
	}
	
	@Override
	protected void preProcessBodyHeader(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		// Do Nothing
	}

	@Override
	protected void preProcessBodyData(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		// Do Nothing		
	}

	@Override
	protected void writeBodyTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception {
		// Do Nothing		
	}
	
}
