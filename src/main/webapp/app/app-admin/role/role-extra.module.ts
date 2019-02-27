import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared';
import {
    RoleExtraService,
    RoleExtraPopupService,
    RoleExtraComponent,
    RoleExtraDetailComponent,
    RoleExtraDialogComponent,
    RoleExtraPopupComponent,
    RoleExtraDeletePopupComponent,
    RoleExtraDeleteDialogComponent,
    roleExtraRoute,
    roleExtraPopupRoute,
    RoleExtraResolvePagingParams,
} from './';

import { AppCommonModule } from '../../common/common.module';

const ENTITY_STATES = [
    ...roleExtraRoute,
    ...roleExtraPopupRoute,
];

@NgModule({
    imports: [
        BaseSharedModule,
        RouterModule.forChild(ENTITY_STATES),
        AppCommonModule
    ],
    declarations: [
        RoleExtraComponent,
        RoleExtraDetailComponent,
        RoleExtraDialogComponent,
        RoleExtraDeleteDialogComponent,
        RoleExtraPopupComponent,
        RoleExtraDeletePopupComponent,
    ],
    entryComponents: [
        RoleExtraComponent,
        RoleExtraDialogComponent,
        RoleExtraPopupComponent,
        RoleExtraDeleteDialogComponent,
        RoleExtraDeletePopupComponent,
    ],
    providers: [
        RoleExtraService,
        RoleExtraPopupService,
        RoleExtraResolvePagingParams,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseRoleExtraModule {}
