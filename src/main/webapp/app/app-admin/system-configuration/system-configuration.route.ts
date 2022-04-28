import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';
import { SystemConfigurationComponent } from './system-configuration.component';
import { SystemConfigurationDetailComponent } from './system-configuration-detail.component';
import { SystemConfigurationPopupComponent } from './system-configuration-dialog.component';
import { SystemConfigurationDeletePopupComponent } from './system-configuration-delete-dialog.component';

import { AppRouteAccessService } from '../../common/app-route-access-service';

@Injectable()
export class SystemConfigurationResolvePagingParams implements Resolve<any> {

    constructor(private paginationUtil: JhiPaginationUtil) {}

    resolve(route: ActivatedRouteSnapshot, state: RouterStateSnapshot) {
        const page = route.queryParams['page'] ? route.queryParams['page'] : '1';
        const sort = route.queryParams['sort'] ? route.queryParams['sort'] : 'name,asc';
        return {
            page: this.paginationUtil.parsePage(page),
            predicate: this.paginationUtil.parsePredicate(sort),
            ascending: this.paginationUtil.parseAscending(sort)
      };
    }
}

export const systemConfigurationRoute: Routes = [
    {
        path: 'app-admin-system-configuration',
        component: SystemConfigurationComponent,
        resolve: {
            'pagingParams': SystemConfigurationResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['MENU:SystemConfiguration'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }, {
        path: 'app-admin-system-configuration/:id',
        component: SystemConfigurationDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:SystemConfiguration.READ'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }
];

export const systemConfigurationPopupRoute: Routes = [
    {
        path: 'app-admin-system-configuration-new',
        component: SystemConfigurationPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:SystemConfiguration.CREATE'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-admin-system-configuration/:id/edit',
        component: SystemConfigurationPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:SystemConfiguration.UPDATE'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-admin-system-configuration/:id/delete',
        component: SystemConfigurationDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:SystemConfiguration.DELETE'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    }
];
