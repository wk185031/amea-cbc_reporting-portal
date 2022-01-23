package my.com.mandrill.base.reporting.ecmReports;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
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
import my.com.mandrill.base.reporting.reportProcessor.CsvReportProcessor;

public class DowntimeCauses extends CsvReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(DowntimeCauses.class);
	private Double hour = 0.00;
	private Double minute = 0.00;
	private Double second = 0.00;
	private Double totalHour = 0.00;
	private Double totalMinute = 0.00;
	private Double totalSecond = 0.00;
	private static final double TOTAL_PERCENTAGE = 100.00;
	public static final DecimalFormat DECIMAL_FORMAT = new DecimalFormat("#,##0.00");
	private static final DecimalFormat DECIMAL_FORMAT_WITHOUT_DECIMAL = new DecimalFormat("##0");

	public Double getHour() {
		return hour;
	}

	public void setHour(Double hour) {
		this.hour = hour;
	}

	public Double getMinute() {
		return minute;
	}

	public void setMinute(Double minute) {
		this.minute = minute;
	}

	public Double getSecond() {
		return second;
	}

	public void setSecond(Double second) {
		this.second = second;
	}

	public Double getTotalHour() {
		return totalHour;
	}

	public void setTotalHour(Double totalHour) {
		this.totalHour = totalHour;
	}

	public Double getTotalMinute() {
		return totalMinute;
	}

	public void setTotalMinute(Double totalMinute) {
		this.totalMinute = totalMinute;
	}

	public Double getTotalSecond() {
		return totalSecond;
	}

	public void setTotalSecond(Double totalSecond) {
		this.totalSecond = totalSecond;
	}

	@Override
	protected void execute(ReportGenerationMgr rgm, File file) {
		DecimalFormat formatter = new DecimalFormat("#,##0.00");
		try {
			rgm.fileOutputStream = new FileOutputStream(file);
			addReportPreProcessingFieldsToGlobalMap(rgm);
			writeHeader(rgm);
			writeBodyHeader(rgm);
			getTotalSecondAndHour(rgm);
			executeBodyQuery(rgm);
			StringBuilder line = new StringBuilder();
			line.append(";").append(DECIMAL_FORMAT_WITHOUT_DECIMAL.format(totalSecond)).append(";").append(totalHour.toString().replace(".", ":")).append(";")
					.append(formatter.format(TOTAL_PERCENTAGE) + "%").append(";");
			line.append(getEol());
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
	protected String getTransactionDateRangeFieldName() {
		return "ASH.ASH_TIMESTAMP";
	}

	@Override
	protected void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		logger.debug("In DowntimeCauses.writeBodyHeader()");
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

	@Override
	protected void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		List<ReportGenerationFields> fields = extractBodyFields(rgm);
		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : fields) {
			switch (field.getFieldName()) {
			case ReportConstants.SECOND:
				setSecond(Double.parseDouble(getFieldValue(rgm, field, fieldsMap)));
				line.append(getFieldValue(rgm, field, fieldsMap));
				break;
			case ReportConstants.HOUR:
				setHour(Double.parseDouble(getFieldValue(rgm, field, fieldsMap)));
				line.append(getFieldValue(rgm, field, fieldsMap).replace(".", ":"));
				break;
			case ReportConstants.PERCENTAGE:
				Double percentage = (getSecond() / totalSecond) * 100;
				line.append(DECIMAL_FORMAT.format(percentage));
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
	
	protected void getTotalSecondAndHour(ReportGenerationMgr rgm) {
		logger.debug("In CsvReportProcessor.executeTrailerQuery()");
		ResultSet rs = null;
		PreparedStatement ps = null;
		HashMap<String, ReportGenerationFields> fieldsMap = null;
		HashMap<String, ReportGenerationFields> lineFieldsMap = null;
		String query = getTrailerQuery(rgm);
		logger.info("Query for trailer line export: {}", query);

		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
				rs = ps.executeQuery();

				while (rs.next()) {
					try {
						totalSecond = rs.getDouble("SECOND");
						totalHour = rs.getDouble("HOUR");
					} catch (SQLException e) {
						rgm.errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}

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
