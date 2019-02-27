import { Injectable, Component } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { HttpResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { SystemConfiguration } from './system-configuration.model';
import { SystemConfigurationService } from './system-configuration.service';

@Injectable()
export class SystemConfigurationPopupService {
    private ngbModalRef: NgbModalRef;

    constructor(
        private datePipe: DatePipe,
        private modalService: NgbModal,
        private router: Router,
        private systemConfigurationService: SystemConfigurationService

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
                this.systemConfigurationService.find(id)
                    .subscribe((systemConfigurationResponse: HttpResponse<SystemConfiguration>) => {
                        const systemConfiguration: SystemConfiguration = systemConfigurationResponse.body;
                        systemConfiguration.createdDate = this.datePipe
                            .transform(systemConfiguration.createdDate, 'yyyy-MM-ddTHH:mm:ss');
                        systemConfiguration.lastModifiedDate = this.datePipe
                            .transform(systemConfiguration.lastModifiedDate, 'yyyy-MM-ddTHH:mm:ss');
                        this.ngbModalRef = this.systemConfigurationModalRef(component, systemConfiguration);
                        resolve(this.ngbModalRef);
                    });
            } else {
                // setTimeout used as a workaround for getting ExpressionChangedAfterItHasBeenCheckedError
                setTimeout(() => {
                    this.ngbModalRef = this.systemConfigurationModalRef(component, new SystemConfiguration());
                    resolve(this.ngbModalRef);
                }, 0);
            }
        });
    }

    systemConfigurationModalRef(component: Component, systemConfiguration: SystemConfiguration): NgbModalRef {
        const modalRef = this.modalService.open(component, { size: 'lg', backdrop: 'static'});
        modalRef.componentInstance.systemConfiguration = systemConfiguration;
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
