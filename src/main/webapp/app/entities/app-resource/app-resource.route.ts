import { Routes } from '@angular/router';

import { UserRouteAccessService } from '../../shared';
import { AppResourceComponent } from './app-resource.component';
import { AppResourceDetailComponent } from './app-resource-detail.component';
import { AppResourcePopupComponent } from './app-resource-dialog.component';
import { AppResourceDeletePopupComponent } from './app-resource-delete-dialog.component';

export const appResourceRoute: Routes = [
    {
        path: 'app-resource',
        component: AppResourceComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.appResource.home.title'
        },
        canActivate: [UserRouteAccessService]
    }, {
        path: 'app-resource/:id',
        component: AppResourceDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.appResource.home.title'
        },
        canActivate: [UserRouteAccessService]
    }
];

export const appResourcePopupRoute: Routes = [
    {
        path: 'app-resource-new',
        component: AppResourcePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.appResource.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-resource/:id/edit',
        component: AppResourcePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.appResource.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'app-resource/:id/delete',
        component: AppResourceDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.appResource.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
