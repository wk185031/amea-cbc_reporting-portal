import { Component, OnInit, Input } from '@angular/core';
import { HttpResponse, HttpClient } from '@angular/common/http';
import { HttpEvent } from '@angular/common/http/src/response';
import { Principal } from '../../shared';
import { GenerateReportService } from './generate-report.service';
import { JhiAlertService } from 'ng-jhipster';
import { GeneratedReportDTO } from './generatedReportDTO.dto';
import { ReportCategory } from '../report-config-category/report-config-category.model';
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
    allCategory: ReportCategory = { id: 0, name: 'All' };

    constructor(
        private generateReportService: GenerateReportService,
        private jhiAlertService: JhiAlertService,
        private http: HttpClient,
        private principal: Principal,
    ) {
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
            this.getReport();
        });
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

    download(reportName: string, reportCategoryId: number) {
        const req = this.generateReportService.downloadReport(this.institutionId,
            (this.reportType === 'monthly' ? this.reportMonth + '-00' : this.reportDate), reportCategoryId, reportName);
        this.http.request(req).subscribe(
            (requestEvent: HttpEvent<Blob[]>) => {
                if (requestEvent instanceof HttpResponse) {
                    if (requestEvent.body) {
                        if (reportName === 'All') {
                            const fileName = this.category.name + this.reportDate + '.zip';
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

    formatDateToString(date) {
        const dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
        const MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
        const yyyy = date.getFullYear();
        return (yyyy + '-' + MM + '-' + dd);
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }
}
