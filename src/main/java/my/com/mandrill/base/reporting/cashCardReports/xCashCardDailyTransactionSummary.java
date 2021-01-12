package my.com.mandrill.base.reporting.cashCardReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

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

public class xCashCardDailyTransactionSummary extends PdfReportProcessor {

	private static final String BODY_HEADER_QUERY = "select count(ACN.ACN_ID) \"ACTIVE_ACCOUNTS\", sum(case when CTR.CTR_DEBIT_CREDIT = 'DEBIT' then TXN.TRL_AMT_TXN else 0 end) \"TOTAL_DEBIT\", sum(case when CTR.CTR_DEBIT_CREDIT = 'CREDIT' then TXN.TRL_AMT_TXN else 0 end) \"TOTAL_CREDIT\", sum(ACN.ACN_BALANCE_1) \"CURRENT BALANCE\""
			+ "from TRANSACTION_LOG txn left join CARD CRD on TXN.TRL_PAN=CRD.CRD_PAN left join TRANSACTION_LOG_CUSTOM TXNC on TXN.TRL_ID=TXNC.TRL_ID left join BRANCH BRC on TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE left join CARD_ACCOUNT CAT on CRD.CRD_ID=CAT.CAT_CRD_ID left join ACCOUNT ACN on CAT.CAT_ACN_ID=ACN.ACN_ID left join CARD_PRODUCT CPD on CRD.CRD_CPD_ID=CPD.CPD_ID left join CBC_TRAN_CODE CTR on TXN.TRL_TSC_CODE=CTR.CTR_CODE and TXNC.TRL_ORIGIN_CHANNEL=CTR.CTR_CHANNEL "
			+ "where CPD.CPD_CODE in ('81', '83') and {corporate_criteria} and {Txn_Date}";

	private final Logger logger = LoggerFactory.getLogger(xCashCardDailyTransactionSummary.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In CashCardDailyTransactionSummary.processPdfRecord()");
		PDDocument doc = null;
		PDPage page = null;
		PDPageContentStream contentStream = null;
		pagination = 0;

		try {
			doc = new PDDocument();
			page = new PDPage();
			doc.addPage(page);
			contentStream = new PDPageContentStream(doc, page);
			PDFont pdfFont = PDType1Font.COURIER;
			float fontSize = 6;
			float leading = 1.5f * fontSize;
			PDRectangle pageSize = page.getMediaBox();
			float margin = 30;
			float width = pageSize.getWidth() - 2 * margin;
			float startX = pageSize.getLowerLeftX() + margin;
			float startY = pageSize.getUpperRightY() - margin;
			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize);

			contentStream.endText();

			saveFile(rgm, doc);
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
			if (contentStream != null) {
				try {
					contentStream.close();
				} catch (IOException e) {
					logger.warn("Error in closing contentStream.", e);
				}
			}
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
			writeTrailer(rgm, null);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
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

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In CashCardDailyTransactionSummary.executePdfBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		HashSet<String> branchSet = null;
		// 1. initialize collection to use to sort the query data by card type
		HashMap<String, List<HashMap<String, ReportGenerationFields>>> productToLineFieldsMap = null;
		List<HashMap<String, ReportGenerationFields>> lineFieldsMapList = null;
		String branchCode = null;
		String branchName = null;
		String productName = null;
		String previousMonthBalance = null;
		String APBalance = null;
		int activeAccount = 0;

		StringBuilder str = null;
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);

				while (rs.next()) {
					lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
					if (pageHeight > totalHeight) {
						addNewPage(contentStream, doc, pdfFont, fontSize, startX, startY);
					}
					
					
					
					
					//**Prevent following to execute
					if(true) {
						continue;
					}
					//**Prevent following to execute
					
					
					
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

					if (branchSet == null) {
						branchSet = new HashSet<String>();
					}

					if (str == null) {
						str = new StringBuilder();
					}

					str.append(lineFieldsMap.get("BRANCH CODE").getValue());
					str.append(",");
					str.append(lineFieldsMap.get("BRANCH NAME").getValue());
					branchSet.add(str.toString());

					// clear StringBuilder to reuse
					str.setLength(0);

					str.append(lineFieldsMap.get("BRANCH CODE").getValue());

//                    branchCode = lineFieldsMap.get(ReportConstants.BRANCH_CODE).getValue();
//                    branchName = lineFieldsMap.get(ReportConstants.BRANCH_NAME).getValue();
//
//                    str.append(branchCode);
//                    str.append(",");
//                    str.append(branchName);
//
					productName = "CASH CARD RETAIL";
//                    previousMonthBalance = lineFieldsMap.get(ReportConstants.BALANCE).getValue();
//                    APBalance = lineFieldsMap.get(ReportConstants.TOTAL).getValue();
//                    activeAccount = Integer.parseInt(lineFieldsMap.get(ReportConstants.STATUS_ACTIVE).getValue());

					str.append(productName);
					str.append(",");
					str.append(previousMonthBalance);
//                    str.append(",");
//                    str.append(APBalance);
//                    str.append(",");
//                    str.append(activeAccount);

					// add list of lineFieldsMap into product map
					if (productToLineFieldsMap == null) {
						productToLineFieldsMap = new HashMap<String, List<HashMap<String, ReportGenerationFields>>>();
					}

					if (productToLineFieldsMap.containsKey(str.toString())) {
						productToLineFieldsMap.get(str.toString()).add(lineFieldsMap);
					} else {
						lineFieldsMapList = new ArrayList<>();
						lineFieldsMapList.add(lineFieldsMap);
						productToLineFieldsMap.put(str.toString(), lineFieldsMapList);
					}

					for (String branch : branchSet) {
						preProcessingHeader(rgm, branch.split(",")[0], branch.split(",")[1]);
						writePdfHeader(rgm, contentStream, leading, pagination);
						for (Map.Entry<String, List<HashMap<String, ReportGenerationFields>>> branchMap : productToLineFieldsMap
								.entrySet()) {
//                            if(branchMap.getKey().split(",")[0].equals(branch.split(",")[0])){
							preProcessingBodyHeader(rgm, productName, previousMonthBalance, APBalance, activeAccount);
							writePdfBodyHeader(rgm, contentStream, leading);
							for (HashMap<String, ReportGenerationFields> m : branchMap.getValue()) {
								writePdfBody(rgm, m, contentStream, leading);
								pageHeight++;
							}
						}
					}

//                    preProcessingHeader(rgm, branchCode, branchName);
//                    writePdfHeader(rgm, contentStream, leading, pagination);
//
//                    preProcessingBodyHeader(rgm, productName, previousMonthBalance, APBalance, activeAccount);
//                    writePdfBodyHeader(rgm, contentStream, leading);
//
//                    writePdfBody(rgm, lineFieldsMap, contentStream, leading);
//                    pageHeight++;

					str.setLength(0);
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
	
	private void addNewPage(PDPageContentStream contentStream, PDDocument doc, PDFont pdfFont, float fontSize,
			float startX, float startY) throws Exception {
		pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
		contentStream.endText();
		contentStream.close();
		PDPage page = new PDPage();
		doc.addPage(new PDPage());
		pagination++;
		contentStream = new PDPageContentStream(doc, page);
		contentStream.setFont(pdfFont, fontSize);
		contentStream.beginText();
		contentStream.newLineAtOffset(startX, startY);	
	}

	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In CashCardDailyTransactionSummary.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		// 1. initialize collection to use to sort the query data by card type
		HashMap<String, List<HashMap<String, ReportGenerationFields>>> productToLineFieldsMap = null;
		HashMap<String, List<HashMap<String, ReportGenerationFields>>> programToLineFieldsMap = null;
		List<HashMap<String, ReportGenerationFields>> lineFieldsMapList = null;
		HashSet<String> branchSet = null;
		String branchCode = null;
		String branchName = null;
		String productName = null;
		String previousMonthBalance = null;
		String APBalance = null;
		int activeAccount = 0;

		StringBuilder str = null;

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

					if (branchSet == null) {
						branchSet = new HashSet<String>();
					}

					if (str == null) {
						str = new StringBuilder();
					}

					str.append(lineFieldsMap.get("BRANCH CODE").getValue());
					str.append(",");
					str.append(lineFieldsMap.get("BRANCH NAME").getValue());
					branchSet.add(str.toString());

					str.setLength(0);

					str.append(lineFieldsMap.get("BRANCH CODE").getValue());
//                    branchCode = lineFieldsMap.get(ReportConstants.BRANCH_CODE).getValue();
//                    branchName = lineFieldsMap.get(ReportConstants.BRANCH_NAME).getValue();
//                    str.append(branchCode);
//                    str.append(",");
//                    str.append(branchName);

//                    previousMonthBalance = lineFieldsMap.get(ReportConstants.BALANCE).getValue();
					productName = lineFieldsMap.get(ReportConstants.CARD_PRODUCT).getValue();
//                    APBalance = lineFieldsMap.get(ReportConstants.TOTAL).getValue();
//                    activeAccount = Integer.parseInt(lineFieldsMap.get(ReportConstants.STATUS_ACTIVE).getValue());

					str.append(productName);
					str.append(",");
					str.append(previousMonthBalance);

					// add list of lineFieldsMap into product map
					if (productToLineFieldsMap == null) {
						productToLineFieldsMap = new HashMap<String, List<HashMap<String, ReportGenerationFields>>>();
					}

					if (productToLineFieldsMap.containsKey(str.toString())) {
						productToLineFieldsMap.get(str.toString()).add(lineFieldsMap);
					} else {
						lineFieldsMapList = new ArrayList<>();
						lineFieldsMapList.add(lineFieldsMap);
						productToLineFieldsMap.put(str.toString(), lineFieldsMapList);
					}

					for (String branch : branchSet) {
						preProcessingHeader(rgm, branch.split(",")[0], branch.split(",")[1]);
						writeHeader(rgm);
						for (Map.Entry<String, List<HashMap<String, ReportGenerationFields>>> branchMap : productToLineFieldsMap
								.entrySet()) {
//                            if(branchMap.getKey().split(",")[0].equals(branch.split(",")[0])){
							preProcessingBodyHeader(rgm, productName, previousMonthBalance, APBalance, activeAccount);
							writeBodyHeader(rgm);
//                                writeBody(rgm, lineFieldsMap);
							for (HashMap<String, ReportGenerationFields> m : branchMap.getValue()) {
								writeBody(rgm, m);
							}
//                            }
						}
					}

//                    preProcessingHeader(rgm, branchCode, branchName);
//                    writeHeader(rgm);

//                    preProcessingBodyHeader(rgm, productName, previousMonthBalance, APBalance, activeAccount);
//                    writeBodyHeader(rgm);

//                    writeBody(rgm, lineFieldsMap);

					str.setLength(0);

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

	private void preProcessingHeader(ReportGenerationMgr rgm, String brcCode, String brcName)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In CashCardDailyTransactionSummary.preProcessingHeader()");

		ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.BRANCH_CODE,
				ReportGenerationFields.TYPE_STRING, "BRANCH CODE:" + brcCode);
		ReportGenerationFields branchName = new ReportGenerationFields(ReportConstants.BRANCH_NAME,
				ReportGenerationFields.TYPE_STRING, "BRANCH NAME:" + brcName);
//        ReportGenerationFields dateMonth = new ReportGenerationFields(ReportConstants.TODAYS_DATE_VALUE,
//            ReportGenerationFields.TYPE_STRING, "For the month of" + month + "- Per Branch /  Bankwide" + rgm.getFileDate().format(DateTimeFormatter.ofPattern("MMyyyy")));
		getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		getGlobalFileFieldsMap().put(branchName.getFieldName(), branchName);
//        getGlobalFileFieldsMap().put(dateMonth.getFieldName(), dateMonth);

		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessingBodyHeader(ReportGenerationMgr rgm, String prodName, String prevMthBal, String APBal,
			int activeAcc) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In CashCardDailyTransactionSummary.preProcessingHeader()");

		ReportGenerationFields cardProductName = new ReportGenerationFields(ReportConstants.CARD_PRODUCT,
				ReportGenerationFields.TYPE_STRING, prodName);
		ReportGenerationFields previousMonthBalance = new ReportGenerationFields(ReportConstants.BALANCE,
				ReportGenerationFields.TYPE_STRING, "PREVIOUS MONTH AP BALANCE: " + prevMthBal);
		ReportGenerationFields APBalance = new ReportGenerationFields(ReportConstants.TOTAL,
				ReportGenerationFields.TYPE_STRING, "MTD AP BALANCE: " + APBal);
		ReportGenerationFields activeAccount = new ReportGenerationFields(ReportConstants.STATUS_ACTIVE,
				ReportGenerationFields.TYPE_STRING, "NUMBER OF ACTIVE ACCOUNT: " + activeAcc);
//        ReportGenerationFields activeAccount = new ReportGenerationFields("TOTAL_ACTIVE",
//            ReportGenerationFields.TYPE_STRING, "NUMBER OF ACTIVE ACCOUNTS : " + activeAcc);

		getGlobalFileFieldsMap().put(cardProductName.getFieldName(), cardProductName);
		getGlobalFileFieldsMap().put(previousMonthBalance.getFieldName(), previousMonthBalance);
		getGlobalFileFieldsMap().put(APBalance.getFieldName(), APBalance);
		getGlobalFileFieldsMap().put(activeAccount.getFieldName(), activeAccount);

		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

}
