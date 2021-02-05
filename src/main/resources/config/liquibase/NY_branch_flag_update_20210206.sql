begin
	update report_category set rec_branch_flag = 'branch' where rec_name = 'ATM Transaction Lists (Branch Reports)';
	update report_category set rec_branch_flag = 'master' where rec_name <> 'ATM Transaction Lists (Branch Reports)';
	
	update report_definition set red_branch_flag = 'branch' where red_rec_id = (select rec_id from report_category where rec_name = 'ATM Transaction Lists (Branch Reports)');
	update report_definition set red_branch_flag = 'master' where red_rec_id in (select rec_id from report_category where rec_name <> 'ATM Transaction Lists (Branch Reports)');	
end;
/
