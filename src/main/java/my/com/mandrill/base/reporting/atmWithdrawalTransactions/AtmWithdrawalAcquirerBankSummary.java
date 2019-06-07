package my.com.mandrill.base.reporting.atmWithdrawalTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.GeneralReportProcess;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class AtmWithdrawalAcquirerBankSummary extends GeneralReportProcess {

	private final Logger logger = LoggerFactory.getLogger(AtmWithdrawalAcquirerBankSummary.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int success = 0;
	private int pagination = 0;
	private boolean branchDetails = false;
	private boolean bankDetails = false;
	private String branchDetailBodyQuery = null;
	private String branchBodyQuery = null;
	private String bankBodyQuery = null;
	private String branchTrailerQuery = null;
	private String bankTrailerQuery = null;
	private String criteriaQuery = null;

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

	public String getCriteriaQuery() {
		return criteriaQuery;
	}

	public void setCriteriaQuery(String criteriaQuery) {
		this.criteriaQuery = criteriaQuery;
	}

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.processPdfRecord()");
		PDDocument doc = null;
		String txnDate = null;
		pagination = 1;
		try {
			doc = new PDDocument();
			PDPage page = new PDPage();
			doc.addPage(page);
			PDPageContentStream contentStream = new PDPageContentStream(doc, page);
			PDFont pdfFont = PDType1Font.COURIER;
			float fontSize = 6;
			float leading = 1.5f * fontSize;
			PDRectangle pageSize = page.getMediaBox();
			float margin = 30;
			float width = pageSize.getWidth() - 2 * margin;
			float startX = pageSize.getLowerLeftX() + margin;
			float startY = pageSize.getUpperRightY() - margin;
			String branchCode = null;
			String branchName = null;
			String terminal = null;

			separateQuery(rgm);
			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			bankDetails = false;
			writePdfHeader(rgm, contentStream, leading, pagination);
			pageHeight += 4;
			writeBranchPdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;

			for (SortedMap.Entry<String, Map<String, Set<String>>> branchCodeMap : filterByCriteria(rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, Set<String>> branchNameMap : branchCodeMap.getValue().entrySet()) {
					branchDetails = true;
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, branchName, terminal);
					rgm.setBodyQuery(getBranchDetailBodyQuery());
					contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
							startY, pdfFont, fontSize, branchDetails, bankDetails);
					pageHeight += 1;
					for (String terminalMap : branchNameMap.getValue()) {
						branchDetails = false;
						terminal = terminalMap;
						rgm.setBodyQuery(getBranchBodyQuery());
						preProcessing(rgm, branchCode, branchName, terminal);
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, branchDetails, bankDetails);
						pageHeight += 1;
					}
				}
			}
			rgm.setTrailerQuery(getBranchTrailerQuery());
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize,
					bankDetails);
			pageHeight += 1;
			contentStream.newLineAtOffset(0, -leading);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream
					.showText("                                                        " + "*** END OF REPORT ***");
			contentStream.endText();
			contentStream.close();

			bankDetails = true;
			pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
			page = new PDPage();
			doc.addPage(page);
			pagination++;
			contentStream = new PDPageContentStream(doc, page);
			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);
			writePdfHeader(rgm, contentStream, leading, pagination);
			pageHeight += 4;
			writeBankPdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;
			rgm.setBodyQuery(getBankBodyQuery());
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize, branchDetails, bankDetails);
			rgm.setTrailerQuery(getBankTrailerQuery());
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize,
					bankDetails);
			pageHeight += 1;
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream
					.showText("                                                        " + "*** END OF REPORT ***");

			contentStream.endText();
			contentStream.close();

			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String fileLocation = rgm.getFileLocation();

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
					throw new Exception("Path: " + fileLocation + " not configured.");
				}
			} else {
				throw new Exception("Errors when generating" + rgm.getFileNamePrefix() + "_" + txnDate
						+ ReportConstants.PDF_FORMAT);
			}
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.PDF_FORMAT,
					e);
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
	public void processCsvTxtRecord(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.processCsvTxtRecord()");
		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);

		try {
			if (rgm.isGenerate() == true) {
				txnDate = df.format(rgm.getFileDate());
			} else {
				txnDate = df.format(rgm.getYesterdayDate());
			}

			if (rgm.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_CSV)) {
				if (rgm.errors == 0) {
					if (fileLocation != null) {
						File directory = new File(fileLocation);
						if (!directory.exists()) {
							directory.mkdirs();
						}
						file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate
								+ ReportConstants.CSV_FORMAT);
						pagination = 1;
						execute(rgm, file);
					} else {
						throw new Exception("Path: " + fileLocation + " not configured.");
					}
				} else {
					throw new Exception("Errors when generating" + rgm.getFileNamePrefix() + "_" + txnDate
							+ ReportConstants.CSV_FORMAT);
				}
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.CSV_FORMAT,
					e);
		}
	}

	private void execute(ReportGenerationMgr rgm, File file) {
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		StringBuilder branchLine = new StringBuilder();
		StringBuilder bankLine = new StringBuilder();
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			bankDetails = false;
			preProcessing(rgm);
			writeHeader(rgm);
			writeBranchBodyHeader(rgm);
			for (SortedMap.Entry<String, Map<String, Set<String>>> branchCodeMap : filterByCriteria(rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, Set<String>> branchNameMap : branchCodeMap.getValue().entrySet()) {
					branchDetails = true;
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, branchName, terminal);
					rgm.setBodyQuery(getBranchDetailBodyQuery());
					executeBodyQuery(rgm, bankDetails);
					for (String terminalMap : branchNameMap.getValue()) {
						branchDetails = false;
						terminal = terminalMap;
						rgm.setBodyQuery(getBranchBodyQuery());
						preProcessing(rgm, branchCode, branchName, terminal);
						executeBodyQuery(rgm, bankDetails);
					}
				}
			}
			rgm.setTrailerQuery(getBranchTrailerQuery());
			executeTrailerQuery(rgm, bankDetails);
			branchLine.append("*** END OF REPORT ***");
			branchLine.append(getEol());
			branchLine.append(getEol());
			rgm.writeLine(branchLine.toString().getBytes());

			bankDetails = true;
			bankLine.append(getEol());
			pagination++;
			writeHeader(rgm);
			writeBankBodyHeader(rgm);
			rgm.setBodyQuery(getBankBodyQuery());
			executeBodyQuery(rgm, bankDetails);
			rgm.setTrailerQuery(getBankTrailerQuery());
			executeTrailerQuery(rgm, bankDetails);
			bankLine.append("*** END OF REPORT ***");
			bankLine.append(getEol());
			bankLine.append(getEol());
			rgm.writeLine(bankLine.toString().getBytes());

			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in generating CSV/TXT file", e);
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

	private SortedMap<String, Map<String, Set<String>>> filterByCriteria(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.filterByCriteria()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, Set<String>>> criteriaMap = new TreeMap<>();
		rgm.setBodyQuery(getCriteriaQuery());
		String query = getBodyQuery(rgm);
		logger.info("Query for filter criteria: {}", query);

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
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								branchName = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.TERMINAL)) {
								terminal = result.toString();
							}
						}
					}
					if (criteriaMap.get(branchCode) == null) {
						Map<String, Set<String>> tmpCriteriaMap = new HashMap<>();
						Set<String> terminalList = new HashSet<>();
						terminalList.add(terminal);
						tmpCriteriaMap.put(branchName, terminalList);
						criteriaMap.put(branchCode, tmpCriteriaMap);
					} else {
						Map<String, Set<String>> tmpCriteriaMap = criteriaMap.get(branchCode);
						if (tmpCriteriaMap.get(branchName) == null) {
							Set<String> terminalList = new HashSet<>();
							terminalList.add(terminal);
							tmpCriteriaMap.put(branchName, terminalList);
						} else {
							Set<String> terminalList = tmpCriteriaMap.get(branchName);
							terminalList.add(terminal);
						}
					}
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
		return criteriaMap;
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setBranchBodyQuery(
					rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setBankBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setBranchDetailBodyQuery(getBranchBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", "")
					.replace("AST.AST_TERMINAL_ID \"TERMINAL\",", "").replace("\"TERMINAL\",", "")
					.replace("\"TERMINAL\" ASC", "")
					.replace(
							getBranchBodyQuery().substring(getBranchBodyQuery().indexOf("GROUP BY"),
									getBranchBodyQuery().indexOf("ORDER BY")),
							"GROUP BY \"BRANCH CODE\", \"BRANCH NAME\" ")
					.replace("\"BRANCH NAME\" ASC,", "\"BRANCH NAME\" ASC"));
			setCriteriaQuery(getBranchBodyQuery());
		}
		if (rgm.getTrailerQuery() != null) {
			setBranchTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setBankTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_NAME + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
		}

		if (rgm.isGenerate() == true) {
			String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnStartDate())
					.concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnEndDate()).concat(" ")
					.concat(ReportConstants.END_TIME);

			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		} else {
			String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getYesterdayDate())
					.concat(" ").concat(ReportConstants.START_TIME);
			String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTodayDate()).concat(" ")
					.concat(ReportConstants.END_TIME);

			ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
							+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
							+ ReportConstants.FORMAT_TXN_DATE + "')");

			getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
		}
		addPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByBranchName,
			String filterByTerminal) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.preProcessing()");
		if (filterByBranchCode != null && filterByBranchName != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			ReportGenerationFields branchName = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_NAME,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_NAME) = '" + filterByBranchName + "'");

			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			getGlobalFileFieldsMap().put(branchName.getFieldName(), branchName);
		}

		if (filterByTerminal != null) {
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "TRIM(AST.AST_TERMINAL_ID) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}

	private void addPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.addPreProcessingFieldsToGlobalMap()");
		ReportGenerationFields todaysDateValue = new ReportGenerationFields(ReportConstants.TODAYS_DATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields runDateValue = new ReportGenerationFields(ReportConstants.RUNDATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields timeValue = new ReportGenerationFields(ReportConstants.TIME_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));

		getGlobalFileFieldsMap().put(todaysDateValue.getFieldName(), todaysDateValue);
		getGlobalFileFieldsMap().put(runDateValue.getFieldName(), runDateValue);
		getGlobalFileFieldsMap().put(timeValue.getFieldName(), timeValue);

		if (rgm.isGenerate() == true) {
			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getTxnEndDate().getTime()));
			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
		} else {
			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getYesterdayDate().getTime()));
			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
		}
	}

	private void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeHeader()");
		addPreProcessingFieldsToGlobalMap(rgm);
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					line.append(pagination);
					line.append(field.getDelimiter());
					line.append(getEol());
				} else if (getGlobalFieldValue(field, true) == null) {
					line.append("");
					line.append(field.getDelimiter());
					line.append(getEol());
				} else {
					line.append(getGlobalFieldValue(field, true));
					line.append(field.getDelimiter());
					line.append(getEol());
				}
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					line.append("");
					line.append(field.getDelimiter());
				} else {
					line.append(getGlobalFieldValue(field, true));
					line.append(field.getDelimiter());
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writePdfHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading,
			int pagination) throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writePdfHeader()");
		addPreProcessingFieldsToGlobalMap(rgm);
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					contentStream.showText(String.valueOf(pagination));
					contentStream.newLineAtOffset(0, -leading);
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(
							String.format("%1$-" + field.getPdfLength() + "s", getGlobalFieldValue(field, true)));
					contentStream.newLineAtOffset(0, -leading);
				}
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

	private void writeBranchBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBranchBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 7:
			case 8:
			case 9:
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
				break;
			default:
				line.append(getGlobalFieldValue(field, true));
				line.append(field.getDelimiter());
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBankBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBankBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 19:
			case 20:
			case 21:
			case 22:
				line.append(getGlobalFieldValue(field, true));
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBranchPdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBranchPdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
				break;
			default:
				if (field.isEol()) {
					if (getGlobalFieldValue(field, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						contentStream
								.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
						contentStream.newLineAtOffset(0, -leading);
					}
				} else {
					if (getGlobalFieldValue(field, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream
								.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
					}
				}
				break;
			}
		}
	}

	private void writeBankPdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBankPdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
				if (field.isEol()) {
					if (getGlobalFieldValue(field, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						contentStream
								.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
						contentStream.newLineAtOffset(0, -leading);
					}
				} else {
					if (getGlobalFieldValue(field, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream
								.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
					}
				}
				break;
			default:
				break;
			}
		}
	}

	private void writeBranchBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 24:
			case 25:
			case 26:
			case 27:
				break;
			default:
				if (branchDetails) {
					if (!field.getFieldName().equalsIgnoreCase(ReportConstants.TERMINAL)
							&& !field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
						if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
							line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
							line.append(field.getDelimiter());
						} else if (getFieldValue(field, fieldsMap, true) == null) {
							line.append("");
							line.append(field.getDelimiter());
						} else {
							line.append(getFieldValue(field, fieldsMap, true));
							line.append(field.getDelimiter());
						}
					} else {
						line.append("");
						line.append(field.getDelimiter());
					}
				} else {
					if (!field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)
							&& !field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
						if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
							line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
							line.append(field.getDelimiter());
						} else if (getFieldValue(field, fieldsMap, true) == null) {
							line.append("");
							line.append(field.getDelimiter());
						} else {
							line.append(getFieldValue(field, fieldsMap, true));
							line.append(field.getDelimiter());
						}
					} else {
						line.append("");
						line.append(field.getDelimiter());
					}
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBankBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 24:
			case 25:
			case 26:
			case 27:
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.NET_SETTLEMENT)) {
					line.append(getFieldValue(field, fieldsMap, true) + " DR");
					line.append(field.getDelimiter());
				} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
					line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
					line.append(field.getDelimiter());
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					line.append("");
					line.append(field.getDelimiter());
				} else {
					line.append(getFieldValue(field, fieldsMap, true));
					line.append(field.getDelimiter());
				}
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBranchPdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, boolean branchDetails)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 24:
			case 25:
			case 26:
			case 27:
				break;
			default:
				if (field.isEol()) {
					if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
						contentStream.newLineAtOffset(0, -leading);
					}
				} else {
					if (branchDetails) {
						if (!field.getFieldName().equalsIgnoreCase(ReportConstants.TERMINAL)
								&& !field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
							if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)
									|| field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s",
										getFieldValue(field, fieldsMap, true)));
							} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
								contentStream.showText(String.format("%" + field.getPdfLength() + "s",
										String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true)))));
							} else if (getFieldValue(field, fieldsMap, true) == null) {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
							} else {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										getFieldValue(field, fieldsMap, true)));
							}
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						}
					} else {
						if (!field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)
								&& !field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
							if (field.getFieldName().equalsIgnoreCase(ReportConstants.TERMINAL)
									|| field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s",
										getFieldValue(field, fieldsMap, true)));
							} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
								contentStream.showText(String.format("%" + field.getPdfLength() + "s",
										String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true)))));
							} else if (getFieldValue(field, fieldsMap, true) == null) {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
							} else {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										getFieldValue(field, fieldsMap, true)));
							}
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						}
					}
				}
				break;
			}
		}
	}

	private void writeBankPdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 24:
			case 25:
			case 26:
			case 27:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.NET_SETTLEMENT)) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true) + " DR"));
						contentStream.newLineAtOffset(0, -leading);
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
						contentStream.newLineAtOffset(0, -leading);
					}
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.BANK_CODE)
							|| field.getFieldName().equalsIgnoreCase(ReportConstants.BANK_NAME)) {
						contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
						contentStream.showText(String.format("%" + field.getPdfLength() + "s",
								String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true)))));
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
				}
				break;
			default:
				break;
			}
		}
	}

	private void executeBodyQuery(ReportGenerationMgr rgm, boolean bankDetails) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

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
					if (bankDetails) {
						writeBankBody(rgm, lineFieldsMap);
					} else {
						writeBranchBody(rgm, lineFieldsMap);
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

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, boolean branchDetails, boolean bankDetails) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.executePdfBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					if (pageHeight > totalHeight) {
						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
						contentStream.endText();
						contentStream.close();
						page = new PDPage();
						doc.addPage(page);
						pagination++;
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
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
								field.setValue(Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					if (bankDetails) {
						writeBankPdfBody(rgm, lineFieldsMap, contentStream, leading);
					} else {
						writeBranchPdfBody(rgm, lineFieldsMap, contentStream, leading, branchDetails);
					}
					success++;
					pageHeight++;
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

	private void writeBranchTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBranchTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		String total = null;
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
				break;
			default:
				if (field.isEol()) {
					if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
						line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
						line.append(field.getDelimiter());
						line.append(getEol());
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						line.append("");
						line.append(field.getDelimiter());
						line.append(getEol());
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
						line.append(field.getDelimiter());
						line.append(getEol());
					}
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
						total = getFieldValue(field, fieldsMap, true);
					}
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
						line.append(total);
						line.append(field.getDelimiter());
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						line.append("");
						line.append(field.getDelimiter());
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
						line.append(field.getDelimiter());
					}
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBankTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBankTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 17:
			case 18:
			case 19:
			case 20:
				if (field.isEol()) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.NET_SETTLEMENT)) {
						line.append(getFieldValue(field, fieldsMap, true) + " DR");
						line.append(field.getDelimiter());
					} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
						line.append(String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true))));
						line.append(field.getDelimiter());
						line.append(getEol());
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						line.append("");
						line.append(field.getDelimiter());
						line.append(getEol());
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
						line.append(field.getDelimiter());
						line.append(getEol());
					}
				} else {
					if (getFieldValue(field, fieldsMap, true) == null) {
						line.append("");
						line.append(field.getDelimiter());
					} else {
						line.append(getFieldValue(field, fieldsMap, true));
						line.append(field.getDelimiter());
					}
				}
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBranchPdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBranchPdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		String total = null;
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
				break;
			default:
				if (field.isEol()) {
					if (field.getFieldName().contains(ReportConstants.LINE)) {
						contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
								getFieldValue(field, fieldsMap, true).charAt(0)));
						contentStream.newLineAtOffset(0, -leading);
					} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
						contentStream.showText(String.format("%" + field.getPdfLength() + "s",
								String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true)))));
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
						contentStream.newLineAtOffset(0, -leading);
					}
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.AR_PER_TERMINAL)) {
						total = getFieldValue(field, fieldsMap, true);
					}
					if (field.getFieldName().contains(ReportConstants.LINE)) {
						contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
								getFieldValue(field, fieldsMap, true).charAt(0)));
					} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL)) {
						contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL_AR_AMOUNT)) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", total));
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
				}
				break;
			}
		}
	}

	private void writeBankPdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.writeBankPdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
			case 19:
			case 20:
				if (field.isEol()) {
					if (field.getFieldName().contains(ReportConstants.LINE)) {
						contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
								getFieldValue(field, fieldsMap, true).charAt(0)));
						contentStream.newLineAtOffset(0, -leading);
					} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.NET_SETTLEMENT)) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true) + " DR"));
						contentStream.newLineAtOffset(0, -leading);
					} else if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
						contentStream.showText(String.format("%" + field.getPdfLength() + "s",
								String.format("%,d", Integer.parseInt(getFieldValue(field, fieldsMap, true)))));
						contentStream.newLineAtOffset(0, -leading);
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
						contentStream.newLineAtOffset(0, -leading);
					}
				} else {
					if (field.getFieldName().contains(ReportConstants.LINE)) {
						contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
								getFieldValue(field, fieldsMap, true).charAt(0)));
					} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.TOTAL)) {
						contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
				}
				break;
			default:
				break;
			}
		}
	}

	private void executeTrailerQuery(ReportGenerationMgr rgm, boolean bankDetails) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.executeTrailerQuery()");
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
					if (bankDetails) {
						writeBankTrailer(rgm, lineFieldsMap);
					} else {
						writeBranchTrailer(rgm, lineFieldsMap);
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

	private void executePdfTrailerQuery(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream,
			PDRectangle pageSize, float leading, float startX, float startY, PDFont pdfFont, float fontSize,
			boolean bankDetails) {
		logger.debug("In AtmWithdrawalAcquirerBankSummary.executePdfTrailerQuery()");
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
					if (bankDetails) {
						writeBankPdfTrailer(rgm, lineFieldsMap, contentStream, leading);
					} else {
						writeBranchPdfTrailer(rgm, lineFieldsMap, contentStream, leading);
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
}
