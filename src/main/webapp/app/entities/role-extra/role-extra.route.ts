import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';
import { RoleExtraComponent } from './role-extra.component';
import { RoleExtraDetailComponent } from './role-extra-detail.component';
import { RoleExtraPopupComponent } from './role-extra-dialog.component';
import { RoleExtraDeletePopupComponent } from './role-extra-delete-dialog.component';

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
        path: 'role-extra',
        component: RoleExtraComponent,
        resolve: {
            'pagingParams': RoleExtraResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService]
    }, {
        path: 'role-extra/:id',
        component: RoleExtraDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService]
    }
];

export const roleExtraPopupRoute: Routes = [
    {
        path: 'role-extra-new',
        component: RoleExtraPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'role-extra/:id/edit',
        component: RoleExtraPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'role-extra/:id/delete',
        component: RoleExtraDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.roleExtra.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
