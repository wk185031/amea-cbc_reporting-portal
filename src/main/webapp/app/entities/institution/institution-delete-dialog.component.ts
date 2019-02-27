import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';

import { Institution } from './institution.model';
import { InstitutionPopupService } from './institution-popup.service';
import { InstitutionService } from './institution.service';

@Component({
    selector: 'jhi-institution-delete-dialog',
    templateUrl: './institution-delete-dialog.component.html'
})
export class InstitutionDeleteDialogComponent {

    institution: Institution;

    constructor(
        private institutionService: InstitutionService,
        public activeModal: NgbActiveModal,
        private eventManager: JhiEventManager
    ) {
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    confirmDelete(id: number) {
        this.institutionService.delete(id).subscribe((response) => {
            this.eventManager.broadcast({
                name: 'institutionListModification',
                content: 'Deleted an institution'
            });
            this.activeModal.dismiss(true);
        });
    }
}

@Component({
    selector: 'jhi-institution-delete-popup',
    template: ''
})
export class InstitutionDeletePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private institutionPopupService: InstitutionPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            this.institutionPopupService
                .open(InstitutionDeleteDialogComponent as Component, params['id']);
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
