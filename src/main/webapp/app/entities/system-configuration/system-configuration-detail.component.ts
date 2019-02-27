import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager } from 'ng-jhipster';

import { SystemConfiguration } from './system-configuration.model';
import { SystemConfigurationService } from './system-configuration.service';

@Component({
    selector: 'jhi-system-configuration-detail',
    templateUrl: './system-configuration-detail.component.html'
})
export class SystemConfigurationDetailComponent implements OnInit, OnDestroy {

    systemConfiguration: SystemConfiguration;
    private subscription: Subscription;
    private eventSubscriber: Subscription;

    constructor(
        private eventManager: JhiEventManager,
        private systemConfigurationService: SystemConfigurationService,
        private route: ActivatedRoute
    ) {
    }

    ngOnInit() {
        this.subscription = this.route.params.subscribe((params) => {
            this.load(params['id']);
        });
        this.registerChangeInSystemConfigurations();
    }

    load(id) {
        this.systemConfigurationService.find(id)
            .subscribe((systemConfigurationResponse: HttpResponse<SystemConfiguration>) => {
                this.systemConfiguration = systemConfigurationResponse.body;
            });
    }
    previousState() {
        window.history.back();
    }

    ngOnDestroy() {
        this.subscription.unsubscribe();
        this.eventManager.destroy(this.eventSubscriber);
    }

    registerChangeInSystemConfigurations() {
        this.eventSubscriber = this.eventManager.subscribe(
            'systemConfigurationListModification',
            (response) => this.load(this.systemConfiguration.id)
        );
    }
}
