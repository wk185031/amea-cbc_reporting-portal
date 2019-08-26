package my.com.mandrill.base.reporting.billingAllocationReportsInterEntity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class InterEntityAcquirerAtmWithdrawalIncome extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(InterEntityAcquirerAtmWithdrawalIncome.class);
	private int branchCodeCount = 0;
	private int branchNameCount = 0;
	private String branchCode = null;
	private String branchName = null;

	public String getBranchCode() {
		return branchCode;
	}

	public void setBranchCode(String branchCode) {
		this.branchCode = branchCode;
	}

	public String getBranchName() {
		return branchName;
	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		StringBuilder line = new StringBuilder();
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
			rgm.writeLine(line.toString().getBytes());
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException e) {
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
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.BRANCH_CODE:
				if (branchCodeCount > 0 && getBranchCode().equals(getFieldValue(rgm, field, fieldsMap))) {
					fieldsMap.get(field.getFieldName()).setValue("");
					line.append(getFieldValue(rgm, field, fieldsMap));
				} else {
					setBranchCode(getFieldValue(rgm, field, fieldsMap));
					line.append(getFieldValue(rgm, field, fieldsMap));
				}
				branchCodeCount++;
				break;
			case ReportConstants.BRANCH_NAME:
				if (branchNameCount > 0 && getBranchName().equals(getFieldValue(rgm, field, fieldsMap))) {
					fieldsMap.get(field.getFieldName()).setValue("");
					line.append(getFieldValue(rgm, field, fieldsMap));
				} else {
					setBranchName(getFieldValue(rgm, field, fieldsMap));
					line.append(getFieldValue(rgm, field, fieldsMap));
				}
				branchNameCount++;
				break;
			default:
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			}
			line.append(field.getDelimiter());
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}