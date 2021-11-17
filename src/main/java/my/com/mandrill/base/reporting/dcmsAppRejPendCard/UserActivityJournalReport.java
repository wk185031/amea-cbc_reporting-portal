package my.com.mandrill.base.reporting.dcmsAppRejPendCard;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class UserActivityJournalReport extends DCMSApproveRejectPendingCardReport {

	private final Logger logger = LoggerFactory.getLogger(UserActivityJournalReport.class);
	
	@Override
	protected PDPageContentStream executePdfBodyQuery(ReportGenerationMgr rgm, PDDocument doc, PDPage page,
			PDPageContentStream contentStream, PDRectangle pageSize, float leading, float startX, float startY,
			PDFont pdfFont, float fontSize) {
		logger.debug("In DCMSApproveRejectPendingCardReport.generateReport(): " + rgm.getFileNamePrefix());
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
				int recordCount = 0;

				if (rs.next()) {
					do {
						if (recordCount > 0 && recordCount % 50 == 0) {
							pageHeight = DEFAULT_PAGE_HEIGHT;
							contentStream.endText();
							contentStream.close();
							page = new PDPage(new PDRectangle(PDRectangle.A4.getHeight(), PDRectangle.A4.getWidth()));
							doc.addPage(page);
							pagination++;
							contentStream = new PDPageContentStream(doc, page);
							contentStream.setFont(pdfFont, fontSize);
							contentStream.beginText();
							contentStream.newLineAtOffset(startX, startY);
							writePdfHeader(rgm, contentStream, leading, pagination);
							contentStream.newLineAtOffset(0, -leading);
							pageHeight += 4;
							contentStream.newLineAtOffset(0, -leading);
							writePdfBodyHeader(rgm, contentStream, leading);
							pageHeight += 2;
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
									field.setValue(
											Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
								} else {
									field.setValue(result.toString());
								}
							} else {
								field.setValue("");
							}
							if ("FROM_DATA".equals(field.getFieldName()) && field.getValue() != null && !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution()));
							} else if ("TO_DATA".equals(field.getFieldName()) && field.getValue() != null && !field.getValue().trim().isEmpty()) {
								field.setValue(extractAccountNumberFromJson(field.getValue(), rgm.getInstitution()));
							}
						}

						writePdfBody(rgm, lineFieldsMap, contentStream, leading);
						pageHeight++;
						recordCount++;
					} while (rs.next());
				} else {
					contentStream.showText(ReportConstants.NO_RECORD);
				}

				addTotalNoOfItemToGlobalParam(recordCount);
				contentStream.newLineAtOffset(0, -leading);
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
	protected void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			String fieldValue = getFieldValue(rgm, field, fieldsMap);
			if (fieldValue.contains("|")) {
				String[] rows = fieldValue.split("\\|");
				for (int i=0; i< rows.length; i++) {
					if (i > 0) {
						contentStream.newLineAtOffset(0, -leading);	
						contentStream.showText(String.format("%161s", rows[i].trim()));
					} else {
						contentStream.showText(rows[i]);
					}
					
				}
			} else {
				contentStream.showText(getFieldValue(rgm, field, fieldsMap));
			}

			if (field.isEol()) {
				contentStream.newLineAtOffset(0, -leading);
			}
		}
	}
}
