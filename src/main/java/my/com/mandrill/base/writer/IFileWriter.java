package my.com.mandrill.base.writer;

import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

import my.com.mandrill.base.reporting.ReportGenerationFields;

public interface IFileWriter {

	public void writeLine(FileOutputStream out, List<ReportGenerationFields> fields,
			Map<String, ReportGenerationFields> data) throws IOException;
	
	public void writeBodyLine(FileOutputStream out, List<ReportGenerationFields> fields, ResultSet rs) throws Exception;

}
