import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared';
import {
    AppResourceService,
    AppResourcePopupService,
    AppResourceComponent,
    AppResourceDetailComponent,
    AppResourceDialogComponent,
    AppResourcePopupComponent,
    AppResourceDeletePopupComponent,
    AppResourceDeleteDialogComponent,
    appResourceRoute,
    appResourcePopupRoute,
} from './';

const ENTITY_STATES = [
    ...appResourceRoute,
    ...appResourcePopupRoute,
];

@NgModule({
    imports: [
        BaseSharedModule,
        RouterModule.forChild(ENTITY_STATES)
    ],
    declarations: [
        AppResourceComponent,
        AppResourceDetailComponent,
        AppResourceDialogComponent,
        AppResourceDeleteDialogComponent,
        AppResourcePopupComponent,
        AppResourceDeletePopupComponent,
    ],
    entryComponents: [
        AppResourceComponent,
        AppResourceDialogComponent,
        AppResourcePopupComponent,
        AppResourceDeleteDialogComponent,
        AppResourceDeletePopupComponent,
    ],
    providers: [
        AppResourceService,
        AppResourcePopupService,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseAppResourceModule {}
