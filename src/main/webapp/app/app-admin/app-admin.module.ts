import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';

import { BaseUserExtraModule } from './user/user-extra.module';
import { BaseRoleExtraModule } from './role/role-extra.module';
import { BaseSystemConfigurationModule } from './system-configuration/system-configuration.module';
import { BaseInstitutionModule } from './institution/institution.module';
import { BaseAppResourceModule } from './role/app-resource/app-resource.module';
/* jhipster-needle-add-entity-module-import - JHipster will add entity modules imports here */

@NgModule({
    imports: [
        BaseUserExtraModule,
        BaseRoleExtraModule,
        BaseSystemConfigurationModule,
        BaseInstitutionModule,
        BaseAppResourceModule
        /* jhipster-needle-add-entity-module - JHipster will add entity modules here */
    ],
    declarations: [],
    entryComponents: [],
    providers: [],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseAppAdminModule {}
