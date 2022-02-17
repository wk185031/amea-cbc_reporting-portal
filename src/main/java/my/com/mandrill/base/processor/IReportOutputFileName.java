package my.com.mandrill.base.processor;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import javax.validation.constraints.NotNull;

import org.springframework.validation.annotation.Validated;

import my.com.mandrill.base.reporting.ReportConstants;

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

        
        
        if (txnStartDate == null && reportTxnEndDate == null) {
        	return fileNamePrefix + "_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern(ReportConstants.DATE_FORMAT_MMDDYYYY)) + reportExtension; 
        } else {
        	String startDateStr = txnStartDate.format(DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_05)).replace("1200AM", "0000AM");
            String endDateStr = reportTxnEndDate.format(DateTimeFormatter.ofPattern(ReportConstants.DATETIME_FORMAT_05));
            
            return fileNamePrefix + " " + startDateStr + "-" + endDateStr + reportExtension;
        }
      
    }
}
