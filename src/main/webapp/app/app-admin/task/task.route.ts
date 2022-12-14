import { Routes } from '@angular/router';

import { UserRouteAccessService } from '../../shared';
import { TaskComponent } from './task.component';
import { TaskDetailComponent } from './task-detail.component';
import { TaskPopupComponent } from './task-dialog.component';
import { TaskDeletePopupComponent } from './task-delete-dialog.component';

export const taskRoute: Routes = [
    {
        path: 'task',
        component: TaskComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.task.home.title'
        },
        canActivate: [UserRouteAccessService]
    }, {
        path: 'task/:id',
        component: TaskDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.task.home.title'
        },
        canActivate: [UserRouteAccessService]
    }
];

export const taskPopupRoute: Routes = [
    {
        path: 'task-new',
        component: TaskPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.task.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'task/:id/edit',
        component: TaskPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.task.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'task/:id/delete',
        component: TaskDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.task.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
