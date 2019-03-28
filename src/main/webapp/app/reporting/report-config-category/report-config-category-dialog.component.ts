import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { ReportCategory } from './report-config-category.model';
import { ReportConfigCategoryService } from './report-config-category.service';
import { ReportConfigCategoryPopupService } from './report-config-category-popup.service';

@Component({
    selector: 'report-config-category-dialog',
    templateUrl: './report-config-category-dialog.component.html'
})
export class ReportConfigCategoryDialogComponent implements OnInit {

    reportCategory: ReportCategory;
    isSaving: boolean;
    reportCategories: ReportCategory[];

    constructor(
        public activeModal: NgbActiveModal,
        private jhiAlertService: JhiAlertService,
        private reportConfigCategoryService: ReportConfigCategoryService,
        private eventManager: JhiEventManager
    ) {
    }

    ngOnInit() {
        this.isSaving = false;
        this.reportConfigCategoryService.query()
            .subscribe((res: HttpResponse<ReportCategory[]>) => { this.reportCategories = res.body; }, (res: HttpErrorResponse) => this.onError(res.message));
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        this.isSaving = true;
        if (this.reportCategory.id) {
            this.subscribeToSaveResponse(
                this.reportConfigCategoryService.update(this.reportCategory));
        } else {
            this.subscribeToSaveResponse(
                this.reportConfigCategoryService.create(this.reportCategory));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<ReportCategory>>) {
        result.subscribe((res: HttpResponse<ReportCategory>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: ReportCategory) {
        this.eventManager.broadcast({ name: 'reportConfigCategoryListModification', content: 'OK' });
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    trackInstitutionById(index: number, item: ReportCategory) {
        return item.id;
    }
}

@Component({
    selector: 'report-config-category-popup',
    template: ''
})
export class ReportConfigCategoryPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private reportConfigCategoryPopupService: ReportConfigCategoryPopupService
    ) { }

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if (params['id']) {
                this.reportConfigCategoryPopupService
                    .open(ReportConfigCategoryDialogComponent as Component, params['id']);
            } else {
                this.reportConfigCategoryPopupService
                    .open(ReportConfigCategoryDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
