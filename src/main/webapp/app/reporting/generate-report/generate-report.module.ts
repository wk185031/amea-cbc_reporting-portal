import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';
import { NgxUiLoaderModule } from 'ngx-ui-loader';

import { BaseSharedModule } from '../../shared/shared.module';
import { BaseAdminModule } from '../../admin/admin.module';

import { AppCommonModule } from '../../common/common.module';
import { generateReportRoute, generateReportPopupRoute, GenerateReportResolvePagingParams } from './generate-report.route';
import { GenerateReportService } from './generate-report.service';
import { GenerateReportComponent } from './generate-report.component';
import { GenerateReportTabComponent } from './generate-report-tab.component';
import { DownloadReportTabComponent } from './download-report-tab.component';
import { ReportStatusModalService } from './report-status-modal.service';
import { ReportStatusComponent } from './report-status.component';

const ENTITY_STATES = [
    ...generateReportRoute,
    ...generateReportPopupRoute
];

@NgModule({
    imports: [
        BaseSharedModule,
        BaseAdminModule,
        RouterModule.forChild(ENTITY_STATES),
        AppCommonModule,
        NgxUiLoaderModule
    ],
    declarations: [
        GenerateReportComponent,
        GenerateReportTabComponent,
        DownloadReportTabComponent,
         ReportStatusComponent
    ],
    entryComponents: [
        GenerateReportComponent,
        GenerateReportTabComponent,
        DownloadReportTabComponent,
          ReportStatusComponent
    ],
    providers: [
        GenerateReportService,
        GenerateReportResolvePagingParams,
          ReportStatusModalService
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class GenerateReportModule { }
