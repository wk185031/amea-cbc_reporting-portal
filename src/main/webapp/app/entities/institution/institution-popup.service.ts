import { Injectable, Component } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { HttpResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { Institution } from './institution.model';
import { InstitutionService } from './institution.service';

@Injectable()
export class InstitutionPopupService {
    private ngbModalRef: NgbModalRef;

    constructor(
        private datePipe: DatePipe,
        private modalService: NgbModal,
        private router: Router,
        private institutionService: InstitutionService

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
                this.institutionService.find(id)
                    .subscribe((institutionResponse: HttpResponse<Institution>) => {
                        const institution: Institution = institutionResponse.body;
                        institution.createdDate = this.datePipe
                            .transform(institution.createdDate, 'yyyy-MM-ddTHH:mm:ss');
                        institution.lastModifiedDate = this.datePipe
                            .transform(institution.lastModifiedDate, 'yyyy-MM-ddTHH:mm:ss');
                        this.ngbModalRef = this.institutionModalRef(component, institution);
                        resolve(this.ngbModalRef);
                    });
            } else {
                // setTimeout used as a workaround for getting ExpressionChangedAfterItHasBeenCheckedError
                setTimeout(() => {
                    this.ngbModalRef = this.institutionModalRef(component, new Institution());
                    resolve(this.ngbModalRef);
                }, 0);
            }
        });
    }

    institutionModalRef(component: Component, institution: Institution): NgbModalRef {
        const modalRef = this.modalService.open(component, { size: 'lg', backdrop: 'static'});
        modalRef.componentInstance.institution = institution;
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
