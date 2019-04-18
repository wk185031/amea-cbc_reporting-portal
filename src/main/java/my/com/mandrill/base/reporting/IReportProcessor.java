package my.com.mandrill.base.reporting;

import java.io.IOException;
import java.util.HashMap;

import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.json.JSONException;

public interface IReportProcessor {

	void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException;

	void postProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException;

	void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException;

	void writeHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException;

	void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException;

	void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException;

	void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap, int success,
			int pagination)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException;

	void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException;

	void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException;

	void writePdfHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading, int pagination)
			throws IOException, JSONException;

	void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException;

	void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, int success, int pagination)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException;

	void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException;

	String getBodyQuery(ReportGenerationMgr rgm);

	String getTrailerQuery(ReportGenerationMgr rgm);

}
