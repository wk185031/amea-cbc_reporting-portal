package my.com.mandrill.base.writer;

import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.reporting.ReportGenerationFields;

@Component
public class CsvWriter implements IFileWriter {

	private final Logger logger = LoggerFactory.getLogger(CsvWriter.class);
	protected static final String EOL = System.lineSeparator();

	@Override
	public void writeLine(FileOutputStream out, List<ReportGenerationFields> fields,
			Map<String, ReportGenerationFields> dataMap) throws IOException {
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getDefaultValue() != null && !field.getDefaultValue().isEmpty()) {
				line.append(field.getDefaultValue());
			} else if (field.getValue() != null && !field.getValue().isEmpty()) {
				line.append(field.getValue());
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
		line.append(EOL);

		out.write(line.toString().getBytes());
	}

	@Override
	public void writeBodyLine(FileOutputStream out, List<ReportGenerationFields> fields, ResultSet rs) throws Exception {
		while(rs.next()) {
			Object result = null;
			
			for (ReportGenerationFields field : fields) {
				result = rs.getObject(field.getFileName());
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
				
//				if (field.isDecrypt()) {
//					decryptValue(field, );
//				}
			}	
			writeLine(out, fields, null);
		}	
	}
	
	private void decryptValue(ReportGenerationFields field) {
		//TODO
//		if (field.getTagValue() != null && !field.getTagValue().trim().isEmpty()) {
//			String customData = SecureString
//					.fromDatabase(field.getValue(), ekyId).getClear();
//			String tagData = getTaggedData(customData, field.getTagValue());
//			field.setValue(tagData);
//			
//		} else {
//			field.setValue(SecurePANField.fromDatabase(field.getValue(), ekyId).getClear());
//		}
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
