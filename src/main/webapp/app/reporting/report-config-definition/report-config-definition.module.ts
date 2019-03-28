import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared/shared.module';
import { BaseAdminModule } from '../../admin/admin.module';

import { AppCommonModule } from '../../common/common.module';
import { ReportConfigDefinitionResolvePagingParams, reportConfigDefinitionRoute, reportConfigDefinitionPopupRoute } from './report-config-definition.route';
import { ReportConfigDefinitionService } from './report-config-definition.service';
import { ReportConfigDefinitionComponent } from './report-config-definition.component';
import { ReportConfigDefinitionDialogComponent, ReportConfigDefinitionPopupComponent } from './report-config-definition-dialog.component';
import { ReportConfigDefinitionDetailComponent } from './report-config-definition-detail.component';
import { ReportConfigDefinitionDeleteDialogComponent, ReportConfigDefinitionDeletePopupComponent } from './report-config-definition-delete-dialog.component';
import { ReportConfigDefinitionPopupService } from './report-config-definition-popup.service';
import { ReportConfigDefinitionMainTabComponent } from './report-config-definition-main-tab.component';
import { ReportConfigDefinitionHeaderFieldsTabComponent } from './report-config-definition-headerFields-tab.component';
import { ReportConfigDefinitionBodyFieldsTabComponent } from './report-config-definition-bodyFields-tab.component';
import { ReportConfigDefinitionTrailerFieldsTabComponent } from './report-config-definition-trailerFields-tab.component';
import { ReportConfigDefinitionQueryTabComponent } from './report-config-definition-query-tab.component';
import { ReportConfigDefinitionViewComponent } from './report-config-definition-view.component';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';

const ENTITY_STATES = [
    ...reportConfigDefinitionRoute,
    ...reportConfigDefinitionPopupRoute
];

@NgModule({
    imports: [
        BaseSharedModule,
        BaseAdminModule,
        RouterModule.forChild(ENTITY_STATES),
        AppCommonModule
    ],
    declarations: [
        ReportConfigDefinitionComponent,
        ReportConfigDefinitionDialogComponent,
        ReportConfigDefinitionViewComponent,
        ReportConfigDefinitionDetailComponent,
        ReportConfigDefinitionDeleteDialogComponent,
        ReportConfigDefinitionPopupComponent,
        ReportConfigDefinitionDeletePopupComponent,
        ReportConfigDefinitionMainTabComponent,
        ReportConfigDefinitionHeaderFieldsTabComponent,
        ReportConfigDefinitionBodyFieldsTabComponent,
        ReportConfigDefinitionTrailerFieldsTabComponent,
        ReportConfigDefinitionQueryTabComponent
    ],
    entryComponents: [
        ReportConfigDefinitionComponent,
        ReportConfigDefinitionDialogComponent,
        ReportConfigDefinitionViewComponent,
        ReportConfigDefinitionDetailComponent,
        ReportConfigDefinitionDeleteDialogComponent,
        ReportConfigDefinitionPopupComponent,
        ReportConfigDefinitionDeletePopupComponent,
        ReportConfigDefinitionMainTabComponent,
        ReportConfigDefinitionHeaderFieldsTabComponent,
        ReportConfigDefinitionBodyFieldsTabComponent,
        ReportConfigDefinitionTrailerFieldsTabComponent,
        ReportConfigDefinitionQueryTabComponent
    ],
    providers: [
        NgbActiveModal,
        ReportConfigDefinitionService,
        ReportConfigDefinitionPopupService,
        ReportConfigDefinitionResolvePagingParams
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class ReportConfigDefinitionModule { }
