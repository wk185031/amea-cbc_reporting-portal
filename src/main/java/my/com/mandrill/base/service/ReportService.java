package my.com.mandrill.base.service;

import java.io.File;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

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
		reportGenerationMgr.setDcmsDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));

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
		reportGenerationMgr.setDcmsDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));

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
}
