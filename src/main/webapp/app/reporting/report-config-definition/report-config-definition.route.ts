import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';

import { AppRouteAccessService } from '../../common/app-route-access-service';
import { ReportConfigDefinitionComponent } from './report-config-definition.component';
import { ReportConfigDefinitionPopupComponent } from './report-config-definition-dialog.component';
import { ReportConfigDefinitionDeletePopupComponent } from './report-config-definition-delete-dialog.component';
import { ReportConfigDefinitionDetailComponent } from './report-config-definition-detail.component';

@Injectable()
export class ReportConfigDefinitionResolvePagingParams implements Resolve<any> {

    constructor(private paginationUtil: JhiPaginationUtil) { }

    resolve(route: ActivatedRouteSnapshot, state: RouterStateSnapshot) {
        const page = route.queryParams['page'] ? route.queryParams['page'] : '1';
        const sort = route.queryParams['sort'] ? route.queryParams['sort'] : 'id,asc';
        return {
            page: this.paginationUtil.parsePage(page),
            predicate: this.paginationUtil.parsePredicate(sort),
            ascending: this.paginationUtil.parseAscending(sort)
        };
    }
}

export const reportConfigDefinitionRoute: Routes = [
    {
        path: 'report-configuration-definition',
        component: ReportConfigDefinitionComponent,
        resolve: {
            'pagingParams': ReportConfigDefinitionResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['MENU:ReportDefinition'],
            pageTitle: 'baseApp.reportDefinition.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    },
    {
        path: 'report-configuration-definition/:id',
        component: ReportConfigDefinitionDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:ReportDefinition.READ'],
            pageTitle: 'baseApp.reportDefinition.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }
];

export const reportConfigDefinitionPopupRoute: Routes = [
    {
        path: 'report-definition-new',
        component: ReportConfigDefinitionPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:ReportDefinition.CREATE'],
            pageTitle: 'baseApp.reportDefinition.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'reportDefinition/:id/edit',
        component: ReportConfigDefinitionPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:ReportDefinition.UPDATE'],
            pageTitle: 'baseApp.reportDefinition.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'reportDefinition/:id/delete',
        component: ReportConfigDefinitionDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:ReportDefinition.DELETE'],
            pageTitle: 'baseApp.reportDefinition.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
