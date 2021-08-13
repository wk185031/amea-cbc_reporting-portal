package my.com.mandrill.base.service;

import java.io.File;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.Query;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.processor.IReportProcessor;
import my.com.mandrill.base.processor.ReportProcessorLocator;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import net.logstash.logback.encoder.org.apache.commons.lang.StringUtils;

@Service
@Transactional
public class ReportService {

	private final Logger log = LoggerFactory.getLogger(ReportService.class);

	@Autowired
	private Environment env;

	@Autowired
	private ReportDefinitionRepository reportDefinitionRepository;

	@Autowired
	private ReportProcessorLocator reportProcessLocator;

	@Autowired
	private EncryptionService encryptionService;
	
	@Autowired
	private EntityManager em;

	public void autoGenerateAllReports(LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime, Long institutionId,
			String instShortCode, boolean manualGenerate) {

		log.debug(
				"Generate report for institution={} [inputStartDateTime={}, inputEndDateTime={}, Report Generation date={}",
				institutionId, inputStartDateTime, inputEndDateTime);
		
		generateReport(inputStartDateTime, inputEndDateTime, institutionId, instShortCode, null, null, false, false);
	}
	
	public void generateReport(LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime, Long institutionId,
			String instShortCode, Long reportCategoryId, Long reportId, boolean manualMonthly, boolean manualGenerate) {
		log.debug(
				"Generate report for institution={} [inputStartDateTime={}, inputEndDateTime={}, institutionId={}, instShortCode={}, reportCategoryId={}, reportId={}, includeMonthly={}, manualGenerate={}",
				institutionId, inputStartDateTime, inputEndDateTime, institutionId, instShortCode, reportCategoryId,
				reportId, manualMonthly, manualGenerate);
		
		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		reportGenerationMgr.setInstitution(instShortCode);
		reportGenerationMgr.setGenerate(manualGenerate);
		reportGenerationMgr.setFileDate(inputStartDateTime.toLocalDate());
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
		reportGenerationMgr.setAuthenticDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC));
	    reportGenerationMgr.setAuthenticDbLink(env.getProperty(ReportConstants.DB_LINK_AUTHENTIC));
		reportGenerationMgr.setEncryptionService(encryptionService);
		
		String yearMonth = inputStartDateTime.toLocalDate().format(DateTimeFormatter.ofPattern("yyyy-MM"));
		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator + yearMonth;
		
		List<ReportDefinition> aList = new ArrayList<>();

		if (reportCategoryId == null || reportCategoryId <= 0) {
			aList = reportDefinitionRepository.findReportDefinitionByInstitution(institutionId);
		} else if (reportId == null || reportId <= 0) {
			aList = reportDefinitionRepository.findAllByCategoryIdAndInstitutionId(reportCategoryId, institutionId);
		} else {
			ReportDefinition reportDefinition = reportDefinitionRepository.findOne(reportId);
			if (reportDefinition != null) {
				aList.add(reportDefinition);
			}
		}
		log.debug("Process {} reports", aList.size());
		
		for (ReportDefinition reportDefinition : aList) {
			reportGenerationMgr.setReportCategory(reportDefinition.getReportCategory().getName());
			reportGenerationMgr.setFileName(reportDefinition.getName());
			reportGenerationMgr.setFileFormat(reportDefinition.getFileFormat());
			reportGenerationMgr.setProcessingClass(reportDefinition.getProcessingClass());
			reportGenerationMgr.setHeaderFields(reportDefinition.getHeaderFields());
			reportGenerationMgr.setBodyFields(reportDefinition.getBodyFields());
			reportGenerationMgr.setTrailerFields(reportDefinition.getTrailerFields());
			reportGenerationMgr.setFrequency(reportDefinition.getFrequency());
			reportGenerationMgr.setBodyQuery(reportDefinition.getBodyQuery());
			reportGenerationMgr.setTrailerQuery(reportDefinition.getTrailerQuery());
			
			handleExceptionFilePrefix(reportGenerationMgr, reportDefinition.getFileNamePrefix(), inputStartDateTime,
					inputEndDateTime);

			String[] frequencies = reportGenerationMgr.getFrequency().split(",");
			for (String freq : frequencies) {
				if (ReportConstants.DAILY.equals(freq)) {
					setTransactionDateRange(reportGenerationMgr, false, inputStartDateTime, inputEndDateTime, directory,
							reportDefinition.getReportCategory().getName(), reportDefinition.isByBusinessDate());
					log.debug("run daily report: name={}, start date={}, end date={}", reportDefinition.getName(),
							reportGenerationMgr.getTxnStartDate(), reportGenerationMgr.getTxnEndDate());
					runReport(reportGenerationMgr);
				}
				
				if (ReportConstants.MONTHLY.equals(freq)) {
					if (manualMonthly || YearMonth.from(inputStartDateTime).atEndOfMonth().isEqual(inputStartDateTime.toLocalDate())) {
						setTransactionDateRange(reportGenerationMgr, true, inputStartDateTime, inputEndDateTime, directory,
								reportDefinition.getReportCategory().getName(), reportDefinition.isByBusinessDate());
						log.debug("run monthly report: name={}, start date={}, end date={}", reportDefinition.getName(),
								reportGenerationMgr.getTxnStartDate(), reportGenerationMgr.getTxnEndDate());
						runReport(reportGenerationMgr);
					}
				}
			}
		}	
	}
	
	private List<LocalDate> getHolidayList() {
		List<LocalDate> holidayList = new ArrayList<LocalDate>();
		
		Query q = em.createNativeQuery("select CEX_DATE from A5SWUAT.CALENDAR_EXCEPTION@A5SWUAT where cex_cgp_id in (select CGP_ID from A5SWUAT.CALENDAR_GROUP@A5SWUAT where CGP_NAME = ?)");
		q.setParameter(1, "Report Calendar");
		for(Object d : q.getResultList()) {
			holidayList.add(((java.sql.Timestamp) d).toLocalDateTime().toLocalDate());
		}
		log.debug("holiday list size = {}", holidayList == null ? 0 : holidayList.size());
		return holidayList;
	}
	
	private void setTransactionDateRange(ReportGenerationMgr reportGenerationMgr, boolean isMonthly,
			LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime, String directory, String reportCategory, boolean byBusinessDate) {
		if (isMonthly) {
			String dayPrefix = "00";
			reportGenerationMgr.setFileBaseDirectory(directory + File.separator + dayPrefix);
			reportGenerationMgr.setFileLocation(directory + File.separator + dayPrefix + File.separator
					+ ReportConstants.MAIN_PATH + File.separator + reportCategory + File.separator);
			LocalDate firstDayOfMonth = inputStartDateTime.toLocalDate().withDayOfMonth(1);
			LocalDate lastDayOfMonth = inputStartDateTime.toLocalDate()
					.withDayOfMonth(inputStartDateTime.toLocalDate().lengthOfMonth());
			reportGenerationMgr.setTxnStartDate(firstDayOfMonth.atStartOfDay());
			reportGenerationMgr.setTxnEndDate(lastDayOfMonth.plusDays(1L).atStartOfDay());
			reportGenerationMgr
					.setReportTxnEndDate(YearMonth.from(inputEndDateTime).atEndOfMonth().atTime(LocalTime.MAX));
		} else {
			String dayPrefix = StringUtils.leftPad(String.valueOf(inputStartDateTime.getDayOfMonth()), 2, "0");
			reportGenerationMgr.setFileBaseDirectory(directory + File.separator + dayPrefix);
			reportGenerationMgr.setFileLocation(directory + File.separator + dayPrefix + File.separator
					+ ReportConstants.MAIN_PATH + File.separator + reportCategory + File.separator);
			calculateTxnDateTime(reportGenerationMgr, inputStartDateTime, inputEndDateTime, byBusinessDate);
			reportGenerationMgr.setReportTxnEndDate(inputEndDateTime);
		}
		log.debug("setTransactionDateRange: txnStartDateTime={}, txnEndDateTime={}", reportGenerationMgr.getTxnStartDate(), reportGenerationMgr.getTxnEndDate());
	}
	
	private void calculateTxnDateTime(ReportGenerationMgr reportGenerationMgr, LocalDateTime inputStartDateTime,
			LocalDateTime inputEndDateTime, boolean byBusinessDate) {
		if (byBusinessDate) {
			
			List<LocalDate> holidays = getHolidayList();
			//TODO: Skip auto file generation on weekend or holiday
			//TODO: Confirm with CBC on generation with date range
			
			// TODO: If inputStartDateTime is on Monday, set the txnStartDate to last Saturday
			// eg: inputStartDate = Monday 00:00:00 -> txnStartDate = Sat 00:00:00, txnEndDate = Tue 00:00:00
			// TODO: If previous day(s) is holiday, include previous day(s)
			
			reportGenerationMgr.setTxnStartDate(inputStartDateTime);
			reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
		} else {
			reportGenerationMgr.setTxnStartDate(inputStartDateTime);
			reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
		}
	}

	private void handleExceptionFilePrefix(ReportGenerationMgr reportGenerationMgr, String filePrefix,
			LocalDateTime startDateTime, LocalDateTime endDateTime) {
		long noOfDaysBetween = ChronoUnit.DAYS.between(startDateTime, endDateTime);
		if (reportGenerationMgr.getFileName().equalsIgnoreCase(ReportConstants.ATM_DAILY_TRANSACTION_SUMMARY)
				&& noOfDaysBetween > 0) {
			reportGenerationMgr.setFileNamePrefix(ReportConstants.ATM_MONTHLY_TRANSACTION_SUMMARY);
		} else {
			reportGenerationMgr.setFileNamePrefix(filePrefix);
		}
	}

	private void runReport(ReportGenerationMgr reportGenerationMgr) {
		IReportProcessor reportProcessor = reportProcessLocator.locate(reportGenerationMgr.getProcessingClass());

		if (reportProcessor != null) {
			log.debug("runReport with processor: {}", reportProcessor);
			reportProcessor.process(reportGenerationMgr);
		} else {
			reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
					env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
		}
	}
}
