import { Injectable, Component } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { HttpResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { AttachmentGroup } from './attachment-group.model';
import { AttachmentGroupService } from './attachment-group.service';

@Injectable()
export class AttachmentGroupPopupService {
    private ngbModalRef: NgbModalRef;

    constructor(
        private datePipe: DatePipe,
        private modalService: NgbModal,
        private router: Router,
        private attachmentGroupService: AttachmentGroupService

    ) {
        this.ngbModalRef = null;
    }

    open(component: Component, id?: number | any): Promise<NgbModalRef> {
        return new Promise<NgbModalRef>((resolve, reject) => {
            const isOpen = this.ngbModalRef !== null;
            if (isOpen) {
                resolve(this.ngbModalRef);
            }

            if (id) {
                this.attachmentGroupService.find(id)
                    .subscribe((attachmentGroupResponse: HttpResponse<AttachmentGroup>) => {
                        const attachmentGroup: AttachmentGroup = attachmentGroupResponse.body;
                        attachmentGroup.createdDate = this.datePipe
                            .transform(attachmentGroup.createdDate, 'yyyy-MM-ddTHH:mm:ss');
                        attachmentGroup.lastModifiedDate = this.datePipe
                            .transform(attachmentGroup.lastModifiedDate, 'yyyy-MM-ddTHH:mm:ss');
                        this.ngbModalRef = this.attachmentGroupModalRef(component, attachmentGroup);
                        resolve(this.ngbModalRef);
                    });
            } else {
                // setTimeout used as a workaround for getting ExpressionChangedAfterItHasBeenCheckedError
                setTimeout(() => {
                    this.ngbModalRef = this.attachmentGroupModalRef(component, new AttachmentGroup());
                    resolve(this.ngbModalRef);
                }, 0);
            }
        });
    }

    attachmentGroupModalRef(component: Component, attachmentGroup: AttachmentGroup): NgbModalRef {
        const modalRef = this.modalService.open(component, { size: 'lg', backdrop: 'static'});
        modalRef.componentInstance.attachmentGroup = attachmentGroup;
        modalRef.result.then((result) => {
            this.router.navigate([{ outlets: { popup: null }}], { replaceUrl: true, queryParamsHandling: 'merge' });
            this.ngbModalRef = null;
        }, (reason) => {
            this.router.navigate([{ outlets: { popup: null }}], { replaceUrl: true, queryParamsHandling: 'merge' });
            this.ngbModalRef = null;
        });
        return modalRef;
    }
}
