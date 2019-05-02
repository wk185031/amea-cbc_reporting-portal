package my.com.mandrill.base.reporting.glHandoffFinalProofSheet;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

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

public class GLHandoffFinalProofSheetOnUs extends GeneralReportProcess {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffFinalProofSheetOnUs.class);

	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int errors = 0;
	private int pagination = 0;
	private String debitBodyQuery = null;
	private String creditBodyQuery = null;
	private String criteriaQuery = null;

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

	public String getCriteriaQuery() {
		return criteriaQuery;
	}

	public void setCriteriaQuery(String criteriaQuery) {
		this.criteriaQuery = criteriaQuery;
	}

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetOnUs.processPdfRecord()");
		PDDocument doc = null;
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

			separateDebitCreditQuery(rgm);
			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			writePdfHeader(rgm, contentStream, leading, pagination);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;

			Iterator<String> branchCodeItr = filterByCriteria(rgm).iterator();

			while (branchCodeItr.hasNext()) {
				branchCode = branchCodeItr.next();
				preProcessing(rgm, branchCode);
				rgm.setBodyQuery(getDebitBodyQuery());
				contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
						pdfFont, fontSize, branchCode);
				rgm.setBodyQuery(getCreditBodyQuery());
				contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
						pdfFont, fontSize, branchCode);
			}
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
			pageHeight += 1;
			contentStream.endText();
			contentStream.close();

			SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
			String txnDate = null;
			if (rgm.isGenerate() == true) {
				txnDate = df.format(rgm.getFileDate());
			} else {
				txnDate = df.format(rgm.getTxnEndDate());
			}
			doc.save(new File(
					rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.PDF_FORMAT));
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			logger.error("Error in generating PDF file", e);
		} finally {
			if (doc != null) {
				try {
					doc.close();
					rgm.exit();
				} catch (IOException e) {
					logger.error("Error in closing PDF file", e);
				}
			}
		}
	}

	@Override
	public void processCsvTxtRecord(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetOnUs.processCsvTxtRecord()");
		File file = null;
		String txnDate = null;
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);

		if (rgm.isGenerate() == true) {
			txnDate = df.format(rgm.getFileDate());
		} else {
			txnDate = df.format(rgm.getTxnEndDate());
		}

		Iterator<String> branchCodeItr = filterByCriteria(rgm).iterator();

		if (rgm.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_CSV)) {
			pagination = 1;
			file = new File(
					rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.CSV_FORMAT);
			execute(rgm, file, branchCodeItr);
		}
		if (rgm.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_TXT)) {
			pagination = 1;
			file = new File(
					rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.TXT_FORMAT);
			execute(rgm, file, branchCodeItr);
		}
	}

	private void execute(ReportGenerationMgr rgm, File file, Iterator<String> branchCodeItr) {
		String branchCode = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			while (branchCodeItr.hasNext()) {
				branchCode = branchCodeItr.next();
				preProcessing(rgm, branchCode);
				rgm.setBodyQuery(getDebitBodyQuery());
				executeBodyQuery(rgm, branchCode);
				rgm.setBodyQuery(getCreditBodyQuery());
				executeBodyQuery(rgm, branchCode);
			}
			executeTrailerQuery(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			logger.error("Error in generating CSV/TXT file", e);
		} finally {
			try {
				if (rgm.fileOutputStream != null) {
					rgm.fileOutputStream.close();
					rgm.exit();
				}
			} catch (IOException e) {
				logger.error("Error in closing fileOutputStream", e);
			}
		}
	}

	private SortedSet<String> filterByCriteria(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetOnUs.filterByCriteria()");
		String branchCode = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedSet<String> branchCodeList = new TreeSet<>();
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
							errors++;
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
				logger.error("Error trying to execute the query to get the criteria", e);
			} finally {
				try {
					ps.close();
					rs.close();
				} catch (SQLException e) {
					logger.error("Error closing DB resources", e);
				}
			}
		}
		return branchCodeList;
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffFinalProofSheetOnUs.preProcessing()");
		if (getCriteriaQuery() != null
				&& getCriteriaQuery().indexOf("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}") != 0) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}

		if (rgm.isGenerate() == true) {
			if (rgm.getTxnStartDate() != null && rgm.getTxnEndDate() != null) {
				String txnStart = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnStartDate())
						.concat(" ").concat(ReportConstants.START_TIME);
				String txnEnd = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01).format(rgm.getTxnEndDate())
						.concat(" ").concat(ReportConstants.END_TIME);

				ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
						ReportGenerationFields.TYPE_STRING,
						"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
								+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
								+ ReportConstants.FORMAT_TXN_DATE + "')");

				getGlobalFileFieldsMap().put(txnDate.getFieldName(), txnDate);
			} else {
				logger.debug("txnStartDate or txnEndDate is empty or null");
			}
		} else {
			// TBD
		}

		addPreProcessingFieldsToGlobalMap(rgm);
		performPreProcessingTransformations(getGlobalFileFieldsMap());
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffFinalProofSheetOnUs.preProcessing()");
		if (filterByBranchCode != null && getDebitBodyQuery() != null && getCreditBodyQuery() != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}
	}

	private void separateDebitCreditQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetOnUs.separateDebitCreditquery()");
		if (rgm.getBodyQuery() != null) {
			setDebitBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_START),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_END)));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_END, ""));
			setCriteriaQuery(getDebitBodyQuery());
		}
	}

	private void addPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetOnUs.addPreProcessingFieldsToGlobalMap()");
		if (rgm.isGenerate() == true) {
			if (rgm.getTxnStartDate() != null && rgm.getTxnEndDate() != null) {
				ReportGenerationFields todaysDateValue = new ReportGenerationFields(ReportConstants.TODAYS_DATE_VALUE,
						ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
				ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
						ReportGenerationFields.TYPE_DATE, Long.toString(rgm.getTxnEndDate().getTime()));
				ReportGenerationFields runDateValue = new ReportGenerationFields(ReportConstants.RUNDATE_VALUE,
						ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
				ReportGenerationFields timeValue = new ReportGenerationFields(ReportConstants.TIME_VALUE,
						ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
				getGlobalFileFieldsMap().put(todaysDateValue.getFieldName(), todaysDateValue);
				getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
				getGlobalFileFieldsMap().put(runDateValue.getFieldName(), runDateValue);
				getGlobalFileFieldsMap().put(timeValue.getFieldName(), timeValue);
			} else {
				logger.debug("\t\t txnStartDate or txnEndDate is empty or null");
			}
		} else {
			ReportGenerationFields todaysDateValue = new ReportGenerationFields(ReportConstants.TODAYS_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
			ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
			ReportGenerationFields runDateValue = new ReportGenerationFields(ReportConstants.RUNDATE_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
			ReportGenerationFields timeValue = new ReportGenerationFields(ReportConstants.TIME_VALUE,
					ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
			getGlobalFileFieldsMap().put(todaysDateValue.getFieldName(), todaysDateValue);
			getGlobalFileFieldsMap().put(asOfDateValue.getFieldName(), asOfDateValue);
			getGlobalFileFieldsMap().put(runDateValue.getFieldName(), runDateValue);
			getGlobalFileFieldsMap().put(timeValue.getFieldName(), timeValue);
		}
	}

	private void writeHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetOnUs.writeHeader()");
		addPreProcessingFieldsToGlobalMap(rgm);
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					line.append(String.valueOf(pagination));
					line.append(getEol());
				} else if (getGlobalFieldValue(field, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(
							String.format("%1$-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
					line.append(getEol());
				}
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(
							String.format("%1$-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetOnUs.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					line.append(String.format("%" + field.getCsvTxtLength() + "s", " ").replace(' ',
							field.getDefaultValue().charAt(0)));
				} else {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", field.getFieldName()));
					line.append(getEol());
				}
			} else {
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", field.getFieldName()));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap, int pagination,
			String branchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NUMBER)) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
						branchCode + getFieldValue(field, fieldsMap, true)));
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
				line.append(String.format("%1$5s", "")
						+ String.format("%1$-" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap, true)));
			} else if (getFieldValue(field, fieldsMap, true) == null) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
			} else {
				line.append(
						String.format("%1$" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap, true)));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetOnUs.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					line.append(String.format("%" + field.getCsvTxtLength() + "s", " ").replace(' ',
							getFieldValue(field, fieldsMap, true).charAt(0)));
					line.append(getEol());
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					line.append(getEol());
				} else {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
					line.append(getEol());
				}
			} else {
				if (getFieldValue(field, fieldsMap, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writePdfHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading,
			int pagination) throws IOException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetOnUs.writePdfHeader()");
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

	private void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetOnUs.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
							field.getDefaultValue().charAt(0)));
					contentStream.newLineAtOffset(0, -leading);
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
					contentStream.newLineAtOffset(0, -leading);
				}
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				}
			}
		}
	}

	private void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, int pagination, String branchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NUMBER)) {
				contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
						branchCode + getFieldValue(field, fieldsMap, true)));
			} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
				contentStream.showText(String.format("%1$5s", "")
						+ String.format("%1$-" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
			} else if (getFieldValue(field, fieldsMap, true) == null) {
				contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
			} else {
				contentStream.showText(
						String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
			}
		}
		contentStream.newLineAtOffset(0, -leading);
	}

	private void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In GLHandoffFinalProofSheetOnUs.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					contentStream.showText(String.format("%" + field.getPdfLength() + "s", " ").replace(' ',
							getFieldValue(field, fieldsMap, true).charAt(0)));
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
				if (getFieldValue(field, fieldsMap, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(
							String.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
				}
			}
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, String branchCode) {
		logger.debug("In GLHandoffFinalProofSheetOnUs.executePdfBodyQuery()");
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
						page = new PDPage();
						doc.addPage(page);
						pagination++;
						contentStream.endText();
						contentStream.close();
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
						writePdfHeader(rgm, contentStream, leading, pagination);
						pageHeight += 4;
					}
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							errors++;
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
								Class clazz = result.getClass();
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, pagination, branchCode);
					pageHeight++;
				}
			} catch (Exception e) {
				logger.error("Error trying to execute the body query", e);
			} finally {
				try {
					ps.close();
					rs.close();
				} catch (SQLException e) {
					logger.error("Error closing DB resources", e);
				}
			}
		}
		return contentStream;
	}

	private void executePdfTrailerQuery(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream,
			PDRectangle pageSize, float leading, float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In GLHandoffFinalProofSheetOnUs.executePdfTrailerQuery()");
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
							errors++;
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
								Class clazz = result.getClass();
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writePdfTrailer(rgm, lineFieldsMap, contentStream, leading);
				}
			} catch (Exception e) {
				logger.error("Error trying to execute the trailer query ", e);
			} finally {
				try {
					ps.close();
					rs.close();
				} catch (SQLException e) {
					logger.error("Error closing DB resources", e);
				}
			}
		}
	}

	private void executeBodyQuery(ReportGenerationMgr rgm, String branchCode) {
		logger.debug("In GLHandoffFinalProofSheetOnUs.executeBodyQuery()");
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
							errors++;
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
								Class clazz = result.getClass();
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap, pagination, branchCode);
				}
			} catch (Exception e) {
				logger.error("Error trying to execute the body query", e);
			} finally {
				try {
					ps.close();
					rs.close();
				} catch (SQLException e) {
					logger.error("Error closing DB resources", e);
				}
			}
		}
	}

	private void executeTrailerQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffFinalProofSheetOnUs.executeTrailerQuery()");
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
							errors++;
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
								Class clazz = result.getClass();
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeTrailer(rgm, lineFieldsMap);
				}
			} catch (Exception e) {
				logger.error("Error trying to execute the trailer query ", e);
			} finally {
				try {
					ps.close();
					rs.close();
				} catch (SQLException e) {
					logger.error("Error closing DB resources", e);
				}
			}
		}
	}
}
