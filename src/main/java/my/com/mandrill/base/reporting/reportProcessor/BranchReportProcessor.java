package my.com.mandrill.base.reporting.reportProcessor;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class BranchReportProcessor extends PdfReportProcessor {

	protected final Logger logger = LoggerFactory.getLogger(BranchReportProcessor.class);

	protected float DEFAULT_MARGIN = 30;

	protected float DEFAULT_FONT_SIZE = 6;

	protected float DEFAULT_LEADING = 1.5f * DEFAULT_FONT_SIZE;

	protected final String GROUP_FIELD_BRANCH = "BRANCH_CODE";

	protected final String GROUP_FIELD_TERMINAL = "TERMINAL";

	@Override
	public void executePdf(ReportGenerationMgr rgm) {
		List<String> writtenFilePath = new ArrayList<>();

		List<Branch> branches = getAllBranchByInstitution(rgm.getInstitution());

		PDDocument masterDoc = null;
		PDDocument branchDoc = null;

		PDPageContentStream masterStream = null;
		PDPageContentStream branchStream = null;

		try {
			masterDoc = new PDDocument();

			PreparedStatement ps = null;
			ResultSet rs = null;
			addReportPreProcessingFieldsToGlobalMap(rgm);

			for (Branch b : branches) {
				logger.debug("Process transaction for branch={}", b.getAbr_code());

				try {
					masterStream = newPage(masterDoc, masterStream, rgm, b.getAbr_code(), b.getAbr_name());

					branchDoc = new PDDocument();
					branchStream = newPage(branchDoc, branchStream, rgm, b.getAbr_code(), b.getAbr_name());
					Map<String, String> groupingField = new HashMap<String, String>();
					groupingField.put(GROUP_FIELD_BRANCH, b.getAbr_code());
					String bodyQuery = replaceBodyQueryCriteria(rgm, b.getAbr_code());
					HashMap<String, ReportGenerationFields> fieldsMap = null;
					HashMap<String, ReportGenerationFields> lineFieldsMap = null;

					boolean noRecordFound = true;

					if (bodyQuery != null && !bodyQuery.trim().isEmpty()) {
						logger.debug("Generate report with body Query = {}", bodyQuery);
						ps = rgm.connection.prepareStatement(bodyQuery);
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
								writeRowData(rgm, lineFieldsMap, groupingField, b.getAbr_code(), masterStream,
										branchStream);
								noRecordFound = false;

							} while (rs.next());
						} else {
							writeNoRecordFound(masterStream, branchStream);
							noRecordFound = true;
						}
					}

					if (!noRecordFound) {
						String terminal = groupingField.get("TERMINAL").substring(0, 4);
						logger.debug("Write summary for last terminal:{}", terminal);
						writeTrailerSummary(rgm, groupingField, masterStream, branchStream);
					}

					endDocument(branchStream);
					branchStream = null;

					String branchDocPath = writeFile(rgm, branchDoc, b.getAbr_code());
					writtenFilePath.add(branchDocPath);
				} finally {
					try {
						if (ps != null) {
							ps.close();
						}
						if (rs != null) {
							rs.close();
						}
					} catch (Exception e) {
						logger.warn("Failed to close statement or resultset", e);
					}

				}

			}
			endDocument(masterStream);
			masterStream = null;
			String masterDocPath = writeFile(rgm, masterDoc, null);
			writtenFilePath.add(masterDocPath);

		} catch (Exception e) {
			logger.error("Failed to generate report. Remove generated files.", e);
			cleanAllFilesOnError(writtenFilePath);
			writtenFilePath = new ArrayList<>();
			throw new RuntimeException(e);
		}
	}

	private PDPageContentStream newPage(PDDocument doc, PDPageContentStream contentStream, ReportGenerationMgr rgm,
			String branchCode, String branchName) throws Exception {
		if (contentStream != null) {
			contentStream.endText();
			contentStream.close();
		}

		PDPage page = new PDPage();
		doc.addPage(page);

		contentStream = new PDPageContentStream(doc, page);
		contentStream.setFont(PDType1Font.COURIER, DEFAULT_FONT_SIZE);
		contentStream.beginText();
		contentStream.newLineAtOffset(page.getMediaBox().getLowerLeftX() + DEFAULT_MARGIN,
				page.getMediaBox().getUpperRightY() - DEFAULT_MARGIN);

		writeReportHeader(contentStream, doc, rgm, branchCode, branchName);
		return contentStream;
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

	protected void writeReportHeader(PDPageContentStream contentStream, PDDocument doc, ReportGenerationMgr rgm,
			String branchCode, String branchName) throws Exception {
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					contentStream.showText(String.valueOf(doc.getNumberOfPages()));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
				contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", branchCode));
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", branchName));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
			}
		}
		contentStream.newLineAtOffset(0, -1.5f * 6);
		contentStream.newLineAtOffset(0, -1.5f * 6);
	}

	protected void writeBodyHeader(PDPageContentStream contentStream, ReportGenerationMgr rgm, String label,
			String value, boolean skipColumnHeader) throws Exception {
		contentStream.showText(label + " " + value);
		contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
		
		if (!skipColumnHeader) {
			writeColumnHeader(contentStream, rgm);
		}
	}

	protected void writeColumnHeader(PDPageContentStream contentStream, ReportGenerationMgr rgm) throws Exception {
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getGlobalFieldValue(rgm, field));
				contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
			} else {
				if (field.isFirstField()) {
					contentStream.showText(String.format("%1$2s", "") + getGlobalFieldValue(rgm, field));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
			}
		}
	}

	protected void writeTrailerSummary(ReportGenerationMgr rgm, Map<String, String> groupingField,
			PDPageContentStream... streams) {
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = replaceTrailerQueryCriteria(rgm, groupingField);
		logger.debug("writeTrailerSummary: query={}", query);

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
					for (PDPageContentStream s : streams) {
						writeBodyTrailer(rgm, s, lineFieldsMap, extractTrailerFields(rgm));
					}
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the trailer query ", e);
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

	protected void writeRowData(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			Map<String, String> groupingField, String branchCode, PDPageContentStream... streams) throws Exception {

		Map<String, String> groupFieldToUpdate = new HashMap<>();
		for (PDPageContentStream contentStream : streams) {
			
			List<ReportGenerationFields> fields = extractBodyFields(rgm);
			
			for (Map.Entry<String, String> entry : groupingField.entrySet()) {
				ReportGenerationFields result = fields.stream()
						.filter(field -> entry.getKey().equals(field.getFieldName())).findAny().orElse(null);
				
				if (result != null) {
					String value = getFieldValue(rgm, result, fieldsMap).trim();
					logger.debug("-----field:{}", result.getFieldName());
					logger.debug("-----------field value:{}", value);
					logger.debug("group value:{}", entry.getValue());
					if (value != null && !value.equals(entry.getValue())) {
						logger.debug("write trailer summary.");
						writeTrailerSummary(rgm, groupingField, contentStream);
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
							writeBodyHeader(contentStream, rgm, field.getFieldName(), value, false);
						} else {
							writeBodyHeader(contentStream, rgm, field.getFieldName(), value, true);
						}

						groupFieldToUpdate.put(field.getFieldName(), value);
					}

				} else {
					if (field.isDecrypt()) {
						decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
					}

					if (field.isEol()) {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
						contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
				}
			}
		}

		groupingField.putAll(groupFieldToUpdate);
	}

	protected void writeBodyTrailer(ReportGenerationMgr rgm, PDPageContentStream contentStream,
			HashMap<String, ReportGenerationFields> fieldsMap, List<ReportGenerationFields> trailerFields)
			throws Exception {
		logger.debug("write body trailer.");
		for (ReportGenerationFields field : trailerFields) {
			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
			} else {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
			}
		}
		contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
		contentStream.newLineAtOffset(0, -DEFAULT_LEADING);
	}

	protected void endDocument(PDPageContentStream contentStream) throws Exception {
		contentStream.endText();
		contentStream.close();
	}

	protected void writeNoRecordFound(PDPageContentStream... streams) throws Exception {
		for (PDPageContentStream s : streams) {
			s.setFont(PDType1Font.COURIER, DEFAULT_FONT_SIZE);
			s.newLineAtOffset(0, -DEFAULT_LEADING);
			s.showText(ReportConstants.NO_RECORD);
		}
	}

	protected String getFileAbsolutePath(String rootPath, String category, String branchCode, String filePrefix,
			LocalDateTime txnStartDate, LocalDateTime txnEndDate) {
		String basePath = rootPath + File.separator + (branchCode == null ? "MAIN" : branchCode) + File.separator
				+ category;
		String prefix = branchCode == null ? filePrefix : (filePrefix + "_" + branchCode);
		String fileName = generateDateRangeOutputFileName(prefix, txnStartDate, txnEndDate, ReportConstants.PDF_FORMAT);
		return basePath + File.separator + fileName;

	}

	protected String writeFile(ReportGenerationMgr rgm, PDDocument doc, String branchCode) throws Exception {
		String fileAbsolutePath = getFileAbsolutePath(rgm.getFileBaseDirectory(), rgm.getReportCategory(), branchCode,
				rgm.getFileNamePrefix(), rgm.getTxnStartDate(), rgm.getReportTxnEndDate());

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

	protected String replaceTrailerQueryCriteria(ReportGenerationMgr rgm, Map<String, String> groupingField) {

		String originalQuery = rgm.getTrailerQuery();
		for (Map.Entry<String, String> entry : groupingField.entrySet()) {
			String placeHolder = entry.getKey();
			String value = entry.getValue();

			if (GROUP_FIELD_TERMINAL.equals(placeHolder) && value.length() > 4) {
				value = value.substring(0, 4);
				rgm.setTrailerQuery(rgm.getTrailerQuery().replace("{" + entry.getKey() + "}", "'" + value + "'"));
			} else {
				rgm.setTrailerQuery(rgm.getTrailerQuery().replace("{" + entry.getKey() + "}", "'" + entry.getValue() + "'"));
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
		return getBodyQuery(rgm);
	}

	protected String getLowestLevelGroupField() {
		return GROUP_FIELD_TERMINAL;
	}

}
