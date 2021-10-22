package my.com.mandrill.base.service;

import java.io.File;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.Instant;
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
import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import my.com.mandrill.base.domain.Job;
import my.com.mandrill.base.domain.JobHistory;
import my.com.mandrill.base.domain.JobHistoryDetails;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.processor.IReportProcessor;
import my.com.mandrill.base.processor.ReportGenerationException;
import my.com.mandrill.base.processor.ReportProcessorLocator;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.repository.JobHistoryRepository;
import my.com.mandrill.base.repository.JobRepository;
import my.com.mandrill.base.repository.ReportCategoryRepository;
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
	private ReportCategoryRepository reportCategoryRepository;

	@Autowired
	private ReportDefinitionRepository reportDefinitionRepository;

	@Autowired
	private ReportProcessorLocator reportProcessLocator;

	@Autowired
	private EncryptionService encryptionService;
		
	@Autowired
	private JobRepository jobRepository;
	
	@Autowired
	private JobHistoryRepository jobHistoryRepository;
		
	@Autowired
	private EntityManager em;
	
	@Autowired
	private DataSource dataSource;

	private ObjectMapper mapper = new ObjectMapper();
	
	public void autoGenerateAllReports(LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime,
			Long institutionId, String instShortCode, boolean manualGenerate, String user) throws JsonProcessingException {

		log.debug(
				"Generate report for institution={} [inputStartDateTime={}, inputEndDateTime={}, Report Generation date={}",
				institutionId, inputStartDateTime, inputEndDateTime);

		generateReport(inputStartDateTime, inputEndDateTime, institutionId, instShortCode, null, null, false, false, user);
	}
	
	public void generateReport(LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime, Long institutionId,
			String instShortCode, Long reportCategoryId, Long reportId, boolean manualMonthly, boolean manualGenerate, String user) throws JsonProcessingException {
		log.debug(
				"Generate report for institution={} [inputStartDateTime={}, inputEndDateTime={}, institutionId={}, instShortCode={}, reportCategoryId={}, reportId={}, includeMonthly={}, manualGenerate={}",
				institutionId, inputStartDateTime, inputEndDateTime, institutionId, instShortCode, reportCategoryId,
				reportId, manualMonthly, manualGenerate);

		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		reportGenerationMgr.setInstitution(instShortCode);
		reportGenerationMgr.setGenerate(manualGenerate);
		reportGenerationMgr.setFileDate(inputStartDateTime.toLocalDate());
		reportGenerationMgr.setYesterdayDate(LocalDate.now().minusDays(1L));
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
		reportGenerationMgr.setAuthenticDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC));
		reportGenerationMgr.setAuthenticDbLink(env.getProperty(ReportConstants.DB_LINK_AUTHENTIC));
		reportGenerationMgr.setEncryptionService(encryptionService);

		String yearMonth = inputStartDateTime.toLocalDate().format(DateTimeFormatter.ofPattern("yyyy-MM"));
		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator + yearMonth;

		List<ReportDefinition> aList = new ArrayList<>();
		
		String reportCategory = null;
		String report = null;

		if (reportCategoryId == null || reportCategoryId <= 0) {
			aList = reportDefinitionRepository.findReportDefinitionByInstitution(institutionId);
			reportCategory = "ALL";
			report = "ALL";
		} else if (reportId == null || reportId <= 0) {
			aList = reportDefinitionRepository.findAllByCategoryIdAndInstitutionId(reportCategoryId, institutionId);
			reportCategory = reportCategoryRepository.findOne(reportCategoryId).getName();
			report = "ALL";
		} else {
			ReportDefinition reportDefinition = reportDefinitionRepository.findOne(reportId);
			if (reportDefinition != null) {
				aList.add(reportDefinition);
			}
			
			reportCategory = reportCategoryRepository.findOne(reportCategoryId).getName();
			report = reportDefinition.getName();
		}
		log.debug("Process {} reports", aList.size());
		
		LocalDateTime currentTs = LocalDateTime.now();
		String description = "REPORT CATEGORY: " + reportCategory + ", REPORT: " + report + ", FROM: " + inputStartDateTime.toString() + ", TO: " + inputEndDateTime.toString();
		
		Job job = jobRepository.findByName("GENERATE_REPORT");
		JobHistoryDetails jobHistoryDetails = new JobHistoryDetails(institutionId.toString(), reportCategoryId != null ? reportCategoryId.toString() : "0", reportCategory, 
				report, description, inputStartDateTime.toString(), inputStartDateTime.toString(), inputEndDateTime.toString(), currentTs.toString(), null);
		
		long dailyJobId = 0;
		long monthlyJobId = 0;
		
		boolean isDailyPartialFailed = false;
		boolean isDailyCompleted = false;
		boolean isMonthlyPartialFailed = false;
		boolean isMonthlyCompleted = false;
		
		String dailyReportPath = null;
		String monthlyReportPath = null;
		
		boolean isDailyFreq = aList.stream().anyMatch(p -> p.getFrequency().contains("Daily"));
		boolean isMonthlyFreq = aList.stream().anyMatch(p -> p.getFrequency().contains("Monthly"));
		
		if(isDailyFreq) {
			dailyJobId = createJobHistory(job, user, inputStartDateTime, inputEndDateTime, mapper.writeValueAsString(jobHistoryDetails), ReportConstants.DAILY);
			dailyReportPath = directory + File.separator + StringUtils.leftPad(String.valueOf(inputStartDateTime.getDayOfMonth()), 2, "0") + File.separator + dailyJobId;		
		}
		
		if(isMonthlyFreq) {
			monthlyJobId = createJobHistory(job, user, inputStartDateTime, inputEndDateTime, mapper.writeValueAsString(jobHistoryDetails), ReportConstants.MONTHLY);
			monthlyReportPath = directory + File.separator + "00" + File.separator + monthlyJobId;	
		}
		
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
					&& !BusinessDay.isWorkingDay(inputStartDateTime.toLocalDate(), holidays)) {
				log.debug("Non working day:{}. System will not auto generate report: {}",
						inputStartDateTime.toLocalDate(), reportDefinition.getName());
				continue;
			} else {
				String[] frequencies = reportGenerationMgr.getFrequency().split(",");
				for (String freq : frequencies) {
					if (ReportConstants.DAILY.equals(freq)) {					
						setTransactionDateRange(reportGenerationMgr, false, inputStartDateTime, inputEndDateTime,
								directory, reportDefinition.getReportCategory().getName(),
								reportDefinition.isByBusinessDate(), manualGenerate, holidays, dailyJobId);
						log.debug("run daily report: name={}, start date={}, end date={}", reportDefinition.getName(),
								reportGenerationMgr.getTxnStartDate(), reportGenerationMgr.getTxnEndDate());
												
						try {
							runReport(reportGenerationMgr);
							isDailyCompleted = true;
						} catch (ReportGenerationException e) {
							log.error("Error generating report:" + e.getFilename());
							isDailyPartialFailed = true;
						}
						
					}

					if (ReportConstants.MONTHLY.equals(freq)) {
						if (manualMonthly || YearMonth.from(inputStartDateTime).atEndOfMonth()
								.isEqual(inputStartDateTime.toLocalDate())) {
							setTransactionDateRange(reportGenerationMgr, true, inputStartDateTime, inputEndDateTime,
									directory, reportDefinition.getReportCategory().getName(),
									reportDefinition.isByBusinessDate(), manualGenerate, holidays, monthlyJobId);
							log.debug("run monthly report: name={}, start date={}, end date={}",
									reportDefinition.getName(), reportGenerationMgr.getTxnStartDate(),
									reportGenerationMgr.getTxnEndDate());
							try {
								runReport(reportGenerationMgr);
								isMonthlyCompleted = true;
							} catch (ReportGenerationException e) {
								log.error("Error generating report:" + e.getFilename());
								isMonthlyPartialFailed = true;
							}
														
						}
					}
				}
			}
		}
		
		if(dailyJobId != 0) {		
			updateJobHistoryOnFinish(reportGenerationMgr, dailyJobId, jobHistoryDetails, isDailyCompleted, isDailyPartialFailed, dailyReportPath);
		}
		
		if(monthlyJobId != 0) {			
			updateJobHistoryOnFinish(reportGenerationMgr, monthlyJobId, jobHistoryDetails, isMonthlyCompleted, isMonthlyPartialFailed, monthlyReportPath);
		}
		
	}
		
	private void updateJobHistoryOnFinish(ReportGenerationMgr rgm, long jobId, JobHistoryDetails jobHistoryDetails, boolean isCompleted, boolean isPartialFailed, String reportPath) throws JsonProcessingException {
		if(jobId != 0) {			
			JobHistory jobHistory = jobHistoryRepository.findOne(jobId);
			jobHistoryDetails.setEndDateTime(LocalDateTime.now().toString());
			jobHistory.setStatus(getJobStatus(isCompleted, isPartialFailed));
			jobHistory.setReportPath(reportPath);
			jobHistory.setDetails(mapper.writeValueAsString(jobHistoryDetails));
			jobHistory.setGenerationEndDate(LocalDateTime.now());
			jobHistory.setLastModifiedDate(Instant.now());
			jobHistoryRepository.save(jobHistory);
		}
	}
	
	private String getJobStatus(boolean isCompleted, boolean isPartialFailed) {
		String status = null;
		
		if(isCompleted && isPartialFailed) {
			status = ReportConstants.STATUS_PARTIAL_FAILED;
		} else if(!isCompleted && isPartialFailed) {
			status = ReportConstants.STATUS_FAILED;
		} else {
			status = ReportConstants.STATUS_COMPLETED;
		}
		
		return status;
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
			boolean byBusinessDate, boolean manualGenerate, Optional<List<LocalDate>> holidays, long jobId) {
		if (isMonthly) {
			String dayPrefix = "00";
			reportGenerationMgr.setFileBaseDirectory(directory + File.separator + dayPrefix + File.separator + jobId);
			reportGenerationMgr.setFileLocation(directory + File.separator + dayPrefix + File.separator + jobId + File.separator
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
			reportGenerationMgr.setFileBaseDirectory(directory + File.separator + dayPrefix + File.separator + jobId);
			reportGenerationMgr.setFileLocation(directory + File.separator + dayPrefix + File.separator + jobId + File.separator
					+ ReportConstants.MAIN_PATH + File.separator + reportCategory + File.separator);
			calculateTxnDateTime(reportGenerationMgr, inputStartDateTime, inputEndDateTime, byBusinessDate,
					manualGenerate, holidays);
			reportGenerationMgr.setReportTxnEndDate(inputEndDateTime);
		}
		log.debug("setTransactionDateRange: txnStartDateTime={}, txnEndDateTime={}, postingDate={}",
				reportGenerationMgr.getTxnStartDate(), reportGenerationMgr.getTxnEndDate(),
				reportGenerationMgr.getPostingDate());
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

	private void runReport(ReportGenerationMgr reportGenerationMgr) throws ReportGenerationException {
		IReportProcessor reportProcessor = reportProcessLocator.locate(reportGenerationMgr.getProcessingClass());

		if (reportProcessor != null) {
			log.debug("runReport with processor: {}", reportProcessor);
			reportProcessor.process(reportGenerationMgr);
		} else {
			reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
					env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
		}
	}
	
	private long createJobHistory(Job job, String user, LocalDateTime inputStartDateTime, LocalDateTime inputEndDateTime, String details, String frequency) {

		PreparedStatement stmt = null;
		ResultSet rs = null;
		Connection conn = null;
		long jobId = 0;
		
		LocalDateTime currentTs = LocalDateTime.now();
	
		String sql = "insert into job_history (job_id, status, created_by, created_date, last_modified_by, last_modified_date, details, report_start_date, report_end_date, generation_start_date, report_frequency) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		try {
			conn = dataSource.getConnection();
			stmt = conn.prepareStatement(sql);
			stmt.setLong(1, job.getId());
			stmt.setString(2, ReportConstants.STATUS_IN_PROGRESS);
			stmt.setString(3, user);
			stmt.setTimestamp(4, Timestamp.valueOf(currentTs));
			stmt.setString(5, user);
			stmt.setTimestamp(6, Timestamp.valueOf(currentTs));
			stmt.setString(7, details);
			stmt.setTimestamp(8, Timestamp.valueOf(inputStartDateTime));
			stmt.setTimestamp(9, Timestamp.valueOf(inputEndDateTime));
			stmt.setTimestamp(10, Timestamp.valueOf(currentTs));
			stmt.setString(11, frequency);
			
			int row = stmt.executeUpdate();	
			
			stmt.close();
			
			if(row > 0) {
				sql = "select max(id) from job_history";
				stmt = conn.prepareStatement(sql);
				rs = stmt.executeQuery();
				
				if(rs.next()) {
					jobId = rs.getLong(1);
				}
			}
			
		} catch (Exception e) {
			throw new RuntimeException("Failed to insert job history", e);
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (Exception e) {
				}
			}

			if (rs != null) {
				try {
					rs.close();
				} catch (Exception e) {
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (Exception e) {
					log.warn("Failed to close conn", e);
				}
			}
		}

		return jobId;
	}
}
