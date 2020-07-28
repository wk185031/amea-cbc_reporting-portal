import { Component, OnInit, OnDestroy, Input, Output, EventEmitter } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { NgbTimeStruct } from '@ng-bootstrap/ng-bootstrap/timepicker/timepicker.module';
import { JhiAlertService, JhiEventManager } from 'ng-jhipster';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';
import { ReportDefinition } from './report-config-definition.model';
import { ReportConfigDefinitionService } from './report-config-definition.service';
import { ReportConfigCategoryService } from '../report-config-category/report-config-category.service';
import { ReportCategory } from '../report-config-category/report-config-category.model';
import { DatePipe } from '@angular/common';

@Component({
    selector: 'report-config-definition-main-tab',
    templateUrl: './report-config-definition-main-tab.component.html'
})
export class ReportConfigDefinitionMainTabComponent implements OnInit {

    @Output() onValueChange = new EventEmitter<boolean>();
    @Input() reportDefinition: ReportDefinition;

    pdfFormat: boolean;
    csvFormat: boolean;
    txtFormat: boolean;
    daily: boolean;
    weekly: boolean;
    monthly: boolean;
    timeAsDate: Date;
    time: NgbTimeStruct;
    timeString: String;
    scheduleFlag: boolean;

    reportDefinitionList: ReportDefinition[];
    reportCategoryList: ReportCategory[];


    constructor(
        public activeModal: NgbActiveModal,
        private reportConfigDefinitionService: ReportConfigDefinitionService,
        private reportConfigCategoryService: ReportConfigCategoryService,
        private jhiAlertService: JhiAlertService,
        private datePipe: DatePipe
    ) {
    }

    ngOnInit() {
        this.scheduleFlag = true;
        if (!this.reportDefinition.id) {
            this.pdfFormat = true;
            this.daily = true;
        } else {
            if (this.reportDefinition.fileFormat.indexOf('PDF') != -1) {
                this.pdfFormat = true;
            }
            if (this.reportDefinition.fileFormat.indexOf('CSV') != -1) {
                this.csvFormat = true;
            }
            if (this.reportDefinition.fileFormat.indexOf('TXT') != -1) {
                this.txtFormat = true;
            }
            if (this.reportDefinition.frequency.indexOf('Daily') != -1) {
                this.daily = true;
            }
            if (this.reportDefinition.frequency.indexOf('Weekly') != -1) {
                this.weekly = true;
            }
            if (this.reportDefinition.frequency.indexOf('Monthly') != -1) {
                this.monthly = true;
            }
        }
        this.reportConfigCategoryService.query().subscribe((reportCategory: HttpResponse<ReportCategory[]>) => {
            this.reportCategoryList = reportCategory.body;
        }, (error: HttpErrorResponse) => this.onError(error.message));
        this.reportConfigDefinitionService.query().subscribe((reportDefinition: HttpResponse<ReportDefinition[]>) => {
            this.reportDefinitionList = reportDefinition.body;
        }, (error: HttpErrorResponse) => this.onError(error.message));
        this.timeAsDate = new Date(this.reportDefinition.scheduleTime * 1000);
        this.time = {hour: this.timeAsDate.getHours(), minute: this.timeAsDate.getMinutes(), second: this.timeAsDate.getSeconds()};
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    valueChange() {
        this.reportDefinition.fileFormat = '';
        this.reportDefinition.frequency = '';

        if ((<HTMLInputElement>document.getElementById('field_pdf')).checked) {
            this.reportDefinition.fileFormat += 'PDF,';
        }
        if ((<HTMLInputElement>document.getElementById('field_csv')).checked) {
            this.reportDefinition.fileFormat += 'CSV,';
        }
        if ((<HTMLInputElement>document.getElementById('field_txt')).checked) {
            this.reportDefinition.fileFormat += 'TXT,';
        }
        if ((<HTMLInputElement>document.getElementById('field_daily')).checked) {
            this.reportDefinition.frequency += 'Daily,';
        }
        /*
        if ((<HTMLInputElement>document.getElementById('field_weekly')).checked) {
            this.reportDefinition.frequency += 'Weekly,';
        }
        */
        if ((<HTMLInputElement>document.getElementById('field_monthly')).checked) {
            this.reportDefinition.frequency += 'Monthly,';
        }

        this.timeAsDate.setHours(this.time.hour, this.time.minute, this.time.second);
        this.reportDefinition.scheduleTime = this.timeAsDate.getTime() / 1000;
        this.onValueChange.emit(true);
    }

    selectReportCategory() {
        if (this.reportCategoryList) {
            this.reportCategoryList = this.reportCategoryList.filter(reportCategory => reportCategory.name);
        }
        this.valueChange();
    }

    selectBranchFlag(branchFlag: string) {
        this.reportDefinition.branchFlag = branchFlag;
        this.valueChange();
    }

    selectInstitutionId(institutionId: string) {
        this.reportDefinition.institutionId = Number(institutionId);
        this.valueChange();
    }

    saveScheduleTime(currentTime: NgbTimeStruct){
        this.time.hour = currentTime.hour;
        this.time.minute = currentTime.minute;
        this.time.second = currentTime.second;
        this.valueChange();
    }

}
