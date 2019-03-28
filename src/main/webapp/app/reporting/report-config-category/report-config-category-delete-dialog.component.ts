import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';
import { ReportCategory } from './report-config-category.model';
import { ReportConfigCategoryService } from './report-config-category.service';
import { ReportConfigCategoryPopupService } from './report-config-category-popup.service';

@Component({
    selector: 'report-config-category-delete-dialog',
    templateUrl: './report-config-category-delete-dialog.component.html'
})
export class ReportConfigCategoryDeleteDialogComponent {

    reportCategory: ReportCategory;

    constructor(
        private reportConfigCategoryService: ReportConfigCategoryService,
        public activeModal: NgbActiveModal,
        private eventManager: JhiEventManager
    ) {
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    confirmDelete(id: number) {
        this.reportConfigCategoryService.delete(id).subscribe((response) => {
            this.eventManager.broadcast({
                name: 'reportConfigCategoryListModification',
                content: 'Deleted a report category'
            });
            this.activeModal.dismiss(true);
        });
    }
}

@Component({
    selector: 'report-config-category-delete-popup',
    template: ''
})
export class ReportConfigCategoryDeletePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private reportConfigCategoryPopupService: ReportConfigCategoryPopupService
    ) { }

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            this.reportConfigCategoryPopupService
                .open(ReportConfigCategoryDeleteDialogComponent as Component, params['id']);
        });
    }

    ngOnDestroy() {
        if (this.routeSub) {
            this.routeSub.unsubscribe();
        }
    }
}
