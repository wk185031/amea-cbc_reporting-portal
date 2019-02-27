import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared/shared.module';
import { BaseAdminModule } from '../../admin/admin.module';
import {
    UserExtraService,
    UserExtraPopupService,
    UserExtraComponent,
    UserExtraDetailComponent,
    UserExtraEditDialogComponent,
    UserExtraNewDialogComponent,
    UserExtraEditPopupComponent,
    UserExtraNewPopupComponent,
    UserExtraDeletePopupComponent,
    UserExtraDeleteDialogComponent,
    userExtraRoute,
    userExtraPopupRoute,
    UserExtraResolvePagingParams,
} from './';

import { AppCommonModule } from '../../common/common.module';

const ENTITY_STATES = [
    ...userExtraRoute,
    ...userExtraPopupRoute,
];

@NgModule({
    imports: [
        BaseSharedModule,
        BaseAdminModule,
        RouterModule.forChild(ENTITY_STATES),
        AppCommonModule
    ],
    declarations: [
        UserExtraComponent,
        UserExtraDetailComponent,
        UserExtraEditDialogComponent,
        UserExtraNewDialogComponent,
        UserExtraDeleteDialogComponent,
        UserExtraEditPopupComponent,
        UserExtraNewPopupComponent,
        UserExtraDeletePopupComponent,
    ],
    entryComponents: [
        UserExtraComponent,
        UserExtraEditDialogComponent,
        UserExtraNewDialogComponent,
        UserExtraEditPopupComponent,
        UserExtraNewPopupComponent,
        UserExtraDeleteDialogComponent,
        UserExtraDeletePopupComponent,
    ],
    providers: [
        UserExtraService,
        UserExtraPopupService,
        UserExtraResolvePagingParams,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseUserExtraModule {}
