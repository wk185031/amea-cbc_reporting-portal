import { Routes } from '@angular/router';

import { UserRouteAccessService } from '../../shared';
import { TaskGroupComponent } from './task-group.component';
import { TaskGroupDetailComponent } from './task-group-detail.component';
import { TaskGroupPopupComponent } from './task-group-dialog.component';
import { TaskGroupDeletePopupComponent } from './task-group-delete-dialog.component';

export const taskGroupRoute: Routes = [
    {
        path: 'task-group',
        component: TaskGroupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.taskGroup.home.title'
        },
        canActivate: [UserRouteAccessService]
    }, {
        path: 'task-group/:id',
        component: TaskGroupDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.taskGroup.home.title'
        },
        canActivate: [UserRouteAccessService]
    }
];

export const taskGroupPopupRoute: Routes = [
    {
        path: 'task-group-new',
        component: TaskGroupPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.taskGroup.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'task-group/:id/edit',
        component: TaskGroupPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.taskGroup.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'task-group/:id/delete',
        component: TaskGroupDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.taskGroup.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
