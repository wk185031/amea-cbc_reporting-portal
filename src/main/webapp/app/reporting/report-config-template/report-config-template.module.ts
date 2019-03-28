import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared/shared.module';
import { BaseAdminModule } from '../../admin/admin.module';

import { AppCommonModule } from '../../common/common.module';
import { ReportConfigTemplateService } from './report-config-template.service';
import { ReportConfigTemplateComponent } from './report-config-template.component';
import { ReportConfigTemplateResolvePagingParams, reportConfigTemplateRoute, reportConfigTemplatePopupRoute } from './report-config-template.route';

const ENTITY_STATES = [
    ...reportConfigTemplateRoute,
    ...reportConfigTemplatePopupRoute
];

@NgModule({
    imports: [
        BaseSharedModule,
        BaseAdminModule,
        RouterModule.forChild(ENTITY_STATES),
        AppCommonModule
    ],
    declarations: [
        ReportConfigTemplateComponent
    ],
    entryComponents: [
        ReportConfigTemplateComponent
    ],
    providers: [
        ReportConfigTemplateService,
        ReportConfigTemplateResolvePagingParams
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class ReportConfigTemplateModule { }
