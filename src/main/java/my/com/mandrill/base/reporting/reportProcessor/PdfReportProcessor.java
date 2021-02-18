package my.com.mandrill.base.reporting.reportProcessor;

import java.io.File;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class PdfReportProcessor extends CsvReportProcessor implements IPdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(PdfReportProcessor.class);
	private String tmpTrailerQuery = null;
	private String onUsBodyQuery = null;
	private String acqBodyQuery = null;
	private String issBodyQuery = null;
	private String onUsTrailerQuery = null;
	private String acqTrailerQuery = null;
	private String issTrailerQuery = null;
	private String branchDetailBodyQuery = null;
	private String branchBodyQuery = null;
	private String bankBodyQuery = null;
	private String branchTrailerQuery = null;
	private String bankTrailerQuery = null;
	private String acquirerDebitBodyQuery = null;
	private String acquirerCreditBodyQuery = null;
	private String acquirerDebitTrailerQuery = null;
	private String acquirerCreditTrailerQuery = null;
	private String debitBodyQuery = null;
	private String creditBodyQuery = null;
	private String debitTrailerQuery = null;
	private String creditTrailerQuery = null;

	public String getTmpTrailerQuery() {
		return tmpTrailerQuery;
	}

	public void setTmpTrailerQuery(String tmpTrailerQuery) {
		this.tmpTrailerQuery = tmpTrailerQuery;
	}

	public String getOnUsBodyQuery() {
		return onUsBodyQuery;
	}

	public void setOnUsBodyQuery(String onUsBodyQuery) {
		this.onUsBodyQuery = onUsBodyQuery;
	}

	public String getAcqBodyQuery() {
		return acqBodyQuery;
	}

	public void setAcqBodyQuery(String acqBodyQuery) {
		this.acqBodyQuery = acqBodyQuery;
	}

	public String getIssBodyQuery() {
		return issBodyQuery;
	}

	public void setIssBodyQuery(String issBodyQuery) {
		this.issBodyQuery = issBodyQuery;
	}

	public String getOnUsTrailerQuery() {
		return onUsTrailerQuery;
	}

	public void setOnUsTrailerQuery(String onUsTrailerQuery) {
		this.onUsTrailerQuery = onUsTrailerQuery;
	}

	public String getAcqTrailerQuery() {
		return acqTrailerQuery;
	}

	public void setAcqTrailerQuery(String acqTrailerQuery) {
		this.acqTrailerQuery = acqTrailerQuery;
	}

	public String getIssTrailerQuery() {
		return issTrailerQuery;
	}

	public void setIssTrailerQuery(String issTrailerQuery) {
		this.issTrailerQuery = issTrailerQuery;
	}

	public String getBranchDetailBodyQuery() {
		return branchDetailBodyQuery;
	}

	public void setBranchDetailBodyQuery(String branchBodyQuery) {
		this.branchDetailBodyQuery = branchBodyQuery;
	}

	public String getBranchBodyQuery() {
		return branchBodyQuery;
	}

	public void setBranchBodyQuery(String branchBodyQuery) {
		this.branchBodyQuery = branchBodyQuery;
	}

	public String getBankBodyQuery() {
		return bankBodyQuery;
	}

	public void setBankBodyQuery(String bankBodyQuery) {
		this.bankBodyQuery = bankBodyQuery;
	}

	public String getBranchTrailerQuery() {
		return branchTrailerQuery;
	}

	public void setBranchTrailerQuery(String branchTrailerQuery) {
		this.branchTrailerQuery = branchTrailerQuery;
	}

	public String getBankTrailerQuery() {
		return bankTrailerQuery;
	}

	public void setBankTrailerQuery(String bankTrailerQuery) {
		this.bankTrailerQuery = bankTrailerQuery;
	}

	public String getAcquirerDebitBodyQuery() {
		return acquirerDebitBodyQuery;
	}

	public void setAcquirerDebitBodyQuery(String acquirerDebitBodyQuery) {
		this.acquirerDebitBodyQuery = acquirerDebitBodyQuery;
	}

	public String getAcquirerCreditBodyQuery() {
		return acquirerCreditBodyQuery;
	}

	public void setAcquirerCreditBodyQuery(String acquirerCreditBodyQuery) {
		this.acquirerCreditBodyQuery = acquirerCreditBodyQuery;
	}

	public String getAcquirerDebitTrailerQuery() {
		return acquirerDebitTrailerQuery;
	}

	public void setAcquirerDebitTrailerQuery(String acquirerDebitTrailerQuery) {
		this.acquirerDebitTrailerQuery = acquirerDebitTrailerQuery;
	}

	public String getAcquirerCreditTrailerQuery() {
		return acquirerCreditTrailerQuery;
	}

	public void setAcquirerCreditTrailerQuery(String acquirerCreditTrailerQuery) {
		this.acquirerCreditTrailerQuery = acquirerCreditTrailerQuery;
	}

	public String getDebitBodyQuery() {
		return debitBodyQuery;
	}

	public void setDebitBodyQuery(String debitBodyQuery) {
		this.debitBodyQuery = debitBodyQuery;
	}

	public String getCreditBodyQuery() {
		return creditBodyQuery;
	}

	public void setCreditBodyQuery(String creditBodyQuery) {
		this.creditBodyQuery = creditBodyQuery;
	}

	public String getDebitTrailerQuery() {
		return debitTrailerQuery;
	}

	public void setDebitTrailerQuery(String debitTrailerQuery) {
		this.debitTrailerQuery = debitTrailerQuery;
	}

	public String getCreditTrailerQuery() {
		return creditTrailerQuery;
	}

	public void setCreditTrailerQuery(String creditTrailerQuery) {
		this.creditTrailerQuery = creditTrailerQuery;
	}

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		// To be overriden
	}

	protected void saveFile(ReportGenerationMgr rgm, PDDocument doc) {
		logger.debug("In PdfReportProcessor.saveFile()");

		String fileLocation = rgm.getFileLocation();
		String txnDate = null;

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

					String fileFullPath = rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.PDF_FORMAT;
					doc.save(new File(fileFullPath));
					logger.info("New file generated in: {}", fileFullPath);
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception("Errors when generating " + rgm.getFileNamePrefix() + "_" + txnDate
						+ ReportConstants.PDF_FORMAT);
			}
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Error in saving " + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.PDF_FORMAT, e);
		}
	}

	protected void saveFile(ReportGenerationMgr rgm, PDDocument doc, String branchCode) {
		logger.debug("In PdfReportProcessor.saveFile()");
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
		List<String> reportPaths = new ArrayList<>();

		// for branch report, report need to populate in both MAIN and branch folder
		String mainFileLocation = rgm.getFileLocation();
		String branchFileLocation = rgm.getFileBaseDirectory() + File.separator + branchCode + File.separator + rgm.getReportCategory() + File.separator;

		reportPaths.add(mainFileLocation);
		reportPaths.add(branchFileLocation);

		String txnDate = null;

		try {
			if (rgm.isGenerate() == true) {
				txnDate = rgm.getFileDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
			} else {
				txnDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
			}

			if (rgm.errors == 0) {
				for(String fileLocation: reportPaths) {
					if (fileLocation != null) {
						File directory = new File(fileLocation);
						if (!directory.exists()) {
							directory.mkdirs();
						}
						String fileFullPath = fileLocation + rgm.getFileNamePrefix() + "_" + branchCode + "_" + txnDate + ReportConstants.PDF_FORMAT;
						doc.save(new File(fileFullPath));
						logger.info("New file generated in: {}", fileFullPath);

					} else {
						throw new Exception("Path is not configured.");
					}
				}				
			} else {
				throw new Exception("Errors when generating " + rgm.getFileNamePrefix() + "_" + branchCode + "_"
						+ txnDate + ReportConstants.PDF_FORMAT);
			}
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Error in saving " + rgm.getFileNamePrefix() + "_" + branchCode + "_" + txnDate
					+ ReportConstants.PDF_FORMAT, e);
		}
	}

	protected List<String> filterByGlDescription(ReportGenerationMgr rgm) {
		logger.debug("In PdfReportProcessor.filterByGlDescription()");
		String tranParticular = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		List<String> descriptionList = new ArrayList<>();
		rgm.setBodyQuery(getCriteriaQuery());
		String query = getBodyQuery(rgm);
		logger.info("Query to filter gl description: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when getting result", e);
							continue;
						}
						if (result != null) {
							if (key.equalsIgnoreCase(ReportConstants.DESCRIPTION)) {
								tranParticular = result.toString();
							}
						}
					}
					descriptionList.add(tranParticular);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the criteria", e);
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
		return descriptionList;
	}

	protected SortedSet<String> filterByBranchCode(ReportGenerationMgr rgm) {
		logger.debug("In PdfReportProcessor.filterByBranchCode()");
		String branchCode = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedSet<String> branchCodeList = new TreeSet<>();
		rgm.setBodyQuery(getAcquirerCreditBodyQuery().indexOf("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}") != 0
				? getAcquirerCreditBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
						: "");
		String query = getBodyQuery(rgm);
		logger.info("Query to filter branch code: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when getting result", e);
							continue;
						}
						if (result != null) {
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
								branchCode = result.toString();
							}
						}
					}
					branchCodeList.add(branchCode);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the criteria", e);
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
		return branchCodeList;
	}

	protected void writePdfHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading,
			int pagination) throws IOException, JSONException {
		logger.debug("In PdfReportProcessor.writePdfHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					contentStream.showText(String.valueOf(pagination));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				contentStream.showText(getGlobalFieldValue(rgm, field));
			}
		}
	}

	protected void writePdfHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading,
			int pagination, String branchCode, String branchName) throws IOException, JSONException {
		logger.debug("In PdfReportProcessor.writePdfHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					contentStream.showText(String.valueOf(pagination));
				} else {
					contentStream.showText(getGlobalFieldValue(rgm, field));
				}
				contentStream.newLineAtOffset(0, -leading);
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
	}

	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In PdfReportProcessor.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getGlobalFieldValue(rgm, field));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				contentStream.showText(getGlobalFieldValue(rgm, field));
			}
		}
	}

	protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
					throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
			}
		}
	}

	protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, String txnQualifier, String voidCode)
					throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.COMMENT)) {
					if (!getFieldValue(field, fieldsMap).trim().equalsIgnoreCase(ReportConstants.APPROVED)) {
						contentStream.showText(String.format("%1$5s", "") + getFieldValue(field, fieldsMap));
					} else if (txnQualifier.equals("R")
							&& getFieldValue(field, fieldsMap).trim().equalsIgnoreCase(ReportConstants.APPROVED)) {
						contentStream.showText(String.format("%1$5s", "")
								+ String.format("%1$-" + field.getPdfLength() + "s", ReportConstants.FULL_REVERSAL));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					}
				} else {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.AMOUNT:
					if (!voidCode.equals("0")) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					}
					break;
				default:
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					break;
				}
			}
		}
	}
	
	protected void writeEmptyPdfBody(PDPageContentStream contentStream, float leading)
					throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		contentStream.showText(" **NO TRANSACTIONS FOR THE DAY** ");
		contentStream.newLineAtOffset(0, -leading);
	}

	protected void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
					throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In PdfReportProcessor.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
			}
		}
	}

	protected void executePdfTrailerQuery(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream,
			PDRectangle pageSize, float leading, float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In PdfReportProcessor.executePdfTrailerQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

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
					writePdfTrailer(rgm, lineFieldsMap, contentStream, leading);
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
}
