package my.com.mandrill.base.reporting.billsPaymentExtractFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class BillsPaymentExtractFilesDetailedTransactions extends TxtReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(BillsPaymentExtractFilesDetailedTransactions.class);
	private int success = 0;
	private double totalPayments = 0.00;
	String txnDate = null;

	@Override
	public void processTxtRecord(ReportGenerationMgr rgm) throws ReportGenerationException {
		logger.debug("In BillsPaymentExtractFilesDetailedTransactions.processTxtRecord()");
		if (getEncryptionService() == null) {
			setEncryptionService(rgm.getEncryptionService());
		}

		File file = null;
		String fileLocation = rgm.getFileLocation();

		try {
			if (rgm.isGenerate() == true) {
				txnDate = rgm.getFileDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
			} else {
				txnDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_01));
			}

			if (rgm.errors == 0) {
				if (fileLocation != null) {
					File directory = new File(fileLocation);
					if (!directory.exists()) {
						directory.mkdirs();
					}

					separateQuery(rgm);

					// Generate Cash card report
					file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + "EMV_CASHCARD_" + txnDate
							+ ReportConstants.DPS_FORMAT + ReportConstants.PGP_FORMAT);

					setQuery(rgm, getCashCardBodyQuery(), getCashCardTrailerQuery());

					execute(rgm, file);

					// Generate ATM card report
					file = new File(rgm.getFileLocation() + rgm.getFileNamePrefix() + txnDate
							+ ReportConstants.DPS_FORMAT + ReportConstants.PGP_FORMAT);

					setQuery(rgm, getAtmCardBodyQuery(), getAtmCardTrailerQuery());

					execute(rgm, file);

					rgm.fileOutputStream.flush();
					rgm.fileOutputStream.close();

				} else {
					throw new Exception("Path is not configured.");
				}
			} else {
				throw new Exception(
						"Errors when generating" + rgm.getFileNamePrefix() + txnDate + ReportConstants.DPS_FORMAT);
			}

		} catch (Exception e) {
			logger.error("Errors in generating " + rgm.getFileNamePrefix() + txnDate + ReportConstants.DPS_FORMAT, e);
			throw new ReportGenerationException(rgm.getFileNamePrefix() + txnDate + ReportConstants.DPS_FORMAT, e);
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
	protected void execute(ReportGenerationMgr rgm, File file) {

		try {
			String billerCode = null;

			rgm.fileOutputStream = new FileOutputStream(file);
			addBatchPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);

			Iterator<String> billerCodeItr = filterByBillerCode(rgm).iterator();

			while (billerCodeItr.hasNext()) {
				billerCode = billerCodeItr.next();
				logger.debug("billerCode:" + billerCode);
				if (hasResult(rgm, billerCode)) {
					writeInstitutionBodyHeader(rgm, billerCode);
					executeBodyQuery(rgm, billerCode);
					writeInstitutionTrailer(rgm, billerCode);
				}
			}

			addPostProcessingFieldsToGlobalMap(rgm);

			preProcessTrailerQuery(rgm);
			executeTrailerQuery(rgm);

		} catch (IOException | JSONException e) {
			rgm.errors++;
			logger.error("Error in generating TXT file", e);
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In BillsPaymentExtractFilesDetailedTransactions.separateQuery()");

		if (rgm.getBodyQuery() != null) {
			logger.debug("rgm.getBodyQuery():" + rgm.getBodyQuery());

			setCashCardBodyQuery(
					rgm.getBodyQuery().substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setAtmCardBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END_BODY))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCriteriaQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_END_BODY),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END_CRITERIA))
					.replace(ReportConstants.SUBSTRING_END_BODY, ""));

			logger.debug("getCriteriaQuery():" + getCriteriaQuery());
		}

		if (rgm.getTrailerQuery() != null) {
			setCashCardTrailerQuery(
					rgm.getTrailerQuery().substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START)));
			setAtmCardTrailerQuery(rgm.getTrailerQuery()
					.substring(rgm.getTrailerQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getTrailerQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
		}

	}

	private void setQuery(ReportGenerationMgr rgm, String bodyQuery, String trailerQuery) {

		rgm.setBodyQuery(bodyQuery);
		rgm.setTrailerQuery(trailerQuery);

	}

	private void addPostProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In BillsPaymentExtractFilesDetailedTransactions.addPostProcessingFieldsToGlobalMap()");
		ReportGenerationFields noOfRecords = new ReportGenerationFields(ReportConstants.NO_OF_DATA_RECORDS,
				ReportGenerationFields.TYPE_NUMBER, Integer.toString(success));
		getGlobalFileFieldsMap().put(noOfRecords.getFieldName(), noOfRecords);
	}

	private SortedSet<String> filterByBillerCode(ReportGenerationMgr rgm) {

		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		SortedSet<String> billerCodeList = new TreeSet<>();

		String query = getCriteriaQuery(rgm, getCriteriaQuery());
		String billerCode = null;

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
							if (key.equalsIgnoreCase(ReportConstants.BP_BILLER_CODE)) {
								billerCode = result.toString();
							}
						}
					}
					billerCodeList.add(billerCode);
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
		return billerCodeList;
	}

	private boolean hasResult(ReportGenerationMgr rgm, String billerCode) {
		logger.debug("In GLHandoffBlocksheetInterEntity.executeQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		String query = getBodyQuery(rgm).replace("{" + ReportConstants.BP_BILLER_CODE + "}", billerCode);
		logger.info("Execute query: {}", query);

		try {
			ps = rgm.connection.prepareStatement(query);
			rs = ps.executeQuery();

			if (!rs.isBeforeFirst()) {
				return false;
			} else {
				return true;
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
		return false;
	}
	
	protected void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In TxtReportProcessor.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.PROCESS_DATE)) {
				line.append(txnDate);
			} else {
				line.append(getGlobalFieldValue(rgm, field));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeInstitutionBodyHeader(ReportGenerationMgr rgm, String billerCode)
			throws IOException, JSONException {
		logger.debug("In TxtReportProcessor.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();

		for (ReportGenerationFields field : fields) {
			if (field.getFieldName().equalsIgnoreCase(ReportConstants.BP_BILLER_CODE)) {
				line.append(billerCode);
			} else {
				line.append(getGlobalFieldValue(rgm, field));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isDecrypt()) {
				decryptValues(field, fieldsMap, getGlobalFileFieldsMap());
			}

			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
					|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.TRAN_AMOUNT)) {
					totalPayments += Double.parseDouble(getFieldValue(field, fieldsMap));
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap))
							.replace(' ', '0').concat("00"));
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap).replace(' ', '0'));
				}
			} else {
				line.append(getFieldValue(rgm, field, fieldsMap));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeInstitutionTrailer(ReportGenerationMgr rgm, String billerCode) throws IOException, JSONException {
		logger.debug("In TxtReportProcessor.writeInstitutionTrailer()");
		StringBuilder line = new StringBuilder();
		line.append("IT");
		line.append(billerCode);
		executeInstitutionTrailerQuery(rgm, billerCode, line);
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void executeInstitutionTrailerQuery(ReportGenerationMgr rgm, String billerCode, StringBuilder line) {

		ResultSet rs = null;
		PreparedStatement ps = null;

		String query = getTrailerQuery(rgm).replace("{" + ReportConstants.BP_BILLER_CODE + "}",
				" AND LPAD(TXNC.TRL_BILLER_CODE, 4, '0') = " + billerCode);
		
		String totalCount = "0000000000000000";
		String totalPayment = "000000000000000";

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.connection.prepareStatement(query);
				rs = ps.executeQuery();

				while (rs.next()) {
					try {
						totalCount = rs.getString(1);
						totalPayment = rs.getString(2);

						line.append(totalCount);
						line.append(totalPayment);

					} catch (SQLException e) {
						rgm.errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}
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
	}

	protected void executeBodyQuery(ReportGenerationMgr rgm, String billerCode) {
		logger.debug("In TxtReportProcessor.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm).replace("{" + ReportConstants.BP_BILLER_CODE + "}", billerCode);
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

	private void preProcessTrailerQuery(ReportGenerationMgr rgm) {
		
		if (rgm.getTrailerQuery() != null) {
			rgm.setTrailerQuery(rgm.getTrailerQuery().replace("{" + ReportConstants.BP_BILLER_CODE + "}", ""));
		}
		
		logger.debug("rgm.getTrailerQuery():" + rgm.getTrailerQuery());
	}
}
