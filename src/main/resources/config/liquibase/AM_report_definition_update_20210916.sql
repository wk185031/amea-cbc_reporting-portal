begin
	update report_definition set red_rec_id = (select rec_id from report_category where rec_name = 'ATM Transaction Lists (Branch Reports)'), 
		red_processing_class = 'my.com.mandrill.base.reporting.reportProcessor.BranchReportProcessor', red_file_format = 'PDF,CSV,' where red_name = 'List of Recycler Transactions';
		
	update report_definition set red_rec_id = (select rec_id from report_category where rec_name = 'ATM Transaction Lists (Branch Reports)'), 
		red_processing_class = 'my.com.mandrill.base.reporting.reportProcessor.BranchReportProcessor', red_file_format = 'PDF,CSV,' where red_name = 'Summary of Recycler Transactions';
	
end;
/
