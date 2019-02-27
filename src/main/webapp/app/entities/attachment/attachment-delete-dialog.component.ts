import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';

import { Attachment } from './attachment.model';
import { AttachmentPopupService } from './attachment-popup.service';
import { AttachmentService } from './attachment.service';

@Component({
    selector: 'jhi-attachment-delete-dialog',
    templateUrl: './attachment-delete-dialog.component.html'
})
export class AttachmentDeleteDialogComponent {

    attachment: Attachment;

    constructor(
        private attachmentService: AttachmentService,
        public activeModal: NgbActiveModal,
        private eventManager: JhiEventManager
    ) {
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    confirmDelete(id: number) {
        this.attachmentService.delete(id).subscribe((response) => {
            this.eventManager.broadcast({
                name: 'attachmentListModification',
                content: 'Deleted an attachment'
            });
            this.activeModal.dismiss(true);
        });
    }
}

@Component({
    selector: 'jhi-attachment-delete-popup',
    template: ''
})
export class AttachmentDeletePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private attachmentPopupService: AttachmentPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            this.attachmentPopupService
                .open(AttachmentDeleteDialogComponent as Component, params['id']);
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
