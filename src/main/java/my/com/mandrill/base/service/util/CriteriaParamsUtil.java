package my.com.mandrill.base.service.util;

import java.time.format.DateTimeFormatter;
import java.util.regex.Pattern;

import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.reporting.ReportConstants;
import my.com.mandrill.base.reporting.ReportGenerationMgr;
import my.com.mandrill.base.reporting.SpringContext;
import my.com.mandrill.base.repository.SystemConfigurationRepository;

public class CriteriaParamsUtil {

	public static String replaceBranchFilterCriteria(String originalString, String institution) {
		if (originalString != null && originalString.contains(ReportConstants.PARAM_BRANCH_INST_FILTER)) {
			SystemConfigurationRepository repo = SpringContext.getBean(SystemConfigurationRepository.class);
			String configName = institution.toLowerCase() + ".branch.prefix";
			SystemConfiguration branchPrefix = repo.findByName(configName);
			
			if (branchPrefix == null) {
				return originalString.replace(ReportConstants.PARAM_BRANCH_INST_FILTER, "");
			}
			
			StringBuilder likeStatement = new StringBuilder();
			String[] prefixes = branchPrefix.getConfig().split(",");
			
			for (String prefix : prefixes) {
				if (likeStatement.length() == 0) {
					likeStatement.append(" AND");	
				} else {
					likeStatement.append(" OR");	
				}
				likeStatement.append(" CBA_CODE like '%").append(prefix).append("'");	
			}
			
			return originalString.replace(ReportConstants.PARAM_BRANCH_INST_FILTER, likeStatement.toString());
		}
		return originalString;
	}	
	
	public static String replaceInstitution(String originalString, String institution, String... params) {
		if (originalString == null || originalString.trim().isEmpty()) {
			return originalString;
		}
		
		String replaceString = originalString;
		
		for (String p : params) {
			if (p != null) {
				String paramPlaceholder = "\\{" + p + "\\}";
				if (ReportConstants.VALUE_INTER_ISSUER_NAME.equals(p) || ReportConstants.VALUE_INTER_ACQUIRER_NAME.equals(p)
						|| ReportConstants.VALUE_INTER_DEO_NAME.equals(p)) {
					String ieInst = "CBC".equals(institution) ? "CBS" : "CBC";
					replaceString = replaceString.replaceAll(paramPlaceholder, "'" + ieInst + "'");
				} else if (ReportConstants.VALUE_ACQR_INST_ID.equals(p) || ReportConstants.VALUE_RECV_INST_ID.equals(p)) {
					String instId = "CBC".equals(institution) ? "0000000010" : "0000000112";
					replaceString = replaceString.replaceAll(paramPlaceholder, "'" + instId + "'");
				} else if (ReportConstants.VALUE_INTER_ACQR_INST_ID.equals(p) || ReportConstants.VALUE_INTER_RECV_INST_ID.equals(p)) {
					String interInstId = "CBC".equals(institution) ? "0000000112" : "0000000010";
					replaceString = replaceString.replaceAll(paramPlaceholder, "'" + interInstId + "'");
				} else {
					replaceString = replaceString.replaceAll(paramPlaceholder, "'" + institution + "'");
				}	
			}
		}
		return replaceString;
	}	
	
	public static String replaceTxnDate(String query, ReportGenerationMgr rgm) {
		
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_01);
		String txnStart = rgm.getTxnStartDate().format(formatter);
		String txnEnd = rgm.getTxnEndDate().format(formatter);
		
		String criteria = "EVENT_DATE >= TO_DATE('" + txnStart + "', '" + ReportConstants.FORMAT_TXN_DATE
				+ "') AND EVENT_DATE < TO_DATE('" + txnEnd + "','"
				+ ReportConstants.FORMAT_TXN_DATE + "')";
		
		query = query.replace('{'+ReportConstants.PARAM_TXN_DATE+'}', criteria);
		
		return query;
		
	}
	
	public static String findDatePattern(String date) {
		
		String yearReg4 = "\\d{4}";
		String yearReg2 = "\\d{2}";
		String monthReg = "(0[1-9]|1[0-2])"; 
		String dayReg = "(0[1-9]|1[0-9]|2[0-9]|3[0-1])";
		String hourReg = "([0-1][0-9]|2[0-3])";
		String minReg = "([0-5][0-9])"; 
		String secReg = "([0-5][0-9])";
		
		if (Pattern.matches("^" + yearReg4 + "-" + monthReg + "-" + dayReg + " " + hourReg + ":" + minReg +":" + secReg +"$", date)) {
			return "yyyy-MM-dd HH:mm:ss";
		} else if (Pattern.matches("^" + monthReg + "-" + dayReg + "-" + yearReg2 + " " + hourReg + ":" + minReg +"$", date)) {
			return "MM-dd-yy HH:mm";
		} else if (Pattern.matches("^" + monthReg + "/" + dayReg + "/" + yearReg2 + " " + hourReg + ":" + minReg +"$", date)) {
			return "MM/dd/yy HH:mm";
		} else if (Pattern.matches("^" + monthReg + "/" + dayReg + "/" + yearReg2 +"$", date)) {
			return "MM/dd/yy";
		} else if (Pattern.matches("^" + monthReg + "-" + dayReg + "-" + yearReg2 +"$", date)) {
			return "MM-dd-yy";
		}
		
		return null;
	}
}
