package my.com.mandrill.base.service;

import java.io.File;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.processor.IReportProcessor;
import my.com.mandrill.base.processor.ReportProcessorLocator;
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

	@Autowired
	private ReportProcessorLocator reportProcessLocator;

	@Autowired
	private EncryptionService encryptionService;

	public void generateAllReports(LocalDate transactionDate, Long institutionId, String instShortCode) {
		LocalDate runDate = LocalDate.now();

		log.info("Generate report for institution:{} [Transaction date={}, Report Generation date={}", institutionId,
				transactionDate, runDate);

		generateDailyReport(transactionDate, institutionId, instShortCode);
		if (YearMonth.from(transactionDate).atEndOfMonth().isEqual(transactionDate)) {
			log.info("Generate monthly report.");
			generateMonthlyReport(transactionDate, institutionId, instShortCode);
		}
	}

	public void generateDailyReport(LocalDate transactionDate, Long institutionId, String instShortCode) {
		log.debug(
				"In ReportGenerationResource.generateDailyReport(): transactionDate={}, institutionId={}, instShortCode={}",
				transactionDate, institutionId, instShortCode);

		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator
				+ DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(transactionDate) + File.separator
				+ DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_07).format(transactionDate) + File.separator;

		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();

		reportGenerationMgr.setYesterdayDate(transactionDate);
		reportGenerationMgr.setTodayDate(transactionDate);
		reportGenerationMgr.setTxnStartDate(transactionDate.atStartOfDay());
		reportGenerationMgr.setTxnEndDate(transactionDate.plusDays(1L).atStartOfDay());
		reportGenerationMgr.setFileDate(reportGenerationMgr.getTxnStartDate().toLocalDate());
		reportGenerationMgr.setInstitution(instShortCode);
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
        reportGenerationMgr.setAuthenticDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC));
        reportGenerationMgr.setAuthenticDbLink(env.getProperty(ReportConstants.DB_LINK_AUTHENTIC));
		reportGenerationMgr.setEncryptionService(encryptionService);
        reportGenerationMgr.setReportTxnEndDate(transactionDate.atTime(LocalTime.MAX));

		for (ReportDefinition reportDefinitionList : reportDefinitionRepository.findReportDefinitionByInstitution(institutionId)) {
			if (reportDefinitionList.getFrequency().contains(ReportConstants.DAILY)) {
				reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
				reportGenerationMgr.setFileName(reportDefinitionList.getName());
				reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
				reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
				reportGenerationMgr.setFileBaseDirectory(directory);
				reportGenerationMgr.setFileLocation(
						directory + File.separator + ReportConstants.MAIN_PATH + File.separator +
						reportDefinitionList.getReportCategory().getName() + File.separator);
				reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
				reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
				reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
				reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
				reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
				reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
				reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());
				runReport(reportGenerationMgr);
			}
		}
	}

	public void generateMonthlyReport(LocalDate transactionDate, Long institutionId, String instShortCode) {
		log.debug(
				"In ReportGenerationResource.generateMonthlyReport(): transactionDate={}, institutionId={}, instShortCode={}",
				transactionDate, institutionId, instShortCode);
		LocalDateTime firstDayOfMonth = YearMonth.from(transactionDate).atDay(1).atStartOfDay();
		LocalDateTime lastDayOfMonth = YearMonth.from(transactionDate).atEndOfMonth().plusDays(1L).atStartOfDay();

		String directory = Paths.get(env.getProperty("application.reportDir.path")).toString() + File.separator
				+ institutionId + File.separator
				+ DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_06).format(firstDayOfMonth) + File.separator
				+ "00" + File.separator;

		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		reportGenerationMgr.setYesterdayDate(firstDayOfMonth.toLocalDate());
		reportGenerationMgr.setTodayDate(transactionDate);
		reportGenerationMgr.setTxnStartDate(firstDayOfMonth);
		reportGenerationMgr.setTxnEndDate(lastDayOfMonth);
		reportGenerationMgr.setInstitution(instShortCode);
		reportGenerationMgr.setDcmsDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_DCMS));
		reportGenerationMgr.setDbLink(env.getProperty(ReportConstants.DB_LINK_DCMS));
        reportGenerationMgr.setAuthenticDbSchema(env.getProperty(ReportConstants.DB_SCHEMA_AUTHENTIC));
        reportGenerationMgr.setAuthenticDbLink(env.getProperty(ReportConstants.DB_LINK_AUTHENTIC));
		reportGenerationMgr.setEncryptionService(encryptionService);
		reportGenerationMgr.setReportTxnEndDate(YearMonth.from(transactionDate).atEndOfMonth().atTime(LocalTime.MAX));

		for (ReportDefinition reportDefinitionList : reportDefinitionRepository.findReportDefinitionByInstitution(institutionId)) {
			if (reportDefinitionList.getFrequency().contains(ReportConstants.MONTHLY)) {
				reportGenerationMgr.setReportCategory(reportDefinitionList.getReportCategory().getName());
				reportGenerationMgr.setFileName(reportDefinitionList.getName());
				
				if(reportGenerationMgr.getFileName().equalsIgnoreCase(ReportConstants.ATM_DAILY_TRANSACTION_SUMMARY)) {
					reportGenerationMgr.setFileNamePrefix(ReportConstants.ATM_MONTHLY_TRANSACTION_SUMMARY);
				}else {
					reportGenerationMgr.setFileNamePrefix(reportDefinitionList.getFileNamePrefix());
				}
				
				reportGenerationMgr.setFileFormat(reportDefinitionList.getFileFormat());
				reportGenerationMgr.setFileBaseDirectory(directory);
				reportGenerationMgr.setFileLocation(
						directory + File.separator + ReportConstants.MAIN_PATH + File.separator +
						reportDefinitionList.getReportCategory().getName() + File.separator);
				reportGenerationMgr.setFrequency(reportDefinitionList.getFrequency());
				reportGenerationMgr.setProcessingClass(reportDefinitionList.getProcessingClass());
				reportGenerationMgr.setHeaderFields(reportDefinitionList.getHeaderFields());
				reportGenerationMgr.setBodyFields(reportDefinitionList.getBodyFields());
				reportGenerationMgr.setTrailerFields(reportDefinitionList.getTrailerFields());
				reportGenerationMgr.setBodyQuery(reportDefinitionList.getBodyQuery());
				reportGenerationMgr.setTrailerQuery(reportDefinitionList.getTrailerQuery());
				runReport(reportGenerationMgr);
			}
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
