import { Component, OnInit } from '@angular/core';
import { DatePipe } from '@angular/common';
import { JhiParseLinks , JhiAlertService} from 'ng-jhipster';

import { Audit } from './audit.model';
import { AuditsService } from './audits.service';
import { ITEMS_PER_PAGE } from '../../shared';
import { GenerateReportService } from '../../reporting/generate-report/generate-report.service';

@Component({
  selector: 'jhi-audit',
  templateUrl: './audits.component.html'
})
export class AuditsComponent implements OnInit {
    audits: Audit[];
    fromDate: string;
    itemsPerPage: any;
    links: any;
    page: number;
    orderProp: string;
    reverse: boolean;
    toDate: string;
    totalItems: number;
    datePipe: DatePipe;

    constructor(
        private auditsService: AuditsService,
        private parseLinks: JhiParseLinks,
        private generateReportService: GenerateReportService,
        private jhiAlertService: JhiAlertService
    ) {
        this.itemsPerPage = ITEMS_PER_PAGE;
        this.page = 1;
        this.reverse = false;
        this.orderProp = 'timestamp';
        this.datePipe = new DatePipe('en');
    }

    getAudits() {
        return this.sortAudits(this.audits);
    }

    loadPage(page: number) {
        this.page = page;
        this.onChangeDate();
    }

    ngOnInit() {
        this.today();
        this.previousMonth();
        this.onChangeDate();
    }

    onChangeDate() {
        this.auditsService.query({page: this.page - 1, size: this.itemsPerPage,
            fromDate: this.fromDate, toDate: this.toDate}).subscribe((res) => {

            this.audits = res.body;
            this.links = this.parseLinks.parse(res.headers.get('link'));
            this.totalItems = + res.headers.get('X-Total-Count');
        });
    }

    previousMonth() {
        const dateFormat = 'yyyy-MM-dd';
        let fromDate: Date = new Date();

        if (fromDate.getMonth() === 0) {
            fromDate = new Date(fromDate.getFullYear() - 1, 11, fromDate.getDate());
        } else {
            fromDate = new Date(fromDate.getFullYear(), fromDate.getMonth() - 1, fromDate.getDate());
        }

        this.fromDate = this.datePipe.transform(fromDate, dateFormat);
    }

    today() {
        const dateFormat = 'yyyy-MM-dd';
        // Today + 1 day - needed if the current day must be included
        const today: Date = new Date();
        today.setDate(today.getDate() + 1);
        const date = new Date(today.getFullYear(), today.getMonth(), today.getDate());
        this.toDate = this.datePipe.transform(date, dateFormat);
    }

    private sortAudits(audits: Audit[]) {
        audits = audits.slice(0).sort((a, b) => {
            if (a[this.orderProp] < b[this.orderProp]) {
                return -1;
            } else if ([b[this.orderProp] < a[this.orderProp]]) {
                return 1;
            } else {
                return 0;
            }
        });

        return this.reverse ? audits.reverse() : audits;
    }
    
    export(reportCategory: string, reportName:string) {
    	console.log('Export method in ts');
    	console.log(this.fromDate);
    	console.log(this.toDate);
    	
    	let fromTime = '00:00';
    	let endTime = '23:59';
    	
    	let startDateTime = this.fromDate + ' ' + fromTime;
        let endDateTime = this.toDate + ' ' + endTime;
            
    	this.generateReportService.exportReport(reportCategory, reportName, startDateTime, endDateTime).subscribe(resp => {
    		const a: any = document.createElement('a');
    		const contentDisposition = resp.headers.get('content-disposition');
    		const filename = contentDisposition.split(';')[1].split('filename')[1].split('=')[1].trim().replace(/(^"|"$)/g, '');
    		console.log('download file: ' + filename);
    		a.href = window.URL.createObjectURL(resp.body);
    		a.target = '_blank';
    		a.download = filename;
            document.body.appendChild(a);
            
            a.click();
    	}, error => {
    		
    		this.jhiAlertService.error('error.report.exportFailed', null, null);
    	});
    	
    }
}
