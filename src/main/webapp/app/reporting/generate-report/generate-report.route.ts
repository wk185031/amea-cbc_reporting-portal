import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';

import { AppRouteAccessService } from '../../common/app-route-access-service';
import { GenerateReportComponent } from './generate-report.component';

@Injectable()
export class GenerateReportResolvePagingParams implements Resolve<any> {

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

export const generateReportRoute: Routes = [
    {
        path: 'generate-report',
        component: GenerateReportComponent,
        resolve: {
            'pagingParams': GenerateReportResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            appPermission: ['MENU:GenerateReport'],
            pageTitle: 'baseApp.reportGeneration.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }
];

export const generateReportPopupRoute: Routes = [
];
