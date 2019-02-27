import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';
import { InstitutionComponent } from './institution.component';
import { InstitutionDetailComponent } from './institution-detail.component';
import { InstitutionPopupComponent } from './institution-dialog.component';
import { InstitutionDeletePopupComponent } from './institution-delete-dialog.component';

import { AppRouteAccessService } from '../../common/app-route-access-service';

@Injectable()
export class InstitutionResolvePagingParams implements Resolve<any> {

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

export const institutionRoute: Routes = [
    {
        path: 'app-admin-institution',
        component: InstitutionComponent,
        resolve: {
            'pagingParams': InstitutionResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['MENU:Institution'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }, {
        path: 'app-admin-institution/:id',
        component: InstitutionDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:Institution.READ'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }
];

export const institutionPopupRoute: Routes = [
    {
        path: 'app-admin-institution-new',
        component: InstitutionPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:Institution.CREATE'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-admin-institution/:id/edit',
        component: InstitutionPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:Institution.UPDATE'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-admin-institution/:id/delete',
        component: InstitutionDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:Institution.DELETE'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService],
        outlet: 'popup'
    }
];
