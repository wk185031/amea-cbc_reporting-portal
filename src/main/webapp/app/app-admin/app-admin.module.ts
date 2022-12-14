import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';

import { BaseUserExtraModule } from './user/user-extra.module';
import { BaseRoleExtraModule } from './role/role-extra.module';
// import { BaseBranchModule } from './branch/branch.module';
import { BaseSystemConfigurationModule } from './system-configuration/system-configuration.module';
import { BaseInstitutionModule } from './institution/institution.module';
import { BaseAppResourceModule } from './role/app-resource/app-resource.module';
import { BaseTaskGroupModule } from './task-group/task-group.module';
import { BaseTaskModule } from './task/task.module';
import { BaseJobModule } from './job/job.module';
import { BaseJobHistoryModule } from './job-history/job-history.module';
/* jhipster-needle-add-entity-module-import - JHipster will add entity modules imports here */

@NgModule({
    imports: [
        BaseUserExtraModule,
        BaseRoleExtraModule,
        //BaseBranchModule,
        BaseSystemConfigurationModule,
        BaseInstitutionModule,
        BaseAppResourceModule,
        BaseTaskGroupModule,
        BaseTaskModule,
        BaseJobModule,
        BaseJobHistoryModule
        /* jhipster-needle-add-entity-module - JHipster will add entity modules here */
    ],
    declarations: [],
    entryComponents: [],
    providers: [],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseAppAdminModule {}
