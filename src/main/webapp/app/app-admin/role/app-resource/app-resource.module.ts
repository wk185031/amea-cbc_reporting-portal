import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { BaseSharedModule } from '../../../shared';
import { AppResourceComponent} from './app-resource.component';
import { AppResourceService } from './app-resource.service';
import { AppPermissionsConfigurationService } from './app-permissions-configuration.service';

@NgModule({
    imports: [
        BaseSharedModule
    ],
    declarations: [
        AppResourceComponent
    ],
    entryComponents: [
        AppResourceComponent
    ],
    providers: [
        AppResourceService,
        AppPermissionsConfigurationService
    ],
    exports: [
        AppResourceComponent
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class BaseAppResourceModule {}
