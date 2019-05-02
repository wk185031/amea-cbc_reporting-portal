package my.com.mandrill.base.reporting.atmTransactionListsBranch.TransactionSummaryGrandTotal;

import java.io.File;
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

public class TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts extends GeneralReportProcess {

	private final Logger logger = LoggerFactory
			.getLogger(TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int success = 0;
	private int errors = 0;
	private int pagination = 0;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.processPdfRecord()");
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
			String branchName = null;
			String terminal = null;

			preProcessing(rgm);

			contentStream.setFont(pdfFont, fontSize);
			contentStream.beginText();
			contentStream.newLineAtOffset(startX, startY);

			for (SortedMap.Entry<String, Map<String, Set<String>>> branchCodeMap : filterByCriteria(rgm).entrySet()) {
				branchCode = branchCodeMap.getKey();
				for (SortedMap.Entry<String, Set<String>> branchNameMap : branchCodeMap.getValue().entrySet()) {
					branchName = branchNameMap.getKey();
					preProcessing(rgm, branchCode, branchName, terminal);
					writePdfHeader(rgm, contentStream, leading, pagination, branchCode, branchName);
					pageHeight += 4;
					for (String terminalMap : branchNameMap.getValue()) {
						terminal = terminalMap;
						contentStream.showText(ReportConstants.TERMINAL + " " + terminal + " - " + branchName);
						pageHeight += 1;
						contentStream.newLineAtOffset(0, -leading);
						writePdfBodyHeader(rgm, contentStream, leading);
						pageHeight += 2;
						preProcessing(rgm, branchCode, branchName, terminal);
						contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX,
								startY, pdfFont, fontSize);
						pageHeight += 1;
						executePdfTrailerQuery(rgm, doc, contentStream, pageSize, leading, startX, startY, pdfFont,
								fontSize);
						pageHeight += 1;
						contentStream.newLineAtOffset(0, -leading);
						pageHeight += 1;
					}
				}
			}
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

	private SortedMap<String, Map<String, Set<String>>> filterByCriteria(ReportGenerationMgr rgm) {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.filterByCriteria()");
		String branchCode = null;
		String branchName = null;
		String terminal = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedMap<String, Map<String, Set<String>>> criteriaMap = new TreeMap<String, Map<String, Set<String>>>();
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
							if (key.equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								branchName = result.toString();
							}
							if (key.equalsIgnoreCase(ReportConstants.TERMINAL)) {
								terminal = result.toString();
							}
						}
					}

					if (criteriaMap.get(branchCode) == null) {
						Map<String, Set<String>> tmpCriteriaMap = new HashMap<String, Set<String>>();
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
		return criteriaMap;
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.preProcessing()");
		if (rgm.getBodyQuery() != null
				&& rgm.getBodyQuery().indexOf("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}") != 0
				&& rgm.getBodyQuery().indexOf("AND {" + ReportConstants.PARAM_BRANCH_NAME + "}") != 0
				&& rgm.getBodyQuery().indexOf("AND {" + ReportConstants.PARAM_TERMINAL + "}") != 0) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_NAME + "}", "")
					.replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));
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

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode, String filterByBranchName,
			String filterByTerminal) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.preProcessing()");
		if (filterByBranchCode != null && filterByBranchName != null && rgm.getTmpBodyQuery() != null
				&& rgm.getTmpBodyQuery().indexOf("AND {" + ReportConstants.PARAM_TERMINAL + "}") != 0) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery().replace("AND {" + ReportConstants.PARAM_TERMINAL + "}", ""));

			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			ReportGenerationFields branchName = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_NAME,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_NAME) = '" + filterByBranchName + "'");

			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
			getGlobalFileFieldsMap().put(branchName.getFieldName(), branchName);
		}

		if (filterByTerminal != null && rgm.getTmpBodyQuery() != null) {
			rgm.setBodyQuery(rgm.getTmpBodyQuery());
			ReportGenerationFields terminal = new ReportGenerationFields(ReportConstants.PARAM_TERMINAL,
					ReportGenerationFields.TYPE_STRING, "TRIM(AST.AST_TERMINAL_ID) = '" + filterByTerminal + "'");
			getGlobalFileFieldsMap().put(terminal.getFieldName(), terminal);
		}
	}

	private void addPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.addPreProcessingFieldsToGlobalMap()");
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
				logger.debug("txnStartDate or txnEndDate is empty or null");
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

	private void writePdfHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading,
			int pagination, String branchCode, String branchName) throws IOException, JSONException {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.writePdfHeader()");
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

	private void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.writePdfBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					contentStream.newLineAtOffset(0, -leading);
				} else {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
					contentStream.newLineAtOffset(0, -leading);
				}
			} else {
				if (field.isFirstField()) {
					contentStream.showText(String.format("%1$2s", "")
							+ String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				} else if (getGlobalFieldValue(field, true) == null) {
					contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
				} else {
					contentStream.showText(String.format("%1$-" + field.getPdfLength() + "s", field.getFieldName()));
				}
			}
		}
	}

	private void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (!field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_CODE)
					&& !field.getFieldName().equalsIgnoreCase(ReportConstants.BRANCH_NAME)
					&& !field.getFieldName().equalsIgnoreCase(ReportConstants.TERMINAL)) {
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
					if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
				}
			} else {
				// Do not print
			}
		}
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.execute()");
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading);
					success++;
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

	private void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.writePdfTrailer()");
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

	private void executePdfTrailerQuery(ReportGenerationMgr rgm, PDDocument doc, PDPageContentStream contentStream,
			PDRectangle pageSize, float leading, float startX, float startY, PDFont pdfFont, float fontSize) {
		logger.debug("In TransactionSummaryGrandTotalOnUsAndOtherBranchesAccounts.executePdfTrailerQuery()");
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
}