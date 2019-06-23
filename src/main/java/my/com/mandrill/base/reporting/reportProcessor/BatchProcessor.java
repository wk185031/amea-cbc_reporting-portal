package my.com.mandrill.base.reporting.reportProcessor;

import java.io.File;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;

public class BatchProcessor extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(BatchProcessor.class);

	@Override
	public void processTxtRecord(ReportGenerationMgr rgm) {
		logger.debug("In BatchProcessor.processTxtRecord()");
		File file = null;
		String txnDate = null;
		String fileLocation = rgm.getFileLocation();
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);

		try {
			if (rgm.isGenerate() == true) {
				txnDate = df.format(rgm.getFileDate());
			} else {
				txnDate = df.format(rgm.getYesterdayDate());
			}

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}
					file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "_" + txnDate + "_" + "001"
							+ ReportConstants.TXT_FORMAT);
					execute(file, rgm);
				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception("Errors when generating" + rgm.getFileNamePrefix() + "_" + txnDate
						+ ReportConstants.TXT_FORMAT);
			}
		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + "_" + txnDate + "_" + "001"
					+ ReportConstants.TXT_FORMAT, e);
		}
	}

	protected void execute(File file, ReportGenerationMgr rgm) {
		// To be overriden
	}
	
	@Override
	protected List<String> filterByGlDescription(ReportGenerationMgr rgm) {
		logger.debug("In BatchProcessor.filterByGlDescription()");
		String tranParticular = null;
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		List<String> tranParticularList = new ArrayList<>();
		rgm.setBodyQuery(getCriteriaQuery());
		String query = getBodyQuery(rgm);
		logger.info("Query to filter gl description: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();
				fieldsMap = rgm.getQueryResultStructure(rs);
				lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);

				while (rs.next()) {
					for (String key : lineFieldsMap.keySet()) {
						ReportGenerationFields field = (ReportGenerationFields) lineFieldsMap.get(key);
						Object result;
						try {
							result = rs.getObject(field.getSource());
						} catch (SQLException e) {
							rgm.errors++;
							logger.error("An error was encountered when getting result", e);
							continue;
						}
						if (result != null) {
							if (key.equalsIgnoreCase(ReportConstants.TRAN_PARTICULAR)) {
								tranParticular = result.toString();
							}
						}
					}
					tranParticularList.add(tranParticular);
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the query to get the criteria", e);
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
		return tranParticularList;
	}

	@Override
	protected void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In BatchProcessor.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
				line.append(String.format("%-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true))
						.replace(' ', '0'));
			} else if (getGlobalFieldValue(field, true) == null) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
			} else {
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}
