package my.com.mandrill.mapper;

import org.apache.commons.lang3.StringUtils;

public class ChannelMapper {

	private static final String BANCNET_ONLINE_ACQ_ID = "9990";
	private static final String BANCNET_ATM_CHANNEL = "BANCNET_ATM";
	
	public static String fromAuth(String originChannel, String interchange, String acqId) {
		if (originChannel != null && !originChannel.trim().isEmpty()) {
			
			if (BANCNET_ATM_CHANNEL.equals(originChannel)) {
				return "ATM";
			}
			
			return originChannel;
		}
		
		if ("Authentic_Service".equals(interchange)) {
			return "MBK";
		} else if ("NDC".equals(interchange)) {
			return "ATM";
		} else if (acqId != null && StringUtils.removeFirst(acqId, "0").equals(BANCNET_ONLINE_ACQ_ID)) {
			return "BANCNET_ONLINE";
		} 
		return null;
	}	
}
