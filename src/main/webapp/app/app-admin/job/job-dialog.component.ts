import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal, NgbTimeStruct } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { Job } from './job.model';
import { JobPopupService } from './job-popup.service';
import { JobService } from './job.service';
import { DatePipe } from '@angular/common';
import { Principal } from '../../shared';

@Component({
    selector: 'jhi-job-dialog',
    templateUrl: './job-dialog.component.html'
})
export class JobDialogComponent implements OnInit {

    job: Job;
    isSaving: boolean;
    statusList: string[];
    currentAccount: any;
    newTime: Date;
    time: NgbTimeStruct;

    constructor(
        public activeModal: NgbActiveModal,
        private jhiAlertService: JhiAlertService,
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
        this.statusList = ['ACTIVE', 'INACTIVE'];
        if (!this.job.status) {
            this.job.status = 'ACTIVE';
        }
        if (!this.job.scheduleTime) {
            this.job.scheduleTime = new Date();
            this.newTime = this.job.scheduleTime;
        } else {
            this.newTime = this.job.scheduleTime;
            this.time = {hour: this.newTime.getHours(), minute: this.newTime.getMinutes(), second: this.newTime.getSeconds()};
        }
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        this.newTime.setHours(this.time.hour, this.time.minute, this.time.second);
        this.job.scheduleTime = this.datePipe.transform(this.newTime, 'yyyy-MM-ddTHH:mm:ss');
        this.isSaving = true;
        if (this.job.id !== undefined) {
            this.subscribeToSaveResponse(
                this.jobService.update(this.job));
        } else {
            this.job.createdBy = this.currentAccount.login;
            this.job.createdDate = this.datePipe.transform(new Date(), 'yyyy-MM-ddTHH:mm:ss');
            this.subscribeToSaveResponse(
                this.jobService.create(this.job));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<Job>>) {
        result.subscribe((res: HttpResponse<Job>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: Job) {
        this.eventManager.broadcast({ name: 'jobListModification', content: 'OK'});
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
    selector: 'jhi-job-popup',
    template: ''
})
export class JobPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private jobPopupService: JobPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.jobPopupService
                    .open(JobDialogComponent as Component, params['id']);
            } else {
                this.jobPopupService
                    .open(JobDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
