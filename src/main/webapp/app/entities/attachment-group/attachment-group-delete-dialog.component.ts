import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';

import { AttachmentGroup } from './attachment-group.model';
import { AttachmentGroupPopupService } from './attachment-group-popup.service';
import { AttachmentGroupService } from './attachment-group.service';

@Component({
    selector: 'jhi-attachment-group-delete-dialog',
    templateUrl: './attachment-group-delete-dialog.component.html'
})
export class AttachmentGroupDeleteDialogComponent {

    attachmentGroup: AttachmentGroup;

    constructor(
        private attachmentGroupService: AttachmentGroupService,
        public activeModal: NgbActiveModal,
        private eventManager: JhiEventManager
    ) {
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    confirmDelete(id: number) {
        this.attachmentGroupService.delete(id).subscribe((response) => {
            this.eventManager.broadcast({
                name: 'attachmentGroupListModification',
                content: 'Deleted an attachmentGroup'
            });
            this.activeModal.dismiss(true);
        });
    }
}

@Component({
    selector: 'jhi-attachment-group-delete-popup',
    template: ''
})
export class AttachmentGroupDeletePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private attachmentGroupPopupService: AttachmentGroupPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            this.attachmentGroupPopupService
                .open(AttachmentGroupDeleteDialogComponent as Component, params['id']);
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
