package my.com.mandrill.base.reporting.reportProcessor;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class BranchReportSplitFileProcessor extends BranchReportProcessor {

	protected final Logger logger = LoggerFactory.getLogger(BranchReportSplitFileProcessor.class);

	protected float DEFAULT_MARGIN = 30;

	protected float DEFAULT_FONT_SIZE = 6;

	protected float DEFAULT_LEADING = 1.5f * DEFAULT_FONT_SIZE;

	protected final String GROUP_FIELD_BRANCH = "BRANCH_CODE";

	protected final String GROUP_FIELD_TERMINAL = "TERMINAL";

	private int lineCounter = 0;

	@Override
	public void executePdf(ReportGenerationMgr rgm) throws ReportGenerationException {
		Queue<Branch> branchQueue = new LinkedList<>(getAllBranchByInstitution(rgm.getInstitution()));
		List<String> writtenFilePath = new ArrayList<>();

		PDDocument masterDoc = null;
		PDPageContentStream masterStream = null;

		addReportPreProcessingFieldsToGlobalMap(rgm);
		PreparedStatement ps = null;
		ResultSet rs = null;

		try {
			HashMap<String, ReportGenerationFields> fieldsMap = null;
			HashMap<String, ReportGenerationFields> lineFieldsMap = null;
			masterDoc = new PDDocument();

			String bodyQuery = replaceBodyQueryCriteria(rgm);
			if (bodyQuery != null && !bodyQuery.trim().isEmpty()) {
				logger.debug("Generate report with body Query = {}", bodyQuery);
				ps = rgm.getConnection().prepareStatement(bodyQuery);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
				String nextBranchCodeToWrite = null;
				Branch currentBranchFromQueue = null;
				boolean isFirstRecord = true;

				if (rs.next()) {
					do {
						for (String key : lineFieldsMap.keySet()) {
							ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
							Object result = rs.getObject(field.getSource());

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

						String currentBranch = rs.getString("BRANCH CODE");
						if (nextBranchCodeToWrite == null || !currentBranch.equals(nextBranchCodeToWrite)) {
							currentBranchFromQueue = branchQueue.poll();
							nextBranchCodeToWrite = currentBranch;
							isFirstRecord = true;
						}

						if (!nextBranchCodeToWrite.equals(currentBranchFromQueue.getAbr_code())) {
							do {
								logger.debug("write empty section for branch: {}",
										currentBranchFromQueue.getAbr_code());
								masterStream = newPage(masterDoc, masterStream, rgm,
										currentBranchFromQueue.getAbr_code(), currentBranchFromQueue.getAbr_name());
								writeNoRecordFound(masterStream);
								incrementLineCounter();
								currentBranchFromQueue = branchQueue.poll();
							} while (currentBranchFromQueue != null
									&& !currentBranchFromQueue.getAbr_code().equals(nextBranchCodeToWrite));
						}

						logger.debug("write record for branch: {}", nextBranchCodeToWrite);
						Map<String, String> groupingField = new HashMap<String, String>();
						groupingField.put(GROUP_FIELD_BRANCH, nextBranchCodeToWrite);
						if (isFirstRecord) {
							masterStream = newPage(masterDoc, masterStream, rgm,
									currentBranchFromQueue.getAbr_code(), currentBranchFromQueue.getAbr_name());
							isFirstRecord = false;
						}
						writeRowData(rgm, masterDoc, null, lineFieldsMap, groupingField,
								currentBranchFromQueue.getAbr_code(), currentBranchFromQueue.getAbr_name(),
								masterStream, null);
						if (getLineCounter() >= getMaxLinePerPage()) {
							masterStream = newPage(masterDoc, masterStream, rgm, currentBranchFromQueue.getAbr_code(),
									currentBranchFromQueue.getAbr_name());
						}

					} while (rs.next());

				} else {
					logger.debug("No records found. Write all empty");
					currentBranchFromQueue = branchQueue.poll();
					Map<String, String> groupingField = new HashMap<String, String>();
					groupingField.put(GROUP_FIELD_BRANCH, currentBranchFromQueue.getAbr_code());
					do {
						logger.debug("write no record found for: currentBranchFromQueue={}, nextBranchCodeToWrite={}",
								currentBranchFromQueue.getAbr_code(), nextBranchCodeToWrite);
						masterStream = newPage(masterDoc, masterStream, rgm, currentBranchFromQueue.getAbr_code(),
								currentBranchFromQueue.getAbr_name());
						writeNoRecordFound(masterStream);
						incrementLineCounter();
						currentBranchFromQueue = branchQueue.poll();
					} while (currentBranchFromQueue != null
							&& !currentBranchFromQueue.getAbr_code().equals(nextBranchCodeToWrite));
				}

				masterStream = endDocument(masterStream);
				masterStream = null;
				String masterDocPath = writeFile(rgm, masterDoc, null);
				writtenFilePath.add(masterDocPath);
			}

		} catch (Exception e) {
			logger.error("Failed to generate report. Remove generated files.", e);
			cleanAllFilesOnError(writtenFilePath);
			writtenFilePath = new ArrayList<>();
			throw new ReportGenerationException(
					"Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
		} finally {
			rgm.cleanAllDbResource(ps, rs);
			if (masterStream != null) {
				try {
					masterStream.close();
				} catch (Exception e) {
					logger.warn("Failed to close masterstream", e);
				}

			}
		}

	}

	protected String replaceBodyQueryCriteria(ReportGenerationMgr rgm) {
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

}
