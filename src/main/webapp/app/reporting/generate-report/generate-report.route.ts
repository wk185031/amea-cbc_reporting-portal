import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';

import { AppRouteAccessService } from '../../common/app-route-access-service';
import { GenerateReportComponent } from './generate-report.component';
import { ReportCategory } from '../report-config-category/report-config-category.model';
import { ReportConfigCategoryService } from '../report-config-category/report-config-category.service';
import { HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs';
import { mergeMap, map } from 'rxjs/operators';
import { forkJoin } from 'rxjs/observable/forkJoin';
import { ReportConfigDefinitionService } from '../report-config-definition/report-config-definition.service';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';
import { of } from 'rxjs/observable/of';

@Injectable()
export class GenerateReportResolvePagingParams implements Resolve<any> {

    constructor(private paginationUtil: JhiPaginationUtil,
        private reportConfigCategoryService: ReportConfigCategoryService,
        private reportConfigDefinitionService: ReportConfigDefinitionService) {
    }

    resolve(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<any> {
        const page = route.queryParams['page'] ? route.queryParams['page'] : '1';
        const sort = route.queryParams['sort'] ? route.queryParams['sort'] : 'id,asc';
        const branchId = route.params.id;
        return forkJoin([this.reportConfigCategoryService.queryNoPaging(),
            this.reportConfigDefinitionService.queryNoPaging()]).pipe(
            map((value) => value),
            mergeMap((value: Observable<[HttpResponse<ReportCategory[]>, HttpResponse<ReportDefinition[]>]>) => {
                return of({
                    page: this.paginationUtil.parsePage(page),
                    predicate: this.paginationUtil.parsePredicate(sort),
                    ascending: this.paginationUtil.parseAscending(sort),
                    categories: value[0].body,
                    reportDefinitions: value[1].body
                });
            })
        );

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
    },
    {
        path: 'generate-report/:id',
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
