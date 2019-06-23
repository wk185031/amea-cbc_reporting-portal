package my.com.mandrill.base.reporting.glHandoffFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
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

public class GLHandoffMovingCash extends BatchProcessor {

	private final Logger logger = LoggerFactory.getLogger(GLHandoffMovingCash.class);
	public static final String DM = "DM";
	public static final String CM = "CM";
	private int success = 0;
	private double fileHash = 0.00;
	private String groupIdDate = null;

	@Override
	protected void execute(File file, ReportGenerationMgr rgm) {
		try {
			String tranParticular = null;
			String branchCode = null;
			rgm.fileOutputStream = new FileOutputStream(file);
			separateQuery(rgm);
			preProcessing(rgm);
			writeHeader(rgm);
			Iterator<String> tranParticularItr = filterByGlDescription(rgm).iterator();
			while (tranParticularItr.hasNext()) {
				tranParticular = tranParticularItr.next();
				if (tranParticular.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
						|| tranParticular.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL)) {
					preProcessing(rgm, tranParticular, branchCode, ReportConstants.CREDIT_IND);
					Iterator<String> branchCodeItr = filterByBranchCode(rgm).iterator();
					while (branchCodeItr.hasNext()) {
						branchCode = branchCodeItr.next();
						preProcessing(rgm, tranParticular, branchCode, ReportConstants.DEBIT_IND);
						rgm.setBodyQuery(getAcquirerDebitBodyQuery());
						executeBodyQuery(rgm, tranParticular, branchCode, ReportConstants.DEBIT_IND);
						preProcessing(rgm, tranParticular, branchCode, ReportConstants.CREDIT_IND);
						rgm.setBodyQuery(getAcquirerCreditBodyQuery());
						executeBodyQuery(rgm, tranParticular, branchCode, ReportConstants.CREDIT_IND);
					}
				} else {
					preProcessing(rgm, tranParticular, branchCode, ReportConstants.DEBIT_IND);
					rgm.setBodyQuery(getDebitBodyQuery());
					executeBodyQuery(rgm, tranParticular, branchCode, ReportConstants.DEBIT_IND);
					preProcessing(rgm, tranParticular, branchCode, ReportConstants.CREDIT_IND);
					rgm.setBodyQuery(getCreditBodyQuery());
					executeBodyQuery(rgm, tranParticular, branchCode, ReportConstants.CREDIT_IND);
				}
			}
			postProcessing(rgm);
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
		logger.debug("In GLHandoffMovingCash.preProcessing()");
		if (getCriteriaQuery() != null) {
			setCriteriaQuery(getCriteriaQuery().replace("AND {" + ReportConstants.PARAM_GL_DESCRIPTION + "}", "")
					.replace("AND {" + ReportConstants.PARAM_CHANNEL + "}", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
		}

		if (rgm.isGenerate() == true) {
			SimpleDateFormat sdf = new SimpleDateFormat(ReportConstants.DATE_FORMAT_12);
			Date date = new Date(rgm.getTxnEndDate().getTime());
			groupIdDate = sdf.format(date);
		} else {
			SimpleDateFormat sdf = new SimpleDateFormat(ReportConstants.DATE_FORMAT_12);
			Date date = new Date(rgm.getYesterdayDate().getTime());
			groupIdDate = sdf.format(date);
		}
		addBatchPreProcessingFieldsToGlobalMap(rgm);
	}

	private void preProcessing(ReportGenerationMgr rgm, String filterByGlDescription, String filterByBranchCode,
			String indicator) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffMovingCash.preProcessing()");
		if (filterByGlDescription != null && getAcquirerDebitBodyQuery() != null && getAcquirerCreditBodyQuery() != null
				&& (filterByGlDescription.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
						|| filterByGlDescription.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL))) {
			ReportGenerationFields branchCode = new ReportGenerationFields(ReportConstants.PARAM_BRANCH_CODE,
					ReportGenerationFields.TYPE_STRING, "TRIM(ABR.ABR_CODE) = '" + filterByBranchCode + "'");
			getGlobalFileFieldsMap().put(branchCode.getFieldName(), branchCode);
		}

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

		// TBC
		switch (filterByGlDescription) {
		case ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL:
			ReportGenerationFields channelPTM = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'NDC+'");
			getGlobalFileFieldsMap().put(channelPTM.getFieldName(), channelPTM);
			break;
		case ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL:
			ReportGenerationFields channelEC = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'NDC+'");
			getGlobalFileFieldsMap().put(channelEC.getFieldName(), channelEC);
			break;
		case ReportConstants.MBK_PAY_TO_MOBILE_OB_DEPOSIT:
			ReportGenerationFields channelMBK = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING, "TXN.TRL_ORIGIN_ICH_NAME = 'Authentic_Service'");
			getGlobalFileFieldsMap().put(channelMBK.getFieldName(), channelMBK);
			break;
		default:
			ReportGenerationFields defaultChannel = new ReportGenerationFields(ReportConstants.PARAM_CHANNEL,
					ReportGenerationFields.TYPE_STRING,
					"TXN.TRL_ORIGIN_ICH_NAME = 'NDC+' AND TXN.TRL_DEST_ICH_NAME = 'CBS_Bridge'");
			getGlobalFileFieldsMap().put(defaultChannel.getFieldName(), defaultChannel);
			break;
		}
	}

	private void separateQuery(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffMovingCash.separateQuery()");
		if (rgm.getBodyQuery() != null) {
			setAcquirerDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("AND GLA.GLA_NAME != 'ACD Inter-Entity IBFT SVC Bridge'", ""));
			setAcquirerCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, "")
					.replace("AND GLA.GLA_NAME != 'Accts. Payable - Inter-Entity IBFT Tfee'", ""));
			setDebitBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SELECT),
							rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START))
					.replace("\"BRANCH CODE\",", "").replace("ABR.ABR_CODE", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("\"BRANCH CODE\" ASC,", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
			setCreditBodyQuery(rgm.getBodyQuery()
					.substring(rgm.getBodyQuery().indexOf(ReportConstants.SUBSTRING_SECOND_QUERY_START),
							rgm.getBodyQuery().lastIndexOf(ReportConstants.SUBSTRING_END))
					.replace(ReportConstants.SUBSTRING_START, "").replace("\"BRANCH CODE\",", "")
					.replace("ABR.ABR_CODE", "")
					.replace("LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID", "")
					.replace("LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID", "")
					.replace("\"BRANCH CODE\" ASC,", "")
					.replace("AND {" + ReportConstants.PARAM_BRANCH_CODE + "}", ""));
			setCriteriaQuery(getDebitBodyQuery());
		}
	}

	private void postProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffMovingCash.postProcessing()");
		addPostProcessingFieldsToGlobalMap(rgm);
	}

	private void addPostProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffMovingCash.addPostProcessingFieldsToGlobalMap()");
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
				if (branchCode != null && (glDescription.equalsIgnoreCase(ReportConstants.ATM_PAY_TO_MOBILE_WITHDRAWAL)
						|| glDescription.equalsIgnoreCase(ReportConstants.ATM_EMERGENCY_CASH_WITHDRAWAL))) {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s",
							branchCode + getFieldValue(field, fieldsMap, true)));
					String glAccNo = branchCode + getFieldValue(field, fieldsMap, true);
					int[] glAccNoArray = new int[glAccNo.length()];
					for (int i = 0; i < glAccNoArray.length; i++) {
						glAccNoArray[i] = glAccNo.charAt(i);
						fileHash += glAccNoArray[i];
					}
				} else {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
					String glAccNo = getFieldValue(field, fieldsMap, true);
					int[] glAccNoArray = new int[glAccNo.length()];
					for (int i = 0; i < glAccNoArray.length; i++) {
						glAccNoArray[i] = glAccNo.charAt(i);
						fileHash += glAccNoArray[i];
					}
				}
				break;
			case ReportConstants.TRAN_REMARKS:
				if (indicator.equals(ReportConstants.DEBIT_IND)) {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", DM));
				} else {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", CM));
				}
				break;
			case ReportConstants.GROUP_ID:
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", "ATM" + groupIdDate + "001000001"));
				break;
			default:
				if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)
						|| field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_DECIMAL)) {
					if (field.getFieldName().equalsIgnoreCase(ReportConstants.TRAN_AMOUNT)) {
						line.append(String
								.format("%" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap, true))
								.replace(' ', '0'));
						fileHash += Double.parseDouble(getFieldValue(field, fieldsMap, true));
					} else {
						line.append(String
								.format("%" + field.getCsvTxtLength() + "s", getFieldValue(field, fieldsMap, true))
								.replace(' ', '0'));
					}
				} else if (getFieldValue(field, fieldsMap, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s",
							getFieldValue(field, fieldsMap, true)));
				}
				break;
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In GLHandoffMovingCash.writeTrailer()");
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
					line.append(String.format("%" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true))
							.replace(' ', '0'));
				}
			} else if (getGlobalFieldValue(field, true) == null) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
			} else {
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	@Override
	protected void executeBodyQuery(ReportGenerationMgr rgm, String glDescription, String branchCode,
			String indicator) {
		logger.debug("In GLHandoffMovingCash.executeBodyQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
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