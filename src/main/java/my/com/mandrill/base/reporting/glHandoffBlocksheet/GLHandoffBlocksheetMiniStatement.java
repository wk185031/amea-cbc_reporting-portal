package my.com.mandrill.base.reporting.glHandoffBlocksheet;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
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

public class GLHandoffBlocksheetMiniStatement extends GeneralReportProcess {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffBlocksheetMiniStatement.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private String acquirerDebitBodyQuery = null;
	private String acquirerCreditBodyQuery = null;
	private String acquirerDebitTrailerQuery = null;
	private String acquirerCreditTrailerQuery = null;
	private String debitBodyQuery = null;
	private String creditBodyQuery = null;
	private String debitTrailerQuery = null;
	private String creditTrailerQuery = null;
	private String criteriaQuery = null;
	private boolean firstRecord = false;
	private boolean newGroup = false;
	private boolean endGroup = false;

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

	public String getCriteriaQuery() {
		return criteriaQuery;
	}

	public void setCriteriaQuery(String criteriaQuery) {
		this.criteriaQuery = criteriaQuery;
	}

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetMiniStatement.processPdfRecord()");
		PDDocument doc = null;
		PDPage page = null;
		PDPageContentStream contentStream = null;
		PDRectangle pageSize = null;
		PDFont pdfFont = PDType1Font.COURIER;
		float fontSize = 6;
		float leading = 1.5f * fontSize;
		float margin = 30;
		float width = 0.0f;
		float startX = 0.0f;
		float startY = 0.0f;
		String txnDate = null;
		pagination = 0;
		try {
			doc = new PDDocument();
			String glDescription = null;
			String branchCode = null;

			separateQuery(rgm);
			preProcessing(rgm);

			Iterator<String> glDescriptionItr = filterByGlDescription(rgm).iterator();

			while (glDescriptionItr.hasNext()) {
				glDescription = glDescriptionItr.next();
				if (!endGroup && !newGroup) {
					page = new PDPage();
					doc.addPage(page);
					firstRecord = true;
					newGroup = true;
					pagination++;
					contentStream = new PDPageContentStream(doc, page);
					pageSize = page.getMediaBox();
					width = pageSize.getWidth() - 2 * margin;
					startX = pageSize.getLowerLeftX() + margin;
					startY = pageSize.getUpperRightY() - margin;
					contentStream.setFont(pdfFont, fontSize);
					contentStream.beginText();
					contentStream.newLineAtOffset(startX, startY);
				}

				if (endGroup && newGroup) {
					endGroup = false;
					pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
					page = new PDPage();
					doc.addPage(page);
					firstRecord = true;
					pagination++;
					contentStream = new PDPageContentStream(doc, page);
					contentStream.setFont(pdfFont, fontSize);
					contentStream.beginText();
					contentStream.newLineAtOffset(startX, startY);
					if (glDescription.equalsIgnoreCase(ReportConstants.CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL)) {
						rgm.setBodyQuery(getAcquirerDebitBodyQuery());
						rgm.setTrailerQuery(getAcquirerDebitTrailerQuery());
						preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
						writePdfHeader(rgm, contentStream, leading, pagination);
						pageHeight += 4;
						writePdfBodyHeader(rgm, contentStream, leading);
						pageHeight += 2;
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.DEBIT_IND);
						preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);

						Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
						while (branchCodeItr.hasNext()) {
							branchCode = branchCodeItr.next();
							pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
							page = new PDPage();
							doc.addPage(page);
							firstRecord = true;
							pagination++;
							contentStream = new PDPageContentStream(doc, page);
							contentStream.setFont(pdfFont, fontSize);
							contentStream.beginText();
							contentStream.newLineAtOffset(startX, startY);
							rgm.setBodyQuery(getAcquirerCreditBodyQuery());
							rgm.setTrailerQuery(getAcquirerCreditTrailerQuery());
							preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
							writePdfHeader(rgm, contentStream, leading, pagination);
							pageHeight += 4;
							writePdfBodyHeader(rgm, contentStream, leading);
							pageHeight += 2;
							contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading,
									startX, startY, pdfFont, fontSize, glDescription, branchCode,
									ReportConstants.CREDIT_IND);
						}
						endGroup = true;
					} else {
						rgm.setBodyQuery(getDebitBodyQuery());
						rgm.setTrailerQuery(getDebitTrailerQuery());
						preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
						writePdfHeader(rgm, contentStream, leading, pagination);
						pageHeight += 4;
						writePdfBodyHeader(rgm, contentStream, leading);
						pageHeight += 2;
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.CREDIT_IND);

						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
						page = new PDPage();
						doc.addPage(page);
						firstRecord = true;
						pagination++;
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
						rgm.setBodyQuery(getCreditBodyQuery());
						rgm.setTrailerQuery(getCreditTrailerQuery());
						preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
						writePdfHeader(rgm, contentStream, leading, pagination);
						pageHeight += 4;
						writePdfBodyHeader(rgm, contentStream, leading);
						pageHeight += 2;
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.CREDIT_IND);
						endGroup = true;
					}
				} else {
					if (glDescription.equalsIgnoreCase(ReportConstants.CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL)) {
						rgm.setBodyQuery(getAcquirerDebitBodyQuery());
						rgm.setTrailerQuery(getAcquirerDebitTrailerQuery());
						preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
						writePdfHeader(rgm, contentStream, leading, pagination);
						pageHeight += 4;
						writePdfBodyHeader(rgm, contentStream, leading);
						pageHeight += 2;
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.DEBIT_IND);
						preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);

						Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
						while (branchCodeItr.hasNext()) {
							branchCode = branchCodeItr.next();
							pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
							page = new PDPage();
							doc.addPage(page);
							firstRecord = true;
							pagination++;
							contentStream = new PDPageContentStream(doc, page);
							contentStream.setFont(pdfFont, fontSize);
							contentStream.beginText();
							contentStream.newLineAtOffset(startX, startY);
							rgm.setBodyQuery(getAcquirerCreditBodyQuery());
							rgm.setTrailerQuery(getAcquirerCreditTrailerQuery());
							preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
							writePdfHeader(rgm, contentStream, leading, pagination);
							pageHeight += 4;
							writePdfBodyHeader(rgm, contentStream, leading);
							pageHeight += 2;
							contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading,
									startX, startY, pdfFont, fontSize, glDescription, branchCode,
									ReportConstants.CREDIT_IND);
						}
						endGroup = true;
					} else {
						rgm.setBodyQuery(getDebitBodyQuery());
						rgm.setTrailerQuery(getDebitTrailerQuery());
						preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
						writePdfHeader(rgm, contentStream, leading, pagination);
						pageHeight += 4;
						writePdfBodyHeader(rgm, contentStream, leading);
						pageHeight += 2;
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.DEBIT_IND);

						pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
						page = new PDPage();
						doc.addPage(page);
						firstRecord = true;
						pagination++;
						contentStream = new PDPageContentStream(doc, page);
						contentStream.setFont(pdfFont, fontSize);
						contentStream.beginText();
						contentStream.newLineAtOffset(startX, startY);
						rgm.setBodyQuery(getCreditBodyQuery());
						rgm.setTrailerQuery(getCreditTrailerQuery());
						preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
						writePdfHeader(rgm, contentStream, leading, pagination);
						pageHeight += 4;
						writePdfBodyHeader(rgm, contentStream, leading);
						pageHeight += 2;
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize, glDescription, branchCode, ReportConstants.CREDIT_IND);
						endGroup = true;
					}
				}
			}

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
			logger.error("Error in generating " + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.PDF_FORMAT,
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
		logger.debug("In GLHandoffBlocksheetMiniStatement.processCsvTxtRecord()");
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

			if (rgm.getFileFormat().equalsIgnoreCase(ReportConstants.FILE_TXT)) {
				if (rgm.errors == 0) {
					if (fileLocation != null) {
						File directory = new File(fileLocation);
						if (!directory.exists()) {
							directory.mkdirs();
						}
						pagination = 0;
						file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate
								+ ReportConstants.TXT_FORMAT);
						execute(rgm, file);
					} else {
						throw new Exception("Path: " + fileLocation + " not configured.");
					}
				} else {
					throw new Exception("Errors when generating" + rgm.getFileNamePrefix() + "_" + txnDate
							+ ReportConstants.TXT_FORMAT);
				}
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + txnDate + ReportConstants.TXT_FORMAT,
					e);
		}
	}

	private void execute(ReportGenerationMgr rgm, File file) {
		String glDescription = null;
		String branchCode = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			Iterator<String> glDescriptionItr = filterByGlDescription(rgm).iterator();
			while (glDescriptionItr.hasNext()) {
				glDescription = glDescriptionItr.next();
				if (glDescription.equalsIgnoreCase(ReportConstants.CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL)) {
					firstRecord = true;
					pagination++;
					rgm.setBodyQuery(getAcquirerDebitBodyQuery());
					rgm.setTrailerQuery(getAcquirerDebitTrailerQuery());
					preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
					writeHeader(rgm, pagination);
					writeBodyHeader(rgm);
					executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
					preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);

					Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
					while (branchCodeItr.hasNext()) {
						branchCode = branchCodeItr.next();
						firstRecord = true;
						pagination++;
						rgm.setBodyQuery(getAcquirerCreditBodyQuery());
						rgm.setTrailerQuery(getAcquirerCreditTrailerQuery());
						preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
						writeHeader(rgm, pagination);
						writeBodyHeader(rgm);
						executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
					}
				} else {
					firstRecord = true;
					pagination++;
					rgm.setBodyQuery(getDebitBodyQuery());
					rgm.setTrailerQuery(getDebitTrailerQuery());
					preProcessing(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);
					writeHeader(rgm, pagination);
					writeBodyHeader(rgm);
					executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.DEBIT_IND);

					firstRecord = true;
					pagination++;
					rgm.setBodyQuery(getCreditBodyQuery());
					rgm.setTrailerQuery(getCreditTrailerQuery());
					preProcessing(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
					writeHeader(rgm, pagination);
					writeBodyHeader(rgm);
					executeBodyQuery(rgm, glDescription, branchCode, ReportConstants.CREDIT_IND);
				}
			}
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

	private List<String> filterByGlDescription(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetMiniStatement.filterByGlDescription()");
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

	private SortedSet<String> filterByBranchCode(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetMiniStatement.filterByBranchCode()");
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

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffBlocksheetMiniStatement.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_GL_DESCRIPTION + "}", "")
					.replace("AND {" + ReportConstants.PARAM_CHANNEL + "}", ""));
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

	private void preProcessing(ReportGenerationMgr rgm, String filterByGlDescription, String filterByBranchCode,
			String indicator) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffBlocksheetMiniStatement.preProcessing()");
		if (filterByGlDescription != null && getDebitBodyQuery() != null && getAcquirerDebitBodyQuery() != null
				&& indicator.equals(ReportConstants.DEBIT_IND)) {
			ReportGenerationFields glDesc = new ReportGenerationFields(ReportConstants.PARAM_GL_DESCRIPTION,
					ReportGenerationFields.TYPE_STRING,
					"TRIM(GLE.GLE_DEBIT_DESCRIPTION) = '" + filterByGlDescription + "'");
			getGlobalFileFieldsMap().put(glDesc.getFieldName(), glDesc);
		}
		if (filterByGlDescription != null && getCreditBodyQuery() != null && getAcquirerCreditBodyQuery() != null
				&& indicator.equals(ReportConstants.CREDIT_IND)) {
			if (filterByGlDescription.equalsIgnoreCase(ReportConstants.CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL)) {
				ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
						ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
				getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			}
			ReportGenerationFields glDesc = new ReportGenerationFields(ReportConstants.PARAM_GL_DESCRIPTION,
					ReportGenerationFields.TYPE_STRING,
					"TRIM(GLE.GLE_CREDIT_DESCRIPTION) = '" + filterByGlDescription + "'");
			getGlobalFileFieldsMap().put(glDesc.getFieldName(), glDesc);
		}

		// TBC
		switch (filterByGlDescription) {
		case ReportConstants.CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL:
			ReportGenerationFields channelOnUs = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ORIGIN_ICH_NAME = 'NDC+' AND CPD.CPD_NAME IN ('CASH CARD', 'EMV CASH CARD')");
			getGlobalFileFieldsMap().put(channelOnUs.getFieldName(), channelOnUs);
			break;
		default:
			ReportGenerationFields defaultChannel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'Bancnet_Interchange'");
			getGlobalFileFieldsMap().put(defaultChannel.getFieldName(), defaultChannel);
			break;
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetMiniStatement.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setAcquirerDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", ""));
			setAcquirerDebitBodyQuery(getAcquirerDebitBodyQuery()
					.replace(getAcquirerDebitBodyQuery().substring(getAcquirerDebitBodyQuery().indexOf("GROUP BY"),
							getAcquirerDebitBodyQuery().indexOf("ORDER BY")), ""));
			setAcquirerCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setAcquirerCreditBodyQuery(getAcquirerCreditBodyQuery()
					.replace(getAcquirerCreditBodyQuery().substring(getAcquirerCreditBodyQuery().indexOf("GROUP BY"),
							getAcquirerCreditBodyQuery().indexOf("ORDER BY")), ""));
			setDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", "")
					.replace("LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN", "")
					.replace("LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID", ""));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, "").replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN", "")
					.replace("LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID", ""));
			setCreditBodyQuery(getCreditBodyQuery().replace(getCreditBodyQuery().substring(
					getCreditBodyQuery().indexOf("GROUP BY"), getCreditBodyQuery().indexOf("ORDER BY")), ""));
			setCriteriaQuery(getDebitBodyQuery().replace("TXN.TRL_DEST_STAN \"CODE\",", "")
					.replace("TXN.TRL_DEST_STAN,", "").replace("TXN.TRL_DEST_STAN ASC,", "")
					.replace(
							"CASE WHEN GLE.GLE_DEBIT_DESCRIPTION IN ('CC ON-US/INTRBRNCH WITHDRAWAL', 'CASH CARD BANCNET WITHDRAWAL') THEN TXN.TRL_AMT_TXN ELSE NVL(TXN.TRL_ISS_CHARGE_AMT, 0) END AS \"DEBIT\",",
							"")
					.replace("TXN.TRL_ACCOUNT_1_ACN_ID \"ACCOUNT NUMBER\",", "").replace("TXN.TRL_AMT_TXN,", "")
					.replace("TXN.TRL_ISS_CHARGE_AMT,", "").replace("TXN.TRL_ACCOUNT_1_ACN_ID,", ""));
			setDebitBodyQuery(getDebitBodyQuery().replace(getDebitBodyQuery()
					.substring(getDebitBodyQuery().indexOf("GROUP BY"), getDebitBodyQuery().indexOf("ORDER BY")), ""));
		}
		if (rgm.getTrailerQuery() != null) {
			setAcquirerDebitTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", ""));
			setAcquirerCreditTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setDebitTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", "")
					.replace("LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN", "")
					.replace("LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID", ""));
			setCreditTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, "").replace("ABR.ABR_CODE \"BRANCH CODE\",", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("ABR.ABR_CODE,", "").replace("ABR.ABR_CODE ASC,", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN", "")
					.replace("LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID", ""));
		}
	}

	private void addPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetMiniStatement.addPreProcessingFieldsToGlobalMap()");
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

	private void writeHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In GLHandoffBlocksheetMiniStatement.writeHeader()");
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
		logger.debug("In GLHandoffBlocksheetMiniStatement.writeBodyHeader()");
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

	private void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String glDescription, String branchCode, String indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		boolean cashCard = false;
		boolean bancnet = false;
		int fieldLength = 0;
		String cashCardValue = null;
		String bancnetValue = null;
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (!firstRecord && !cashCard && !bancnet) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)
						|| field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NUMBER)
						|| field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)
						|| field.getFieldName().equalsIgnoreCase(ReportConstants.DESCRIPTION)) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
						line.append(
								String.format("%1$4s", "") + String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					}
				} else {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.CODE)) {
						if (getFieldValue(field, fieldsMap, true).length() <= 6) {
							String formatStan = String.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true))
									.replace(' ', '0');
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatStan));
						} else {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
					} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.ACCOUNT_NUMBER)) {
						if (getFieldValue(field, fieldsMap, true).length() <= 16) {
							String formatAccNo = String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true))
									.replace(' ', '0');
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatAccNo));
						} else {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
				}
			} else {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
					if (!(glDescription.equalsIgnoreCase(ReportConstants.CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL)
							&& indicator.equals(ReportConstants.CREDIT_IND))) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", "5008"));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					fieldLength = field.getCsvTxtLength();
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NUMBER)) {
					if (branchCode != null
							&& glDescription.equalsIgnoreCase(ReportConstants.CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL)
							&& indicator.equals(ReportConstants.CREDIT_IND)) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								branchCode + getFieldValue(field, fieldsMap, true)));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					fieldLength += field.getCsvTxtLength();
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
					if (getFieldValue(field, fieldsMap, true).contains("Cash Card")) {
						line.append(String.format("%1$4s", "") + String.format("%1$-" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true).substring(0, 28)));
						cashCardValue = getFieldValue(field, fieldsMap, true).substring(29,
								getFieldValue(field, fieldsMap, true).length());
						cashCard = true;
					} else if (getFieldValue(field, fieldsMap, true).contains("Bancnet")) {
						line.append(String.format("%1$4s", "") + String.format("%1$-" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true).substring(0, 23)));
						bancnetValue = getFieldValue(field, fieldsMap, true).substring(24,
								getFieldValue(field, fieldsMap, true).length());
						bancnet = true;
					} else {
						line.append(String.format("%1$4s", "") + String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.CODE)) {
					if (getFieldValue(field, fieldsMap, true).length() <= 6) {
						String formatStan = String.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true))
								.replace(' ', '0');
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatStan));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
				} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.ACCOUNT_NUMBER)) {
					if (getFieldValue(field, fieldsMap, true).length() <= 16) {
						String formatAccNo = String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true))
								.replace(' ', '0');
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", formatAccNo));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
				}
			}
		}
		line.append(getEol());
		if (cashCard) {
			cashCard = false;
			line.append(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + cashCardValue.length()) + "s", cashCardValue));
			line.append(getEol());
		}
		if (bancnet) {
			bancnet = false;
			line.append(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + bancnetValue.length()) + "s", bancnetValue));
			line.append(getEol());
		}
		rgm.writeLine(line.toString().getBytes());
		firstRecord = false;
	}

	private void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In GLHandoffBlocksheetMiniStatement.writeTrailer()");
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
		logger.debug("In GLHandoffBlocksheetMiniStatement.writePdfHeader()");
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
		logger.debug("In GLHandoffBlocksheetMiniStatement.writePdfBodyHeader()");
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
			PDPageContentStream contentStream, float leading, String glDescription, String branchCode, String indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		boolean cashCard = false;
		boolean bancnet = false;
		int fieldLength = 0;
		String cashCardValue = null;
		String bancnetValue = null;
		for (ReportGenerationFields field : fields) {
			if (!firstRecord && !cashCard && !bancnet) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)
						|| field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NUMBER)
						|| field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)
						|| field.getFieldName().equalsIgnoreCase(ReportConstants.DESCRIPTION)) {
					if (field.isEol()) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
							contentStream.showText(
									String.format("%1$4s", "") + String.format("%1$" + field.getPdfLength() + "s", ""));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						}
					}
				} else {
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
						if (field.getFieldName().equalsIgnoreCase(ReportConstants.CODE)) {
							if (getFieldValue(field, fieldsMap, true).length() <= 6) {
								String formatStan = String
										.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true))
										.replace(' ', '0');
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatStan));
							} else {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										getFieldValue(field, fieldsMap, true)));
							}
						} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.ACCOUNT_NUMBER)) {
							if (getFieldValue(field, fieldsMap, true).length() <= 16) {
								String formatAccNo = String
										.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true))
										.replace(' ', '0');
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatAccNo));
							} else {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										getFieldValue(field, fieldsMap, true)));
							}
						} else if (getFieldValue(field, fieldsMap, true) == null) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
					}
				}
			} else {
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
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
						if (!(glDescription.equalsIgnoreCase(ReportConstants.CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL)
								&& indicator.equals(ReportConstants.CREDIT_IND))) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", "5008"));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						fieldLength += field.getPdfLength();
					} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NUMBER)) {
						if (branchCode != null
								&& glDescription.equalsIgnoreCase(ReportConstants.CASH_CARD_ON_US_INTRBRNCH_WITHDRAWAL)
								&& indicator.equals(ReportConstants.CREDIT_IND)) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									branchCode + getFieldValue(field, fieldsMap, true)));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						fieldLength += field.getPdfLength();
					} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
						if (getFieldValue(field, fieldsMap, true).contains("Cash Card")) {
							contentStream.showText(
									String.format("%1$4s", "") + String.format("%1$-" + field.getPdfLength() + "s",
											getFieldValue(field, fieldsMap, true).substring(0, 28)));
							cashCardValue = getFieldValue(field, fieldsMap, true).substring(29,
									getFieldValue(field, fieldsMap, true).length());
							cashCard = true;
						} else if (getFieldValue(field, fieldsMap, true).contains("Bancnet")) {
							contentStream.showText(
									String.format("%1$4s", "") + String.format("%1$-" + field.getPdfLength() + "s",
											getFieldValue(field, fieldsMap, true).substring(0, 23)));
							bancnetValue = getFieldValue(field, fieldsMap, true).substring(24,
									getFieldValue(field, fieldsMap, true).length());
							bancnet = true;
						} else {
							contentStream.showText(String.format("%1$4s", "") + String
									.format("%1$" + field.getPdfLength() + "s", getFieldValue(field, fieldsMap, true)));
						}
					} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.CODE)) {
						if (getFieldValue(field, fieldsMap, true).length() <= 6) {
							String formatStan = String.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true))
									.replace(' ', '0');
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatStan));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
					} else if (field.getFieldName().equalsIgnoreCase(ReportConstants.ACCOUNT_NUMBER)) {
						if (getFieldValue(field, fieldsMap, true).length() <= 16) {
							String formatAccNo = String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true))
									.replace(' ', '0');
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", formatAccNo));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
					} else if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
				}
			}
		}
		if (cashCard) {
			cashCard = false;
			contentStream.showText(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + cashCardValue.length()) + "s", cashCardValue));
			contentStream.newLineAtOffset(0, -leading);
		}
		if (bancnet) {
			bancnet = false;
			contentStream.showText(String.format("%1$4s", "")
					+ String.format("%1$" + (fieldLength + bancnetValue.length()) + "s", bancnetValue));
			contentStream.newLineAtOffset(0, -leading);
		}
		firstRecord = false;
	}

	private void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In GLHandoffBlocksheetMiniStatement.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE) && field.isFirstField()) {
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
			PDFont pdfFont, float fontSize, String glDescription, String branchCode, String indicator) {
		logger.debug("In GLHandoffBlocksheetMiniStatement.executePdfBodyQuery()");
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
					if (pageHeight > totalHeight && !endGroup) {
						endGroup = false;
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, glDescription, branchCode, indicator);
					pageHeight++;
				}
				pageHeight += 1;
				executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
				pageHeight += 1;
				contentStream.endText();
				contentStream.close();
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

	private void executePdfTrailerQuery(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream,
			PDRectangle pageSize, float leading, float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In GLHandoffBlocksheetMiniStatement.executePdfTrailerQuery()");
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

	private void executeBodyQuery(ReportGenerationMgr rgm, String glDescription, String branchCode, String indicator) {
		logger.debug("In GLHandoffBlocksheetMiniStatement.executeBodyQuery()");
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
					writeBody(rgm, lineFieldsMap, glDescription, branchCode, indicator);
				}
				executeTrailerQuery(rgm);
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

	private void executeTrailerQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetMiniStatement.executeTrailerQuery()");
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
					writeTrailer(rgm, lineFieldsMap);
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
