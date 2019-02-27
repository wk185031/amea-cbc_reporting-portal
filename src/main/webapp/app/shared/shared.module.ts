import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { DatePipe } from '@angular/common';
import { JhiTreeViewComponent } from './tree-view/tree-view.component';
import { TreeModule } from 'angular-tree-component';

import {
    BaseSharedLibsModule,
    BaseSharedCommonModule,
    CSRFService,
    AuthServerProvider,
    AccountService,
    UserService,
    StateStorageService,
    LoginService,
    LoginModalService,
    JhiLoginModalComponent,
    Principal,
    HasAnyAuthorityDirective,
} from './';

@NgModule({
    imports: [
        BaseSharedLibsModule,
        BaseSharedCommonModule,
        TreeModule
    ],
    declarations: [
        JhiLoginModalComponent,
        HasAnyAuthorityDirective,
        JhiTreeViewComponent
    ],
    providers: [
        LoginService,
        LoginModalService,
        AccountService,
        StateStorageService,
        Principal,
        CSRFService,
        AuthServerProvider,
        UserService,
        DatePipe
    ],
    entryComponents: [
        JhiLoginModalComponent,
        JhiTreeViewComponent
    ],
    exports: [
        BaseSharedCommonModule,
        JhiLoginModalComponent,
        JhiTreeViewComponent,
        HasAnyAuthorityDirective,
        DatePipe
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]

})
export class BaseSharedModule {}
