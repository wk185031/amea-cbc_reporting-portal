import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';
import { InstitutionComponent } from './institution.component';
import { InstitutionDetailComponent } from './institution-detail.component';
import { InstitutionPopupComponent } from './institution-dialog.component';
import { InstitutionDeletePopupComponent } from './institution-delete-dialog.component';

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
        path: 'institution',
        component: InstitutionComponent,
        resolve: {
            'pagingParams': InstitutionResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService]
    }, {
        path: 'institution/:id',
        component: InstitutionDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService]
    }
];

export const institutionPopupRoute: Routes = [
    {
        path: 'institution-new',
        component: InstitutionPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'institution/:id/edit',
        component: InstitutionPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'institution/:id/delete',
        component: InstitutionDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.institution.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
