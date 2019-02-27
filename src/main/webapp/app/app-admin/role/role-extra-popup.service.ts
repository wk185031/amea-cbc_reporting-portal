import { Injectable, Component } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { HttpResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { RoleExtra } from '../../entities/role-extra/role-extra.model';
import { RoleExtraService } from './role-extra.service';

@Injectable()
export class RoleExtraPopupService {
    private ngbModalRef: NgbModalRef;

    constructor(
        private datePipe: DatePipe,
        private modalService: NgbModal,
        private router: Router,
        private roleExtraService: RoleExtraService

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
                this.roleExtraService.find(id)
                    .subscribe((roleExtraResponse: HttpResponse<RoleExtra>) => {
                        const roleExtra: RoleExtra = roleExtraResponse.body;
                        roleExtra.createdDate = this.datePipe
                            .transform(roleExtra.createdDate, 'yyyy-MM-ddTHH:mm:ss');
                        roleExtra.lastModifiedDate = this.datePipe
                            .transform(roleExtra.lastModifiedDate, 'yyyy-MM-ddTHH:mm:ss');
                        this.ngbModalRef = this.roleExtraModalRef(component, roleExtra);
                        resolve(this.ngbModalRef);
                    });
            } else {
                // setTimeout used as a workaround for getting ExpressionChangedAfterItHasBeenCheckedError
                setTimeout(() => {
                    this.ngbModalRef = this.roleExtraModalRef(component, new RoleExtra());
                    resolve(this.ngbModalRef);
                }, 0);
            }
        });
    }

    roleExtraModalRef(component: Component, roleExtra: RoleExtra): NgbModalRef {
        const modalRef = this.modalService.open(component, { size: 'lg', backdrop: 'static'});
        modalRef.componentInstance.roleExtra = roleExtra;
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
