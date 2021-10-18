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
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDType1Font;

import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.BranchReportProcessor;

public class ATMWithdrawalsSummaryReport extends BranchReportProcessor {
	
	private double subTotalOnusOtherBranch = 0.00;
	private double subTotalInterEntity = 0.00;
	private double subTotalOtherBank = 0.00;
	private double subTotalCashCard = 0.00;
	private double subTotalMovingCashNow = 0.00;
	private double subTotalMovingCashJump = 0.00;
	private double subTotalSum = 0.00;
	private double overallTotalOnusOtherBranch = 0.00;
	private double overallTotalInterEntity = 0.00;
	private double overallTotalOtherBank = 0.00;
	private double overallTotalCashCard = 0.00;
	private double overallTotalMovingCashNow = 0.00;
	private double overallTotalMovingCashJump = 0.00;
	private double overallTotalSum = 0.00;
	
	DecimalFormat formatter = new DecimalFormat("#,##0.00");
	
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

			PreparedStatement ps = null;
			ResultSet rs = null;
			addReportPreProcessingFieldsToGlobalMap(rgm);

			for (Branch b : branches) {
				logger.debug("Process transaction for branch={}", b.getAbr_code());
				
				subTotalOnusOtherBranch = 0.00;
				subTotalInterEntity = 0.00;
				subTotalOtherBank = 0.00;
				subTotalCashCard = 0.00;
				subTotalMovingCashNow = 0.00;
				subTotalMovingCashJump = 0.00;
				subTotalSum = 0.00;

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
								
								subTotalOnusOtherBranch += Double.parseDouble(lineFieldsMap.get("ON-US").getValue());
								subTotalInterEntity += Double.parseDouble(lineFieldsMap.get("INTER-ENTITY").getValue());
								subTotalOtherBank += Double.parseDouble(lineFieldsMap.get("OTHER BANKS").getValue());
								subTotalCashCard += Double.parseDouble(lineFieldsMap.get("CASH CARD").getValue());
								subTotalMovingCashNow += Double.parseDouble(lineFieldsMap.get("NOW").getValue());
								subTotalMovingCashJump += Double.parseDouble(lineFieldsMap.get("JUMP").getValue());
								subTotalSum += Double.parseDouble(lineFieldsMap.get("TOTAL").getValue());
								
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
						
						writeText(rgm, branchDoc, branchStream, null, null, null);
						// custom overall total
						writeText(rgm, branchDoc, branchStream, "SUB TOTAL                     " +
								String.format("%18s", formatter.format(subTotalOnusOtherBranch)) +
								String.format("%18s", formatter.format(subTotalInterEntity)) +
								String.format("%18s", formatter.format(subTotalOtherBank)) +
								String.format("%18s", formatter.format(subTotalCashCard)) +
								String.format("%18s", formatter.format(subTotalMovingCashNow)) +
								String.format("%18s", formatter.format(subTotalMovingCashJump)) +
								String.format("%18s", formatter.format(subTotalSum)),
								b.getAbr_code(), b.getAbr_name());
						
						writeText(rgm, masterDoc, masterStream, null, null, null);
						writeText(rgm, masterDoc, masterStream, "SUB TOTAL                     " +
								String.format("%18s", formatter.format(subTotalOnusOtherBranch)) +
								String.format("%18s", formatter.format(subTotalInterEntity)) +
								String.format("%18s", formatter.format(subTotalOtherBank)) +
								String.format("%18s", formatter.format(subTotalCashCard)) +
								String.format("%18s", formatter.format(subTotalMovingCashNow)) +
								String.format("%18s", formatter.format(subTotalMovingCashJump)) +
								String.format("%18s", formatter.format(subTotalSum)),
								b.getAbr_code(), b.getAbr_name());
						
						overallTotalOnusOtherBranch += subTotalOnusOtherBranch;
						overallTotalInterEntity += subTotalInterEntity;
						overallTotalOtherBank += subTotalOtherBank;
						overallTotalMovingCashNow += subTotalMovingCashNow;
						overallTotalMovingCashJump += subTotalMovingCashJump;
						overallTotalSum += subTotalSum;
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
			
			// need new page for master to print overall total for all branches
			masterStream = newOverallTotalPage(masterDoc, masterStream, rgm);
			
			masterStream = endDocument(masterStream);
			masterStream = null;
			String masterDocPath = writeFile(rgm, masterDoc, null);
			writtenFilePath.add(masterDocPath);

		} catch (Exception e) {
			logger.error("Failed to generate report. Remove generated files.", e);
			cleanAllFilesOnError(writtenFilePath);
			writtenFilePath = new ArrayList<>();
			throw new ReportGenerationException("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
		}
	}
	
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
	
	protected PDPageContentStream newOverallTotalPage(PDDocument doc, PDPageContentStream contentStream, ReportGenerationMgr rgm) throws Exception {
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
		
		writeText(rgm, doc, contentStream, "OVER-ALL TOTAL                " +
				String.format("%18s", formatter.format(overallTotalOnusOtherBranch)) +
				String.format("%18s", formatter.format(overallTotalInterEntity)) +
				String.format("%18s", formatter.format(overallTotalOtherBank)) +
				String.format("%18s", formatter.format(overallTotalCashCard)) +
				String.format("%18s", formatter.format(overallTotalMovingCashNow)) +
				String.format("%18s", formatter.format(overallTotalMovingCashJump)) +
				String.format("%18s", formatter.format(overallTotalSum)),
				null, null);
		
		return contentStream;
	}
}
