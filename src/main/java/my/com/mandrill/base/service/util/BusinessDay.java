package my.com.mandrill.base.service.util;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.Period;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BusinessDay {

	private final static Logger log = LoggerFactory.getLogger(BusinessDay.class);

	/**
	 * If previous day of the date is weekend or holiday, continue to roll backward
	 * until it finds the first occurence of weekend/holiday.
	 * 
	 * If date is weekend or holiday, return as is.
	 * 
	 * @param date
	 * @param holidays
	 * @return
	 */
	public static LocalDate rollBackward(LocalDate date, Optional<List<LocalDate>> holidays) {
		if (!isWorkingDay(date, holidays)) {
			return date;
		}
		
		LocalDate previousNonWorkingDay = date.minus(Period.ofDays(1));
		if (!isWorkingDay(previousNonWorkingDay, holidays)) {
			do {
				previousNonWorkingDay = previousNonWorkingDay.minus(Period.ofDays(1));
			} while (!isWorkingDay(previousNonWorkingDay, holidays));
		}
		// Add back 1 day as we want the last non working day
		// Or return date as is if yesterday is a working day
		previousNonWorkingDay = previousNonWorkingDay.plus(Period.ofDays(1));
		return previousNonWorkingDay;
	}

	/**
	 * If the date is weekend or holiday, find the next business day. Otherwise
	 * return as it is.
	 * 
	 * @param date
	 * @param holidays
	 * @return
	 */
	/**
	 * @param date
	 * @param holidays
	 * @return
	 */
	public static LocalDate rollForward(LocalDate date, Optional<List<LocalDate>> holidays) {
		if (!isWorkingDay(date, holidays)) {
			do {
				date = date.plus(Period.ofDays(1));
			} while (!isWorkingDay(date, holidays));
		}
		return date;
	}

	public static boolean isWorkingDay(LocalDate date, Optional<List<LocalDate>> holidays) {
		if (date == null) {
			throw new IllegalArgumentException("date must not be empty");
		}

		boolean isWeekend = date.getDayOfWeek() == DayOfWeek.SATURDAY || date.getDayOfWeek() == DayOfWeek.SUNDAY;
		boolean isHoliday = holidays.isPresent() && holidays.get().contains(date);

		log.debug("isWorkingDay: date={}, isWeekend={}, isHoliday={}", date, isWeekend, isHoliday);

		return !isWeekend && !isHoliday;
	}

}
