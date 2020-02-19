import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ReportCategory } from '../report-config-category/report-config-category.model';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';

@Component({
    selector: 'jhi-generate-report',
    templateUrl: './generate-report.component.html'
})
export class GenerateReportComponent {
    generateReportTab = 'nav-link active';
    downloadReportTab = 'nav-link';
    categories: ReportCategory[];
    reportDefinitions: ReportDefinition[];

    constructor(private activatedRoute: ActivatedRoute) {
        this.activatedRoute.data.subscribe((data) => {
            this.categories = data['pagingParams'].categories;
            this.reportDefinitions = data['pagingParams'].reportDefinitions;
        });
    }

    onTabChange(value) {
        this.generateReportTab = 'nav-link';
        this.downloadReportTab = 'nav-link';
        if (value === 'generate') {
            this.generateReportTab = 'nav-link active';
        } else if (value === 'download') {
            this.downloadReportTab = 'nav-link active';
        }
    }
}
