package my.com.mandrill.base.reporting.glHandoffFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.BatchProcessor;

public class DefaultGLHandoff extends BatchProcessor {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffCashCard.class);
	private int success = 0;
	private double fileHash = 0.00;
	private String groupIdDate = null;
	
	@Override
	protected void execute(File file, ReportGenerationMgr rgm) {
		String branchCode = null;
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			preProcessing(rgm);
			writeHeader(rgm);
			
			ResultSet rs = null;
			PreparedStatement ps = null;
			String query = getBodyQuery(rgm);
			logger.info("Execute query: {}", query);

			ps = rgm.connection.prepareStatement(query);
			rs = ps.executeQuery();
			HashMap<String, ReportGenerationFields> fieldsMap = rgm.getQueryResultStructure(rs);
			HashMap<String, ReportGenerationFields> lineFieldsMap = rgm.getLineFieldsMap(fieldsMap);
			
			if (rs.next()) {
				do {
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
						if (ReportConstants.BRANCH_CODE.equals(field.getFieldName())) {
							branchCode = field.getValue();
						}
					}
					writeBody(rgm, lineFieldsMap, branchCode);
					success++;
				} while (rs.next());
			}

			addPostProcessingFieldsToGlobalMap(rgm);
			writeTrailer(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException | SQLException e) {
			rgm.errors++;
			logger.error("Error in generating GL file", e);
			throw new RuntimeException(e);
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
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String branchCode)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		
		ReportGenerationFields glAccNumField = fields.stream()
				.filter(field -> ReportConstants.AC_NUMBER.equals(field.getFieldName())).findAny().orElse(null);
		String glAccountNumber = getFieldValue(glAccNumField, fieldsMap);
		
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.BRANCH_CODE:
				if (glAccountNumber != null && glAccountNumber.length() > 10) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", glAccountNumber.substring(0, 4)));	
				} else {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", getFieldValue(rgm, field, fieldsMap)));	
				}
				break;
			case ReportConstants.AC_NUMBER:
				String glAccNo = null; 
				
				if(getFieldValue(field, fieldsMap).length() < ReportConstants.GL_ACCOUNT_NUMBER_MAX_LENGTH) {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s",
							branchCode + getFieldValue(field, fieldsMap)));
					glAccNo = branchCode + getFieldValue(field, fieldsMap);					
				} else {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap)));
					glAccNo = getFieldValue(field, fieldsMap);
				}
				
				int[] glAccNoArray = new int[glAccNo.length()];
				for (int i = 0; i < glAccNoArray.length; i++) {
					glAccNoArray[i] = glAccNo.charAt(i);
					fileHash += glAccNoArray[i];
				}
				break;
			case ReportConstants.GROUP_ID:
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", "ATM" + groupIdDate + "001000001"));
				break;
			default:
				if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
						|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TRAN_AMOUNT)) {
						line.append(String.format("%" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap))
								.replace(' ', '0'));
						fileHash += Double.parseDouble(getFieldValue(field, fieldsMap));
					} else {
						line.append(String.format("%" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap))
								.replace(' ', '0'));
					}
				} else {
					line.append(getFieldValue(rgm, field, fieldsMap));
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
	
	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {

		if (rgm.isGenerate() == true) {
			groupIdDate = rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_03));
		} else {
			groupIdDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_03));
		}
		addBatchPreProcessingFieldsToGlobalMap(rgm);
		addPostingDateFieldsToGlobalMap(rgm);
	}
	
	private void addPostProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffOnUs.addPostProcessingFieldsToGlobalMap()");
		ReportGenerationFields noOfRecords = new ReportGenerationFields(ReportConstants.NO_OF_DATA_RECORDS,
				ReportGenerationFields.TYPE_NUMBER, Integer.toString(success));
		getGlobalFileFieldsMap().put(noOfRecords.getFieldName(), noOfRecords);
	}
	
	private void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In GLHandoffRecycler.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
					|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.FILE_HASH)) {
					DecimalFormat formatter = new DecimalFormat(field.getFieldFormat());
					line.append(String.format("%" + field.getCsvTxtLength() + "s", formatter.format(fileHash))
							.replace(' ', '0'));
				} else {
					line.append(String.format("%" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field))
							.replace(' ', '0'));
				}
			} else {
				line.append(getGlobalFieldValue(rgm, field));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
	
}
