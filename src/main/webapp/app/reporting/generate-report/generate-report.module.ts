import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared/shared.module';
import { BaseAdminModule } from '../../admin/admin.module';

import { AppCommonModule } from '../../common/common.module';
import { generateReportRoute, generateReportPopupRoute, GenerateReportResolvePagingParams } from './generate-report.route';
import { GenerateReportService } from './generate-report.service';
import { GenerateReportComponent } from './generate-report.component';

const ENTITY_STATES = [
    ...generateReportRoute,
    ...generateReportPopupRoute
];

@NgModule({
    imports: [
        BaseSharedModule,
        BaseAdminModule,
        RouterModule.forChild(ENTITY_STATES),
        AppCommonModule
    ],
    declarations: [
        GenerateReportComponent
    ],
    entryComponents: [
        GenerateReportComponent
    ],
    providers: [
        GenerateReportService,
        GenerateReportResolvePagingParams
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class GenerateReportModule { }
