import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';
import { UserExtraComponent } from './user-extra.component';
import { UserExtraDetailComponent } from './user-extra-detail.component';
import { UserExtraEditPopupComponent } from './user-extra-edit-dialog.component';
import { UserExtraNewPopupComponent } from './user-extra-new-dialog.component';
import { UserExtraDeletePopupComponent } from './user-extra-delete-dialog.component';

import { AppRouteAccessService } from '../../common/app-route-access-service';

@Injectable()
export class UserExtraResolvePagingParams implements Resolve<any> {

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

export const userExtraRoute: Routes = [
    {
        path: 'app-admin-user',
        component: UserExtraComponent,
        resolve: {
            'pagingParams': UserExtraResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['MENU:User'],
            pageTitle: 'baseApp.userExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }, {
        path: 'app-admin-user/:id',
        component: UserExtraDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:User.READ'],
            pageTitle: 'baseApp.userExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }
];

export const userExtraPopupRoute: Routes = [
    {
        path: 'app-admin-user-new',
        component: UserExtraNewPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:User.CREATE'],
            pageTitle: 'baseApp.userExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-admin-user/:id/edit',
        component: UserExtraEditPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:User.UPDATE'],
            pageTitle: 'baseApp.userExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-admin-user/:id/delete',
        component: UserExtraDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:User.DELETE'],
            pageTitle: 'baseApp.userExtra.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    }
];
