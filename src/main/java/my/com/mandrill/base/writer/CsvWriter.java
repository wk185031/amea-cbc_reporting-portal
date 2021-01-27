package my.com.mandrill.base.writer;

import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.StringEscapeUtils;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.reporting.ReportGenerationFields;

@Component
public class CsvWriter implements IFileWriter {

	public static final String DEFAULT_DELIMITER = ",";
	public static final String DELIMITER_SEMICOLON = ";";
	public static final String EOL = System.lineSeparator();

	@Override
	public void writeLine(FileOutputStream out, String line) throws IOException {
		StringBuilder lineBuilder = new StringBuilder(line);
		out.write(lineBuilder.toString().getBytes());
	}

	@Override
	public void writeLine(FileOutputStream out, List<ReportGenerationFields> fields,
			Map<String, ReportGenerationFields> dataMap) throws IOException {
		StringBuilder line = new StringBuilder();

		for (ReportGenerationFields field : fields) {
			if (field.isGroup()) {
				// skip grouping body field
				continue;
			}
			if (field.getDefaultValue() != null && !field.getDefaultValue().isEmpty()) {
				line.append(field.getDefaultValue());
			} else if (field.getValue() != null && !field.getValue().isEmpty()) {
				line.append(field.format());
			} else if (dataMap != null && dataMap.containsKey(field.getFieldName())) {
				field.setValue(dataMap.get(field.getFieldName()).getValue());
				line.append(field.format());
			}
			line.append(field.getDelimiter());

			if (field.isEol()) {
				line.append(field.getDelimiter());
				line.append(EOL);
			}
		}
		out.write(line.toString().getBytes());
	}

	@Override
	public void writeBodyLine(FileOutputStream out, List<ReportGenerationFields> fields, ResultSet rs)
			throws Exception {
		Map<String, ReportGenerationFields> groupingMap = new HashMap<>();

		while (rs.next()) {
			Object result = null;

			for (ReportGenerationFields field : fields) {
				if (result != null) {
					if (result instanceof Date) {
						field.setValue(Long.toString(((Date) result).getTime()));
					} else if (result instanceof oracle.sql.TIMESTAMP) {
						field.setValue(Long.toString(((oracle.sql.TIMESTAMP) result).timestampValue().getTime()));
					} else if (result instanceof oracle.sql.DATE) {
						field.setValue(Long.toString(((oracle.sql.DATE) result).timestampValue().getTime()));
					} else {
						field.setValue(result.toString());
					}
				} else {
					field.setValue("");
				}

			}
			writeLine(out, fields, groupingMap);
		}
	}

	public String getTaggedData(String customData, String tag) {
		if (customData == null || tag == null) {
			return null;
		}

		String xmlTag = "<" + tag + ">";
		int beginIndex = customData.indexOf(xmlTag) + xmlTag.length();

		if (beginIndex < xmlTag.length()) {
			return null;
		}

		int endIndex = customData.indexOf("<", beginIndex);

		if (beginIndex >= endIndex) {
			return null;
		} else {
			String beforeValue = customData.substring(beginIndex, endIndex);
			return StringEscapeUtils.unescapeXml(beforeValue);
		}
	}
}
