import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DiffMatchPatchModule } from 'ng-diff-match-patch';

import { BaseSharedModule } from '../../shared';
import { AuditsRoutingModule } from './audits.route';
import { AuditsComponent } from './audits.component';
import { AuditsService } from './audits.service';

import { AppCommonModule } from '../../common/common.module';

@NgModule({
    imports: [
        CommonModule,
        BaseSharedModule,
        DiffMatchPatchModule,
        AuditsRoutingModule,
        AppCommonModule
    ],
    declarations: [
        AuditsComponent
    ],
    providers: [
        AuditsService
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class AuditsModule { }
