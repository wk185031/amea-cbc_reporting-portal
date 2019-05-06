import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot, Routes } from '@angular/router';
import { JhiPaginationUtil } from 'ng-jhipster';

import { UserRouteAccessService } from '../../shared';

import { AppRouteAccessService } from '../../common/app-route-access-service';
import { DatabaseSynchronizationComponent } from './database-synchronization.component';

@Injectable()
export class DatabaseSynchronizationResolvePagingParams implements Resolve<any> {

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

export const databaseSynchronizationRoute: Routes = [
    {
        path: 'database-synchronization',
        component: DatabaseSynchronizationComponent,
        resolve: {
            'pagingParams': DatabaseSynchronizationResolvePagingParams
        },
        data: {
            authorities: ['ROLE_USER'],
            // appPermission: ['MENU:GenerateReport'],
            pageTitle: 'baseApp.databaseSynchronization.title'
        },
        canActivate: [UserRouteAccessService, AppRouteAccessService]
    }
];