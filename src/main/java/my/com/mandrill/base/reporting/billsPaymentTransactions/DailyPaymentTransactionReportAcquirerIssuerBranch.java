package my.com.mandrill.base.reporting.billsPaymentTransactions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.SortedMap;
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

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.PdfReportProcessor;

public class DailyPaymentTransactionReportAcquirerIssuerBranch extends PdfReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(DailyPaymentTransactionReportAcquirerIssuerBranch.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.processPdfRecord()");
		PDDocument doc = null;
		PDPage page = null;
		PDRectangle pageSize = null;
		PDPageContentStream contentStream = null;
		PDFont pdfFont = PDType1Font.COURIER;
		float fontSize = 6;
		float leading = 1.5f * fontSize;
		float margin = 30;
		float width = 0.0f;
		float startX = 0.0f;
		float startY = 0.0f;
		boolean acquiring = false;
		boolean issuing = false;
		String branchCode = null;
		String branchName = null;
		TreeSet<String> branchCodesList = new TreeSet<>();
		pagination = 0;
		try {
			doc = new PDDocument();
			addReportPreProcessingFieldsToGlobalMap(rgm);

			if (rgm.getBodyQuery() != null) {
				setAcqBodyQuery(rgm.getBodyQuery());
				setIssBodyQuery(rgm.getBodyQuery());
			}

			if (rgm.getTrailerQuery() != null) {
				setAcqTrailerQuery(rgm.getTrailerQuery());
				setIssTrailerQuery(rgm.getTrailerQuery());
			}

			setCriteriaQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", "")
					.replace("{" + ReportConstants.PARAM_BRANCH_CODE + "}", "ABR.ABR_CODE")
					.replace("{" + ReportConstants.PARAM_BRANCH_NAME + "}", "ABR.ABR_NAME")
					.replace("{" + ReportConstants.PARAM_JOIN_CRITERIA + "}",
							"JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID"));
			rgm.setBodyQuery(getCriteriaQuery());
			if (!executeQuery(rgm)) {
				page = new PDPage();
				doc.addPage(page);
				contentStream = new PDPageContentStream(doc, page);
				pageSize = page.getMediaBox();
				width = pageSize.getWidth() - 2 * margin;
				startX = pageSize.getLowerLeftX() + margin;
				startY = pageSize.getUpperRightY() - margin;
				contentStream.setFont(pdfFont, fontSize);
				contentStream.beginText();
				contentStream.newLineAtOffset(startX, startY);
				contentStream.endText();
				contentStream.close();
				saveFile(rgm, doc);
			} else {
				preProcessing(rgm, "acquiring");
				for (SortedMap.Entry<String, String> acquiringBranchCodeMap : filterByBranch(rgm).entrySet()) {
					branchCodesList.add(acquiringBranchCodeMap.getKey());
				}

				preProcessing(rgm, "issuing");
				for (SortedMap.Entry<String, String> issuingBranchCodeMap : filterByBranch(rgm).entrySet()) {
					branchCodesList.add(issuingBranchCodeMap.getKey());
				}

				for (String branchCodes : branchCodesList) {
					preProcessing(rgm, "acquiring");
					for (SortedMap.Entry<String, String> acquiringBranchCodeMap : filterByBranch(rgm).entrySet()) {
						if (acquiringBranchCodeMap.getKey().equals(branchCodes)) {
							acquiring = true;
						}
					}

					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, String> issuingBranchCodeMap : filterByBranch(rgm).entrySet()) {
						if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
							issuing = true;
						}
					}

					if (acquiring && issuing) {
						preProcessing(rgm, "acquiring");
						for (SortedMap.Entry<String, String> acquiringBranchCodeMap : filterByBranch(rgm).entrySet()) {
							if (acquiringBranchCodeMap.getKey().equals(branchCodes)) {
								branchCode = acquiringBranchCodeMap.getKey();
								branchName = acquiringBranchCodeMap.getValue();
								pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
								page = new PDPage();
								doc.addPage(page);
								pagination++;
								pageSize = page.getMediaBox();
								width = pageSize.getWidth() - 2 * margin;
								startX = pageSize.getLowerLeftX() + margin;
								startY = pageSize.getUpperRightY() - margin;
								contentStream = new PDPageContentStream(doc, page);
								contentStream.setFont(pdfFont, fontSize);
								contentStream.beginText();
								contentStream.newLineAtOffset(startX, startY);

								writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
								contentStream.newLineAtOffset(0, -leading);
								pageHeight += 4;
								writePdfBodyHeader(rgm, contentStream, leading);
								pageHeight += 2;
								contentStream.newLineAtOffset(0, -leading);
								pageHeight += 1;

								pdfBranchAsAcquiringIssuingDetails(rgm, branchCode, doc, page, contentStream, pageSize,
										leading, startX, startY, pdfFont, fontSize);
							}
						}
					} else if (acquiring) {
						preProcessing(rgm, "acquiring");
						for (SortedMap.Entry<String, String> acquiringBranchCodeMap : filterByBranch(rgm).entrySet()) {
							if (acquiringBranchCodeMap.getKey().equals(branchCodes)) {
								branchCode = acquiringBranchCodeMap.getKey();
								branchName = acquiringBranchCodeMap.getValue();
								pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
								page = new PDPage();
								doc.addPage(page);
								pagination++;
								pageSize = page.getMediaBox();
								width = pageSize.getWidth() - 2 * margin;
								startX = pageSize.getLowerLeftX() + margin;
								startY = pageSize.getUpperRightY() - margin;
								contentStream = new PDPageContentStream(doc, page);
								contentStream.setFont(pdfFont, fontSize);
								contentStream.beginText();
								contentStream.newLineAtOffset(startX, startY);

								writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
								contentStream.newLineAtOffset(0, -leading);
								pageHeight += 4;
								writePdfBodyHeader(rgm, contentStream, leading);
								pageHeight += 2;
								contentStream.newLineAtOffset(0, -leading);
								pageHeight += 1;
								pdfBranchAsAcquiringDetails(rgm, branchCode, false, doc, page, contentStream, pageSize,
										leading, startX, startY, pdfFont, fontSize);
							}
						}
					} else if (issuing) {
						preProcessing(rgm, "issuing");
						for (SortedMap.Entry<String, String> issuingBranchCodeMap : filterByBranch(rgm).entrySet()) {
							if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
								branchCode = issuingBranchCodeMap.getKey();
								branchName = issuingBranchCodeMap.getValue();
								pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
								page = new PDPage();
								doc.addPage(page);
								pagination++;
								pageSize = page.getMediaBox();
								width = pageSize.getWidth() - 2 * margin;
								startX = pageSize.getLowerLeftX() + margin;
								startY = pageSize.getUpperRightY() - margin;
								contentStream = new PDPageContentStream(doc, page);
								contentStream.setFont(pdfFont, fontSize);
								contentStream.beginText();
								contentStream.newLineAtOffset(startX, startY);

								writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
								contentStream.newLineAtOffset(0, -leading);
								pageHeight += 4;
								writePdfBodyHeader(rgm, contentStream, leading);
								pageHeight += 2;
								contentStream.newLineAtOffset(0, -leading);
								pageHeight += 1;
								pdfBranchAsIssuingDetails(rgm, branchCode, true, doc, page, contentStream, pageSize,
										leading, startX, startY, pdfFont, fontSize);
							}
						}
					}
				}
				saveFile(rgm, doc);
			}
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
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

	private void pdfBranchAsAcquiringIssuingDetails(ReportGenerationMgr rgm, String branchCode, PDDocument doc,
			PDPage page, PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX,
			float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.pdfBranchAsAcquiringIssuingDetails()");
		try {
			preProcessing(rgm, false, branchCode);
			rgm.setBodyQuery(getAcqBodyQuery());
			rgm.setTrailerQuery(getAcqTrailerQuery());
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream.showText("BRANCH AS ACQUIRER");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.showText("FOR THIS BRANCH");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 3;
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;

			preProcessing(rgm, true, branchCode);
			rgm.setBodyQuery(getIssBodyQuery());
			rgm.setTrailerQuery(getIssTrailerQuery());
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream.showText("BRANCH AS ISSUER");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.showText("FOR THIS BRANCH");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 3;
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;

			contentStream.endText();
			contentStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in pdfBranchAsAcquiringIssuingDetails", e);
		}
	}

	private void pdfBranchAsAcquiringDetails(ReportGenerationMgr rgm, String branchCode, boolean indicator,
			PDDocument doc, PDPage page, PDPageContentStream contentStream, PDRectangle pageSize, float leading,
			float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.pdfBranchAsAcquiringDetails()");
		try {
			preProcessing(rgm, indicator, branchCode);
			rgm.setBodyQuery(getAcqBodyQuery());
			rgm.setTrailerQuery(getAcqTrailerQuery());
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream.showText("BRANCH AS ACQUIRER");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.showText("FOR THIS BRANCH");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 3;
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream.endText();
			contentStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in pdfBranchAsAcquiringDetails", e);
		}
	}

	private void pdfBranchAsIssuingDetails(ReportGenerationMgr rgm, String branchCode, boolean indicator,
			PDDocument doc, PDPage page, PDPageContentStream contentStream, PDRectangle pageSize, float leading,
			float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.pdfBranchAsIssuingDetails()");
		try {
			preProcessing(rgm, indicator, branchCode);
			rgm.setBodyQuery(getIssBodyQuery());
			rgm.setTrailerQuery(getIssTrailerQuery());
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream.showText("BRANCH AS ISSUER");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.showText("FOR THIS BRANCH");
			contentStream.newLineAtOffset(0, -leading);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 3;
			executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont, fontSize);
			contentStream.newLineAtOffset(0, -leading);
			pageHeight += 1;
			contentStream.endText();
			contentStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in pdfBranchAsIssuingDetails", e);
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		boolean acquiring = false;
		boolean issuing = false;
		String branchCode = null;
		String branchName = null;
		TreeSet<String> branchCodesList = new TreeSet<>();
		pagination = 0;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			addReportPreProcessingFieldsToGlobalMap(rgm);

			if (rgm.getBodyQuery() != null) {
				setAcqBodyQuery(rgm.getBodyQuery());
				setIssBodyQuery(rgm.getBodyQuery());
			}

			if (rgm.getTrailerQuery() != null) {
				setAcqTrailerQuery(rgm.getTrailerQuery());
				setIssTrailerQuery(rgm.getTrailerQuery());
			}

			preProcessing(rgm, "acquiring");
			for (SortedMap.Entry<String, String> acquiringBranchCodeMap : filterByBranch(rgm).entrySet()) {
				branchCodesList.add(acquiringBranchCodeMap.getKey());
			}

			preProcessing(rgm, "issuing");
			for (SortedMap.Entry<String, String> issuingBranchCodeMap : filterByBranch(rgm).entrySet()) {
				branchCodesList.add(issuingBranchCodeMap.getKey());
			}

			for (String branchCodes : branchCodesList) {
				preProcessing(rgm, "acquiring");
				for (SortedMap.Entry<String, String> acquiringBranchCodeMap : filterByBranch(rgm).entrySet()) {
					if (acquiringBranchCodeMap.getKey().equals(branchCodes)) {
						acquiring = true;
					}
				}

				preProcessing(rgm, "issuing");
				for (SortedMap.Entry<String, String> issuingBranchCodeMap : filterByBranch(rgm).entrySet()) {
					if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
						issuing = true;
					}
				}

				if (acquiring && issuing) {
					preProcessing(rgm, "acquiring");
					for (SortedMap.Entry<String, String> acquiringBranchCodeMap : filterByBranch(rgm).entrySet()) {
						if (acquiringBranchCodeMap.getKey().equals(branchCodes)) {
							pagination++;
							branchCode = acquiringBranchCodeMap.getKey();
							branchName = acquiringBranchCodeMap.getValue();
							writeHeader(rgm, pagination, branchCode, branchName);
							writeBodyHeader(rgm);
							branchAsAcquiringDetails(rgm, branchCode, false);
						}
					}
					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, String> issuingBranchCodeMap : filterByBranch(rgm).entrySet()) {
						branchCode = issuingBranchCodeMap.getKey();
						branchName = issuingBranchCodeMap.getValue();
						if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
							branchAsIssuingDetails(rgm, branchCode, true);
						}
					}
				} else if (acquiring) {
					preProcessing(rgm, "acquiring");
					for (SortedMap.Entry<String, String> acquiringBranchCodeMap : filterByBranch(rgm).entrySet()) {
						if (acquiringBranchCodeMap.getKey().equals(branchCodes)) {
							pagination++;
							branchCode = acquiringBranchCodeMap.getKey();
							branchName = acquiringBranchCodeMap.getValue();
							writeHeader(rgm, pagination, branchCode, branchName);
							writeBodyHeader(rgm);
							branchAsAcquiringDetails(rgm, branchCode, false);
						}
					}
				} else if (issuing) {
					preProcessing(rgm, "issuing");
					for (SortedMap.Entry<String, String> issuingBranchCodeMap : filterByBranch(rgm).entrySet()) {
						if (issuingBranchCodeMap.getKey().equals(branchCodes)) {
							pagination++;
							branchCode = issuingBranchCodeMap.getKey();
							branchName = issuingBranchCodeMap.getValue();
							writeHeader(rgm, pagination, branchCode, branchName);
							writeBodyHeader(rgm);
							branchAsIssuingDetails(rgm, branchCode, false);
						}
					}
				}
			}
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in generating CSV file", e);
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

	private void branchAsAcquiringDetails(ReportGenerationMgr rgm, String branchCode, boolean indicator) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.branchAsAcquiringDetails()");
		StringBuilder line = new StringBuilder();
		try {
			preProcessing(rgm, indicator, branchCode);
			rgm.setBodyQuery(getAcqBodyQuery());
			rgm.setTrailerQuery(getAcqTrailerQuery());
			executeBodyQuery(rgm);
			line.append(getEol());
			line.append("BRANCH AS ACQUIRER");
			line.append(getEol());
			line.append("FOR THIS BRANCH");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			executeTrailerQuery(rgm);
			line = new StringBuilder();
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in branchAsAcquiringDetails", e);
		}
	}

	private void branchAsIssuingDetails(ReportGenerationMgr rgm, String branchCode, boolean indicator) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.branchAsIssuingDetails()");
		StringBuilder line = new StringBuilder();
		try {
			preProcessing(rgm, indicator, branchCode);
			rgm.setBodyQuery(getIssBodyQuery());
			rgm.setTrailerQuery(getIssTrailerQuery());
			executeBodyQuery(rgm);
			line.append(getEol());
			line.append("BRANCH AS ISSUER");
			line.append(getEol());
			line.append("FOR THIS BRANCH");
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
			executeTrailerQuery(rgm);
			line = new StringBuilder();
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in branchAsIssuingDetails", e);
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, String indicator) {
		if (indicator.equalsIgnoreCase("acquiring")) {
			rgm.setBodyQuery(getAcqBodyQuery().replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", "")
					.replace("{" + ReportConstants.PARAM_BRANCH_CODE + "}", "ABR.ABR_CODE")
					.replace("{" + ReportConstants.PARAM_BRANCH_NAME + "}", "ABR.ABR_NAME")
					.replace("{" + ReportConstants.PARAM_JOIN_CRITERIA + "}",
							"JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID"));
		} else {
			rgm.setBodyQuery(getIssBodyQuery().replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", "")
					.replace("{" + ReportConstants.PARAM_BRANCH_CODE + "}", "BRC.BRC_CODE")
					.replace("{" + ReportConstants.PARAM_BRANCH_NAME + "}", "BRC.BRC_NAME")
					.replace("{" + ReportConstants.PARAM_JOIN_CRITERIA + "}",
							"JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE"));
		}
	}

	private void preProcessing(ReportGenerationMgr rgm, boolean indicator, String filterByBranchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.preProcessing()");
		if (!indicator) {
			setAcqBodyQuery(getAcqBodyQuery().replace("{" + ReportConstants.PARAM_BRANCH_CODE + "}", "ABR.ABR_CODE")
					.replace("{" + ReportConstants.PARAM_BRANCH_NAME + "}", "ABR.ABR_NAME")
					.replace("{" + ReportConstants.PARAM_JOIN_CRITERIA + "}",
							"JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID"));
			setAcqTrailerQuery(getAcqTrailerQuery().replace("{" + ReportConstants.PARAM_JOIN_CRITERIA + "}",
					"JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID"));

			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "ABR.ABR_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		} else {
			setIssBodyQuery(getIssBodyQuery().replace("{" + ReportConstants.PARAM_BRANCH_CODE + "}", "BRC.BRC_CODE")
					.replace("{" + ReportConstants.PARAM_BRANCH_NAME + "}", "BRC.BRC_NAME")
					.replace("{" + ReportConstants.PARAM_JOIN_CRITERIA + "}",
							"JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE"));
			setIssTrailerQuery(getIssTrailerQuery().replace("{" + ReportConstants.PARAM_JOIN_CRITERIA + "}",
					"JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE"));

			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_TXN_CRITERIA,
					ReportGenerationFields.TYPE_STRING, "BRC.BRC_CODE = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.isFirstField()) {
					contentStream.showText(String.format("%1$7s", "")
							+ String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				} else
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
			}
		}
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getSequence()) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 10:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				break;
			default:
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, String channel)
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
				switch (field.getFieldName()) {
				case ReportConstants.TERMINAL:
					if (channel.equals(ReportConstants.OB) && getFieldValue(field, fieldsMap).trim().length() == 8) {
						String terminalId = getFieldValue(field, fieldsMap);
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								terminalId.substring(0, 4) + "-" + terminalId.substring(terminalId.length() - 4)));
					} else {
						String terminalId = getFieldValue(field, fieldsMap);
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								terminalId.substring(terminalId.length() - 4)));
					}
					break;
				default:
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
					break;
				}
			}
		}
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap, String channel)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			switch (field.getFieldName()) {
			case ReportConstants.TERMINAL:
				if (channel.equals(ReportConstants.OB) && getFieldValue(field, fieldsMap).trim().length() == 8) {
					String terminalId = getFieldValue(field, fieldsMap).trim();
					line.append(terminalId.substring(0, 4) + "-" + terminalId.substring(terminalId.length() - 4));
				} else {
					String terminalId = getFieldValue(field, fieldsMap).trim();
					line.append(terminalId.substring(terminalId.length() - 4));
				}
				line.append(field.getDelimiter());
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				line.append(field.getDelimiter());
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.execute()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String channel = null;
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
							} else if (key.equalsIgnoreCase(ReportConstants.CHANNEL)) {
								channel = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, channel);
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

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String channel = null;
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
							} else if (key.equalsIgnoreCase(ReportConstants.CHANNEL)) {
								channel = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap, channel);
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

	@Override
	protected void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.writePdfTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				contentStream.newLineAtOffset(0, -leading);
			} else {
				if (field.isFirstField()) {
					contentStream.showText(String.format("%1$3s", "") + getFieldValue(rgm, field, fieldsMap));
				} else {
					contentStream.showText(getFieldValue(rgm, field, fieldsMap));
				}
			}
		}
	}

	@Override
	protected void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			line.append(getFieldValue(rgm, field, fieldsMap));
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private boolean executeQuery(ReportGenerationMgr rgm) {
		logger.debug("In DailyPaymentTransactionReportAcquirerIssuerBranch.executeQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = getBodyQuery(rgm);
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.connection.prepareStatement(query);
			rs = ps.executeQuery();

			if (!rs.isBeforeFirst()) {
				return false;
			} else {
				return true;
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
		return false;
	}
}
