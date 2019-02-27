import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { Institution } from './institution.model';
import { InstitutionPopupService } from './institution-popup.service';
import { InstitutionService } from './institution.service';
import { AttachmentGroup, AttachmentGroupService } from '../attachment-group';

@Component({
    selector: 'jhi-institution-dialog',
    templateUrl: './institution-dialog.component.html'
})
export class InstitutionDialogComponent implements OnInit {

    institution: Institution;
    isSaving: boolean;

    attachmentgroups: AttachmentGroup[];

    institutions: Institution[];

    constructor(
        public activeModal: NgbActiveModal,
        private jhiAlertService: JhiAlertService,
        private institutionService: InstitutionService,
        private attachmentGroupService: AttachmentGroupService,
        private eventManager: JhiEventManager
    ) {
    }

    ngOnInit() {
        this.isSaving = false;
        this.attachmentGroupService
            .query({filter: 'institution-is-null'})
            .subscribe((res: HttpResponse<AttachmentGroup[]>) => {
                if (!this.institution.attachmentGroup || !this.institution.attachmentGroup.id) {
                    this.attachmentgroups = res.body;
                } else {
                    this.attachmentGroupService
                        .find(this.institution.attachmentGroup.id)
                        .subscribe((subRes: HttpResponse<AttachmentGroup>) => {
                            this.attachmentgroups = [subRes.body].concat(res.body);
                        }, (subRes: HttpErrorResponse) => this.onError(subRes.message));
                }
            }, (res: HttpErrorResponse) => this.onError(res.message));
        this.institutionService.query()
            .subscribe((res: HttpResponse<Institution[]>) => { this.institutions = res.body; }, (res: HttpErrorResponse) => this.onError(res.message));
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        this.isSaving = true;
        if (this.institution.id !== undefined) {
            this.subscribeToSaveResponse(
                this.institutionService.update(this.institution));
        } else {
            this.subscribeToSaveResponse(
                this.institutionService.create(this.institution));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<Institution>>) {
        result.subscribe((res: HttpResponse<Institution>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: Institution) {
        this.eventManager.broadcast({ name: 'institutionListModification', content: 'OK'});
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    trackAttachmentGroupById(index: number, item: AttachmentGroup) {
        return item.id;
    }

    trackInstitutionById(index: number, item: Institution) {
        return item.id;
    }
}

@Component({
    selector: 'jhi-institution-popup',
    template: ''
})
export class InstitutionPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private institutionPopupService: InstitutionPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.institutionPopupService
                    .open(InstitutionDialogComponent as Component, params['id']);
            } else {
                this.institutionPopupService
                    .open(InstitutionDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
