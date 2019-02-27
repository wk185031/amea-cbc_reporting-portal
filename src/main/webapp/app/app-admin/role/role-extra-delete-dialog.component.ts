import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';

import { RoleExtra } from '../../entities/role-extra/role-extra.model';
import { RoleExtraPopupService } from './role-extra-popup.service';
import { RoleExtraService } from './role-extra.service';

@Component({
    selector: 'jhi-role-extra-delete-dialog',
    templateUrl: './role-extra-delete-dialog.component.html'
})
export class RoleExtraDeleteDialogComponent {

    roleExtra: RoleExtra;

    constructor(
        private roleExtraService: RoleExtraService,
        public activeModal: NgbActiveModal,
        private eventManager: JhiEventManager
    ) {
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    confirmDelete(id: number) {
        this.roleExtraService.delete(id).subscribe((response) => {
            this.eventManager.broadcast({
                name: 'roleExtraListModification',
                content: 'Deleted an roleExtra'
            });
            this.activeModal.dismiss(true);
        });
    }
}

@Component({
    selector: 'jhi-role-extra-delete-popup',
    template: ''
})
export class RoleExtraDeletePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private roleExtraPopupService: RoleExtraPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            this.roleExtraPopupService
                .open(RoleExtraDeleteDialogComponent as Component, params['id']);
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
