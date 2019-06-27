package my.com.mandrill.base.reporting.billsPaymentExtractFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.TxtReportProcessor;

public class BillsPaymentExtractFilesSummary extends TxtReportProcessor{

	private final Logger logger = LoggerFactory
			.getLogger(BillsPaymentExtractFilesSummary.class);
	private float pageHeight = PDRectangle.A4.getHeight() - ReportConstants.PAGE_HEIGHT_THRESHOLD;
	private float totalHeight = PDRectangle.A4.getHeight();
	private int pagination = 0;
	private int success = 0;


	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		StringBuilder line = new StringBuilder();
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			pagination = 1;
			preProcessing(rgm);
			writeHeader(rgm, pagination);
			writeBodyHeader(rgm);
			postProcessing(rgm);
			executeBodyQuery(rgm);
			executeTrailerQuery(rgm);
			line.append(getEol());
			line.append(getEol());
			rgm.writeLine(line.toString().getBytes());

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
	protected void writeHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		logger.debug("In TxtReportProcessor.writeHeader()");
		List<ReportGenerationFields> fields = extractHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().equalsIgnoreCase(ReportConstants.PAGE_NUMBER)) {
					line.append(String.valueOf(pagination));
				} else if (getGlobalFieldValue(field, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(
							String.format("%1$-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
				}
				line.append(getEol());
			} else {
				if (getGlobalFieldValue(field, true) == null) {
					line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
				} else {
					line.append(
							String.format("%1$-" + field.getCsvTxtLength() + "s", getGlobalFieldValue(field, true)));
				}
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In DailyPaymentTransactionReportTellerCardSummaryUtilityCompany.preProcessing()");
		addReportPreProcessingFieldsToGlobalMap(rgm);
	}
	
	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In TxtReportProcessor.writeBodyHeader()");
		List<ReportGenerationFields> fields = extractBodyHeaderFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldName().contains(ReportConstants.LINE)) {
					line.append(String.format("%" + field.getCsvTxtLength() + "s", " ").replace(' ',
							field.getDefaultValue().charAt(0)));
				} else {
					line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", field.getFieldName()));
					line.append(getEol());
				}
			} else {
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s", field.getFieldName()));
			}
		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

	private void postProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		logger.debug("In GLHandoffIssuer.postProcessing()");
		addPostProcessingFieldsToGlobalMap(rgm);
	}

	private void addPostProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		logger.debug("In GLHandoffIssuer.addPostProcessingFieldsToGlobalMap()");
		ReportGenerationFields noOfRecords = new ReportGenerationFields(ReportConstants.NO_OF_DATA_RECORDS,
				ReportGenerationFields.TYPE_NUMBER, Integer.toString(success));
		getGlobalFileFieldsMap().put(noOfRecords.getFieldName(), noOfRecords);
	}
	
	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			if (field.isEol()) {
				if (field.getFieldType().equalsIgnoreCase(ReportGenerationFields.TYPE_NUMBER)) {
				line.append(String.format("%" + field.getCsvTxtLength() + "s", " ").replace(' ',
						getFieldValue(field, fieldsMap, true).charAt(0)));
			} else if (getFieldValue(field, fieldsMap, true) == null) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
			} else {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
						getFieldValue(field, fieldsMap, true)));
			}
			line.append(getEol());
		} else {
			if (field.getFieldName().contains(ReportConstants.BP_BILLER_NAME)) {
				line.append(String.format("%1$-" + field.getCsvTxtLength() + "s",
						getFieldValue(field, fieldsMap, true)));
			} else if (getFieldValue(field, fieldsMap, true) == null) {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s", ""));
			} else {
				line.append(String.format("%1$" + field.getCsvTxtLength() + "s",
						getFieldValue(field, fieldsMap, true)));
			}
		}
	}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}

}
