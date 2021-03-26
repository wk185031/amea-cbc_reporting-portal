package my.com.mandrill.base.service.util;

import my.com.mandrill.base.reporting.ReportConstants;

public class CriteriaParamsUtil {

	public static String replaceInstitution(String originalString, String institution, String... params) {
		if (originalString == null || originalString.trim().isEmpty()) {
			return originalString;
		}
		
		String replaceString = originalString;
		
		for (String p : params) {
			if (p != null) {
				String paramPlaceholder = "\\{" + p + "\\}";
				if (ReportConstants.VALUE_INTER_ISSUER_NAME.equals(p)) {
					String ieInst = "CBC".equals(institution) ? "CBS" : "CBC";
					replaceString = replaceString.replaceAll(paramPlaceholder, "'" + ieInst + "'");
				} else {
					replaceString = replaceString.replaceAll(paramPlaceholder, "'" + institution + "'");
				}	
			}
		}
		return replaceString;
	}
	
}
