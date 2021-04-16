package my.com.mandrill.base.processor;

import my.com.mandrill.base.reporting.ReportConstants;
import org.springframework.validation.annotation.Validated;

import javax.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public interface IReportOutputFileName {

    @Validated
    /**
     * Generate report file name with report date range value
     * @param fileNamePrefix file name prefix
     * @param tnxStartDate report start date
     * @param reportTxnEndDate report end date
     * @param reportExtension report extension
     * @return String of filename (fileNamePrefix + " " + startDateStr + "-" + endDateStr + reportExtension)
     **/
    default String generateDateRangeOutputFileName(String fileNamePrefix, @NotNull LocalDateTime txnStartDate, @NotNull LocalDateTime reportTxnEndDate, String reportExtension){

        String startDateStr = txnStartDate.format(DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_05)).replace("1200AM", "0000AM");
        String endDateStr = reportTxnEndDate.format(DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_05));

        return fileNamePrefix + " " + startDateStr + "-" + endDateStr + reportExtension;
    }
}
