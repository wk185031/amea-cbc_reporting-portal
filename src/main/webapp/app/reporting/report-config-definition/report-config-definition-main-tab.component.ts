import { Component, OnInit, OnDestroy, Input, Output, EventEmitter } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiAlertService, JhiEventManager } from 'ng-jhipster';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';
import { ReportDefinition } from './report-config-definition.model';
import { ReportConfigDefinitionService } from './report-config-definition.service';
import { ReportConfigCategoryService } from '../report-config-category/report-config-category.service';
import { ReportCategory } from '../report-config-category/report-config-category.model';

@Component({
    selector: 'report-config-definition-main-tab',
    templateUrl: './report-config-definition-main-tab.component.html'
})
export class ReportConfigDefinitionMainTabComponent implements OnInit {

    @Output() onValueChange = new EventEmitter<boolean>();
    @Input() reportDefinition: ReportDefinition;

    pdfFormat: boolean
    csvFormat: boolean
    txtFormat: boolean

    reportDefinitionList: ReportDefinition[];
    reportCategoryList: ReportCategory[];

    constructor(
        public activeModal: NgbActiveModal,
        private reportConfigDefinitionService: ReportConfigDefinitionService,
        private reportConfigCategoryService: ReportConfigCategoryService,
        private jhiAlertService: JhiAlertService
    ) {
    }

    ngOnInit() {
        if (!this.reportDefinition.id) {
            this.pdfFormat = true;
        }
        else {
            if (this.reportDefinition.fileFormat.indexOf('PDF') != -1) {
                this.pdfFormat = true;
            }
            if (this.reportDefinition.fileFormat.indexOf('CSV') != -1) {
                this.csvFormat = true;
            }
            if (this.reportDefinition.fileFormat.indexOf('TXT') != -1) {
                this.txtFormat = true;
            }
        }
        this.reportConfigCategoryService.query().subscribe((reportCategory: HttpResponse<ReportCategory[]>) => {
            this.reportCategoryList = reportCategory.body;
        }, (error: HttpErrorResponse) => this.onError(error.message));
        this.reportConfigDefinitionService.query().subscribe((reportDefinition: HttpResponse<ReportDefinition[]>) => {
            this.reportDefinitionList = reportDefinition.body;
        }, (error: HttpErrorResponse) => this.onError(error.message));
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    valueChange() {
        this.reportDefinition.fileFormat = '';
        if ((<HTMLInputElement>document.getElementById('field_pdf')).checked) {
            this.reportDefinition.fileFormat += 'PDF,';
        }
        if ((<HTMLInputElement>document.getElementById('field_csv')).checked) {
            this.reportDefinition.fileFormat += 'CSV,';
        }
        if ((<HTMLInputElement>document.getElementById('field_txt')).checked) {
            this.reportDefinition.fileFormat += 'TXT,';
        }
        this.onValueChange.emit(true);
    }

    selectReportCategory() {
        if (this.reportCategoryList) {
            this.reportCategoryList = this.reportCategoryList.filter(reportCategory => reportCategory.name);
        }
        this.valueChange();
    }
}