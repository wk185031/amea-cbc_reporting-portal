import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared';
import {
    InstitutionService,
    InstitutionPopupService,
    InstitutionComponent,
    InstitutionDetailComponent,
    InstitutionDialogComponent,
    InstitutionPopupComponent,
    InstitutionDeletePopupComponent,
    InstitutionDeleteDialogComponent,
    institutionRoute,
    institutionPopupRoute,
    InstitutionResolvePagingParams,
} from './';

const ENTITY_STATES = [
    ...institutionRoute,
    ...institutionPopupRoute,
];

@NgModule({
    imports: [
        BaseSharedModule,
        RouterModule.forChild(ENTITY_STATES)
    ],
    declarations: [
        InstitutionComponent,
        InstitutionDetailComponent,
        InstitutionDialogComponent,
        InstitutionDeleteDialogComponent,
        InstitutionPopupComponent,
        InstitutionDeletePopupComponent,
    ],
    entryComponents: [
        InstitutionComponent,
        InstitutionDialogComponent,
        InstitutionPopupComponent,
        InstitutionDeleteDialogComponent,
        InstitutionDeletePopupComponent,
    ],
    providers: [
        InstitutionService,
        InstitutionPopupService,
        InstitutionResolvePagingParams,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseInstitutionModule {}
