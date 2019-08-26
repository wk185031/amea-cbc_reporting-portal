import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { ReportDefinition } from './report-config-definition.model';
import { ReportConfigDefinitionService } from './report-config-definition.service';
import { ReportConfigDefinitionPopupService } from './report-config-definition-popup.service';
import { isUndefined } from 'util';

@Component({
    selector: 'report-config-definition-dialog',
    templateUrl: './report-config-definition-dialog.component.html'
})
export class ReportConfigDefinitionDialogComponent implements OnInit {

    reportDefinition: ReportDefinition;
    canSave: boolean;
    isSaving: boolean = false;
    valueChanged: boolean = false;

    constructor(
        public activeModal: NgbActiveModal,
        private jhiAlertService: JhiAlertService,
        private reportConfigDefinitionService: ReportConfigDefinitionService,
        private eventManager: JhiEventManager
    ) {
    }

    ngOnInit() {
        if (!this.reportDefinition.id) {
            this.reportDefinition.headerSection = [];
            this.reportDefinition.bodySection = [];
            this.reportDefinition.trailerSection = [];
        } else {
            this.reportDefinition.headerSection = JSON.parse(this.reportDefinition.headerFields);
            this.reportDefinition.headerSection.forEach(section => {
                if (section.leftJustified === false) {
                    section.leftJustified = false;
                } else {
                    section.leftJustified = true;
                }
                if (isUndefined(section.padFieldLength)) {
                    section.padFieldLength = 0;
                }
            });
            this.reportDefinition.bodySection = JSON.parse(this.reportDefinition.bodyFields);
            this.reportDefinition.bodySection.forEach(section => {
                if (section.bodyHeader === true) {
                    if (section.leftJustified === false) {
                        section.leftJustified = false;
                    } else {
                        section.leftJustified = true;
                    }
                } else {
                    if (section.leftJustified === true) {
                        section.leftJustified = true;
                    } else {
                        section.leftJustified = false;
                    }
                }
                if (isUndefined(section.padFieldLength)) {
                    section.padFieldLength = 0;
                }
                if (isUndefined(section.decrypt)) {
                    section.decrypt = false;
                    section.decryptionKey = null;
                    section.tagValue = null;
                }
            });
            this.reportDefinition.trailerSection = JSON.parse(this.reportDefinition.trailerFields);
            this.reportDefinition.trailerSection.forEach(section => {
                if (section.leftJustified === true) {
                    section.leftJustified = true;
                } else {
                    section.leftJustified = false;
                }
                if (isUndefined(section.padFieldLength)) {
                    section.padFieldLength = 0;
                }
                if (isUndefined(section.decrypt)) {
                    section.decrypt = false;
                    section.decryptionKey = null;
                    section.tagValue = null;
                }
            });
        }
        this.canSave = this.checking();
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        if (this.valueChanged) {
            this.isSaving = true;
            this.resequence();
            this.reportDefinition.headerFields = JSON.stringify(this.reportDefinition.headerSection);
            this.reportDefinition.bodyFields = JSON.stringify(this.reportDefinition.bodySection);
            this.reportDefinition.trailerFields = JSON.stringify(this.reportDefinition.trailerSection);
            if (this.reportDefinition.id) {
                this.subscribeToSaveResponse(this.reportConfigDefinitionService.update(this.reportDefinition));
            } else {
                this.subscribeToSaveResponse(this.reportConfigDefinitionService.create(this.reportDefinition));
            }
        }
        else {
            this.activeModal.dismiss();
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<ReportDefinition>>) {
        result.subscribe((res: HttpResponse<ReportDefinition>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: ReportDefinition) {
        this.eventManager.broadcast({ name: 'reportConfigDefinitionListModification', content: 'OK' });
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    valueChange(value: boolean) {
        if (value) {
            this.canSave = this.checking();
            this.valueChanged = true;
        }
    }

    checking() {
        if (!this.reportDefinition.name || this.reportDefinition.name === '') {
            return false;
        }
        if (!this.reportDefinition.description || this.reportDefinition.description === '') {
            return false;
        }
        if (!this.reportDefinition.reportCategory) {
            return false;
        }
        if (!this.reportDefinition.fileNamePrefix || this.reportDefinition.fileNamePrefix === '') {
            return false;
        }
        return true;
    }

    resequence() {
        let headerSectionSequence = 1;
        let bodySectionSequence = 1;
        let trailerSectionSequence = 1;
        if (this.reportDefinition.headerSection) {
            for (const headerSection of this.reportDefinition.headerSection) {
                headerSection.sequence = headerSectionSequence;
                headerSectionSequence++;
            }
        }
        if (this.reportDefinition.bodySection) {
            for (const bodySection of this.reportDefinition.bodySection) {
                bodySection.sequence = bodySectionSequence;
                bodySectionSequence++;
            }
        }
        if (this.reportDefinition.trailerSection) {
            for (const trailerSection of this.reportDefinition.trailerSection) {
                trailerSection.sequence = trailerSectionSequence;
                trailerSectionSequence++;
            }
        }
    }
}

@Component({
    selector: 'report-config-definition-popup',
    template: ''
})
export class ReportConfigDefinitionPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private reportConfigDefinitionPopupService: ReportConfigDefinitionPopupService
    ) { }

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if (params['id']) {
                this.reportConfigDefinitionPopupService
                    .open(ReportConfigDefinitionDialogComponent as Component, params['id']);
            } else {
                this.reportConfigDefinitionPopupService
                    .open(ReportConfigDefinitionDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
