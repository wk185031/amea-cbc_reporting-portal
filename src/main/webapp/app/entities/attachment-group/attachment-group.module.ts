import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../shared';
import {
    AttachmentGroupService,
    AttachmentGroupPopupService,
    AttachmentGroupComponent,
    AttachmentGroupDetailComponent,
    AttachmentGroupDialogComponent,
    AttachmentGroupPopupComponent,
    AttachmentGroupDeletePopupComponent,
    AttachmentGroupDeleteDialogComponent,
    attachmentGroupRoute,
    attachmentGroupPopupRoute,
} from './';

const ENTITY_STATES = [
    ...attachmentGroupRoute,
    ...attachmentGroupPopupRoute,
];

@NgModule({
    imports: [
        BaseSharedModule,
        RouterModule.forChild(ENTITY_STATES)
    ],
    declarations: [
        AttachmentGroupComponent,
        AttachmentGroupDetailComponent,
        AttachmentGroupDialogComponent,
        AttachmentGroupDeleteDialogComponent,
        AttachmentGroupPopupComponent,
        AttachmentGroupDeletePopupComponent,
    ],
    entryComponents: [
        AttachmentGroupComponent,
        AttachmentGroupDialogComponent,
        AttachmentGroupPopupComponent,
        AttachmentGroupDeleteDialogComponent,
        AttachmentGroupDeletePopupComponent,
    ],
    providers: [
        AttachmentGroupService,
        AttachmentGroupPopupService,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseAttachmentGroupModule {}
