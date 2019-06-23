package my.com.mandrill.base.reporting.glHandoffBlocksheet;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class GLHandoffBlocksheetRecycler extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffBlocksheetRecycler.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private boolean firstRecord = false;
	private boolean newBranch = false;
	private boolean endBranch = false;

	@Override
	public void processPdfRecord(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetRecycler.processPdfRecord()");
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
		pagination = 0;
		try {
			doc = new PDDocument();
			String branchCode = null;

			separateQuery(rgm);
			preProcessing(rgm);

			Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();

			while (branchCodeItr.hasNext()) {
				branchCode = branchCodeItr.next();
				if (!endBranch && !newBranch) {
					page = new PDPage();
					doc.addPage(page);
					firstRecord = true;
					newBranch = true;
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

				if (endBranch && newBranch) {
					endBranch = false;
					pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
					page = new PDPage();
					doc.addPage(page);
					firstRecord = true;
					pagination++;
					contentStream = new PDPageContentStream(doc, page);
					contentStream.setFont(pdfFont, fontSize);
					contentStream.beginText();
					contentStream.newLineAtOffset(startX, startY);
					rgm.setBodyQuery(getDebitBodyQuery());
					rgm.setTrailerQuery(getDebitTrailerQuery());
					pdfProcessingDetail(rgm, branchCode, contentStream, doc, page, pageSize, leading, startX, startY,
							pdfFont, fontSize);
				} else {
					rgm.setBodyQuery(getDebitBodyQuery());
					rgm.setTrailerQuery(getDebitTrailerQuery());
					pdfProcessingDetail(rgm, branchCode, contentStream, doc, page, pageSize, leading, startX, startY,
							pdfFont, fontSize);
				}

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
				pdfProcessingDetail(rgm, branchCode, contentStream, doc, page, pageSize, leading, startX, startY,
						pdfFont, fontSize);
				endBranch = true;
			}

			saveFile(rgm, doc);
		} catch (Exception e) {
			rgm.errors++;
			logger.error("Error in generating " + rgm.getFileNamePrefix() + "_" + ReportConstants.PDF_FORMAT, e);
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

	private void pdfProcessingDetail(ReportGenerationMgr rgm, String branchCode, PDPageContentStream contentStream,
			PDDocument doc, PDPage page, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In GLHandoffBlocksheetRecycler.pdfProcessingDetail()");
		try {
			preProcessing(rgm, branchCode);
			writePdfHeader(rgm, contentStream, leading, pagination);
			pageHeight += 4;
			writePdfBodyHeader(rgm, contentStream, leading);
			pageHeight += 2;
			contentStream = executePdfBodyQuery(rgm, doc, page, contentStream, pageSize, leading, startX, startY,
					pdfFont, fontSize, branchCode);
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
			rgm.errors++;
			logger.error("Error in pdfProcessingDetail", e);
		}
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		String branchCode = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 0;
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			rgm.setTrailerQuery(rgm.getFixTrailerQuery());
			separateQuery(rgm);
			preProcessing(rgm);

			Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
			while (branchCodeItr.hasNext()) {
				branchCode = branchCodeItr.next();
				firstRecord = true;
				pagination++;
				rgm.setBodyQuery(getDebitBodyQuery());
				rgm.setTrailerQuery(getDebitTrailerQuery());
				processingDetail(rgm, branchCode);

				firstRecord = true;
				pagination++;
				rgm.setBodyQuery(getCreditBodyQuery());
				rgm.setTrailerQuery(getCreditTrailerQuery());
				processingDetail(rgm, branchCode);
			}
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException e) {
			rgm.errors++;
			logger.error("Error in generating TXT file", e);
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

	private void processingDetail(ReportGenerationMgr rgm, String branchCode) {
		logger.debug("In GLHandoffBlocksheetRecycler.processingDetail()");
		try {
			preProcessing(rgm, branchCode);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm, branchCode);
			executeTrailerQuery(rgm);
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in processingDetail", e);
		}
	}

	@Override
	protected SortedSet<String> filterByBranchCode(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetRecycler.filterByBranchCode()");
		String branchCode = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedSet<String> branchCodeList = new TreeSet<>();
		rgm.setBodyQuery(getCriteriaQuery());
		String query = getBodyQuery(rgm);
		logger.info("Query for filter branch code: {}", query);

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
		logger.debug("In GLHandoffBlocksheetRecycler.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByBranchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffBlocksheetRecycler.preProcessing()");
		if (filterByBranchCode != null && rgm.getBodyQuery() != null) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffBlocksheetRecycler.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setDebitBodyQuery(rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
					rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCriteriaQuery(getDebitBodyQuery());
		}

		if (rgm.getTrailerQuery() != null) {
			setDebitTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setCreditTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String branchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (!firstRecord) {
				switch (field.getFieldName()) {
				case ReportConstants.BRANCH_CODE:
				case ReportConstants.GL_ACCOUNT_NUMBER:
				case ReportConstants.GL_ACCOUNT_NAME:
				case ReportConstants.DESCRIPTION:
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					}
					break;
				default:
					switch (field.getFieldName()) {
					case ReportConstants.CODE:
						if (getFieldValue(field, fieldsMap, true).length() <= 6) {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s", String
									.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
						} else {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						break;
					case ReportConstants.ACCOUNT_NUMBER:
						if (getFieldValue(field, fieldsMap, true).length() <= 16) {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ',
											'0')));
						} else {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						break;
					default:
						if (getFieldValue(field, fieldsMap, true) == null) {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
						} else {
							line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						break;
					}
					break;
				}
			} else {
				switch (field.getFieldName()) {
				case ReportConstants.GL_ACCOUNT_NUMBER:
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							branchCode + getFieldValue(field, fieldsMap, true)));
					break;
				case ReportConstants.CODE:
					if (getFieldValue(field, fieldsMap, true).length() <= 6) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", String
								.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				case ReportConstants.ACCOUNT_NUMBER:
					if (getFieldValue(field, fieldsMap, true).length() <= 16) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", String
								.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				default:
					if (getFieldValue(field, fieldsMap, true) == null) {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
					} else {
						line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					break;
				}
			}
		}
		firstRecord = false;
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		logger.debug("In GLHandoffBlocksheetRecycler.writePdfBodyHeader()");
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
			PDPageContentStream contentStream, float leading, String branchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (!firstRecord) {
				switch (field.getFieldName()) {
				case ReportConstants.BRANCH_CODE:
				case ReportConstants.GL_ACCOUNT_NUMBER:
				case ReportConstants.GL_ACCOUNT_NAME:
				case ReportConstants.DESCRIPTION:
					if (field.isEol()) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						contentStream.newLineAtOffset(0, -leading);
					} else {
						if (field.getFieldName().equalsIgnoreCase(ReportConstants.GL_ACCOUNT_NAME)) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						}
					}
					break;
				default:
					if (field.isEol()) {
						if (getFieldValue(field, fieldsMap, true) == null) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						contentStream.newLineAtOffset(0, -leading);
					} else {
						switch (field.getFieldName()) {
						case ReportConstants.CODE:
							if (getFieldValue(field, fieldsMap, true).length() <= 6) {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										String.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true))
												.replace(' ', '0')));
							} else {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										getFieldValue(field, fieldsMap, true)));
							}
							break;
						case ReportConstants.ACCOUNT_NUMBER:
							if (getFieldValue(field, fieldsMap, true).length() <= 16) {
								contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
										String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true))
												.replace(' ', '0')));
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
					break;
				}
			} else {
				if (field.isEol()) {
					if (getFieldValue(field, fieldsMap, true) == null) {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", ""));
					} else {
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								getFieldValue(field, fieldsMap, true)));
					}
					contentStream.newLineAtOffset(0, -leading);
				} else {
					switch (field.getFieldName()) {
					case ReportConstants.GL_ACCOUNT_NUMBER:
						contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
								branchCode + getFieldValue(field, fieldsMap, true)));
						break;
					case ReportConstants.CODE:
						if (getFieldValue(field, fieldsMap, true).length() <= 6) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s", String
									.format("%1$" + 6 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
						} else {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									getFieldValue(field, fieldsMap, true)));
						}
						break;
					case ReportConstants.ACCOUNT_NUMBER:
						if (getFieldValue(field, fieldsMap, true).length() <= 16) {
							contentStream.showText(String.format("%1$" + field.getPdfLength() + "s",
									String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ',
											'0')));
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
		firstRecord = false;
	}

	private PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize, String branchCode) {
		logger.debug("In GLHandoffBlocksheetRecycler.executePdfBodyQuery()");
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
					if (pageHeight > totalHeight && !endBranch) {
						endBranch = false;
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
					writePdfBody(rgm, lineFieldsMap, contentStream, leading, branchCode);
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
}