package my.com.mandrill.base.service.util;

import java.util.HashMap;
import java.util.Map;

import my.com.mandrill.base.domain.SystemConfiguration;
import my.com.mandrill.base.reporting.SpringContext;
import my.com.mandrill.base.repository.SystemConfigurationRepository;

public class EloadProviderUtil {
	
	public static Map<String, String> eloadProviderMap = new HashMap<>();

	public static Map<String, String> getEloadProviderMap() {
		
		if(eloadProviderMap.isEmpty()) {
			SystemConfigurationRepository configRepo = SpringContext.getBean(SystemConfigurationRepository.class);
			SystemConfiguration config = configRepo.findByName("eload.provider");
			
			for (String eloadProvider : config.getConfig().split(";")) {
				eloadProviderMap.put(eloadProvider.split("-")[0], eloadProvider.split("-")[1]);
			}
		}
				
		return eloadProviderMap;
	}
}
