import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';

import { AppRouteAccessService } from '../../common/app-route-access-service';
import { ReportConfigTemplateComponent } from './report-config-template.component';

@Injectable()
export class ReportConfigTemplateResolvePagingParams implements Resolve<any> {

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

export const reportConfigTemplateRoute: Routes = [
    {
        path: 'report-configuration-template',
        component: ReportConfigTemplateComponent,
        resolve: {
            'pagingParams': ReportConfigTemplateResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'reportConfig.template.main.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }
];

export const reportConfigTemplatePopupRoute: Routes = [
];
