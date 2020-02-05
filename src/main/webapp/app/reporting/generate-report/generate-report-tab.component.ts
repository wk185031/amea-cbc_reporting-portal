import { Component, OnInit, Input } from '@angular/core';

import { GenerateReportService } from './generate-report.service';
import { ReportCategory } from '../report-config-category/report-config-category.model';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';
import { Subscription } from 'rxjs';
import { JhiAlertService, JhiEventManager } from 'ng-jhipster';
import { Principal } from '../../shared';
import { ReportGeneration } from './generate-report.model';
import { NgxUiLoaderService } from 'ngx-ui-loader';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

@Component({
    selector: 'generate-report-tab',
    templateUrl: './generate-report-tab.component.html'
})
export class GenerateReportTabComponent implements OnInit {
    currentAccount: any;
    eventSubscriber: Subscription;
    deleteEventSubscriber: Subscription;
    fromDateString: String;
    toDateString: String;
    category: ReportCategory;
    @Input() categories: ReportCategory[];
    report: ReportDefinition;
    reports: ReportDefinition[];
    @Input() allReports: ReportDefinition[];
    generateReport: ReportGeneration;
    generated: String;
    failed: String;

    constructor(
        private generateReportService: GenerateReportService,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private eventManager: JhiEventManager,
        private ngxLoader: NgxUiLoaderService
    ) {
        this.reports = [];
    }

    loadAll() {
        const toDate = new Date();
        toDate.setDate(toDate.getDate() - 1);
        this.generateReport.txnEnd = this.formatDateString(toDate);
        this.generateReport.txnStart = this.formatDateString(toDate);
        this.category = this.categories[0];
        this.report = null;
        this.filterByCategory();
    }

    ngOnInit() {
        this.generateReport = new ReportGeneration();
        this.loadAll();
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.registerChangeInReportGeneration();
        this.category = this.categories[0];
        this.generated = "baseApp.reportGenerationResult.generated";
        this.failed = "baseApp.reportGenerationResult.failed";
    }

    ngOnDestroy() {
        if (this.eventManager && this.eventSubscriber) {
            this.eventManager.destroy(this.eventSubscriber);
        }
    }

    private onSuccess(msg: any) {
        this.ngxLoader.stop();
        this.jhiAlertService.success(msg, null, null);
    }

    private onError(msg: any) {
        this.ngxLoader.stop();
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
        this.reports = this.allReports.filter(report => report.reportCategory.id === this.category.id);
    }

    generate() {
        if (this.generateReport && this.generateReport.fileDate) {
            this.ngxLoader.start();
            this.generateReportService.generateReport(this.category.id,
                this.report ? this.report.id : 0,
                this.generateReport.fileDate,
                this.generateReport.txnStart,
                this.generateReport.txnEnd).subscribe(
                (res: HttpResponse<ReportDefinition[]>) => {
                    this.onSuccess(this.generated);
                },
                (res: HttpErrorResponse) => this.onError(this.failed));
        }
    }
}
