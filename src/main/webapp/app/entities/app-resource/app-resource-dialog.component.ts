import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { AppResource } from './app-resource.model';
import { AppResourcePopupService } from './app-resource-popup.service';
import { AppResourceService } from './app-resource.service';

@Component({
    selector: 'jhi-app-resource-dialog',
    templateUrl: './app-resource-dialog.component.html'
})
export class AppResourceDialogComponent implements OnInit {

    appResource: AppResource;
    isSaving: boolean;

    appresources: AppResource[];

    constructor(
        public activeModal: NgbActiveModal,
        private jhiAlertService: JhiAlertService,
        private appResourceService: AppResourceService,
        private eventManager: JhiEventManager
    ) {
    }

    ngOnInit() {
        this.isSaving = false;
        this.appResourceService.query()
            .subscribe((res: HttpResponse<AppResource[]>) => { this.appresources = res.body; }, (res: HttpErrorResponse) => this.onError(res.message));
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        this.isSaving = true;
        if (this.appResource.id !== undefined) {
            this.subscribeToSaveResponse(
                this.appResourceService.update(this.appResource));
        } else {
            this.subscribeToSaveResponse(
                this.appResourceService.create(this.appResource));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<AppResource>>) {
        result.subscribe((res: HttpResponse<AppResource>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: AppResource) {
        this.eventManager.broadcast({ name: 'appResourceListModification', content: 'OK'});
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    trackAppResourceById(index: number, item: AppResource) {
        return item.id;
    }
}

@Component({
    selector: 'jhi-app-resource-popup',
    template: ''
})
export class AppResourcePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private appResourcePopupService: AppResourcePopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.appResourcePopupService
                    .open(AppResourceDialogComponent as Component, params['id']);
            } else {
                this.appResourcePopupService
                    .open(AppResourceDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
