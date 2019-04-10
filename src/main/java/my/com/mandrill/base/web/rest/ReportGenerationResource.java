package my.com.mandrill.base.web.rest;

import static my.com.mandrill.base.service.AppPermissionService.COLON;
import static my.com.mandrill.base.service.AppPermissionService.MENU;
import static my.com.mandrill.base.service.AppPermissionService.RESOURCE_GENERATE_REPORT;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Optional;

import javax.persistence.EntityManager;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.github.jhipster.web.util.ResponseUtil;
import my.com.mandrill.base.domain.ReportDefinition;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.repository.ReportDefinitionRepository;
import my.com.mandrill.base.repository.search.ReportDefinitionSearchRepository;
import my.com.mandrill.base.security.SecurityUtils;

/**
 * REST controller for managing ReportGeneration.
 */
@RestController
@RequestMapping("/api")
public class ReportGenerationResource {

	private final Logger log = LoggerFactory.getLogger(ReportGenerationResource.class);
	private static final String ENTITY_NAME = "reportGeneration";
	private final ReportDefinitionRepository reportDefinitionRepository;
	private final ReportDefinitionSearchRepository reportDefinitionSearchRepository;
	private final EntityManager entityManager;
	private final Environment env;

	public ReportGenerationResource(ReportDefinitionRepository reportDefinitionRepository,
			ReportDefinitionSearchRepository reportDefinitionSearchRepository, EntityManager entityManager,
			Environment env) {
		this.reportDefinitionRepository = reportDefinitionRepository;
		this.reportDefinitionSearchRepository = reportDefinitionSearchRepository;
		this.entityManager = entityManager;
		this.env = env;
	}

	@GetMapping("/reportGeneration/{reportId}/{fileDate}/{txnStart}/{txnEnd}")
	@PreAuthorize("@AppPermissionService.hasPermission('" + MENU + COLON + RESOURCE_GENERATE_REPORT + "')")
	public ResponseEntity<ReportDefinition> generateReport(@PathVariable Long reportId, @PathVariable String fileDate,
			@PathVariable String txnStart, @PathVariable String txnEnd) throws ParseException {
		log.debug("User: {}, Rest to generate report ID: {}, File Date: {}, Txn Start Date: {}, Txn End Date: {}",
				SecurityUtils.getCurrentUserLogin().orElse(""), reportId, fileDate, txnStart, txnEnd);
		ReportDefinition reportDefinition = reportDefinitionRepository.findOne(reportId);
		txnStart = txnStart.replace("-", "");
		txnEnd = txnEnd.replace("-", "");
		ReportGenerationMgr reportGenerationMgr = new ReportGenerationMgr();
		reportGenerationMgr.setGenerate(true);
		reportGenerationMgr.setReportCategory(reportDefinition.getReportCategory().getName());
		reportGenerationMgr.setFileName(reportDefinition.getName());
		reportGenerationMgr.setFileNamePrefix(reportDefinition.getFileNamePrefix());
		reportGenerationMgr.setFileFormat(reportDefinition.getFileFormat());
		reportGenerationMgr.setFileLocation(reportDefinition.getFileLocation());
		reportGenerationMgr.setProcessingClass(reportDefinition.getProcessingClass());
		reportGenerationMgr.setHeaderFields(reportDefinition.getHeaderFields());
		reportGenerationMgr.setBodyFields(reportDefinition.getBodyFields());
		reportGenerationMgr.setTrailerFields(reportDefinition.getTrailerFields());
		reportGenerationMgr.setQuery(reportDefinition.getQuery());
		reportGenerationMgr.setFileDate(getFileDate(fileDate));
		reportGenerationMgr.setTxnStartDate(getTxnStartDate(txnStart));
		reportGenerationMgr.setTxnEndDate(getTxnEndDate(txnEnd));
		reportGenerationMgr.run(env.getProperty(ReportConstants.DB_URL), env.getProperty(ReportConstants.DB_USERNAME),
				env.getProperty(ReportConstants.DB_PASSWORD));

		return ResponseUtil.wrapOrNotFound(Optional.ofNullable(reportDefinition));
	}

	private Date getFileDate(String fileDate) throws ParseException {
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_01);
		Date date = df.parse(fileDate);
		return date;
	}

	private Date getTxnStartDate(String txnStart) throws ParseException {
		String txnStartTime = txnStart + " " + ReportConstants.START_TIME;
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_07);
		Date date = df.parse(txnStartTime);
		return date;
	}

	private Date getTxnEndDate(String txnEnd) throws ParseException {
		String txnStartTime = txnEnd + " " + ReportConstants.END_TIME;
		SimpleDateFormat df = new SimpleDateFormat(ReportConstants.DATE_FORMAT_07);
		Date date = df.parse(txnStartTime);
		return date;
	}
}
