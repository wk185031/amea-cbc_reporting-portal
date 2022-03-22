package my.com.mandrill.base.reporting.billingAllocationReportsInterEntity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class InterEntityIbftTransactionFees extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(InterEntityIbftTransactionFees.class);
	private int transmittingCount = 0;
	private int acquiringCount = 0;
	private int receivingCount = 0;
	private double transmittingExpense = 0.00;
	private double acquiringIncome = 0.00;
	private double receivingIncome = 0.00;
	private double totalBilling = 0.00;
	private double overallTransmittingExpense = 0.00;
	private double overallAcquiringIncome = 0.00;
	private double overallReceivingIncome = 0.00;
	private double overallTotalBilling = 0.00;

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			
			writeHeader(rgm);
			writeBodyHeader(rgm);
			executeBodyQuery(rgm);
			writeTrailer(rgm);
			
			rgm.fileOutputStream.flush();
			rgm.fileOutputStream.close();
		} catch (IOException | JSONException | InstantiationException | IllegalAccessException
				| ClassNotFoundException e) {
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
		logger.debug("In InterEntityIbftTransactionFees.writeBodyHeader()");
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

	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TRANSMITTING_COUNT:
				line.append(getFieldValue(rgm, field, fieldsMap));
				transmittingCount += Integer.parseInt(getFieldValue(field, fieldsMap).replace(",", ""));
				break;
			case ReportConstants.TRANSMITTING_EXPENSE:
				line.append(getFieldValue(rgm, field, fieldsMap));

				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					transmittingExpense = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					transmittingExpense = Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				overallTransmittingExpense += transmittingExpense;
				break;
			case ReportConstants.ACQUIRER_COUNT:
				line.append(getFieldValue(rgm, field, fieldsMap));
				acquiringCount += Integer.parseInt(getFieldValue(field, fieldsMap).replace(",", ""));
				break;
			case ReportConstants.ACQUIRER_INCOME:
				line.append(getFieldValue(rgm, field, fieldsMap));

				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					acquiringIncome = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					acquiringIncome = Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				overallAcquiringIncome += acquiringIncome;
				break;
			case ReportConstants.RECEIVING_COUNT:
				line.append(getFieldValue(rgm, field, fieldsMap));
				receivingCount += Integer.parseInt(getFieldValue(field, fieldsMap).replace(",", ""));
				break;
			case ReportConstants.RECEIVING_INCOME:
				line.append(getFieldValue(rgm, field, fieldsMap));

				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					receivingIncome = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					receivingIncome = Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				overallReceivingIncome += receivingIncome;
				break;
			case ReportConstants.TOTAL_BILLING:
				line.append(getFieldValue(rgm, field, fieldsMap));
				
				if (getFieldValue(field, fieldsMap).indexOf(",") != -1) {
					totalBilling = Double.parseDouble(getFieldValue(field, fieldsMap).replace(",", ""));
				} else {
					totalBilling = Double.parseDouble(getFieldValue(field, fieldsMap));
				}
				
				overallTotalBilling += totalBilling;
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

	private void writeTrailer(ReportGenerationMgr rgm)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		logger.debug("In IbftTransactionFees.writeTrailer()");
		List<ReportGenerationFields> fields = extractTrailerFields(rgm);
		StringBuilder line = new StringBuilder();
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.TRANSMITTING_COUNT:
				line.append(transmittingCount);
				line.append(field.getDelimiter());
				break;
			case ReportConstants.TRANSMITTING_EXPENSE:
				line.append(formatter.format(overallTransmittingExpense));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.ACQUIRER_COUNT:
				line.append(acquiringCount);
				line.append(field.getDelimiter());
				break;
			case ReportConstants.ACQUIRER_INCOME:
				line.append(formatter.format(overallAcquiringIncome));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.RECEIVING_COUNT:
				line.append(receivingCount);
				line.append(field.getDelimiter());
				break;
			case ReportConstants.RECEIVING_INCOME:
				line.append(formatter.format(overallReceivingIncome));
				line.append(field.getDelimiter());
				break;
			case ReportConstants.TOTAL_BILLING:
				line.append(formatter.format(overallTotalBilling));
				line.append(field.getDelimiter());
				break;
			default:
				line.append(getGlobalFieldValue(rgm, field));
				line.append(field.getDelimiter());
				break;
			}

		}
		line.append(getEol());
		rgm.writeLine(line.toString().getBytes());
	}
}