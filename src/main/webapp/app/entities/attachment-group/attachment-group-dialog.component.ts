import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';

import { AttachmentGroup } from './attachment-group.model';
import { AttachmentGroupPopupService } from './attachment-group-popup.service';
import { AttachmentGroupService } from './attachment-group.service';

@Component({
    selector: 'jhi-attachment-group-dialog',
    templateUrl: './attachment-group-dialog.component.html'
})
export class AttachmentGroupDialogComponent implements OnInit {

    attachmentGroup: AttachmentGroup;
    isSaving: boolean;

    constructor(
        public activeModal: NgbActiveModal,
        private attachmentGroupService: AttachmentGroupService,
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
        if (this.attachmentGroup.id !== undefined) {
            this.subscribeToSaveResponse(
                this.attachmentGroupService.update(this.attachmentGroup));
        } else {
            this.subscribeToSaveResponse(
                this.attachmentGroupService.create(this.attachmentGroup));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<AttachmentGroup>>) {
        result.subscribe((res: HttpResponse<AttachmentGroup>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: AttachmentGroup) {
        this.eventManager.broadcast({ name: 'attachmentGroupListModification', content: 'OK'});
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }
}

@Component({
    selector: 'jhi-attachment-group-popup',
    template: ''
})
export class AttachmentGroupPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private attachmentGroupPopupService: AttachmentGroupPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.attachmentGroupPopupService
                    .open(AttachmentGroupDialogComponent as Component, params['id']);
            } else {
                this.attachmentGroupPopupService
                    .open(AttachmentGroupDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
