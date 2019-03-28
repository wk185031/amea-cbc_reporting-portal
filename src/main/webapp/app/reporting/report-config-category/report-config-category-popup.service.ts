import { Injectable, Component } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { HttpResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { ReportConfigCategoryService } from './report-config-category.service';
import { ReportCategory } from './report-config-category.model';

@Injectable()
export class ReportConfigCategoryPopupService {
    private ngbModalRef: NgbModalRef;

    constructor(
        private datePipe: DatePipe,
        private modalService: NgbModal,
        private router: Router,
        private reportConfigCategoryService: ReportConfigCategoryService

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
                this.reportConfigCategoryService.find(id)
                    .subscribe((reportConfigCategoryResponse: HttpResponse<ReportCategory>) => {
                        const reportConfigCategory: ReportCategory = reportConfigCategoryResponse.body;
                        reportConfigCategory.createdDate = this.datePipe
                            .transform(reportConfigCategory.createdDate, 'yyyy-MM-ddTHH:mm:ss');
                        reportConfigCategory.lastModifiedDate = this.datePipe
                            .transform(reportConfigCategory.lastModifiedDate, 'yyyy-MM-ddTHH:mm:ss');
                        this.ngbModalRef = this.reportConfigCategoryModalRef(component, reportConfigCategory);
                        resolve(this.ngbModalRef);
                    });
            } else {
                // setTimeout used as a workaround for getting ExpressionChangedAfterItHasBeenCheckedError
                setTimeout(() => {
                    this.ngbModalRef = this.reportConfigCategoryModalRef(component, new ReportCategory());
                    resolve(this.ngbModalRef);
                }, 0);
            }
        });
    }

    reportConfigCategoryModalRef(component: Component, reportConfigCategory: ReportCategory): NgbModalRef {
        const modalRef = this.modalService.open(component, { size: 'lg', backdrop: 'static' });
        modalRef.componentInstance.reportCategory = reportConfigCategory;
        modalRef.result.then((result) => {
            this.router.navigate([{ outlets: { popup: null } }], { replaceUrl: true, queryParamsHandling: 'merge' });
            this.ngbModalRef = null;
        }, (reason) => {
            this.router.navigate([{ outlets: { popup: null } }], { replaceUrl: true, queryParamsHandling: 'merge' });
            this.ngbModalRef = null;
        });
        return modalRef;
    }
}
