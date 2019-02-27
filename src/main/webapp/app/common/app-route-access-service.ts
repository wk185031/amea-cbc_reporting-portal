import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivate, Router, RouterStateSnapshot } from '@angular/router';

import { Principal } from '../shared/auth/principal.service';
import { LoginModalService } from '../shared/login/login-modal.service';
import { StateStorageService } from '../shared/auth/state-storage.service';

import { AppPermissionService } from '.';

@Injectable()
export class AppRouteAccessService implements CanActivate {

    constructor(private router: Router,
                private loginModalService: LoginModalService,
                private principal: Principal,
                private stateStorageService: StateStorageService, 
                private appPermissionService: AppPermissionService) {
    }

    canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean | Promise<boolean> {

        const authorities = route.data['appPermission'];
        // We need to call the checkLogin / and so the principal.identity() function, to ensure,
        // that the client has a principal too, if they already logged in by the server.
        // This could happen on a page refresh.
        return this.checkLogin(authorities, state.url);
    }

    checkLogin(authorities: string[], url: string): Promise<boolean> {
        const principal = this.principal;
        return Promise.resolve(principal.identity().then((account) => {

            if (!authorities || authorities.length === 0) {
                return true;
            }

            if (account) {
                return this.appPermissionService.hasAnyAuthority(authorities).then((response) => {
                    if (response) {
                        return true;
                    }
                    return false;
                });
            }

            this.stateStorageService.storeUrl(url);
            this.router.navigate(['accessdenied']).then(() => {
                // only show the login dialog, if the user hasn't logged in yet
                if (!account) {
                    this.loginModalService.open();
                }
            });
            return false;
        }));
    }
}
