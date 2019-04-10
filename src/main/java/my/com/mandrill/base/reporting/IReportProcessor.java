package my.com.mandrill.base.reporting;

import java.io.IOException;
import java.util.HashMap;

import org.json.JSONException;

public interface IReportProcessor {

	void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException;

	void postProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException;

	void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException;

	void writeBodyHeaderLine(ReportGenerationMgr rgm) throws IOException, JSONException;

	void writeBodyLine(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException;

	void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException;

	void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException;

	String writePdfHeader(ReportGenerationMgr rgm) throws IOException, JSONException;

	String writePdfBodyHeaderLine(ReportGenerationMgr rgm) throws IOException, JSONException;

	String writePdfBodyLine(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException;

	String writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException;

	String getFullFileName(String partialFileName, ReportGenerationMgr rgm);

	String getQuery(ReportGenerationMgr rgm);
}
