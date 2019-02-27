import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { EntityAuditComponent } from './entity-audit.component';

import { AppRouteAccessService } from '../../common/app-route-access-service';

const routes: Routes = [
    {
        path: 'entity-audit',
        component: EntityAuditComponent,
        data: {
            appPermission: ['MENU:EntityAudit'],
            pageTitle: 'global.menu.admin.entity-audit'
        },
        canActivate: [AppRouteAccessService]
    }
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule]
})
export class EntityAuditRoutingModule { }
