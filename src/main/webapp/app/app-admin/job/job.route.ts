import { Routes } from '@angular/router';

import { UserRouteAccessService } from '../../shared';
import { JobComponent } from './job.component';
import { JobDetailComponent } from './job-detail.component';
import { JobPopupComponent } from './job-dialog.component';
import { JobDeletePopupComponent } from './job-delete-dialog.component';

export const jobRoute: Routes = [
    {
        path: 'job',
        component: JobComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.job.home.title'
        },
        canActivate: [UserRouteAccessService]
    }, {
        path: 'job/:id',
        component: JobDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.job.home.title'
        },
        canActivate: [UserRouteAccessService]
    }
];

export const jobPopupRoute: Routes = [
    {
        path: 'job-new',
        component: JobPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.job.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'job/:id/edit',
        component: JobPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.job.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'job/:id/delete',
        component: JobDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.job.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
