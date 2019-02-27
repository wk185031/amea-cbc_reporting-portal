import { Routes } from '@angular/router';

import { UserRouteAccessService } from '../../shared';
import { AttachmentComponent } from './attachment.component';
import { AttachmentDetailComponent } from './attachment-detail.component';
import { AttachmentPopupComponent } from './attachment-dialog.component';
import { AttachmentDeletePopupComponent } from './attachment-delete-dialog.component';

export const attachmentRoute: Routes = [
    {
        path: 'attachment',
        component: AttachmentComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachment.home.title'
        },
        canActivate: [UserRouteAccessService]
    }, {
        path: 'attachment/:id',
        component: AttachmentDetailComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachment.home.title'
        },
        canActivate: [UserRouteAccessService]
    }
];

export const attachmentPopupRoute: Routes = [
    {
        path: 'attachment-new',
        component: AttachmentPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachment.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'attachment/:id/edit',
        component: AttachmentPopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachment.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    },
    {
        path: 'attachment/:id/delete',
        component: AttachmentDeletePopupComponent,
        data: {
            authorities: ['ROLE_USER'],
            pageTitle: 'baseApp.attachment.home.title'
        },
        canActivate: [UserRouteAccessService],
        outlet: 'popup'
    }
];
