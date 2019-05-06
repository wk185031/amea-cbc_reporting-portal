import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared';
import {
    TaskGroupService,
    TaskGroupPopupService,
    TaskGroupComponent,
    TaskGroupDetailComponent,
    TaskGroupDialogComponent,
    TaskGroupPopupComponent,
    TaskGroupDeletePopupComponent,
    TaskGroupDeleteDialogComponent,
    taskGroupRoute,
    taskGroupPopupRoute,
} from '.';

const ENTITY_STATES = [
    ...taskGroupRoute,
    ...taskGroupPopupRoute,
];

@NgModule({
    imports: [
        BaseSharedModule,
        RouterModule.forChild(ENTITY_STATES)
    ],
    declarations: [
        TaskGroupComponent,
        TaskGroupDetailComponent,
        TaskGroupDialogComponent,
        TaskGroupDeleteDialogComponent,
        TaskGroupPopupComponent,
        TaskGroupDeletePopupComponent,
    ],
    entryComponents: [
        TaskGroupComponent,
        TaskGroupDialogComponent,
        TaskGroupPopupComponent,
        TaskGroupDeleteDialogComponent,
        TaskGroupDeletePopupComponent,
    ],
    providers: [
        TaskGroupService,
        TaskGroupPopupService,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseTaskGroupModule {}
