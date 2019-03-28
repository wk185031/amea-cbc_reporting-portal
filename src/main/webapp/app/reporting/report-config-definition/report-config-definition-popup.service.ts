import { Injectable, Component } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { HttpResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { ReportConfigDefinitionService } from './report-config-definition.service';
import { ReportDefinition } from './report-config-definition.model';

@Injectable()
export class ReportConfigDefinitionPopupService {
    private ngbModalRef: NgbModalRef;

    constructor(
        private datePipe: DatePipe,
        private modalService: NgbModal,
        private router: Router,
        private reportConfigDefinitionService: ReportConfigDefinitionService

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
                this.reportConfigDefinitionService.find(id)
                    .subscribe((reportConfigDefinitionResponse: HttpResponse<ReportDefinition>) => {
                        const reportConfigDefinition: ReportDefinition = reportConfigDefinitionResponse.body;
                        reportConfigDefinition.createdDate = this.datePipe
                            .transform(reportConfigDefinition.createdDate, 'yyyy-MM-ddTHH:mm:ss');
                        reportConfigDefinition.lastModifiedDate = this.datePipe
                            .transform(reportConfigDefinition.lastModifiedDate, 'yyyy-MM-ddTHH:mm:ss');
                        this.ngbModalRef = this.reportConfigDefinitionModalRef(component, reportConfigDefinition);
                        resolve(this.ngbModalRef);
                    });
            } else {
                // setTimeout used as a workaround for getting ExpressionChangedAfterItHasBeenCheckedError
                setTimeout(() => {
                    this.ngbModalRef = this.reportConfigDefinitionModalRef(component, new ReportDefinition());
                    resolve(this.ngbModalRef);
                }, 0);
            }
        });
    }

    reportConfigDefinitionModalRef(component: Component, reportConfigDefinition: ReportDefinition): NgbModalRef {
        const modalRef = this.modalService.open(component, { size: 'lg', backdrop: 'static' });
        modalRef.componentInstance.reportDefinition = reportConfigDefinition;
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
