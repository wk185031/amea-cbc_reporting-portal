package com.authentic.secure.mask;

import java.util.Arrays;

import my.com.mandrill.base.reporting.security.Masker;
import my.com.mandrill.base.reporting.security.SecurityManagerService;

public class PANMasker extends Masker {

	public PANMasker() {
		super();
	}

	/**
	 * Apply a mask to the specified string.
	 * 
	 * <p>
	 * If the specified string is 4 or less characters in length then no masking is
	 * performed and the original string is return.
	 * 
	 * <p>
	 * If the string is between 5 and 12 characters in length, the first 4
	 * characters are masked.
	 * 
	 * <p>
	 * If the string is over 12 characters in length, the first 6 and last 4
	 * characters are shown in the clear while the intervening characters are
	 * masked.
	 * 
	 * @param The
	 *            string to be masked.
	 * @return The masked version of the specified string.
	 */
	@Override
	public String mask(String string) {
		String result = string;
		if (string != null && string.length() > 4) {
			int length = string.length();
			char[] mask = new char[length];
			Arrays.fill(mask, SecurityManagerService.getMaskChar().charAt(0));

			if (length > 12) {
				result = string.substring(0, 6) + String.valueOf(mask).substring(10) + string.substring(length - 4);
			} else {
				result = String.valueOf(mask).substring(4) + string.substring(length - 4);
			}
		}
		return result;
	}
}
