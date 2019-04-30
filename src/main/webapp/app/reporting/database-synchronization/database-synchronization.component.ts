import { Component, OnInit, ViewChild } from '@angular/core';

import { DatabaseSynchronizationService } from './database-synchronization.service';
// import { ReportCategory } from '../report-config-category/report-config-category.model';
// import { ReportDefinition } from '../report-config-definition/report-config-definition.model';
import { Subscription, Observable } from 'rxjs';
import { JhiAlertService, JhiEventManager } from 'ng-jhipster';
import { Principal } from '../../shared';
// import { ReportConfigCategoryService } from '../report-config-category/report-config-category.service';
// import { ReportConfigDefinitionService } from '../report-config-definition/report-config-definition.service';
import { HttpErrorResponse, HttpResponse, HttpEvent, HttpClient } from '@angular/common/http';
import { NgbTimeStruct } from '@ng-bootstrap/ng-bootstrap/timepicker/timepicker.module';
import { Job, JobService } from '../../app-admin/job';
import { DatePipe } from '@angular/common';
import { NgbPopover } from '@ng-bootstrap/ng-bootstrap';

@Component({
    selector: 'database-synchronization',
    templateUrl: './database-synchronization.component.html'
})
export class DatabaseSynchronizationComponent implements OnInit {

    @ViewChild('p') p: NgbPopover;
    currentAccount: any;
    eventSubscriber: Subscription;
    deleteEventSubscriber: Subscription;
    fromDateString: String;
    toDateString: String;
    time: NgbTimeStruct;
    readonlyInputs: boolean;
    spinners: boolean;
    newTime: Date;
    job: Job;
    
    constructor(
        private databaseSynchronizationService: DatabaseSynchronizationService,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private eventManager: JhiEventManager,
        private http: HttpClient,
        private jobService: JobService,
        private datePipe: DatePipe,
    ) {
    }

    loadJob() {
        this.jobService.query({
            name: "DB_SYNC"
        }).subscribe((res: HttpResponse<Job[]>) => { 
            this.job = res.body[0]; 
            this.loadScheduleTime();
        }, (res: HttpErrorResponse) => this.onError(res.message));
    }

    loadScheduleTime() {
        if (!this.job) {
            this.time = {hour: 0, minute: 30, second: 0};
        } else {
            this.newTime = this.job.scheduleTime;
            this.time = {hour: this.newTime.getHours(), minute: this.newTime.getMinutes(), second: this.newTime.getSeconds()};
        }

    }

    ngOnInit() {
        this.loadJob();
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.readonlyInputs = true;
        this.spinners = false;
    }

    editScheduler() {
        if (this.p.isOpen()) {
            this.p.close();
        } else {
            this.p.open();
        }
    }

    saveSchedulerChanges() {
        this.newTime.setHours(this.time.hour, this.time.minute, this.time.second);
        this.job.scheduleTime = this.datePipe.transform(this.newTime, 'yyyy-MM-ddTHH:mm:ss');
        this.job.createdDate = this.datePipe.transform(this.job.createdDate, 'yyyy-MM-ddTHH:mm:ss');
        this.subscribeToSaveResponse(this.jobService.update(this.job));
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<Job>>) {
        result.subscribe((res: HttpResponse<Job>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: Job) {
        this.eventManager.broadcast({ name: 'jobListModification', content: 'OK'});
        this.p.close();
    }

    private onSaveError() {
    }
    
    ngOnDestroy() {
        if (this.eventManager && this.eventSubscriber) {
            this.eventManager.destroy(this.eventSubscriber);
        }
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    formatDateString(date) {
        const dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
        const MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
        const yyyy = date.getFullYear();
        return (yyyy + '-' + MM + '-' + dd);
    }

    syncDatabase() {
        const req = this.databaseSynchronizationService.syncDatabase(this.currentAccount.login);
        this.http.request(req).subscribe((res: HttpResponse<any>) => console.log(res));
    }
}
