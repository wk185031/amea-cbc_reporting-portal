import { Component, OnInit } from '@angular/core';
import { HttpResponse, HttpClient } from '@angular/common/http';
import { HttpEvent } from '@angular/common/http/src/response';
import { Principal } from '../../shared';
import { GenerateReportService } from './generate-report.service';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';
import { JhiAlertService } from 'ng-jhipster';
import { GeneratedReportDTO } from './generatedReportDTO.dto';

import { UserExtraService, UserExtra } from '../../entities/user-extra';
@Component({
    selector: 'download-report-tab',
    templateUrl: './download-report-tab.component.html'
})
export class DownloadReportTabComponent implements OnInit {
    reports: ReportDefinition[];
    generatedReportDTOs: GeneratedReportDTO[];
    userExtra: UserExtra;
    institutionId: number;
    branchId: number;

    constructor(
        private generateReportService: GenerateReportService,
        private jhiAlertService: JhiAlertService,
        private userExtraService: UserExtraService,
        private http: HttpClient,
        private principal: Principal
    ) {
    }

    ngOnInit() {
        this.principal.identity().then((account) => {
            this.institutionId = this.principal.getSelectedInstitutionId();
            // For Branch
            /*
            this.userExtraService.find(+account.id).subscribe((res: HttpResponse<UserExtra>) => {
                this.userExtra = res.body; 
                branchId = ths.userExtra.branch;
            });
            */
            this.generateReportService.getReportList(this.institutionId).subscribe((data: any) => {
                this.generatedReportDTOs = data;
            }, (error) => {
                this.onError(error.message);
                this.generatedReportDTOs = [];
            });
        });

    }

    download(reportCategoryId: number, date: string, reportName: string) {
        console.log('reportCategoryId: ' + reportCategoryId + ', date: ' + date + ', file: ' + reportName);
        const req = this.generateReportService.downloadReport(reportCategoryId, date, reportName);
        this.http.request(req).subscribe(
            (requestEvent: HttpEvent<Blob[]>) => {
                if (requestEvent instanceof HttpResponse) {
                    if (requestEvent.body) {
                        if (reportName === 'All') {
                            const fileName = date + '.zip';
                            const a: any = document.createElement('a');
                            a.href = window.URL.createObjectURL(requestEvent.body);
                            a.target = '_blank';
                            a.download = fileName;
                            document.body.appendChild(a);
                            a.click();
                        } else {
                            const fileName = date + '-' + reportName + '.zip';
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

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }
}
