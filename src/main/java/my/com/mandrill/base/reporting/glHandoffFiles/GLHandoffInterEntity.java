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
import java.util.Iterator;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.BatchProcessor;

public class GLHandoffInterEntity extends BatchProcessor {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffInterEntity.class);
	private int success = 0;
	private double fileHash = 0.00;
	private String groupIdDate = null;

	private String ie_ins_name = "CBS";
	private String ie_ins_id = "0000000112";
	private String ins_id = "0000000010";

	@Override
	protected void execute(File file, ReportGenerationMgr rgm) {
		try {
			String tranParticular = null;
			String branchCode = null;
			rgm.fileOutputStream = new FileOutputStream(file);
			separateQuery(rgm);
			preProcessing(rgm);

			if (rgm.getInstitution().equalsIgnoreCase("CBS")) {
				ie_ins_name = "CBC";
				ie_ins_id = "0000000010";
				ins_id = "0000000112";
			}

			writeHeader(rgm);
			Iterator<String> tranParticularItr = filterByGlDescription(rgm).iterator();
			while (tranParticularItr.hasNext()) {
				tranParticular = tranParticularItr.next();

				rgm.setBodyQuery(getDebitBodyQuery());
				preProcessing(rgm, tranParticular, branchCode, ReportConstants.DEBIT_IND);
				executeBodyQuery(rgm, tranParticular, branchCode, ReportConstants.DEBIT_IND);

				rgm.setBodyQuery(getCreditBodyQuery());
				preProcessing(rgm, tranParticular, branchCode, ReportConstants.CREDIT_IND);
				executeBodyQuery(rgm, tranParticular, branchCode, ReportConstants.CREDIT_IND);

			}

			addPostProcessingFieldsToGlobalMap(rgm);
			writeTrailer(rgm);
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException | IOException
				| JSONException e) {
			rgm.errors++;
			logger.error("Error in generating GL file", e);
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

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffInterEntity.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_GL_DESCRIPTION + "}", "")
					.replace("AND {" + ReportConstants.PARAM_CHANNEL + "}", ""));
		}

		if (rgm.isGenerate() == true) {
			groupIdDate = rgm.getTxnEndDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_03));
		} else {
			groupIdDate = rgm.getYesterdayDate().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_03));
		}
		addBatchPreProcessingFieldsToGlobalMap(rgm);
		addPostingDateFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByGlDescription, String filterByBranchCode,
			String indicator) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffInterEntity.preProcessing()");
		if (filterByGlDescription != null && getDebitBodyQuery() != null
				&& indicator.equals(ReportConstants.DEBIT_IND)) {
			ReportGenerationFields glDesc = new ReportGenerationFields(ReportConstants.PARAM_GL_DESCRIPTION,
					ReportGenerationFields.TYPE_STRING,
					"TRIM(GLE.GLE_DEBIT_DESCRIPTION) = '" + filterByGlDescription + "'");
			getGlobalFileFieldsMap().put(glDesc.getFieldName(), glDesc);
		}

		if (filterByGlDescription != null && getCreditBodyQuery() != null
				&& indicator.equals(ReportConstants.CREDIT_IND)) {
			ReportGenerationFields glDesc = new ReportGenerationFields(ReportConstants.PARAM_GL_DESCRIPTION,
					ReportGenerationFields.TYPE_STRING,
					"TRIM(GLE.GLE_CREDIT_DESCRIPTION) = '" + filterByGlDescription + "'");
			getGlobalFileFieldsMap().put(glDesc.getFieldName(), glDesc);
		}

		switch (filterByGlDescription) {
		case ReportConstants.INTER_ENTITY_SERVICE_CHARGE:
		case ReportConstants.INTER_ENTITY_AP_ATM_WITHDRAWAL:
			ReportGenerationFields channelAP = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"(TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL)) AND TXN.TRL_ISS_NAME = '"
							+ rgm.getInstitution() + "'  AND (TXN.TRL_DEO_NAME = '" + ie_ins_name
							+ "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ie_ins_id + "')");
			getGlobalFileFieldsMap().put(channelAP.getFieldName(), channelAP);
			break;
		case ReportConstants.INTER_ENTITY_AR_ATM_WITHDRAWAL:
			ReportGenerationFields channelAR = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"(TXN.TRL_TSC_CODE IN (128) OR (TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NULL)) AND TXN.TRL_ISS_NAME = '"
							+ ie_ins_name + "'  AND (TXN.TRL_DEO_NAME = '" + rgm.getInstitution()
							+ "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ins_id + "')");
			getGlobalFileFieldsMap().put(channelAR.getFieldName(), channelAR);
			break;
		case ReportConstants.INTER_ENTITY_IBFT_CHARGE:
		case ReportConstants.INTER_ENTITY_FUND_TRANSFER_DR:
			ReportGenerationFields channelDR = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_TSC_CODE IN (40,42,48) AND TXN.TRL_ISS_NAME = '" + rgm.getInstitution()
							+ "' AND (((TXN.TRL_DEO_NAME = '" + rgm.getInstitution()
							+ "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ins_id + "')"
							+ " AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ie_ins_id + "') OR "
							+ "((TXN.TRL_DEO_NAME = '" + ie_ins_name + "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '"
							+ ie_ins_id + "')" + " AND (LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') IN ('" + ie_ins_id
							+ "','" + ins_id + "')"
							+ "OR (TXN.TRL_FRD_REV_INST_ID IS NULL AND TXN.TRL_TSC_CODE = 40)))) ");
			getGlobalFileFieldsMap().put(channelDR.getFieldName(), channelDR);
			break;
		case ReportConstants.INTER_ENTITY_FUND_TRANSFER_CR:
			ReportGenerationFields channelCR = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_TSC_CODE IN (40, 42, 44, 48) " + " AND ((TXN.TRL_ISS_NAME = '" + rgm.getInstitution() + "'"
							+ " AND (TXN.TRL_DEO_NAME = '" + ie_ins_name
							+ "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ie_ins_id + "') "
							+ " AND (LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ins_id
							+ "' OR (TXN.TRL_FRD_REV_INST_ID IS NULL AND TXN.TRL_TSC_CODE = 40)))"
							+ " OR (TXN.TRL_ISS_NAME = '" + ie_ins_name + "'" + " AND (TXN.TRL_DEO_NAME IN ('"
							+ rgm.getInstitution() + "' , '" + ie_ins_name
							+ "') OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') IN ('" + ie_ins_id + "','" + ins_id + "'))"
							+ " AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, '0') = '" + ins_id + "'))");
			getGlobalFileFieldsMap().put(channelCR.getFieldName(), channelCR);
			rgm.setBodyQuery(rgm.getBodyQuery().replace("TXN.TRL_ACCOUNT_1_ACN_ID", "TXN.TRL_ACCOUNT_2_ACN_ID"));
			break;
		default:
			ReportGenerationFields defaultChannel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_TSC_CODE = 31 AND TXN.TRL_ISS_NAME = '" + rgm.getInstitution()
							+ "'  AND (TXN.TRL_DEO_NAME = '" + ie_ins_name
							+ "' OR LPAD(TXN.TRL_ACQR_INST_ID, 10, '0') = '" + ie_ins_id + "')");
			getGlobalFileFieldsMap().put(defaultChannel.getFieldName(), defaultChannel);
			break;
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffInterEntity.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, ""));
			setCriteriaQuery(getDebitBodyQuery());
		}
	}

	private void addPostProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffInterEntity.addPostProcessingFieldsToGlobalMap()");
		ReportGenerationFields noOfRecords = new ReportGenerationFields(ReportConstants.NO_OF_DATA_RECORDS,
				ReportGenerationFields.TYPE_NUMBER, Integer.toString(success));
		getGlobalFileFieldsMap().put(noOfRecords.getFieldName(), noOfRecords);
	}

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			String glDescription, String branchCode, String indicator)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.AC_NUMBER:
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap)));
				String glAccNo = getFieldValue(field, fieldsMap);
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

	private void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In GLHandoffInterEntity.writeTrailer()");
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

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm, String glDescription, String branchCode,
			String indicator) {
		logger.debug("In GLHandoffInterEntity.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getBodyQuery(rgm);
		logger.info("Query for body line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
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
					writeBody(rgm, lineFieldsMap, glDescription, branchCode, indicator);
					success++;
				}
			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}
}
