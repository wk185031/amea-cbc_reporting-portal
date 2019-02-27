import { Routes } from '@angular/router';

import { UserRouteAccessService } from '../../shared';
import { AttachmentGroupComponent } from './attachment-group.component';
import { AttachmentGroupDetailComponent } from './attachment-group-detail.component';
import { AttachmentGroupPopupComponent } from './attachment-group-dialog.component';
import { AttachmentGroupDeletePopupComponent } from './attachment-group-delete-dialog.component';

export const attachmentGroupRoute: Routes = [
    {
        path: 'attachment-group',
        component: AttachmentGroupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachmentGroup.home.title'
        },
        canActivate: [UserRouteAccessService]
    }, {
        path: 'attachment-group/:id',
        component: AttachmentGroupDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachmentGroup.home.title'
        },
        canActivate: [UserRouteAccessService]
    }
];

export const attachmentGroupPopupRoute: Routes = [
    {
        path: 'attachment-group-new',
        component: AttachmentGroupPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachmentGroup.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'attachment-group/:id/edit',
        component: AttachmentGroupPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachmentGroup.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'attachment-group/:id/delete',
        component: AttachmentGroupDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachmentGroup.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
