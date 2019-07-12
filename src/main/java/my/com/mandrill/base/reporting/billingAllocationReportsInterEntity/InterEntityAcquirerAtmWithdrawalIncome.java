package my.com.mandrill.base.reporting.billingAllocationReportsInterEntity;

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
import java.util.Set;
import java.util.SortedMap;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class InterEntityAcquirerAtmWithdrawalIncome extends CsvReportProcessor {
	private final Logger logger = LoggerFactory.getLogger(InterEntityAcquirerAtmWithdrawalIncome.class);
	private int pagination = 0;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			
			rgm.setBodyQuery(rgm.getFixBodyQuery());
			preProcessing(rgm);
			
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
			
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in generating CSV file", e);
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
	
	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In InterEntityAcquirerAtmWithdrawalIncome.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				line.append(getEol());
			} else {
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In InterEntityAcquirerAtmWithdrawalIncome.preProcessing()");
		if (rgm.getBodyQuery() != null) {
			rgm.setTmpBodyQuery(rgm.getBodyQuery());
			rgm.setBodyQuery(rgm.getBodyQuery().replace("AND {" + ReportConstants.PARAM_TXN_CRITERIA + "}", ""));
		}
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}
	
	protected void executeBodyQuery(ReportGenerationMgr rgm) {
		logger.debug("In AtmWithdrawalAcquirerBank.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String tmpBranchCode = null;
		String tmpBranchName = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
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
							if (field.getSource().equalsIgnoreCase(ReportConstants.BRANCH_CODE)) {
								if (tmpBranchCode != null) {
									if (result.toString().equalsIgnoreCase(tmpBranchCode)) {
										result = null;
									} else {
										tmpBranchCode = result.toString();
									}
								} else {
									tmpBranchCode = result.toString();
								}
							} else if (field.getSource().equalsIgnoreCase(ReportConstants.BRANCH_NAME)) {
								if (tmpBranchName != null) {
									if (result.toString().equalsIgnoreCase(tmpBranchName)) {
										result = null;
									} else {
										tmpBranchName = result.toString();
									}
								} else {
									tmpBranchName = result.toString();
								}
							}
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
							} else {
								field.setValue(result.toString());
							}
						} else {
							field.setValue("");
						}
					}
					writeBody(rgm, lineFieldsMap);
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
}