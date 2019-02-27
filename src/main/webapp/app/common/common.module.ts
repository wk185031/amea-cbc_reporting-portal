import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';

import {
    AppService, 
    AppPermissionService, 
    AppHasAnyPermissionDirective
} from './';
import { AppAttachmentService } from './app-attachment.service';

@NgModule({
    imports: [
    ],
    declarations: [
        AppHasAnyPermissionDirective,
    ],
    providers: [
        AppService,
        AppPermissionService,
        AppAttachmentService
    ],
    entryComponents: [],
    exports: [
        AppHasAnyPermissionDirective
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]

})
export class AppCommonModule {}
