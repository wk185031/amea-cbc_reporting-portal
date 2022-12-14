import { Component, OnInit, Input } from '@angular/core';

import { GenerateReportService } from './generate-report.service';
import { ReportCategory } from '../report-config-category/report-config-category.model';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';
import { Subscription } from 'rxjs';
import { JhiAlertService, JhiEventManager } from 'ng-jhipster';
import { Principal } from '../../shared';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

@Component({
    selector: 'jhi-generate-report-tab',
    templateUrl: './generate-report-tab.component.html'
})
export class GenerateReportTabComponent implements OnInit {
    currentAccount: any;
    eventSubscriber: Subscription;
    deleteEventSubscriber: Subscription;
    institutionId: number;
    branchId: number;
    @Input() categories: ReportCategory[];
    category: ReportCategory;
    allCategory: ReportCategory = { id: 0, name: 'All' };
    @Input() allReports: ReportDefinition[];
    report: ReportDefinition;
    reports: ReportDefinition[];
    todaydate: string;
    txnStartDate: string;
    txnStartTime: string;
    txnEndDate: string;
    txnEndTime: string;
    generated: String;
    ongoingGenerate: String;
    failed: String;
    searchByDateRange: boolean = false;

    constructor(
        private generateReportService: GenerateReportService,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private eventManager: JhiEventManager
    ) {
        this.reports = [];
    }

    loadAll() {
        const today = new Date();
        this.todaydate = this.formatDateString(today);
        this.txnStartDate = this.todaydate;
        this.txnStartTime = '00:00';
        this.txnEndDate = this.todaydate;
        this.txnEndTime = '23:59';
        this.category = this.categories[0];
        this.report = null;
        this.filterByCategory();
    }

    ngOnInit() {
        this.loadAll();
        this.principal.identity().then((account) => {
            this.currentAccount = account;
            this.institutionId = this.principal.getSelectedInstitutionId();
            this.branchId = this.principal.getSelectedBranchId();
        });
        this.registerChangeInReportGeneration();
        this.category = this.categories[0];
        this.generated = 'baseApp.reportGenerationResult.generated';
        this.ongoingGenerate = 'baseApp.reportGeneration.ongoingGenerate';
        this.failed = 'baseApp.reportGenerationResult.failed';
    }

    ngOnDestroy() {
        if (this.eventManager && this.eventSubscriber) {
            this.eventManager.destroy(this.eventSubscriber);
        }
    }

    private onSuccess(msg: any) {
        this.jhiAlertService.success(msg, null, null);
    }

    private onError(msg: any) {
        this.jhiAlertService.error(msg, null, null);
    }

    registerChangeInReportGeneration() {
        this.eventSubscriber = this.eventManager.subscribe('reportGenerationListModification', (response) => this.loadAll());
        this.deleteEventSubscriber = this.eventManager.subscribe('reportGenerationTreeStructureDelete', (response) => this.loadAll());
    }

    formatDateString(date) {
        const dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
        const MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
        const yyyy = date.getFullYear();
        return (yyyy + '-' + MM + '-' + dd);
    }

    filterByCategory() {
        this.reports = this.allReports.filter((report) => report.reportCategory.id === this.category.id);
    }

    generate() {
            if (!this.searchByDateRange) {
              this.txnStartTime = '00:00';
              this.txnEndDate = this.txnStartDate;
              this.txnEndTime = '23:59';
            } else {
              if (!this.txnStartTime) {
                this.txnStartTime = '00:00';
              }
              if (!this.txnEndDate) {
                this.txnEndDate = this.txnStartDate;
              }
              if (!this.txnEndTime) {
                this.txnEndTime = '23:59';
              }
            }

            let startDateTime = this.txnStartDate + ' ' + this.txnStartTime;
            let endDateTime = this.txnEndDate + ' ' + this.txnEndTime;
            
            if (this.isDateRangeValid(startDateTime, endDateTime)) {
            	this.generateReportService.generateReportWithStartEndDate(this.branchId, this.institutionId, 
           			 this.category ? this.category.id : 0, this.report ? this.report.id : 0, startDateTime, endDateTime).subscribe(
                		(res: HttpResponse<ReportDefinition[]>) => {
                    		this.onSuccess(this.ongoingGenerate);
                		},
                		(res: HttpErrorResponse) => {
                			if (res.error.detail) {
                				this.onError(res.error.detail);
                			} else {
                				this.onError(res.error.message);
                			}
                	
                	});          	           	
            } else {
            	alert("Transaction End Date must be at least same or after Transaction Start Date.")
            }
            

           
    }
    
    isDateRangeValid(txnStartDate, txnEndDate) {		
    	let fromDate = new Date(txnStartDate);
    	let toDate = new Date(txnEndDate);

    	return toDate.getTime() >= fromDate.getTime();
    }
    
    disableDateSelection() {
	    if (this.report) {
	    	return this.report.name === 'Cash Card Balance';
	    } else {
	    	return false;
	    }	
    }

    resetDate(toReset) {
      if (toReset) {
        this.txnStartTime = null;
        this.txnEndDate = null;
        this.txnEndTime = null;
      } else {
        this.txnStartTime = '00:00';
        this.txnEndDate = this.txnStartDate;
        this.txnEndTime = '23:59';
      }
    }
}
