import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';

import { BaseUserExtraModule } from './user-extra/user-extra.module';
import { BaseRoleExtraModule } from './role-extra/role-extra.module';
import { BaseAppResourceModule } from './app-resource/app-resource.module';
import { BaseSystemConfigurationModule } from './system-configuration/system-configuration.module';
import { BaseInstitutionModule } from './institution/institution.module';
import { BaseAttachmentGroupModule } from './attachment-group/attachment-group.module';
import { BaseAttachmentModule } from './attachment/attachment.module';
/* jhipster-needle-add-entity-module-import - JHipster will add entity modules imports here */

@NgModule({
    imports: [
        BaseUserExtraModule,
        BaseRoleExtraModule,
        BaseAppResourceModule,
        BaseSystemConfigurationModule,
        BaseInstitutionModule,
        BaseAttachmentGroupModule,
        BaseAttachmentModule,
        /* jhipster-needle-add-entity-module - JHipster will add entity modules here */
    ],
    declarations: [],
    entryComponents: [],
    providers: [],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseEntityModule {}
