import { Injectable, Component } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModal, NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { HttpResponse } from '@angular/common/http';
import { DatePipe } from '@angular/common';
import { TaskGroup } from './task-group.model';
import { TaskGroupService } from './task-group.service';

@Injectable()
export class TaskGroupPopupService {
    private ngbModalRef: NgbModalRef;

    constructor(
        private datePipe: DatePipe,
        private modalService: NgbModal,
        private router: Router,
        private taskGroupService: TaskGroupService

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
                this.taskGroupService.find(id)
                    .subscribe((taskGroupResponse: HttpResponse<TaskGroup>) => {
                        const taskGroup: TaskGroup = taskGroupResponse.body;
                        taskGroup.createdDate = this.datePipe
                            .transform(taskGroup.createdDate, 'yyyy-MM-ddTHH:mm:ss');
                        this.ngbModalRef = this.taskGroupModalRef(component, taskGroup);
                        resolve(this.ngbModalRef);
                    });
            } else {
                // setTimeout used as a workaround for getting ExpressionChangedAfterItHasBeenCheckedError
                setTimeout(() => {
                    this.ngbModalRef = this.taskGroupModalRef(component, new TaskGroup());
                    resolve(this.ngbModalRef);
                }, 0);
            }
        });
    }

    taskGroupModalRef(component: Component, taskGroup: TaskGroup): NgbModalRef {
        const modalRef = this.modalService.open(component, { size: 'lg', backdrop: 'static'});
        modalRef.componentInstance.taskGroup = taskGroup;
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
