package my.com.mandrill.base.processor;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONException;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.reporting.Column;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;

public abstract class BaseReportProcessor implements IReportProcessor {

	protected Map<String, ReportGenerationFields> initPredefinedDataMap() {
		Map<String, ReportGenerationFields> predefinedDataMap = new HashMap<>();
		
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01);
		ReportGenerationFields todaysDateValue = new ReportGenerationFields(ReportConstants.TODAYS_DATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields runDateValue = new ReportGenerationFields(ReportConstants.RUNDATE_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		ReportGenerationFields timeValue = new ReportGenerationFields(ReportConstants.TIME_VALUE,
				ReportGenerationFields.TYPE_DATE, Long.toString(new Date().getTime()));
		
		predefinedDataMap.put(todaysDateValue.getFieldName(), todaysDateValue);
		predefinedDataMap.put(runDateValue.getFieldName(), runDateValue);
		predefinedDataMap.put(timeValue.getFieldName(), timeValue);
		
		return predefinedDataMap;
	}
	
	protected List<ReportGenerationFields> parseFieldConfig(String jsonConfig) throws Exception {
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> fields = null;

		if (jsonConfig != null) {
			fields = objectMapper.readValue(jsonConfig.getBytes(), new TypeReference<List<ReportGenerationFields>>() {
			});
		}

		if (fields.size() > 0) {
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
}
