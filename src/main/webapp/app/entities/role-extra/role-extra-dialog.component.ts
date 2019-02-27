import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { RoleExtra } from './role-extra.model';
import { RoleExtraPopupService } from './role-extra-popup.service';
import { RoleExtraService } from './role-extra.service';
import { AppResource, AppResourceService } from '../app-resource';

@Component({
    selector: 'jhi-role-extra-dialog',
    templateUrl: './role-extra-dialog.component.html'
})
export class RoleExtraDialogComponent implements OnInit {

    roleExtra: RoleExtra;
    isSaving: boolean;

    appresources: AppResource[];

    constructor(
        public activeModal: NgbActiveModal,
        private jhiAlertService: JhiAlertService,
        private roleExtraService: RoleExtraService,
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
        if (this.roleExtra.id !== undefined) {
            this.subscribeToSaveResponse(
                this.roleExtraService.update(this.roleExtra));
        } else {
            this.subscribeToSaveResponse(
                this.roleExtraService.create(this.roleExtra));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<RoleExtra>>) {
        result.subscribe((res: HttpResponse<RoleExtra>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: RoleExtra) {
        this.eventManager.broadcast({ name: 'roleExtraListModification', content: 'OK'});
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

    getSelected(selectedVals: Array<any>, option: any) {
        if (selectedVals) {
            for (let i = 0; i < selectedVals.length; i++) {
                if (option.id === selectedVals[i].id) {
                    return selectedVals[i];
                }
            }
        }
        return option;
    }
}

@Component({
    selector: 'jhi-role-extra-popup',
    template: ''
})
export class RoleExtraPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private roleExtraPopupService: RoleExtraPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.roleExtraPopupService
                    .open(RoleExtraDialogComponent as Component, params['id']);
            } else {
                this.roleExtraPopupService
                    .open(RoleExtraDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
