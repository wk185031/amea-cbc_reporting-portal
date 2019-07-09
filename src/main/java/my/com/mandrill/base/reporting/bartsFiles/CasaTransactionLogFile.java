package my.com.mandrill.base.reporting.bartsFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class CasaTransactionLogFile extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(CasaTransactionLogFile.class);

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			writeHeader(rgm);
			executeBodyQuery(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
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

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In CasaTransactionLogFile.preProcessing()");
		addBatchPreProcessingFieldsToGlobalMap(rgm);
	}

	@Override
	protected void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In CasaTransactionLogFile.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (getGlobalFieldValue(field, true) == null) {
					line.append("");
				} else {
					line.append(getGlobalFieldValue(field, true));
				}
				line.append(getEol());
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					line.append("");
				} else {
					line.append(getGlobalFieldValue(field, true));
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String customData)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.FROM_ACCOUNT_NO:
			case ReportConstants.TO_ACCOUNT_NO:
				if (getFieldValue(field, fieldsMap, true).length() <= 16) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							String.format("%1$" + 16 + "s", getFieldValue(field, fieldsMap, true)).replace(' ', '0')));
				} else {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
				}
				break;
			case ReportConstants.SUBSCRIBER_ACCT_NUMBER:
				if (extractBillerSubn(customData).length() <= 16) {
					line.append(String.format("%1$" + 16 + "s", extractBillerSubn(customData)).replace(' ', '0'));
				} else {
					line.append(extractBillerSubn(customData));
				}
				break;
			default:
				if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
						|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.AMOUNT)) {
						line.append(String
								.format("%" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap, true))
								.replace(' ', '0').concat("00"));
					} else {
						line.append(String
								.format("%" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap, true))
								.replace(' ', '0'));
					}
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In CasaTransactionLogFile.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		String customData = null;
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
							} else if (key.equalsIgnoreCase(ReportConstants.CUSTOM_DATA)) {
								customData = result.toString();
								field.setValue(result.toString());
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap, customData);
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

	private String extractBillerSubn(String customData) {
		Pattern pattern = Pattern.compile("<([^<>]+)>([^<>]+)</\\1>");
		Matcher matcher = pattern.matcher(customData);
		Map<String, String> map = new HashMap<>();

		while (matcher.find()) {
			String xmlElem = matcher.group();
			String key = xmlElem.substring(1, xmlElem.indexOf('>'));
			String value = xmlElem.substring(xmlElem.indexOf('>') + 1, xmlElem.lastIndexOf('<'));
			map.put(key, value);
			if (map.get(ReportConstants.BILLER_SUBN) != null) {
				return map.get(ReportConstants.BILLER_SUBN);
			}
		}
		return "";
	}
}