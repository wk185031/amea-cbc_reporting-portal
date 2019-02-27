import { Injectable } from '@angular/core';
import { AppResource } from '../entities/app-resource';

import { Principal } from '../shared/auth/principal.service';

@Injectable()
export class AppPermissionService {

    MENU = 'MENU:';
    OPER = 'OPER:';

    CREATE = '.CREATE';
    READ = '.READ';
    UPDATE = '.UPDATE';
    DELETE = '.DELETE';
    WORKFLOW = '.WORKFLOW';
    SHIPPING_MANAGER = '.SHIPPINGMANAGER';
    SUPERVISOR = '.SUPERVISOR';

    TEMPLATE_MAINTENANCE = '.TEMPLATE_MAINTENANCE';

    permissions: AppResource[];

    constructor(
        private principal: Principal
    ) {}

    hasPermission(requestedResource: String) {
        // TODO remove when fully tested
        if (this.permissions) {
            return this.permissions.find((resource: AppResource) => resource.code === requestedResource);
        }

        return false;
    }

    hasAnyAuthority(authorities: string[]): Promise<boolean> {
        return Promise.resolve(this.appHasAnyAuthorityDirect(authorities));
    }

    appHasAnyAuthorityDirect(authorities: string[]): boolean {
        if (!this.principal.isAuthenticated() || !this.principal.isIdentityResolved() ) {
            return false;
        }

        for (let i = 0; i < authorities.length; i++) {
            console.log('authorities:' + authorities[i]);
            if (this.hasPermission(authorities[i])) {
                return true;
            }
        }

        return false;
    }
}
