package my.com.mandrill.base.service.util;

import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.reporting.ReportConstants;
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
}
