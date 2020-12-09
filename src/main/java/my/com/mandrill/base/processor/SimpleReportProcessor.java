package my.com.mandrill.base.processor;

import java.io.File;
import java.io.FileOutputStream;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Map;

import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.writer.CsvWriter;

@Component
public class SimpleReportProcessor extends BaseReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(SimpleReportProcessor.class);

	@Autowired
	private CsvWriter csvWriter;
	
	@Autowired
	private DataSource datasource;
	
	public void process(ReportGenerationMgr rgm) {
		FileOutputStream out;
		File outputFile = createEmptyReportFile(rgm.getFileLocation(), rgm.getFileNamePrefix(),
				(rgm.isGenerate() ? rgm.getFileDate() : rgm.getYesterdayDate()));

		ResultSet rs = null;
		PreparedStatement ps = null;
		
		try {			
			out = new FileOutputStream(outputFile);
			
			Map<String, ReportGenerationFields> predefinedDataMap = initPredefinedDataMap();
			Map<String, ReportGenerationFields> bodyFieldMap = null;
			
			//TODO: Daily vs Monthly
			
			//header
			csvWriter.writeLine(out, parseFieldConfig(rgm.getHeaderFields()), predefinedDataMap);
			
			//body header
			csvWriter.writeLine(out, parseFieldConfig(rgm.getBodyFields()), predefinedDataMap);
			
			//body data
			String query = parseBodyQuery(rgm.getBodyQuery(), predefinedDataMap);
			ps = datasource.getConnection().prepareStatement(query);
			rs = ps.executeQuery();
			csvWriter.writeBodyLine(out, parseFieldConfig(rgm.getBodyFields()), rs);
			
//			writeHeader(out, rgm.getHeaderFields());
//			writeBodyHeader(out);
//			writeBodyData(out);
//			writeTrailer(out);
		} catch (Exception e) {
			logger.debug("Failed to process file:{}", outputFile.getAbsolutePath(), e);
			if (outputFile.exists()) {
				try {
					outputFile.delete();
				} catch (Exception e1) {
					logger.warn("Failed to delete failed report.", e1);
				}			
			}
			throw new ReportGenerationException(outputFile.getName(), e);
		}
	}
	
	

//	public void writeHeader(FileOutputStream out, String headerFieldConfig) throws Exception {
//		List<ReportGenerationFields> headerFields = parseFieldConfig(headerFieldConfig);
//		
//		StringBuilder line = new StringBuilder();
//		for (ReportGenerationFields field : headerFields) {
//			line.append(field.getValueWithDefault());
//			line.append(field.getDelimiter());
//			
//			if (field.isEol()) {
//				line.append(field.getDelimiter());
//				line.append(EOL);
//			}
//		}
//		line.append(EOL);		
//	}

	public void writeBodyHeader(FileOutputStream out) {

	}

	public void writeBodyData(FileOutputStream out) {

	}

	public void writeTrailer(FileOutputStream out) {

	}

}
