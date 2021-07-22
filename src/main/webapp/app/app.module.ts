import './vendor.ts';

import { NgModule, Injector } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HTTP_INTERCEPTORS } from '@angular/common/http';
import { Ng2Webstorage, LocalStorageService, SessionStorageService } from 'ngx-webstorage';
import { JhiEventManager } from 'ng-jhipster';

import { AuthInterceptor } from './blocks/interceptor/auth.interceptor';
import { AuthExpiredInterceptor } from './blocks/interceptor/auth-expired.interceptor';
import { ErrorHandlerInterceptor } from './blocks/interceptor/errorhandler.interceptor';
import { NotificationInterceptor } from './blocks/interceptor/notification.interceptor';
import { BaseSharedModule, UserRouteAccessService } from './shared';
import { BaseAppRoutingModule } from './app-routing.module';
import { BaseHomeModule } from './home/home.module';
import { BaseAdminModule } from './admin/admin.module';
import { BaseAccountModule } from './account/account.module';
import { BaseEntityModule } from './entities/entity.module';
import { PaginationConfig } from './blocks/config/uib-pagination.config';
// jhipster-needle-angular-add-module-import JHipster will add new module here
import {
    JhiMainComponent,
    NavbarComponent,
    FooterComponent,
    ProfileService,
    PageRibbonComponent,
    ActiveMenuDirective,
    ErrorComponent
} from './layouts';

import { BaseAppAdminModule } from './app-admin/app-admin.module';
import { AppCommonModule } from './common/common.module';
import { AppRouteAccessService } from './common/app-route-access-service';
import { AppRouteSelfRegistrationService } from './common/app-route-self-registration-service';
import { ReportConfigCategoryModule } from './reporting/report-config-category/report-config-category.module';
import { ReportConfigDefinitionModule } from './reporting/report-config-definition/report-config-definition.module';
// import { DashboardModule } from './reporting/dashboard/dashboard.module';
import { GenerateReportModule } from './reporting/generate-report/generate-report.module';
import { DatabaseSynchronizationModule } from './reporting/database-synchronization/database-synchronization.module';
import { BranchService } from './entities/branch';
import { NgIdleKeepaliveModule } from '@ng-idle/keepalive'; 

@NgModule({
    imports: [
        BrowserModule,
        BaseAppRoutingModule,
        Ng2Webstorage.forRoot({ prefix: 'jhi', separator: '-' }),
        BaseSharedModule,
        BaseHomeModule,
        BaseAdminModule,
        BaseAccountModule,
        BaseEntityModule,
        // jhipster-needle-angular-add-module JHipster will add new module here
        BaseAppAdminModule,
        AppCommonModule,
        ReportConfigCategoryModule,
        ReportConfigDefinitionModule,
        // DashboardModule,
        GenerateReportModule,
        DatabaseSynchronizationModule,
        NgIdleKeepaliveModule.forRoot()
    ],
    declarations: [
        JhiMainComponent,
        NavbarComponent,
        ErrorComponent,
        PageRibbonComponent,
        ActiveMenuDirective,
        FooterComponent
    ],
    providers: [
        ProfileService,
        PaginationConfig,
        UserRouteAccessService,
        AppRouteAccessService,
        BranchService,
        AppRouteSelfRegistrationService,
        {
            provide: HTTP_INTERCEPTORS,
            useClass: AuthInterceptor,
            multi: true,
            deps: [
                LocalStorageService,
                SessionStorageService
            ]
        },
        {
            provide: HTTP_INTERCEPTORS,
            useClass: AuthExpiredInterceptor,
            multi: true,
            deps: [
                Injector
            ]
        },
        {
            provide: HTTP_INTERCEPTORS,
            useClass: ErrorHandlerInterceptor,
            multi: true,
            deps: [
                JhiEventManager
            ]
        },
        {
            provide: HTTP_INTERCEPTORS,
            useClass: NotificationInterceptor,
            multi: true,
            deps: [
                Injector
            ]
        }
    ],
    bootstrap: [JhiMainComponent]
})
export class BaseAppModule { }
