import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRouteSnapshot, NavigationEnd } from '@angular/router';

import { JhiLanguageHelper } from '../../shared';
import { Idle, DEFAULT_INTERRUPTSOURCES } from '@ng-idle/core';
import { Keepalive } from '@ng-idle/keepalive';
import { Principal } from '../../shared/auth/principal.service';
import { LoginService } from '../../shared/login/login.service';


@Component({
    selector: 'jhi-main',
    templateUrl: './main.component.html'
})
export class JhiMainComponent implements OnInit {

    constructor(
        private jhiLanguageHelper: JhiLanguageHelper,
        private router: Router,
        private loginService: LoginService,
        private principal: Principal,
        private idle: Idle,
        private keepalive: Keepalive,
    ) {
        // API call from DB
        var idleScreenConfig = {
            idle: 600, // time for screen to show timout warning (in second)
            timeOut: 5, // countdown time before logout (in second)
            enableTimeOut: true // able to set timeout 
        }

        // set default interrupt, the timeout will reset if event happen on screen (click or touch or press key)
        idle.setInterrupts(DEFAULT_INTERRUPTSOURCES); 
        
        // will execute after idle for x second, and will reset to x second after interrupt
        idle.setIdle(idleScreenConfig.idle) 

        // will execute after finish x second countdown
        idle.setTimeout(idleScreenConfig.timeOut);
        idle.onTimeout.subscribe(() => {
            this.loginService.logoutNavBar();
            this.router.navigate(['']).then();
            idle.watch()
        });

        // start idle after login
        if (idleScreenConfig.enableTimeOut) idle.watch()
    }

    private getPageTitle(routeSnapshot: ActivatedRouteSnapshot) {
        let title: string = (routeSnapshot.data && routeSnapshot.data['pageTitle']) ? routeSnapshot.data['pageTitle'] : 'baseApp';
        if (routeSnapshot.firstChild) {
            title = this.getPageTitle(routeSnapshot.firstChild) || title;
        }
        return title;
    }

    ngOnInit() {
        this.router.events.subscribe((event) => {
            if (event instanceof NavigationEnd) {
                this.jhiLanguageHelper.updateTitle(this.getPageTitle(this.router.routerState.snapshot.root));
            }
        });
    }

    isAuthenticated() {
        return this.principal.isAuthenticated();
    }

}
