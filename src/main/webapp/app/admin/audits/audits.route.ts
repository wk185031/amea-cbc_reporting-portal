import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { AuditsComponent } from './audits.component';
import { AppRouteAccessService } from '../../common/app-route-access-service';

const routes: Routes = [{
    path: 'audits',
    component: AuditsComponent,
    data: {
    	appPermission: ['MENU:ActionAudit'],
        pageTitle: 'audits.title'
    },
    canActivate: [AppRouteAccessService]
}];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule]
})
export class AuditsRoutingModule { }
