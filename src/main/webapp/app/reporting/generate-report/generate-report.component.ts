import { Component, OnInit } from '@angular/core';

import { GenerateReportService } from './generate-report.service';
import { ReportCategory } from '../report-config-category/report-config-category.model';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';
import { Subscription, Observable } from 'rxjs';
import { JhiAlertService, JhiEventManager } from 'ng-jhipster';
import { Principal } from '../../shared';
import { ReportConfigCategoryService } from '../report-config-category/report-config-category.service';
import { ReportConfigDefinitionService } from '../report-config-definition/report-config-definition.service';
import { HttpErrorResponse, HttpResponse, HttpEvent, HttpClient } from '@angular/common/http';
import { ReportGeneration } from './generate-report.model';

@Component({
    selector: 'generate-report',
    templateUrl: './generate-report.component.html'
})
export class GenerateReportComponent implements OnInit {
    currentAccount: any;
    eventSubscriber: Subscription;
    deleteEventSubscriber: Subscription;
    fromDateString: String;
    toDateString: String;
    category: ReportCategory;
    categories: ReportCategory[];
    report: ReportDefinition;
    reports: ReportDefinition[];
    allReports: ReportDefinition[];
    generateReport: ReportGeneration;

    constructor(
        private generateReportService: GenerateReportService,
        private reportConfigCategoryService: ReportConfigCategoryService,
        private reportConfigDefinitionService: ReportConfigDefinitionService,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private eventManager: JhiEventManager,
        private http: HttpClient
    ) {
    }

    loadAll() {
        const toDate = new Date(Date.now());
        this.generateReport.txnEnd = this.formatDateString(toDate);
        const fromDate = new Date();
        fromDate.setDate(fromDate.getDate() - 1);
        this.generateReport.txnStart = this.formatDateString(fromDate);

        this.reportConfigDefinitionService.query().subscribe((response: HttpResponse<ReportDefinition[]>) => {
            this.allReports = response.body;
            this.reportConfigCategoryService.query().subscribe((response: HttpResponse<ReportCategory[]>) => {
                this.categories = response.body;
                if (this.categories || this.categories.length > 0) {
                    this.category = this.categories[0];
                    this.filterByCategory();
                }
            }, (response: HttpErrorResponse) => this.onError(response.message));
        }, (response: HttpErrorResponse) => this.onError(response.message));
    }

    ngOnInit() {
        this.generateReport = new ReportGeneration();
        this.loadAll();
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.registerChangeInReportGeneration();
    }

    ngOnDestroy() {
        if (this.eventManager && this.eventSubscriber) {
            this.eventManager.destroy(this.eventSubscriber);
        }
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
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
        if (this.allReports) {
            this.reports = this.allReports.filter(report => report.reportCategory.id === this.category.id);
            if (this.reports || this.reports.length > 0) {
                this.report = this.reports[0];
            }
        }
    }

    generate() {
        if (this.generateReport && this.report.id && this.generateReport.fileDate && this.generateReport.txnStart && this.generateReport.txnEnd) {
            const req = this.generateReportService.generateReport(this.report.id, this.generateReport.fileDate, this.generateReport.txnStart, this.generateReport.txnEnd);
            this.http.request(req).subscribe(
            );
        }
    }
}
