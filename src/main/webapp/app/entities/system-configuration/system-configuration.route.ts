import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';
import { SystemConfigurationComponent } from './system-configuration.component';
import { SystemConfigurationDetailComponent } from './system-configuration-detail.component';
import { SystemConfigurationPopupComponent } from './system-configuration-dialog.component';
import { SystemConfigurationDeletePopupComponent } from './system-configuration-delete-dialog.component';

@Injectable()
export class SystemConfigurationResolvePagingParams implements Resolve<any> {

    constructor(private paginationUtil: JhiPaginationUtil) {}

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

export const systemConfigurationRoute: Routes = [
    {
        path: 'system-configuration',
        component: SystemConfigurationComponent,
        resolve: {
            'pagingParams': SystemConfigurationResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService]
    }, {
        path: 'system-configuration/:id',
        component: SystemConfigurationDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService]
    }
];

export const systemConfigurationPopupRoute: Routes = [
    {
        path: 'system-configuration-new',
        component: SystemConfigurationPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'system-configuration/:id/edit',
        component: SystemConfigurationPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'system-configuration/:id/delete',
        component: SystemConfigurationDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.systemConfiguration.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
