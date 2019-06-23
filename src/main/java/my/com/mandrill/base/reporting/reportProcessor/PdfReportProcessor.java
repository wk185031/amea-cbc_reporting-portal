package my.com.mandrill.base.reporting.reportProcessor;

import java.io.File;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
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
	private String issBodyQuery = null;
	private String onUsTrailerQuery = null;
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
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
		String fileLocation = rgm.getFileLocation();
		String txnDate = null;

		try {
			if (rgm.isGenerate() == true) {
				txnDate = df.format(rgm.getFileDate());
			} else {
				txnDate = df.format(rgm.getYesterdayDate());
			}

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}
					doc.save(new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate
							+ ReportConstants.PDF_FORMAT));
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception("Errors when generating" + rgm.getFileNamePrefix() + "_" + txnDate
						+ ReportConstants.PDF_FORMAT);
			}
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Error in saving " + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.PDF_FORMAT, e);
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
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$-" + field.getPdfLength() + "s", getGlobalFieldValue(field, true)));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$-" + field.getPdfLength() + "s", getGlobalFieldValue(field, true)));
				}
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
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$-" + field.getPdfLength() + "s", getGlobalFieldValue(field, true)));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", branchCode));
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", branchName));
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$-" + field.getPdfLength() + "s", getGlobalFieldValue(field, true)));
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
				if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				}
			}
		}
	}

	protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
					contentStream.showText(String.format("%" + field.getPdfLength() + "s",
							String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true)))));
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				}
			}
		}
	}

	protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, String txnQualifier, String voidCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.COMMENT)) {
					if (!getFieldValue(field, fieldsMap, true).equalsIgnoreCase(ReportConstants.APPROVED)) {
						contentStream.showText(String.format("%1$5s", "") + String
								.format("%1$-" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
					} else if (txnQualifier.equals("R")
							&& getFieldValue(field, fieldsMap, true).equalsIgnoreCase(ReportConstants.APPROVED)) {
						contentStream.showText(String.format("%1$5s", "")
								+ String.format("%1$-" + field.getPdfLength() + "s", ReportConstants.FULL_REVERSAL));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					}
					contentStream.newLineAtOffset(0, -leading);
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
					contentStream.newLineAtOffset(0, -leading);
				}
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.ATM_CARD_NUMBER:
					if (getFieldValue(field, fieldsMap, true).length() <= 19) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", String
								.format("%1$" + 19 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				case ReportConstants.SEQ_NUMBER:
				case ReportConstants.TRACE_NUMBER:
					if (getFieldValue(field, fieldsMap, true).length() <= 6) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", String
								.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				case ReportConstants.ACCOUNT:
					if (getFieldValue(field, fieldsMap, true).length() <= 16) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", String
								.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				case ReportConstants.AMOUNT:
					if (!voidCode.equals("0")) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				case ReportConstants.VOID_CODE:
					if (getFieldValue(field, fieldsMap, true).length() <= 3) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", String
								.format("%1$" + 3 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				default:
					if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				}
			}
		}
	}

	protected void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In PdfReportProcessor.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
							getFieldValue(field, fieldsMap, true).charAt(0)));
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				}
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				}
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