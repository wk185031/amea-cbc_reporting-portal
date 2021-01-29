package my.com.mandrill.base.processor;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import javax.sql.DataSource;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.writer.CsvWriter;

public abstract class BaseReportProcessor implements IReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(BaseReportProcessor.class);
	private static final String ENCRYPTION_KEY_SUFFIX = "_ENCKEY";

	@Autowired
	private CsvWriter csvWriter;

	@Autowired
	private DataSource datasource;

	@Override
	public void process(ReportGenerationMgr rgm) {
		FileOutputStream out = null;
		File outputFile = createEmptyReportFile(rgm.getFileLocation(), rgm.getFileNamePrefix(),
				(rgm.isGenerate() ? rgm.getFileDate() : rgm.getYesterdayDate()));

		Connection conn = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		try {
			ReportContext currentContext = new ReportContext();
			currentContext.setTxnEndDateTime(rgm.getTxnEndDate());
			currentContext.setPredefinedFieldMap(initPredefinedFieldMap(rgm));
			currentContext.setDataMap(initDataMap(rgm));
			currentContext.setQuery(parseBodyQuery(rgm.getBodyQuery(), currentContext.getPredefinedFieldMap()));

			logger.debug("Execute query: {}", currentContext.getQuery());
			conn = datasource.getConnection();
			ps = conn.prepareStatement(currentContext.getQuery());
			rs = ps.executeQuery();

			out = new FileOutputStream(outputFile);

			writeReportHeader(out, rgm.getHeaderFields(), currentContext.getPredefinedFieldMap());

			while (rs.next()) {
				List<ReportGenerationFields> bodyFields = mapResultsetToField(extractBodyFields(rgm.getBodyFields()),
						rs);

				preProcessBodyHeader(currentContext, bodyFields, out);
				writeBodyHeader(currentContext, extractBodyHeaderFields(rgm.getBodyFields()), out);

				preProcessBodyData(currentContext, bodyFields, out);
				writeBodyData(currentContext, bodyFields, out);
			}

			// Write trailer for last group
			writeBodyTrailer(currentContext, extractBodyFields(rgm.getBodyFields()), out);
			writeReportTrailer(currentContext, parseFieldConfig(rgm.getTrailerFields()), out);
			out.close();
			logger.debug("Report generation complete. Total records={}", currentContext.getTotalRecord());
			
			postReportGeneration(outputFile);
			
		} catch (Exception e) {
			logger.debug("Failed to process file: {}", outputFile.getAbsolutePath(), e);
			if (outputFile != null && outputFile.exists()) {
				try {
					outputFile.delete();
				} catch (Exception e1) {
					logger.warn("Failed to delete failed report.", e1);
				}
			}
			throw new ReportGenerationException(outputFile.getName(), e);
		} finally {
			if (ps != null) {
				try {
					ps.close();
				} catch (Exception e2) {
					logger.warn("Failed to close preparedStatement.");
				}

			}
			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e3) {
					logger.warn("Failed to close resultSet.");
				}

			}

			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e4) {
					logger.warn("Failed to close connection.");
				}
			}
		}
	}
	
	protected void postReportGeneration(File outputFile) throws Exception {
		
	}

	protected Map<String, ReportGenerationFields> initPredefinedFieldMap(ReportGenerationMgr rgm) {
		Map<String, ReportGenerationFields> predefinedDataMap = new HashMap<>();

		ReportGenerationFields todaysDateValue = new ReportGenerationFields(ReportConstants.TODAYS_DATE_VALUE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnEndDate().toLocalDate().toString());
		ReportGenerationFields runDateValue = new ReportGenerationFields(ReportConstants.RUNDATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields timeValue = new ReportGenerationFields(ReportConstants.TIME_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields asOfDateValue = new ReportGenerationFields(ReportConstants.AS_OF_DATE_VALUE,
				ReportGenerationFields.TYPE_DATE, rgm.getTxnStartDate().toLocalDate().toString());

		predefinedDataMap.put(todaysDateValue.getFieldName(), todaysDateValue);
		predefinedDataMap.put(runDateValue.getFieldName(), runDateValue);
		predefinedDataMap.put(timeValue.getFieldName(), timeValue);
		predefinedDataMap.put(asOfDateValue.getFieldName(), asOfDateValue);

		initQueryPlaceholder(rgm, predefinedDataMap);

		return predefinedDataMap;
	}

	protected Map<String, Map<String, ?>> initDataMap(ReportGenerationMgr rgm) {
		return new HashMap<>();
	}

	protected void initQueryPlaceholder(ReportGenerationMgr rgm,
			Map<String, ReportGenerationFields> predefinedDataMap) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);

		ReportGenerationFields txnDate = new ReportGenerationFields(ReportConstants.PARAM_TXN_DATE,
				ReportGenerationFields.TYPE_STRING,
				"TXN.TRL_SYSTEM_TIMESTAMP >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
						+ "') AND TXN.TRL_SYSTEM_TIMESTAMP < TO_DATE('" + txnEnd + "','"
						+ ReportConstants.FORMAT_TXN_DATE + "')");
		predefinedDataMap.put(txnDate.getFieldName(), txnDate);
	}

	protected List<ReportGenerationFields> parseFieldConfig(String jsonConfig) throws Exception {
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> fields = null;

		if (jsonConfig != null) {
			fields = objectMapper.readValue(jsonConfig.getBytes(), new TypeReference<List<ReportGenerationFields>>() {
			});
		}

		if (fields != null && fields.size() > 0) {
			fields.get(fields.size() - 1).setEndOfSection(true);
		}
		return fields;
	}

	protected String parseBodyQuery(String bodyQuery, Map<String, ReportGenerationFields> predefinedDataMap) {
		if (bodyQuery != null && !bodyQuery.trim().isEmpty()) {
			Pattern p = Pattern.compile("[{]\\w+,*\\w*[}]");
			Matcher m = p.matcher(bodyQuery);
			StringBuffer sb = new StringBuffer();
			while (m.find()) {
				String paramName = m.group().substring(1, m.group().length() - 1);
				if (predefinedDataMap.containsKey(paramName)) {
					String value = predefinedDataMap.get(paramName).format();
					m.appendReplacement(sb, value);
				}
			}
			m.appendTail(sb);
			return sb.toString();
		}
		return bodyQuery;
	}

	protected List<ReportGenerationFields> extractBodyHeaderFields(String bodyFieldConfig)
			throws JSONException, JsonParseException, JsonMappingException, IOException {

		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> bodyHeaderFields = null;
		if (bodyFieldConfig != null) {
			bodyHeaderFields = objectMapper.readValue(bodyFieldConfig.getBytes(),
					new TypeReference<List<ReportGenerationFields>>() {
					});
			bodyHeaderFields = bodyHeaderFields.stream()
					.filter((reportGenerationField) -> reportGenerationField.isBodyHeader() == true)
					.collect(Collectors.toList());
			if (bodyHeaderFields.size() > 0) {
				bodyHeaderFields.get(bodyHeaderFields.size() - 1).setEndOfSection(true);
			}
		}
		return bodyHeaderFields;
	}

	protected List<ReportGenerationFields> extractBodyFields(String bodyFieldConfig)
			throws JSONException, JsonParseException, JsonMappingException, IOException {
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> bodyFields = null;
		if (bodyFieldConfig != null) {
			bodyFields = objectMapper.readValue(bodyFieldConfig, new TypeReference<List<ReportGenerationFields>>() {
			});
			bodyFields = bodyFields.stream()
					.filter((reportGenerationField) -> reportGenerationField.isBodyHeader() == false)
					.collect(Collectors.toList());
			if (bodyFields.size() > 0) {
				bodyFields.get(bodyFields.size() - 1).setEndOfSection(true);
			}
		}
		return bodyFields;
	}

	protected File createEmptyReportFile(String reportPathStr, String fileNamePrefix, LocalDate txnDate) {
		String txnDateStr = txnDate.format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
		String filename = fileNamePrefix + "_" + txnDateStr + ReportConstants.CSV_FORMAT;

		File reportPath = new File(reportPathStr);
		if (!reportPath.exists()) {
			reportPath.mkdirs();
		}

		Path filePath = Paths.get(reportPath.getAbsolutePath(), filename);
		return filePath.toFile();
	}

	protected void writeReportHeader(FileOutputStream out, String headerFieldConfig,
			Map<String, ReportGenerationFields> predefinedDataMap) throws Exception {
		csvWriter.writeLine(out, parseFieldConfig(headerFieldConfig), predefinedDataMap);
		csvWriter.writeLine(out, CsvWriter.EOL);
	}

	abstract protected void preProcessBodyHeader(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception;

	protected void writeBodyHeader(ReportContext context, List<ReportGenerationFields> bodyHeaderFields,
			FileOutputStream out) throws Exception {
		if (context.isWriteBodyHeader()) {
			csvWriter.writeLine(out, bodyHeaderFields, null);
			context.setWriteBodyHeader(false);
		}
	}

	abstract protected void preProcessBodyData(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception;

	protected void writeBodyData(ReportContext context, List<ReportGenerationFields> bodyFields, FileOutputStream out)
			throws Exception {

		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : bodyFields) {
			if (field.isGroup()) {
				handleGroupFieldInBody(context, field, line);
			} else {
				String fieldValue = getFormattedFieldValue(field, context);
				if (ReportGenerationFields.TYPE_NUMBER.equals(field.getFieldType())
						|| ReportGenerationFields.TYPE_DECIMAL.equals(field.getFieldType())) {
					line.append("\"" + fieldValue + "\"");
					addToSumField(context, field);
				} else {
					line.append(fieldValue);
				}
				line.append(field.getDelimiter());

				if (field.isEol()) {
					line.append(CsvWriter.EOL);
				}
			}
		}

		csvWriter.writeLine(out, line.toString());
		context.setTotalRecord(context.getTotalRecord() + 1);
	}

	protected void addToSumField(ReportContext context, ReportGenerationFields field) {
		if (field.isSumAmount() && field.getValue() != null && !field.getValue().trim().isEmpty()) {
			if (context.getSubTotal().containsKey(field.getFieldName())) {
				context.getSubTotal().put(field.getFieldName(),
						context.getSubTotal().get(field.getFieldName()).add(new BigDecimal(field.getValue())));
			} else {
				context.getSubTotal().put(field.getFieldName(), new BigDecimal(field.getValue()));
			}
		}
	}

	protected void handleGroupFieldInBody(ReportContext context, ReportGenerationFields field, StringBuilder bodyLine) {
		bodyLine.append(field.getValue()).append(CsvWriter.EOL);
	}

	abstract protected void writeBodyTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) throws Exception;

	protected String getFormattedFieldValue(ReportGenerationFields field, ReportContext context) {
		if (field.getDefaultValue() != null && !field.getDefaultValue().isEmpty()) {
			return field.getDefaultValue();
		} else if (field.getValue() != null && !field.getValue().isEmpty()) {
			return field.format();
		} else if (context.getPredefinedFieldMap() != null
				&& context.getPredefinedFieldMap().containsKey(field.getFieldName())) {
			field.setValue(context.getPredefinedFieldMap().get(field.getFieldName()).getValue());
			return field.format();
		}
		return field.getValue();
	}

	protected List<ReportGenerationFields> mapResultsetToField(List<ReportGenerationFields> bodyFields, ResultSet rs)
			throws Exception {
		for (ReportGenerationFields f : bodyFields) {
			if (f.getFieldName() == null) {
				continue;
			}
			Object result = rs.getObject(f.getFieldName());
			if (result != null) {
				if (result instanceof Date) {
					f.setValue(Long.toString(((Date) result).getTime()));
				} else if (result instanceof oracle.sql.TIMESTAMP) {
					f.setValue(Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
				} else if (result instanceof oracle.sql.DATE) {
					f.setValue(Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
				} else {
					f.setValue(result.toString());
				}
			} else {
				f.setValue("");
			}

			if (f.isDecrypt()) {
				String decryptionKey = f.getFieldName() + ENCRYPTION_KEY_SUFFIX;
				Object decryptionKeyValue = rs.getObject(decryptionKey);
				f.setDecryptionKey(decryptionKeyValue == null ? null : decryptionKeyValue.toString());
			}
		}
		return bodyFields;
	}

	protected void writeReportTrailer(ReportContext context, List<ReportGenerationFields> bodyFields,
			FileOutputStream out) {

	}
}
