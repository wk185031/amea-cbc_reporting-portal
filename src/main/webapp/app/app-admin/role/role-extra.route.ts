import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';
import { RoleExtraComponent } from './role-extra.component';
import { RoleExtraDetailComponent } from './role-extra-detail.component';
import { RoleExtraPopupComponent } from './role-extra-dialog.component';
import { RoleExtraDeletePopupComponent } from './role-extra-delete-dialog.component';

import { AppRouteAccessService } from '../../common/app-route-access-service';

@Injectable()
export class RoleExtraResolvePagingParams implements Resolve<any> {

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

export const roleExtraRoute: Routes = [
    {
        path: 'app-admin-role',
        component: RoleExtraComponent,
        resolve: {
            'pagingParams': RoleExtraResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['MENU:UserRole'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }, {
        path: 'app-admin-role/:id',
        component: RoleExtraDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:UserRole.READ'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }
];

export const roleExtraPopupRoute: Routes = [
    {
        path: 'app-admin-role-new',
        component: RoleExtraPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:UserRole.CREATE'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-admin-role/:id/edit',
        component: RoleExtraPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:UserRole.UPDATE'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-admin-role/:id/delete',
        component: RoleExtraDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:UserRole.DELETE'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    }
];
