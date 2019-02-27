import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager } from 'ng-jhipster';

import { RoleExtra } from './role-extra.model';
import { RoleExtraService } from './role-extra.service';

@Component({
    selector: 'jhi-role-extra-detail',
    templateUrl: './role-extra-detail.component.html'
})
export class RoleExtraDetailComponent implements OnInit, OnDestroy {

    roleExtra: RoleExtra;
    private subscription: Subscription;
    private eventSubscriber: Subscription;

    constructor(
        private eventManager: JhiEventManager,
        private roleExtraService: RoleExtraService,
        private route: ActivatedRoute
    ) {
    }

    ngOnInit() {
        this.subscription = this.route.params.subscribe((params) => {
            this.load(params['id']);
        });
        this.registerChangeInRoleExtras();
    }

    load(id) {
        this.roleExtraService.find(id)
            .subscribe((roleExtraResponse: HttpResponse<RoleExtra>) => {
                this.roleExtra = roleExtraResponse.body;
            });
    }
    previousState() {
        window.history.back();
    }

    ngOnDestroy() {
        this.subscription.unsubscribe();
        this.eventManager.destroy(this.eventSubscriber);
    }

    registerChangeInRoleExtras() {
        this.eventSubscriber = this.eventManager.subscribe(
            'roleExtraListModification',
            (response) => this.load(this.roleExtra.id)
        );
    }
}
