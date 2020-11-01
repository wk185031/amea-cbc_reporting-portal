package my.com.mandrill.base.service;

import java.io.File;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
<<<<<<< Updated upstream
=======
import java.util.List;
import java.util.stream.Collectors;
>>>>>>> Stashed changes

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.repository.ReportDefinitionRepository;

@Service
@Transactional
public class ReportService {

<<<<<<< Updated upstream
	private final Logger log = LoggerFactory.getLogger(ReportService.class);

	@Autowired
	private Environment env;

	@Autowired
	private ReportDefinitionRepository reportDefinitionRepository;

	
	public void generateAllReports(LocalDate transactionDate, Long institutionId, String instShortCode) {
		LocalDate runDate = LocalDate.now();
		LocalDate lastDayOfMonth = YearMonth
				.from(LocalDateTime.now()).atEndOfMonth();
		
		log.info("Generate report for institution:{} [Transaction date={}, Report Generation date={}", institutionId, transactionDate, runDate);
		
		generateDailyReport(transactionDate, institutionId, instShortCode);
		if (YearMonth.from(transactionDate).atEndOfMonth().isEqual(transactionDate)) {
			log.info("Generate monthly report.");
			generateMonthlyReport(transactionDate, institutionId, instShortCode);
		}
	}
	
	public void generateDailyReport(LocalDate transactionDate, Long institutionId, String instShortCode) {
		log.debug("In ReportGenerationResource.generateDailyReport()");

		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator
				+ DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(transactionDate) + File.separator
				+ DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_07).format(transactionDate) + File.separator;

		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		reportGenerationMgr.setYesterdayDate(transactionDate);
		reportGenerationMgr.setTodayDate(transactionDate);
		reportGenerationMgr.setInstitution(instShortCode);	
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));

		for (ReportDefinition reportDefinitionList : reportDefinitionRepository
				.findAll(new Sort(Sort.Direction.ASC, "id"))) {
			if (reportDefinitionList.getFrequency().contains(ReportConstants.DAILY)) {
				reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
				reportGenerationMgr.setFileName(reportDefinitionList.getName());
				reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
				reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
				reportGenerationMgr.setFileLocation(
						directory + reportDefinitionList.getReportCategory().getName() + File.separator);
				reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
				reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
				reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
				reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
				reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
				reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
				reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());
				reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
						env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
			}
		}
	}

	public void generateMonthlyReport(LocalDate transactionDate, Long institutionId, String instShortCode) {
		log.debug("In ReportGenerationResource.generateMonthlyReport()");
		LocalDate firstDayOfMonth = YearMonth.from(transactionDate).atDay(1);
		LocalDate lastDayOfMonth = YearMonth.from(transactionDate).atEndOfMonth();

		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator
				+ DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(lastDayOfMonth) + File.separator
				+ "00" + File.separator;

		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		reportGenerationMgr.setYesterdayDate(firstDayOfMonth);
		reportGenerationMgr.setTodayDate(lastDayOfMonth);
		reportGenerationMgr.setInstitution(instShortCode);
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));

		for (ReportDefinition reportDefinitionList : reportDefinitionRepository
				.findAll(new Sort(Sort.Direction.ASC, "id"))) {
			if (reportDefinitionList.getFrequency().contains(ReportConstants.MONTHLY)) {
				reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
				reportGenerationMgr.setFileName(reportDefinitionList.getName());
				reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
				reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
				reportGenerationMgr.setFileLocation(
						directory + reportDefinitionList.getReportCategory().getName() + File.separator);
				reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
				reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
				reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
				reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
				reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
				reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
				reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());
				reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
						env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
			}
		}
	}
=======
    private final Logger log = LoggerFactory.getLogger(ReportService.class);

    @Autowired
    private Environment env;

    @Autowired
    private ReportDefinitionRepository reportDefinitionRepository;

    @Autowired
    private InstitutionRepository institutionRepository;

    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");

    public void generateAllReports(LocalDate transactionDate, Long institutionId, String instShortCode) {
        LocalDate runDate = LocalDate.now();
        LocalDate yesterdayDate = LocalDate.now().minusDays(1L);
        LocalDate currentDate = LocalDate.now();
        LocalDate firstDayOfMonth = YearMonth.from(LocalDateTime.now()).atDay(1);

        log.info("Generate report for institution:{} [Transaction date={}, Report Generation date={}", institutionId, transactionDate, runDate);

        generateDailyReport(transactionDate, institutionId, instShortCode);
        if (YearMonth.from(transactionDate).atEndOfMonth().isEqual(transactionDate)) {
            log.info("Generate monthly report.");
            generateMonthlyReport(transactionDate, institutionId, instShortCode);
        }

    }

    public void generateDailyReport(LocalDate transactionDate, Long institutionId, String instShortCode) {
        log.debug("In ReportGenerationResource.generateDailyReport()");

        String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
            + institutionId + File.separator
            + DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(transactionDate) + File.separator
            + DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_07).format(transactionDate) + File.separator;

        ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
        reportGenerationMgr.setYesterdayDate(transactionDate);
        reportGenerationMgr.setTodayDate(transactionDate);
        reportGenerationMgr.setInstitution(instShortCode);
        reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));

        for (ReportDefinition reportDefinitionList : reportDefinitionRepository
            .findAll(new Sort(Sort.Direction.ASC, "id"))) {
            if (reportDefinitionList.getFrequency().contains(ReportConstants.DAILY)) {
                reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
                reportGenerationMgr.setFileName(reportDefinitionList.getName());
                reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
                reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
                reportGenerationMgr.setFileLocation(
                    directory + reportDefinitionList.getReportCategory().getName() + File.separator);
                reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
                reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
                reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
                reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
                reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
                reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
                reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());
                reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
                    env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
            }
        }
    }

    public void generateMonthlyReport(LocalDate transactionDate, Long institutionId, String instShortCode) {
        log.debug("In ReportGenerationResource.generateMonthlyReport()");
        LocalDate firstDayOfMonth = YearMonth.from(transactionDate).atDay(1);
        LocalDate lastDayOfMonth = YearMonth.from(transactionDate).atEndOfMonth();

        String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
            + institutionId + File.separator
            + DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(lastDayOfMonth) + File.separator
            + "00" + File.separator;

        ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
        reportGenerationMgr.setYesterdayDate(firstDayOfMonth);
        reportGenerationMgr.setTodayDate(lastDayOfMonth);
        reportGenerationMgr.setInstitution(instShortCode);
        reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));

        for (ReportDefinition reportDefinitionList : reportDefinitionRepository
            .findAll(new Sort(Sort.Direction.ASC, "id"))) {
            if (reportDefinitionList.getFrequency().contains(ReportConstants.MONTHLY)) {
                reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
                reportGenerationMgr.setFileName(reportDefinitionList.getName());
                reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
                reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
                reportGenerationMgr.setFileLocation(
                    directory + reportDefinitionList.getReportCategory().getName() + File.separator);
                reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
                reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
                reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
                reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
                reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
                reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
                reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());
                reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
                    env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
            }
        }
    }


    /**
     * This method trigger each minute by cron setting
     * 1. Get report definition where schedule's time matching the current hour/minute
     * 2. Get institution the report belong to, set institution short code accordingly
     * 3. Generate report by daily or monthly frequency
     */
    @Scheduled(cron = "0 0/1 * 1/1 * ?")
    @Transactional
    public void generateReportAtTime() {
        log.debug("In ReportService.generateReportAtTime(), polling schedule check for time: " + LocalDateTime.now().format(formatter));

        String instShortCode = null;
        String dateTimeStr = LocalDateTime.now().format(formatter);
        LocalDate currentDate = LocalDate.now();
        LocalDate firstDayOfMonth = YearMonth.from(currentDate).minusMonths(1).atDay(1);
        LocalDate firstDayOfCurrentMonth = YearMonth.from(currentDate).atDay(1);
//        LocalDate firstDayOfMonth = YearMonth.from(currentDate).atDay(1);
        LocalDate lastDayOfMonth = YearMonth.from(currentDate).minusMonths(1).atEndOfMonth();
        ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
        String directory = null;

        // get all report definition filter by matching HH:mm for current hour/minute
        List<ReportDefinition> reportDefinitionList = reportDefinitionRepository.findReportDefinitionByTime(dateTimeStr);

        log.debug("No of report to generate: " + reportDefinitionList.size());

        // get institutions of type 'Institution'
        List<Institution> institutions = institutionRepository.findInstitutionWithInstitutionType();

        // iterate filtered reportDefinition list
        for(ReportDefinition rd: reportDefinitionList) {

            log.debug("Generating report: " + rd.getFileNamePrefix());
            log.debug("CHECK>>> firstDayOfMonth : " + firstDayOfMonth.toString());
            log.debug("CHECK>>> lastDayOfMonth : " + lastDayOfMonth.toString());

            Institution institution = institutions.stream().filter(i -> i.getId() == rd.getInstitutionId()).collect(Collectors.toList()).get(0);

            if(institution.getName().equals(ReportConstants.CBC_INSTITUTION)) {
                instShortCode = "CBC";
            } else if (institution.getName().equals(ReportConstants.CBS_INSTITUTION)) {
                instShortCode = "CBS";
            }

//        if (firstDayOfMonth.isEqual(currentDate)) {
//            log.debug("CHECK>>> firstDayOfMonth : " + firstDayOfMonth.toString());
//            log.debug("CHECK>>> currentDate : " + currentDate.toString());
//            log.info("Generate monthly report.");
//            generateMonthlyReport(transactionDate, institutionId, instShortCode);
//        }else{
//            log.info("test");

            if(rd.getScheduleTime().format(formatter).equals(dateTimeStr) ) {
                if (rd.getFrequency().contains(ReportConstants.DAILY)) {

                    directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
                        + institution.getId() + File.separator
                        + DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(currentDate) + File.separator
                        + DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_07).format(currentDate) + File.separator;

                    reportGenerationMgr.setTxnStartDate(currentDate);
                    reportGenerationMgr.setTxnEndDate(currentDate);
                    reportGenerationMgr.setYesterdayDate(currentDate);
                    reportGenerationMgr.setTodayDate(currentDate);
                    reportGenerationMgr.setInstitution(instShortCode);
                    reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
                    reportGenerationMgr.setFileDate(currentDate);
                    reportGenerationMgr.setReportCategory(rd.getReportCategory().getName());
                    reportGenerationMgr.setFileName(rd.getName());
                    reportGenerationMgr.setFileNamePrefix(rd.getFileNamePrefix());
                    reportGenerationMgr.setFileFormat(rd.getFileFormat());
                    reportGenerationMgr.setFileLocation(
                        directory + rd.getReportCategory().getName() + File.separator);
                    reportGenerationMgr.setFrequency(rd.getFrequency());
                    reportGenerationMgr.setProcessingClass(rd.getProcessingClass());
                    reportGenerationMgr.setHeaderFields(rd.getHeaderFields());
                    reportGenerationMgr.setBodyFields(rd.getBodyFields());
                    reportGenerationMgr.setTrailerFields(rd.getTrailerFields());
                    reportGenerationMgr.setBodyQuery(rd.getBodyQuery());
                    reportGenerationMgr.setTrailerQuery(rd.getTrailerQuery());
                    reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
                        env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
                }

                if (rd.getFrequency().contains(ReportConstants.MONTHLY) && firstDayOfCurrentMonth.isEqual(currentDate)) {

                    directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
                        + institution.getId() + File.separator
                        + DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(lastDayOfMonth) + File.separator
                        + "00" + File.separator;


                    reportGenerationMgr.setTxnStartDate(firstDayOfMonth);
                    reportGenerationMgr.setTxnEndDate(lastDayOfMonth);

                    reportGenerationMgr.setYesterdayDate(firstDayOfMonth);
                    reportGenerationMgr.setTodayDate(lastDayOfMonth);
                    reportGenerationMgr.setInstitution(instShortCode);
                    reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
                    reportGenerationMgr.setReportCategory(rd.getReportCategory().getName());
                    reportGenerationMgr.setFileName(rd.getName());
                    reportGenerationMgr.setFileNamePrefix(rd.getFileNamePrefix());
                    reportGenerationMgr.setFileFormat(rd.getFileFormat());
                    reportGenerationMgr.setFileLocation(
                        directory + rd.getReportCategory().getName() + File.separator);
                    reportGenerationMgr.setFrequency(rd.getFrequency());
                    reportGenerationMgr.setProcessingClass(rd.getProcessingClass());
                    reportGenerationMgr.setHeaderFields(rd.getHeaderFields());
                    reportGenerationMgr.setBodyFields(rd.getBodyFields());
                    reportGenerationMgr.setTrailerFields(rd.getTrailerFields());
                    reportGenerationMgr.setBodyQuery(rd.getBodyQuery());
                    reportGenerationMgr.setTrailerQuery(rd.getTrailerQuery());
                    reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL),
                        env.getProperty(ReportConstants.DB_USERNAME), env.getProperty(ReportConstants.DB_PASSWORD));
                }
            }
        }
    }
>>>>>>> Stashed changes
}
