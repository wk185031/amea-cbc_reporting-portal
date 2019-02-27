import { Injectable, Component } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { HttpResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { UserExtra } from '../../entities/user-extra/user-extra.model';
import { UserExtraService } from './user-extra.service';

@Injectable()
export class UserExtraPopupService {
    private ngbModalRef: NgbModalRef;

    constructor(
        private datePipe: DatePipe,
        private modalService: NgbModal,
        private router: Router,
        private userExtraService: UserExtraService

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
                this.userExtraService.find(id)
                    .subscribe((userExtraResponse: HttpResponse<UserExtra>) => {
                        const userExtra: UserExtra = userExtraResponse.body;
                        userExtra.createdDate = this.datePipe
                            .transform(userExtra.createdDate, 'yyyy-MM-ddTHH:mm:ss');
                        userExtra.lastModifiedDate = this.datePipe
                            .transform(userExtra.lastModifiedDate, 'yyyy-MM-ddTHH:mm:ss');
                        this.ngbModalRef = this.userExtraModalRef(component, userExtra);
                        resolve(this.ngbModalRef);
                    });
            } else {
                // setTimeout used as a workaround for getting ExpressionChangedAfterItHasBeenCheckedError
                setTimeout(() => {
                    this.ngbModalRef = this.userExtraModalRef(component, new UserExtra());
                    resolve(this.ngbModalRef);
                }, 0);
            }
        });
    }

    userExtraModalRef(component: Component, userExtra: UserExtra): NgbModalRef {
        const modalRef = this.modalService.open(component, { size: 'lg', backdrop: 'static'});
        modalRef.componentInstance.userExtra = userExtra;
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
