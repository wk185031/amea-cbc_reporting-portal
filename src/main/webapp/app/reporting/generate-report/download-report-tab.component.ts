import { Component, OnInit, OnDestroy, Input, OnChanges } from '@angular/core';
import { HttpResponse, HttpErrorResponse, HttpClient } from '@angular/common/http';
import { HttpEvent } from '@angular/common/http/src/response';
import { Principal } from '../../shared';
import { GenerateReportService } from './generate-report.service';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';

@Component({
    selector: 'download-report-tab',
    templateUrl: './download-report-tab.component.html'
})
export class DownloadReportTabComponent implements OnInit {
    reports: ReportDefinition[];

    constructor(
        private generateReportService: GenerateReportService,
        private http: HttpClient
    ) {
    }

    ngOnInit() {
        this.reports = this.generateReportService.reportDefinition;
    }

    download(reportCategoryId: number, reportId: number) {
        for (const report of this.reports) {
            console.log(reportCategoryId);
            const req = this.generateReportService.downloadReport(reportCategoryId, reportId);
            this.http.request(req).subscribe(
                (requestEvent: HttpEvent<Blob>) => {
                    if (requestEvent instanceof HttpResponse) {
                        if (requestEvent.body) {
                            if (reportId === 0) {
                                if (report.generatedFileNamePdf) {
                                    const fileName = report.reportCategory.name + "_PDF.zip";
                                    const a: any = document.createElement('a');
                                    a.href = window.URL.createObjectURL(requestEvent.body);
                                    a.target = '_blank';
                                    a.download = fileName;
                                    document.body.appendChild(a);
                                    a.click();
                                }
                                if (report.generatedFileNameTxt) {
                                    const fileName = report.reportCategory.name + "_TXT.zip";
                                    console.log(fileName);
                                    const a: any = document.createElement('a');
                                    a.href = window.URL.createObjectURL(requestEvent.body);
                                    a.target = '_blank';
                                    a.download = fileName;
                                    document.body.appendChild(a);
                                    a.click();
                                }
                                if (report.generatedFileNameCsv) {
                                    const fileName = report.reportCategory.name + "_CSV.zip";
                                    console.log(fileName);
                                    const a: any = document.createElement('a');
                                    a.href = window.URL.createObjectURL(requestEvent.body);
                                    a.target = '_blank';
                                    a.download = fileName;
                                    document.body.appendChild(a);
                                    a.click();
                                }
                            } else {
                                if (report.generatedFileNamePdf) {
                                    console.log(report.generatedFileNamePdf);
                                    const fileName = report.generatedFileNamePdf;
                                    const a: any = document.createElement('a');
                                    a.href = window.URL.createObjectURL(requestEvent.body);
                                    a.target = '_blank';
                                    a.download = fileName;
                                    document.body.appendChild(a);
                                    a.click();
                                }
                                if (report.generatedFileNameTxt) {
                                    console.log(report.generatedFileNameTxt);
                                    const fileName = report.generatedFileNameTxt;
                                    const a: any = document.createElement('a');
                                    a.href = window.URL.createObjectURL(requestEvent.body);
                                    a.target = '_blank';
                                    a.download = fileName;
                                    document.body.appendChild(a);
                                    a.click();
                                }
                                if (report.generatedFileNameCsv) {
                                    console.log(report.generatedFileNameCsv);
                                    const fileName = report.generatedFileNameCsv;
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
                    this.generateReportService.reportDefinition = this.generateReportService.reportDefinition.filter((existingReport) => existingReport.id !== report.id);
                }
            );
        }
    }
}
