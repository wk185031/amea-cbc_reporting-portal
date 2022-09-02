package my.com.mandrill.base.reporting.atmTransactionListsBranch;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPageContentStream;

import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.BranchReportProcessor;

public class ListOfATMWithdrawal extends BranchReportProcessor {

	@Override
	public void executePdf(ReportGenerationMgr rgm) throws ReportGenerationException {
		List<String> writtenFilePath = new ArrayList<>();

		List<Branch> branches = getAllBranchByInstitution(rgm.getInstitution());

		PDDocument masterDoc = null;
		PDDocument branchDoc = null;

		PDPageContentStream masterStream = null;
		PDPageContentStream branchStream = null;

		try {
			masterDoc = new PDDocument();

			addReportPreProcessingFieldsToGlobalMap(rgm);

			for (Branch b : branches) {
				logger.debug("Process transaction for branch={}", b.getAbr_code());

				PreparedStatement ps = null;
				ResultSet rs = null;

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
						ps = rgm.getConnection().prepareStatement(bodyQuery);
						rs = ps.executeQuery();
						fieldsMap = rgm.getQueryResultStructure(rs);
						lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
						ReportGenerationFields terminalField = null;

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
									if (getLowestLevelGroupField().equals(field.getFieldName())) {
										terminalField = field;
									}
								}

								if (!groupingField.containsKey(getLowestLevelGroupField())) {
									// First record for the branch
									groupingField.put(getLowestLevelGroupField(), terminalField.getValue());
									
									masterStream = writeBodyHeader(rgm, masterDoc, masterStream, terminalField.getFieldName(), terminalField.getValue(),
											b.getAbr_code(), b.getAbr_name(), false);
									if (branchStream != null) {
										branchStream = writeBodyHeader(rgm, branchDoc, branchStream, terminalField.getFieldName(), terminalField.getValue(),
												b.getAbr_code(), b.getAbr_name(), false);
									}						
									incrementLineCounter(getNoOfRowForBodyHeader());

									masterStream = writeColumnHeader(rgm, masterDoc, masterStream, b.getAbr_code(), b.getAbr_name());
									if (branchStream != null) {
										branchStream = writeColumnHeader(rgm, branchDoc, branchStream, b.getAbr_code(), b.getAbr_name());
									}	
									incrementLineCounter(getNoOfRowForColumnHeader());
								}  else if (groupingField.containsKey(getLowestLevelGroupField()) && !groupingField.get(getLowestLevelGroupField()).equals(terminalField.getValue())) {
									// For next terminal in same branch
									writeTrailerSummary(rgm, masterDoc, branchDoc, groupingField, b.getAbr_code(), b.getAbr_name(), masterStream,
											branchStream);
									
									masterStream = newPage(masterDoc, masterStream, rgm, b.getAbr_code(),
											b.getAbr_name());
									if (branchStream != null) {
										branchStream = newPage(branchDoc, branchStream, rgm, b.getAbr_code(),
												b.getAbr_name());
									}
									
									groupingField.put(getLowestLevelGroupField(), terminalField.getValue());
									
									masterStream = writeBodyHeader(rgm, masterDoc, masterStream, terminalField.getFieldName(), terminalField.getValue(),
											b.getAbr_code(), b.getAbr_name(), false);
									if (branchStream != null) {
										branchStream = writeBodyHeader(rgm, branchDoc, branchStream, terminalField.getFieldName(), terminalField.getValue(),
												b.getAbr_code(), b.getAbr_name(), false);
									}						
									incrementLineCounter(getNoOfRowForBodyHeader());

									masterStream = writeColumnHeader(rgm, masterDoc, masterStream, b.getAbr_code(), b.getAbr_name());
									if (branchStream != null) {
										branchStream = writeColumnHeader(rgm, branchDoc, branchStream, b.getAbr_code(), b.getAbr_name());
									}	
									incrementLineCounter(getNoOfRowForColumnHeader());
								}
								
								writeRowData(rgm, masterDoc, branchDoc, lineFieldsMap, groupingField, b.getAbr_code(),
										b.getAbr_name(), masterStream, branchStream);
								if (getLineCounter() >= getMaxLinePerPage()) {
									masterStream = newPage(masterDoc, masterStream, rgm, b.getAbr_code(),
											b.getAbr_name());
									if (branchStream != null) {
										branchStream = newPage(branchDoc, branchStream, rgm, b.getAbr_code(),
												b.getAbr_name());
									}
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
						writeTrailerSummary(rgm, masterDoc, branchDoc, groupingField, b.getAbr_code(), b.getAbr_name(),
								masterStream, branchStream);
					}

					if (branchStream != null) {
						branchStream = endDocument(branchStream);
						branchStream = null;
					}

					String branchDocPath = writeFile(rgm, branchDoc, b.getAbr_code());
					writtenFilePath.add(branchDocPath);
				} finally {
					rgm.cleanAllDbResource(ps, rs);
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
			throw new ReportGenerationException(
					"Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
		}
	}
	
	

	@Override
	protected void writeRowData(ReportGenerationMgr rgm, PDDocument masterDoc, PDDocument branchDoc,
			HashMap<String, ReportGenerationFields> fieldsMap, Map<String, String> groupingField, String branchCode,
			String branchName, PDPageContentStream masterStream, PDPageContentStream branchStream) throws Exception {
		
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (getLowestLevelGroupField().equals(field.getFieldName())) {
				continue;
			}
			setBody(true);
			setBodyHeader(false);
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			String fieldValue = getFieldValue(rgm, field, fieldsMap);
			if (field.isEol()) {
				masterStream = writeText(rgm, masterDoc, masterStream, fieldValue, branchCode, branchName);
				masterStream = writeText(rgm, masterDoc, masterStream, null, branchCode, branchName);

				if (branchStream != null) {
					branchStream = writeText(rgm, branchDoc, branchStream, fieldValue, branchCode, branchName);
					branchStream = writeText(rgm, branchDoc, branchStream, null, branchCode, branchName);
				}
				

				// Same counter for master and branch
				incrementLineCounter();
				incrementLineCounter();
			} else {
				masterStream = writeText(rgm, masterDoc, masterStream, fieldValue, branchCode, branchName);
				if (branchStream != null) {
					branchStream = writeText(rgm, branchDoc, branchStream, fieldValue, branchCode, branchName);
				}
				
			}
		}
	}

	/**
	 * Determine if the group field in current row is a new group compare to previous
	 * 
	 * @param rgm
	 * @param groupingField
	 * @param fieldsMap
	 * @param groupFieldName
	 * @return
	 * @throws Exception
	 */
	protected ReportGenerationFields getNewGroupField(ReportGenerationMgr rgm, Map<String, String> groupingField,
			HashMap<String, ReportGenerationFields> fieldsMap, String groupFieldName) throws Exception {

		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		ReportGenerationFields groupField = null;

		for (Map.Entry<String, String> entry : groupingField.entrySet()) {
			groupField = fields.stream().filter(field -> entry.getKey().equals(groupFieldName))
					.findAny().orElse(null);

			if (groupField != null) {
				String value = getFieldValue(rgm, groupField, fieldsMap).trim();
				if (value != null && !value.equals(entry.getValue())) {
					return groupField;
				}
			}
		}
		return groupField;
	}

}
