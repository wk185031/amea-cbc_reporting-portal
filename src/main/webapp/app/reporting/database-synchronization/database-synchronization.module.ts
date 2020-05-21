import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';
import { NgxUiLoaderModule } from 'ngx-ui-loader';

import { BaseSharedModule } from '../../shared/shared.module';
import { BaseAdminModule } from '../../admin/admin.module';

import { AppCommonModule } from '../../common/common.module';
import { databaseSynchronizationRoute, DatabaseSynchronizationResolvePagingParams } from './database-synchronization.route';
import { DatabaseSynchronizationService } from './database-synchronization.service';
import { DatabaseSynchronizationComponent } from './database-synchronization.component';

const ENTITY_STATES = [
    ...databaseSynchronizationRoute
];

@NgModule({
    imports: [
        BaseSharedModule,
        BaseAdminModule,
        RouterModule.forChild(ENTITY_STATES),
        AppCommonModule,
        NgxUiLoaderModule,
    ],
    declarations: [
        DatabaseSynchronizationComponent
    ],
    entryComponents: [
        DatabaseSynchronizationComponent
    ],
    providers: [
        DatabaseSynchronizationService,
        DatabaseSynchronizationResolvePagingParams
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class DatabaseSynchronizationModule { }
