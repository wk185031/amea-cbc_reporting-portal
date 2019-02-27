import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared';
import {
    SystemConfigurationService,
    SystemConfigurationPopupService,
    SystemConfigurationComponent,
    SystemConfigurationDetailComponent,
    SystemConfigurationDialogComponent,
    SystemConfigurationPopupComponent,
    SystemConfigurationDeletePopupComponent,
    SystemConfigurationDeleteDialogComponent,
    systemConfigurationRoute,
    systemConfigurationPopupRoute,
    SystemConfigurationResolvePagingParams,
} from './';

const ENTITY_STATES = [
    ...systemConfigurationRoute,
    ...systemConfigurationPopupRoute,
];

@NgModule({
    imports: [
        BaseSharedModule,
        RouterModule.forChild(ENTITY_STATES)
    ],
    declarations: [
        SystemConfigurationComponent,
        SystemConfigurationDetailComponent,
        SystemConfigurationDialogComponent,
        SystemConfigurationDeleteDialogComponent,
        SystemConfigurationPopupComponent,
        SystemConfigurationDeletePopupComponent,
    ],
    entryComponents: [
        SystemConfigurationComponent,
        SystemConfigurationDialogComponent,
        SystemConfigurationPopupComponent,
        SystemConfigurationDeleteDialogComponent,
        SystemConfigurationDeletePopupComponent,
    ],
    providers: [
        SystemConfigurationService,
        SystemConfigurationPopupService,
        SystemConfigurationResolvePagingParams,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseSystemConfigurationModule {}
