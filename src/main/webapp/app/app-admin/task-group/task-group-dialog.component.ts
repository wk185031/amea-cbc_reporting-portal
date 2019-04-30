import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { TaskGroup } from './task-group.model';
import { TaskGroupPopupService } from './task-group-popup.service';
import { TaskGroupService } from './task-group.service';
import { Principal } from '../../shared';
import { DatePipe } from '@angular/common';
import { Job, JobService } from '../job';

@Component({
    selector: 'jhi-task-group-dialog',
    templateUrl: './task-group-dialog.component.html'
})
export class TaskGroupDialogComponent implements OnInit {

    taskGroup: TaskGroup;
    isSaving: boolean;
    currentAccount: any;
    statusList: string[];

    jobs: Job[];

    constructor(
        public activeModal: NgbActiveModal,
        private jhiAlertService: JhiAlertService,
        private taskGroupService: TaskGroupService,
        private jobService: JobService,
        private eventManager: JhiEventManager,
        private datePipe: DatePipe,
        private principal: Principal
    ) {
        
    }

    ngOnInit() {
        this.isSaving = false;
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.jobService.query()
            .subscribe((res: HttpResponse<Job[]>) => { this.jobs = res.body; }, (res: HttpErrorResponse) => this.onError(res.message));
        this.statusList = ['ACTIVE', 'INACTIVE'];
        if (!this.taskGroup.status) {
            this.taskGroup.status = 'ACTIVE';
        }
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        this.isSaving = true;
        if (this.taskGroup.id !== undefined) {
            this.subscribeToSaveResponse(
                this.taskGroupService.update(this.taskGroup));
        } else {
            this.taskGroup.createdBy = this.currentAccount.login;
            this.taskGroup.createdDate = this.datePipe.transform(new Date(), 'yyyy-MM-ddTHH:mm:ss');
            this.subscribeToSaveResponse(
                this.taskGroupService.create(this.taskGroup));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<TaskGroup>>) {
        result.subscribe((res: HttpResponse<TaskGroup>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: TaskGroup) {
        this.eventManager.broadcast({ name: 'taskGroupListModification', content: 'OK'});
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }
}

@Component({
    selector: 'jhi-task-group-popup',
    template: ''
})
export class TaskGroupPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private taskGroupPopupService: TaskGroupPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.taskGroupPopupService
                    .open(TaskGroupDialogComponent as Component, params['id']);
            } else {
                this.taskGroupPopupService
                    .open(TaskGroupDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
