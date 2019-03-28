import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';
import { ReportDefinition } from './report-config-definition.model';
import { ReportConfigDefinitionService } from './report-config-definition.service';
import { ReportConfigDefinitionPopupService } from './report-config-definition-popup.service';

@Component({
    selector: 'report-config-definition-delete-dialog',
    templateUrl: './report-config-definition-delete-dialog.component.html'
})
export class ReportConfigDefinitionDeleteDialogComponent {

    reportDefinition: ReportDefinition;

    constructor(
        private reportConfigDefinitionService: ReportConfigDefinitionService,
        public activeModal: NgbActiveModal,
        private eventManager: JhiEventManager
    ) {
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    confirmDelete(id: number) {
        this.reportConfigDefinitionService.delete(id).subscribe((response) => {
            this.eventManager.broadcast({
                name: 'reportConfigDefinitionListModification',
                content: 'Deleted a report definition'
            });
            this.activeModal.dismiss(true);
        });
    }
}

@Component({
    selector: 'report-config-definition-delete-popup',
    template: ''
})
export class ReportConfigDefinitionDeletePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private reportConfigDefinitionPopupService: ReportConfigDefinitionPopupService
    ) { }

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            this.reportConfigDefinitionPopupService
                .open(ReportConfigDefinitionDeleteDialogComponent as Component, params['id']);
        });
    }

    ngOnDestroy() {
        if (this.routeSub) {
            this.routeSub.unsubscribe();
        }
    }
}
