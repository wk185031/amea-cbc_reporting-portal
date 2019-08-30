import { Component, OnInit, Input } from '@angular/core';

import { GenerateReportService } from './generate-report.service';
import { ReportCategory } from '../report-config-category/report-config-category.model';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';
import { Subscription } from 'rxjs';
import { JhiAlertService, JhiEventManager } from 'ng-jhipster';
import { Principal } from '../../shared';
import { ReportGeneration } from './generate-report.model';

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

    constructor(
        private generateReportService: GenerateReportService,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private eventManager: JhiEventManager
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
        this.reports = this.allReports.filter(report => report.reportCategory.id === this.category.id);
    }

    generate() {
        if (this.generateReport && this.generateReport.fileDate) {
            this.generateReportService.generateReport(this.category.id,
                this.report ? this.report.id : 0,
                this.generateReport.fileDate,
                this.generateReport.txnStart,
                this.generateReport.txnEnd);
        }
    }
}
