import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared/shared.module';
import { BaseAdminModule } from '../../admin/admin.module';

import { AppCommonModule } from '../../common/common.module';
import { reportConfigCategoryRoute, ReportConfigCategoryResolvePagingParams, reportConfigCategoryPopupRoute } from './report-config-category.route';
import { ReportConfigCategoryComponent } from './report-config-category.component';
import { ReportConfigCategoryService } from './report-config-category.service';
import { ReportConfigCategoryDialogComponent, ReportConfigCategoryPopupComponent } from './report-config-category-dialog.component';
import { ReportConfigCategoryPopupService } from './report-config-category-popup.service';
import { ReportConfigCategoryDetailComponent } from './report-config-category-detail.component';
import { ReportConfigCategoryDeleteDialogComponent, ReportConfigCategoryDeletePopupComponent } from './report-config-category-delete-dialog.component';

const ENTITY_STATES = [
    ...reportConfigCategoryRoute,
    ...reportConfigCategoryPopupRoute
];

@NgModule({
    imports: [
        BaseSharedModule,
        BaseAdminModule,
        RouterModule.forChild(ENTITY_STATES),
        AppCommonModule
    ],
    declarations: [
        ReportConfigCategoryComponent,
        ReportConfigCategoryDialogComponent,
        ReportConfigCategoryDetailComponent,
        ReportConfigCategoryDeleteDialogComponent,
        ReportConfigCategoryPopupComponent,
        ReportConfigCategoryDeletePopupComponent
    ],
    entryComponents: [
        ReportConfigCategoryComponent,
        ReportConfigCategoryDialogComponent,
        ReportConfigCategoryDetailComponent,
        ReportConfigCategoryDeleteDialogComponent,
        ReportConfigCategoryPopupComponent,
        ReportConfigCategoryDeletePopupComponent
    ],
    providers: [
        ReportConfigCategoryService,
        ReportConfigCategoryPopupService,
        ReportConfigCategoryResolvePagingParams
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class ReportConfigCategoryModule { }
