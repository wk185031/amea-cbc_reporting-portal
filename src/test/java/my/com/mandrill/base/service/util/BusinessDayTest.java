package my.com.mandrill.base.service.util;

import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.Test;

public class BusinessDayTest {

	@Test
	public void testIsWorkingDay() {

		LocalDate minTestDate = LocalDate.parse("2021-08-12");
		LocalDate maxTestDate = LocalDate.parse("2021-08-25");

		LocalDate currentDate = minTestDate;
		List<LocalDate> holidays = getHolidayList();

		while (currentDate.isBefore(maxTestDate)) {
			boolean isWorkingDay = BusinessDay.isWorkingDay(currentDate, Optional.of(holidays));
			if (getExpectedWorkDays().contains(currentDate)) {
				System.out.println(currentDate + " is working day");
				assert isWorkingDay;
			} else {
				System.out.println(currentDate + " is holiday");
				assert !isWorkingDay;
			}
			currentDate = currentDate.plus(Period.ofDays(1));
		}
	}

	@Test
	public void testRollBackward() {
		LocalDate minTestDate = LocalDate.parse("2021-08-12");
		LocalDate maxTestDate = LocalDate.parse("2021-09-01");

		LocalDate currentDate = minTestDate;
		List<LocalDate> holidays = getHolidayList();

		Map<LocalDate, LocalDate> expected = expectedRollBackwardResults();

		do {
			assert BusinessDay.rollBackward(currentDate, Optional.of(holidays)).equals(expected.get(currentDate));
			currentDate = currentDate.plus(Period.ofDays(1));
		} while (currentDate.isBefore(maxTestDate));
	}

	@Test
	public void testRollForward() {
		LocalDate minTestDate = LocalDate.parse("2021-08-12");
		LocalDate maxTestDate = LocalDate.parse("2021-09-01");

		LocalDate currentDate = minTestDate;
		List<LocalDate> holidays = getHolidayList();

		Map<LocalDate, LocalDate> expected = expectedRollForwardResults();

		do {
			assert BusinessDay.rollForward(currentDate, Optional.of(holidays)).equals(expected.get(currentDate));
			currentDate = currentDate.plus(Period.ofDays(1));
		} while (currentDate.isBefore(maxTestDate));
	}

	private Map<LocalDate, LocalDate> expectedRollBackwardResults() {
		Map<LocalDate, LocalDate> map = new HashMap<>();
		map.put(LocalDate.parse("2021-08-12"), LocalDate.parse("2021-08-12"));
		map.put(LocalDate.parse("2021-08-13"), LocalDate.parse("2021-08-13"));
		map.put(LocalDate.parse("2021-08-14"), LocalDate.parse("2021-08-14"));
		map.put(LocalDate.parse("2021-08-15"), LocalDate.parse("2021-08-15"));
		map.put(LocalDate.parse("2021-08-16"), LocalDate.parse("2021-08-16"));
		map.put(LocalDate.parse("2021-08-17"), LocalDate.parse("2021-08-13"));
		map.put(LocalDate.parse("2021-08-18"), LocalDate.parse("2021-08-18"));
		map.put(LocalDate.parse("2021-08-19"), LocalDate.parse("2021-08-19"));
		map.put(LocalDate.parse("2021-08-20"), LocalDate.parse("2021-08-19"));
		map.put(LocalDate.parse("2021-08-21"), LocalDate.parse("2021-08-21"));
		map.put(LocalDate.parse("2021-08-22"), LocalDate.parse("2021-08-22"));
		map.put(LocalDate.parse("2021-08-23"), LocalDate.parse("2021-08-23"));
		map.put(LocalDate.parse("2021-08-24"), LocalDate.parse("2021-08-21"));
		map.put(LocalDate.parse("2021-08-25"), LocalDate.parse("2021-08-25"));
		map.put(LocalDate.parse("2021-08-26"), LocalDate.parse("2021-08-26"));
		map.put(LocalDate.parse("2021-08-27"), LocalDate.parse("2021-08-27"));
		map.put(LocalDate.parse("2021-08-28"), LocalDate.parse("2021-08-28"));
		map.put(LocalDate.parse("2021-08-29"), LocalDate.parse("2021-08-29"));
		map.put(LocalDate.parse("2021-08-30"), LocalDate.parse("2021-08-28"));
		map.put(LocalDate.parse("2021-08-31"), LocalDate.parse("2021-08-31"));

		return map;
	}

	private Map<LocalDate, LocalDate> expectedRollForwardResults() {
		Map<LocalDate, LocalDate> map = new HashMap<>();
		map.put(LocalDate.parse("2021-08-12"), LocalDate.parse("2021-08-12"));
		map.put(LocalDate.parse("2021-08-13"), LocalDate.parse("2021-08-17"));
		map.put(LocalDate.parse("2021-08-14"), LocalDate.parse("2021-08-17"));
		map.put(LocalDate.parse("2021-08-15"), LocalDate.parse("2021-08-17"));
		map.put(LocalDate.parse("2021-08-16"), LocalDate.parse("2021-08-17"));
		map.put(LocalDate.parse("2021-08-17"), LocalDate.parse("2021-08-17"));
		map.put(LocalDate.parse("2021-08-18"), LocalDate.parse("2021-08-18"));
		map.put(LocalDate.parse("2021-08-19"), LocalDate.parse("2021-08-20"));
		map.put(LocalDate.parse("2021-08-20"), LocalDate.parse("2021-08-20"));
		map.put(LocalDate.parse("2021-08-21"), LocalDate.parse("2021-08-24"));
		map.put(LocalDate.parse("2021-08-22"), LocalDate.parse("2021-08-24"));
		map.put(LocalDate.parse("2021-08-23"), LocalDate.parse("2021-08-24"));
		map.put(LocalDate.parse("2021-08-24"), LocalDate.parse("2021-08-24"));
		map.put(LocalDate.parse("2021-08-25"), LocalDate.parse("2021-08-25"));
		map.put(LocalDate.parse("2021-08-26"), LocalDate.parse("2021-08-26"));
		map.put(LocalDate.parse("2021-08-27"), LocalDate.parse("2021-08-27"));
		map.put(LocalDate.parse("2021-08-28"), LocalDate.parse("2021-08-30"));
		map.put(LocalDate.parse("2021-08-29"), LocalDate.parse("2021-08-30"));
		map.put(LocalDate.parse("2021-08-30"), LocalDate.parse("2021-08-30"));
		map.put(LocalDate.parse("2021-08-31"), LocalDate.parse("2021-08-31"));

		return map;
	}

	private List<LocalDate> getExpectedWorkDays() {
		List<LocalDate> workDays = new ArrayList<LocalDate>();

		workDays.add(LocalDate.parse("2021-08-12"));
		workDays.add(LocalDate.parse("2021-08-17"));
		workDays.add(LocalDate.parse("2021-08-18"));
		workDays.add(LocalDate.parse("2021-08-20"));
		workDays.add(LocalDate.parse("2021-08-24"));
		workDays.add(LocalDate.parse("2021-08-25"));

		return workDays;
	}

	private List<LocalDate> getHolidayList() {
		List<LocalDate> holidays = new ArrayList<LocalDate>();

		holidays.add(LocalDate.parse("2021-08-13"));
		holidays.add(LocalDate.parse("2021-08-16"));
		holidays.add(LocalDate.parse("2021-08-19"));
		holidays.add(LocalDate.parse("2021-08-23"));

		return holidays;
	}

}
