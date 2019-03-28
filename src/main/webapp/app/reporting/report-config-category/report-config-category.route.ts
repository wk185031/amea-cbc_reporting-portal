import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';

import { AppRouteAccessService } from '../../common/app-route-access-service';
import { ReportConfigCategoryComponent } from './report-config-category.component';
import { ReportConfigCategoryPopupComponent } from './report-config-category-dialog.component';
import { ReportConfigCategoryDeleteDialogComponent, ReportConfigCategoryDeletePopupComponent } from './report-config-category-delete-dialog.component';

@Injectable()
export class ReportConfigCategoryResolvePagingParams implements Resolve<any> {

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

export const reportConfigCategoryRoute: Routes = [
    {
        path: 'report-configuration-category',
        component: ReportConfigCategoryComponent,
        resolve: {
            'pagingParams': ReportConfigCategoryResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['MENU:ReportCategory'],
            pageTitle: 'baseApp.reportCategory.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }
];

export const reportConfigCategoryPopupRoute: Routes = [
    {
        path: 'report-category-new',
        component: ReportConfigCategoryPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:ReportCategory.CREATE'],
            pageTitle: 'baseApp.reportCategory.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'reportCategory/:id/edit',
        component: ReportConfigCategoryPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:ReportCategory.UPDATE'],
            pageTitle: 'baseApp.reportCategory.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'reportCategory/:id/delete',
        component: ReportConfigCategoryDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['OPER:ReportCategory.DELETE'],
            pageTitle: 'baseApp.reportCategory.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
