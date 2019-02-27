import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager } from 'ng-jhipster';

import { AppResource } from './app-resource.model';
import { AppResourceService } from './app-resource.service';

@Component({
    selector: 'jhi-app-resource-detail',
    templateUrl: './app-resource-detail.component.html'
})
export class AppResourceDetailComponent implements OnInit, OnDestroy {

    appResource: AppResource;
    private subscription: Subscription;
    private eventSubscriber: Subscription;

    constructor(
        private eventManager: JhiEventManager,
        private appResourceService: AppResourceService,
        private route: ActivatedRoute
    ) {
    }

    ngOnInit() {
        this.subscription = this.route.params.subscribe((params) => {
            this.load(params['id']);
        });
        this.registerChangeInAppResources();
    }

    load(id) {
        this.appResourceService.find(id)
            .subscribe((appResourceResponse: HttpResponse<AppResource>) => {
                this.appResource = appResourceResponse.body;
            });
    }
    previousState() {
        window.history.back();
    }

    ngOnDestroy() {
        this.subscription.unsubscribe();
        this.eventManager.destroy(this.eventSubscriber);
    }

    registerChangeInAppResources() {
        this.eventSubscriber = this.eventManager.subscribe(
            'appResourceListModification',
            (response) => this.load(this.appResource.id)
        );
    }
}
