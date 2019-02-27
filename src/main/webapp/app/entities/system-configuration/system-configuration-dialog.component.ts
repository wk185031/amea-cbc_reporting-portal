import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';

import { SystemConfiguration } from './system-configuration.model';
import { SystemConfigurationPopupService } from './system-configuration-popup.service';
import { SystemConfigurationService } from './system-configuration.service';

@Component({
    selector: 'jhi-system-configuration-dialog',
    templateUrl: './system-configuration-dialog.component.html'
})
export class SystemConfigurationDialogComponent implements OnInit {

    systemConfiguration: SystemConfiguration;
    isSaving: boolean;

    constructor(
        public activeModal: NgbActiveModal,
        private systemConfigurationService: SystemConfigurationService,
        private eventManager: JhiEventManager
    ) {
    }

    ngOnInit() {
        this.isSaving = false;
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        this.isSaving = true;
        if (this.systemConfiguration.id !== undefined) {
            this.subscribeToSaveResponse(
                this.systemConfigurationService.update(this.systemConfiguration));
        } else {
            this.subscribeToSaveResponse(
                this.systemConfigurationService.create(this.systemConfiguration));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<SystemConfiguration>>) {
        result.subscribe((res: HttpResponse<SystemConfiguration>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: SystemConfiguration) {
        this.eventManager.broadcast({ name: 'systemConfigurationListModification', content: 'OK'});
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }
}

@Component({
    selector: 'jhi-system-configuration-popup',
    template: ''
})
export class SystemConfigurationPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private systemConfigurationPopupService: SystemConfigurationPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.systemConfigurationPopupService
                    .open(SystemConfigurationDialogComponent as Component, params['id']);
            } else {
                this.systemConfigurationPopupService
                    .open(SystemConfigurationDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
