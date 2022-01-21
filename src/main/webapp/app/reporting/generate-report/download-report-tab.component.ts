import { Component, OnInit, Input } from '@angular/core';
import { HttpResponse, HttpErrorResponse, HttpClient } from '@angular/common/http';
import { HttpEvent } from '@angular/common/http/src/response';
import { GenerateReportService } from './generate-report.service';
import { GeneratedReportDTO } from './generatedReportDTO.dto';
// import { LoginModalService } from './login-modal.service';
import { ReportCategory } from '../report-config-category/report-config-category.model';
import { ActivatedRoute, Router } from '@angular/router';
import { JobHistory } from '../../app-admin/job-history/job-history.model';
import { JobHistoryService } from '../../app-admin/job-history/job-history.service';
import { JhiEventManager, JhiParseLinks, JhiAlertService } from 'ng-jhipster';
import { ITEMS_PER_PAGE, Principal } from '../../shared';
import { NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
 import { ReportStatusModalService } from './report-status-modal.service';


@Component({
    selector: 'jhi-download-report-tab',
    templateUrl: './download-report-tab.component.html'
})
export class DownloadReportTabComponent implements OnInit {
    generatedReportDTO: GeneratedReportDTO;
    institutionId: number;
    branchId: number;
    todaydate: string;
    reportType: string;
    reportDate: string;
    reportMonth: string;
    @Input() categories: ReportCategory[];
    category: ReportCategory;
    downloadReportCategory: ReportCategory;
    downloadReportDate: string;
    routeData: any;
    page: any;
    links: any;
    predicate: any;
    previousPage: any;
    totalItems: any;
    queryCount: any;
    reverse: any;
    allCategory: ReportCategory = { id: 0, name: 'All' };
    currentSearch: string;
    itemsPerPage: any;
    jobHistories: JobHistory[];
    txnDate: any;
    account: Account;
    modalRef: NgbModalRef;
    id: number;

    constructor(
        private generateReportService: GenerateReportService,
        private jobHistoryService: JobHistoryService,
        private jhiAlertService: JhiAlertService,
        private http: HttpClient,
        private principal: Principal,
        private activatedRoute: ActivatedRoute,
        private router: Router,
        private parseLinks: JhiParseLinks,
        // private loginService: LoginModalService,
         private reportStatusService: ReportStatusModalService
    ) {
    	this.itemsPerPage = ITEMS_PER_PAGE;
        this.routeData = this.activatedRoute.data.subscribe((data) => {
        this.page = data.pagingParams.page;
        this.previousPage = data.pagingParams.page;
        this.reverse = data.pagingParams.descending;
        this.predicate = data.pagingParams.predicate;
        });
    }

    ngOnInit() {
        const today = new Date();
        this.todaydate = this.formatDateToString(today);
        this.reportDate = this.todaydate;
        this.reportMonth = this.todaydate.substring(0, 7);
        this.reportType = 'daily';
        this.category = this.allCategory;
        this.generatedReportDTO = new GeneratedReportDTO();
        this.principal.identity().then((account) => {
            this.institutionId = this.principal.getSelectedInstitutionId();
            this.branchId = this.principal.getSelectedBranchId();
            this.account = account;
            this.getReport();
        });
        //this.loadAll();
    }

    getReport() {
        this.downloadReportCategory = this.category;
        this.downloadReportDate = this.reportDate;

        if (this.reportType === 'monthly') {
            this.generateReportService.getReport(this.institutionId, this.reportMonth + '-00', this.category.id).subscribe((data: any) => {
                this.generatedReportDTO = data;
            }, (error) => {
                this.onError(error.message);
            });
        } else {
            this.generateReportService.getReport(this.institutionId, this.reportDate, this.category.id).subscribe((data: any) => {
                this.generatedReportDTO = data;
            }, (error) => {
                this.onError(error.message);
                this.generatedReportDTO = null;
            });
        }
    }
    
    getGeneratedReport(details: string) {
    	var parsedDetail = JSON.parse(details);
        this.downloadReportCategory = parsedDetail.reportCategory;
        this.downloadReportDate = parsedDetail.transactionStartDate;

        if (!parsedDetail.searchByDate) {
            this.generateReportService.getReport(parsedDetail.institutionId, parsedDetail.transactionStartDate + '-00', parsedDetail.reportCategoryId).subscribe((data: any) => {
                this.generatedReportDTO = data;
            }, (error) => {
                this.onError(error.message);
            });
        } else {
            this.generateReportService.getReport(parsedDetail.institutionId, parsedDetail.transactionStartDate, parsedDetail.reportCategoryId).subscribe((data: any) => {
                this.generatedReportDTO = data;
            }, (error) => {
                this.onError(error.message);
                this.generatedReportDTO = null;
            });
        }
    }
    
    downloadReport(reportName: string, details: string, reportCategoryId: number, jobId: number, frequency: string, reportStartDate: string) {
    	var parsedDetail = JSON.parse(details);
        const req = this.generateReportService.downloadReport(this.branchId, parsedDetail.institutionId,
            reportStartDate, parsedDetail.reportCategoryId, parsedDetail.report, jobId, frequency);
        this.http.request(req).subscribe(
            (requestEvent: HttpEvent<Blob[]>) => {
                if (requestEvent instanceof HttpResponse) {
                    if (requestEvent.body) {
                        if (reportName === 'All') {
                            const fileName = parsedDetail.reportCategory + parsedDetail.transactionStartDate.slice(0, -6) + '.zip';
                            const a: any = document.createElement('a');
                            a.href = window.URL.createObjectURL(requestEvent.body);
                            a.target = '_blank';
                            a.download = fileName;
                            document.body.appendChild(a);
                            a.click();
                        } else {
                            const fileName = reportName;
                            const a: any = document.createElement('a');
                            a.href = window.URL.createObjectURL(requestEvent.body);
                            a.target = '_blank';
                            a.download = fileName;
                            document.body.appendChild(a);
                            a.click();
                        }
                    }
                }
            }
        );
    }

    deleteReport(jobId: string) {
        this.generateReportService.deleteReport(jobId).subscribe((response) => {
            this.loadAll();
        });
    }

    formatDateToString(date) {
        const dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
        const MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
        const yyyy = date.getFullYear();
        return (yyyy + '-' + MM + '-' + dd);
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }
       
    clear() {
        this.page = 0;
        this.txnDate = '';
        this.router.navigate(['/generate-report', {
            page: this.page,
            sort: this.predicate + ',' + (this.reverse ? 'asc' : 'desc')
        }]);
       
    }
    
    trackId(index: number, item: JobHistory){
    	return item.createdDate;
    }
    
    sort() {
        const result = [this.predicate + ',' + (this.reverse ? 'asc' : 'desc')];
        if (this.predicate !== 'createdDate') {
            result.push('createdDate');
        }
        return result;
    }
    
    searchReportGenerated(query) {
        this.page = 0;
        this.txnDate = query;
        this.router.navigate(['/generate-report', {
            search: this.txnDate,
            page: this.page,
            sort: this.predicate + ',' + (this.reverse ? 'asc' : 'desc')
        }]);
        this.loadAll();
    }
	
	private onSuccess(data, headers) {
	 	//console.log('data: '+JSON.stringify(data));
	 	this.links = this.parseLinks.parse(headers.get('link'));
        this.totalItems = headers.get('X-Total-Count');
        this.queryCount = this.totalItems;
        this.jobHistories = data;
    }
    
	loadAll() {
        if (this.txnDate) {
        	console.log('date selected: '+this.txnDate);
            this.jobHistoryService.searchJobHistory({
            	institutionId: this.institutionId,
                page: this.page - 1,
                query: this.txnDate,
                size: this.itemsPerPage,
                sort: this.sort()}).subscribe(
                    (res: HttpResponse<JobHistory[]>) => this.onSuccess(res.body, res.headers),
                    (res: HttpErrorResponse) => this.onError(res.message)
                );
            return;
        }
        console.log('no date selected');
        this.jobHistoryService.searchJobHistory({
        	institutionId: this.institutionId,
            page: this.page - 1,
            size: this.itemsPerPage,
            sort: this.sort()}).subscribe(
                (res: HttpResponse<JobHistory[]>) => this.onSuccess(res.body, res.headers),
                (res: HttpErrorResponse) => this.onError(res.message)
        );
    }
    
    loadPage(page: number) {
        if (page !== this.previousPage) {
            this.previousPage = page;
            this.transition();
        }
    }
    
    transition() {
        this.router.navigate(['/generate-report'], {queryParams:
            {
                page: this.page,
                size: this.itemsPerPage,
                search: this.txnDate,
                sort: this.predicate + ',' + (this.reverse ? 'asc' : 'desc')
            }
        });
        this.loadAll();
    }
    
    getDetails(detail) {
    	var parsedDetail = JSON.parse(detail);
		return parsedDetail.description;
	}
	
	getGeneratedEndDateTime(detail){
		var parsedDetail = JSON.parse(detail);
		return parsedDetail.endDateTime;
	}
	
	reportStatus(id:number, detail) {
		const parsedDetail = JSON.parse(detail);
		const reportStatusMap = parsedDetail.reportStatusMap;
			
		this.generateReportService.setJobDetail(reportStatusMap);
        this.modalRef = this.reportStatusService.open();
    }
}


