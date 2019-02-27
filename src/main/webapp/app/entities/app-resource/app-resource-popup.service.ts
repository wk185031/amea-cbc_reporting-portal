import { Injectable, Component } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { HttpResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { AppResource } from './app-resource.model';
import { AppResourceService } from './app-resource.service';

@Injectable()
export class AppResourcePopupService {
    private ngbModalRef: NgbModalRef;

    constructor(
        private datePipe: DatePipe,
        private modalService: NgbModal,
        private router: Router,
        private appResourceService: AppResourceService

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
                this.appResourceService.find(id)
                    .subscribe((appResourceResponse: HttpResponse<AppResource>) => {
                        const appResource: AppResource = appResourceResponse.body;
                        appResource.createdDate = this.datePipe
                            .transform(appResource.createdDate, 'yyyy-MM-ddTHH:mm:ss');
                        appResource.lastModifiedDate = this.datePipe
                            .transform(appResource.lastModifiedDate, 'yyyy-MM-ddTHH:mm:ss');
                        this.ngbModalRef = this.appResourceModalRef(component, appResource);
                        resolve(this.ngbModalRef);
                    });
            } else {
                // setTimeout used as a workaround for getting ExpressionChangedAfterItHasBeenCheckedError
                setTimeout(() => {
                    this.ngbModalRef = this.appResourceModalRef(component, new AppResource());
                    resolve(this.ngbModalRef);
                }, 0);
            }
        });
    }

    appResourceModalRef(component: Component, appResource: AppResource): NgbModalRef {
        const modalRef = this.modalService.open(component, { size: 'lg', backdrop: 'static'});
        modalRef.componentInstance.appResource = appResource;
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
