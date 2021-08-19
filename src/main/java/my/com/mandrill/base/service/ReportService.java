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
import java.util.Optional;

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
import my.com.mandrill.base.service.util.BusinessDay;
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

	public void autoGenerateAllReports(LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime,
			Long institutionId, String instShortCode, boolean manualGenerate) {

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

			Optional<List<LocalDate>> holidays = getHolidayList();
			if (!manualGenerate && reportDefinition.isByBusinessDate()
					&& !BusinessDay.isWorkingDay(reportGenerationMgr.getTxnStartDate().toLocalDate(), holidays)) {
				log.debug("Non working day. System will not auto generate report: {}", reportDefinition.getName());
				continue;
			} else {
				String[] frequencies = reportGenerationMgr.getFrequency().split(",");
				for (String freq : frequencies) {
					if (ReportConstants.DAILY.equals(freq)) {
						setTransactionDateRange(reportGenerationMgr, false, inputStartDateTime, inputEndDateTime,
								directory, reportDefinition.getReportCategory().getName(),
								reportDefinition.isByBusinessDate(), manualGenerate, holidays);
						log.debug("run daily report: name={}, start date={}, end date={}", reportDefinition.getName(),
								reportGenerationMgr.getTxnStartDate(), reportGenerationMgr.getTxnEndDate());
						runReport(reportGenerationMgr);
					}

					if (ReportConstants.MONTHLY.equals(freq)) {
						if (manualMonthly || YearMonth.from(inputStartDateTime).atEndOfMonth()
								.isEqual(inputStartDateTime.toLocalDate())) {
							setTransactionDateRange(reportGenerationMgr, true, inputStartDateTime, inputEndDateTime,
									directory, reportDefinition.getReportCategory().getName(),
									reportDefinition.isByBusinessDate(), manualGenerate, holidays);
							log.debug("run monthly report: name={}, start date={}, end date={}",
									reportDefinition.getName(), reportGenerationMgr.getTxnStartDate(),
									reportGenerationMgr.getTxnEndDate());
							runReport(reportGenerationMgr);
						}
					}
				}
			}
		}
	}

	private Optional<List<LocalDate>> getHolidayList() {
		List<LocalDate> holidayList = new ArrayList<LocalDate>();

		StringBuilder sb = new StringBuilder();
		sb.append("select CEX_DATE from ").append(env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC))
				.append(".CALENDAR_EXCEPTION@").append(env.getProperty(ReportConstants.DB_LINK_AUTHENTIC))
				.append(" where cex_cgp_id in (select CGP_ID from ")
				.append(env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC)).append(".CALENDAR_GROUP@")
				.append(env.getProperty(ReportConstants.DB_LINK_AUTHENTIC)).append(" where CGP_NAME = ?)");

		Query q = em.createNativeQuery(sb.toString());
		q.setParameter(1, "Report Calendar");
		for (Object d : q.getResultList()) {
			holidayList.add(((java.sql.Timestamp) d).toLocalDateTime().toLocalDate());
		}
		log.debug("holiday list size = {}", holidayList == null ? 0 : holidayList.size());
		return Optional.of(holidayList);
	}

	private void setTransactionDateRange(ReportGenerationMgr reportGenerationMgr, boolean isMonthly,
			LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime, String directory, String reportCategory,
			boolean byBusinessDate, boolean manualGenerate, Optional<List<LocalDate>> holidays) {
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
			calculateTxnDateTime(reportGenerationMgr, inputStartDateTime, inputEndDateTime, byBusinessDate,
					manualGenerate, holidays);
			reportGenerationMgr.setReportTxnEndDate(inputEndDateTime);
		}
		log.debug("setTransactionDateRange: txnStartDateTime={}, txnEndDateTime={}, postingDate={}",
				reportGenerationMgr.getTxnStartDate(), reportGenerationMgr.getTxnEndDate(), reportGenerationMgr.getPostingDate());
	}

	private void calculateTxnDateTime(ReportGenerationMgr reportGenerationMgr, LocalDateTime inputStartDateTime,
			LocalDateTime inputEndDateTime, boolean byBusinessDate, boolean manualGenerate,
			Optional<List<LocalDate>> holidays) {
		if (byBusinessDate) {
			if (manualGenerate) {
				LocalDate endDate = inputEndDateTime.toLocalDate();
				LocalDate postingDate = BusinessDay.rollForward(endDate, holidays);
				reportGenerationMgr.setTxnStartDate(inputStartDateTime);
				reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
				reportGenerationMgr.setPostingDate(postingDate);
			} else {
				LocalDate startDate = inputStartDateTime.toLocalDate();
				LocalDate rollbackStartDate = BusinessDay.rollBackward(startDate, holidays);
				reportGenerationMgr.setTxnStartDate(rollbackStartDate.atStartOfDay());
				reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
				reportGenerationMgr.setPostingDate(inputEndDateTime.toLocalDate());
			}
		} else {
			reportGenerationMgr.setTxnStartDate(inputStartDateTime);
			// Plus 1 minute to make it from 11:59 to 00:00 as criteria in report use less
			// than '<' in date range
			reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
		}
	}

	/*
	 * private void calculateTxnDateTime(ReportGenerationMgr reportGenerationMgr,
	 * LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime, boolean
	 * byBusinessDate, boolean isMonthly) { List<LocalDate> holidays =
	 * getHolidayList().isPresent() ? getHolidayList().get() : new ArrayList<>(); if
	 * (byBusinessDate) { LocalDate inputStartDate =
	 * inputStartDateTime.toLocalDate(); LocalDate inputEndtDate =
	 * inputEndDateTime.toLocalDate(); DayOfWeek DayOfWeekinputStartDateTimee =
	 * inputStartDateTime.getDayOfWeek(); DayOfWeek DayOfWeekinputEndDateTimee =
	 * inputEndDateTime.getDayOfWeek();
	 * 
	 * if (isMonthly == false) { // 3.Date range selection (end date is a holiday)
	 * for (LocalDate holidaydates : holidays) { if
	 * (inputEndtDate.equals(holidaydates)) { // If end date is a holiday and is a
	 * weekend if (DayOfWeekinputEndDateTimee.name() == ReportConstants.SATURDAY) {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusDays(2)); } else if
	 * (DayOfWeekinputEndDateTimee.name() == ReportConstants.SUNDAY) {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusDays(1).plusMinutes(1L
	 * )); }
	 * 
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusDays(1).plusMinutes(1L
	 * )); } } // 2.Date range selection (end date is a weekend) if
	 * (DayOfWeekinputEndDateTimee.name() == ReportConstants.SATURDAY) {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusDays(2)); } else if
	 * (DayOfWeekinputEndDateTimee.name() == ReportConstants.SUNDAY) {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusDays(1));
	 * 
	 * } // 4. Date range selection (start date is a holiday, end date is working)
	 * else if ((holidays.contains(inputStartDate)) &
	 * (DayOfWeekinputEndDateTimee.name() != ReportConstants.SATURDAY ||
	 * DayOfWeekinputEndDateTimee.name() != ReportConstants.SUNDAY)) {
	 * 
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
	 * 
	 * } // 5. Date range selection (start date is a weekend, end date is working)
	 * else if ((DayOfWeekinputStartDateTimee.name() == ReportConstants.SATURDAY ||
	 * DayOfWeekinputStartDateTimee.name() == ReportConstants.SUNDAY) &
	 * (DayOfWeekinputEndDateTimee.name() != ReportConstants.SATURDAY ||
	 * DayOfWeekinputEndDateTimee.name() != ReportConstants.SUNDAY)) {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
	 * 
	 * } else { // 1.Date range selection (end date is a working day)
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L)); }
	 * 
	 * // TODO: Skip auto file generation on weekend or holiday // TODO: Confirm
	 * with CBC on generation with date range
	 * 
	 * // TODO: If inputStartDateTime is on Monday, set the txnStartDate to last //
	 * Saturday // eg: inputStartDate = Monday 00:00:00 -> txnStartDate = Sat
	 * 00:00:00, // txnEndDate = Tue 00:00:00 // TODO: If previous day(s) is
	 * holiday, include previous day(s) // DayOfWeek DayOfWeekinputStartDateTime =
	 * inputStartDateTime.getDayOfWeek(); // if(DayOfWeekinputStartDateTime.name()
	 * == ReportConstants.MONDAY) { //
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime.minusDays(2)); //
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L)); // }else
	 * { // reportGenerationMgr.setTxnStartDate(inputStartDateTime); //
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L)); // }
	 * 
	 * } else { for (LocalDate holidaydates : holidays) {
	 * 
	 * if (inputEndtDate.equals(holidaydates)) { if
	 * (DayOfWeekinputEndDateTimee.name() == ReportConstants.SATURDAY) {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusDays(2)); } else if
	 * (DayOfWeekinputEndDateTimee.name() == ReportConstants.SUNDAY) {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusDays(1).plusMinutes(1L
	 * )); }
	 * 
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusDays(1).plusMinutes(1L
	 * )); } }
	 * 
	 * // 2.Date range selection (end date is a weekend) if
	 * (DayOfWeekinputEndDateTimee.name() == ReportConstants.SATURDAY) {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.minusDays(1).plusMinutes(
	 * 1L)); } else if (DayOfWeekinputEndDateTimee.name() == ReportConstants.SUNDAY)
	 * { reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.minusDays(2).plusMinutes(
	 * 1L));
	 * 
	 * } else if ((holidays.contains(inputStartDate)) &
	 * (DayOfWeekinputEndDateTimee.name() != ReportConstants.SATURDAY ||
	 * DayOfWeekinputEndDateTimee.name() != ReportConstants.SUNDAY)) {
	 * 
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
	 * 
	 * } else if ((DayOfWeekinputStartDateTimee.name() == ReportConstants.SATURDAY
	 * || DayOfWeekinputStartDateTimee.name() == ReportConstants.SUNDAY) &
	 * (DayOfWeekinputEndDateTimee.name() != ReportConstants.SATURDAY ||
	 * DayOfWeekinputEndDateTimee.name() != ReportConstants.SUNDAY)) {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L));
	 * 
	 * } else { reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L)); } }
	 * 
	 * // FIXME: to set posting date appropriately
	 * reportGenerationMgr.setPostingDate(LocalDate.now()); } else {
	 * reportGenerationMgr.setTxnStartDate(inputStartDateTime);
	 * reportGenerationMgr.setTxnEndDate(inputEndDateTime.plusMinutes(1L)); } }
	 */

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
