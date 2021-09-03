package my.com.mandrill.base.reporting.atmTransactionListsBranch;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPageContentStream;

import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.BranchReportProcessor;

public class ATMWithdrawalsSummaryReport extends BranchReportProcessor {
	
	private double overallTotalOnusOtherBranch = 0.00;
	private double overallTotalInterEntity = 0.00;
	private double overallTotalOtherBank = 0.00;
	private double overallTotalCashCard = 0.00;
	private double overallTotalMovingCashNow = 0.00;
	private double overallTotalMovingCashJump = 0.00;
	private double overallTotalSum = 0.00;

	@Override
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
	
	@Override
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
					
					overallTotalOnusOtherBranch += Double.parseDouble(lineFieldsMap.get("ON-US").getValue());
					overallTotalInterEntity += Double.parseDouble(lineFieldsMap.get("INTER-ENTITY").getValue());
					overallTotalOtherBank += Double.parseDouble(lineFieldsMap.get("OTHER BANKS").getValue());
					overallTotalCashCard += Double.parseDouble(lineFieldsMap.get("CASH CARD").getValue());
					overallTotalMovingCashNow += Double.parseDouble(lineFieldsMap.get("NOW").getValue());
					overallTotalMovingCashJump += Double.parseDouble(lineFieldsMap.get("JUMP").getValue());
					overallTotalSum += Double.parseDouble(lineFieldsMap.get("TOTAL").getValue());
										
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

	@Override
	public void executePdf(ReportGenerationMgr rgm) {
		List<String> writtenFilePath = new ArrayList<>();

		List<Branch> branches = getAllBranchByInstitution(rgm.getInstitution());

		PDDocument masterDoc = null;
		PDDocument branchDoc = null;

		PDPageContentStream masterStream = null;
		PDPageContentStream branchStream = null;

		DecimalFormat formatter=new DecimalFormat("#,##0.00");
		
		try {
			masterDoc = new PDDocument();

			PreparedStatement ps = null;
			ResultSet rs = null;
			addReportPreProcessingFieldsToGlobalMap(rgm);

			for (Branch b : branches) {
				logger.debug("Process transaction for branch={}", b.getAbr_code());
				
				overallTotalOnusOtherBranch = 0.00;
				overallTotalInterEntity = 0.00;
				overallTotalOtherBank = 0.00;
				overallTotalCashCard = 0.00;
				overallTotalMovingCashNow = 0.00;
				overallTotalMovingCashJump = 0.00;
				overallTotalSum = 0.00;

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
						
						// custom overall total
						writeText(rgm, branchDoc, branchStream, "OVER-ALL TOTAL                " +
								String.format("%18s", formatter.format(overallTotalOnusOtherBranch)) +
								String.format("%18s", formatter.format(overallTotalInterEntity)) +
								String.format("%18s", formatter.format(overallTotalOtherBank)) +
								String.format("%18s", formatter.format(overallTotalCashCard)) +
								String.format("%18s", formatter.format(overallTotalMovingCashNow)) +
								String.format("%18s", formatter.format(overallTotalMovingCashJump)) +
								String.format("%18s", formatter.format(overallTotalSum)),
								b.getAbr_code(), b.getAbr_name());
						writeText(rgm, masterDoc, masterStream, "OVER-ALL TOTAL                " +
								String.format("%18s", formatter.format(overallTotalOnusOtherBranch)) +
								String.format("%18s", formatter.format(overallTotalInterEntity)) +
								String.format("%18s", formatter.format(overallTotalOtherBank)) +
								String.format("%18s", formatter.format(overallTotalCashCard)) +
								String.format("%18s", formatter.format(overallTotalMovingCashNow)) +
								String.format("%18s", formatter.format(overallTotalMovingCashJump)) +
								String.format("%18s", formatter.format(overallTotalSum)),
								b.getAbr_code(), b.getAbr_name());
					}

					branchStream = endDocument(branchStream);
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
			masterStream = endDocument(masterStream);
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

	
}
