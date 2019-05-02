import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';

import { BaseSharedModule } from '../../shared';
import {
    JobHistoryService,
} from '.';

@NgModule({
    imports: [
        BaseSharedModule
    ],
    declarations: [
    ],
    entryComponents: [
    ],
    providers: [
        JobHistoryService,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseJobHistoryModule {}
