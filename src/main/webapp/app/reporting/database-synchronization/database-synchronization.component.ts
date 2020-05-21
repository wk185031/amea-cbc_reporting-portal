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
import { JobHistoryService } from '../../app-admin/job-history';
import { JobHistory } from '../../app-admin/job-history/job-history.model';
import { NgxUiLoaderService } from 'ngx-ui-loader';

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
    jobHistory: JobHistory;
    jobHistories: JobHistory[];
    tableSync: string[];
    tablesMap: Map<string, boolean>;
    tablesArr: string[];

    constructor(
        private databaseSynchronizationService: DatabaseSynchronizationService,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private eventManager: JhiEventManager,
        private http: HttpClient,
        private jobService: JobService,
        private datePipe: DatePipe,
        private jobHistoryService: JobHistoryService,
        private ngxLoader: NgxUiLoaderService
    ) {
    }

    loadJob() {
        this.jobService.query({
            name: "DB_SYNC"
        }).subscribe((res: HttpResponse<Job[]>) => {
            this.job = res.body[0];
            this.loadTableSync();
        }, (res: HttpErrorResponse) => this.onError(res.message));
    }

    loadTableSync() {
        if (this.job.tableSync != null) {
            this.tableSync = this.job.tableSync.split(',');
            this.tablesArr.forEach(table => {
                if (this.tableSync.indexOf(table) > -1) {
                    this.tablesMap.set(table, true);
                } else {
                    this.tablesMap.set(table, false);
                }
            });
        } else {
            this.tablesArr.forEach(table => {
                this.tablesMap.set(table, false);
            });
        }
        this.loadScheduleTime();
    }

    loadScheduleTime() {
        if (!this.job) {
            this.time = {hour: 0, minute: 30, second: 0};
        } else {
            this.newTime = this.job.scheduleTime;
            this.time = {hour: this.newTime.getHours(), minute: this.newTime.getMinutes(), second: this.newTime.getSeconds()};
        }
        this.getPreviousSyncTime();
        this.periodicSyncTimeCheck();
    }

    checkSelectedTableSync(table) {
        return this.tablesMap.get(table);
    }

    setTableSync(event) {
        this.tablesMap.set(event.target.value, event.target.checked);
    }

    saveTableSyncChanges() {
        let tablesString: string = null;
        let count: number = 0;
        this.tablesMap.forEach((value: boolean, key: string) => {
            if (value) {
                if (count == 0) {
                    tablesString = key;
                } else {
                    tablesString = tablesString + ',' + key;
                }
                count++;
            }
        });

        this.job.scheduleTime = this.datePipe.transform(this.job.scheduleTime, 'yyyy-MM-ddTHH:mm:ss');
        this.job.createdDate = this.datePipe.transform(this.job.createdDate, 'yyyy-MM-ddTHH:mm:ss');
        this.job.tableSync = tablesString;
        this.subscribeToSaveResponse(this.jobService.update(this.job));
    }

    ngOnInit() {
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.readonlyInputs = true;
        this.spinners = false;
        this.tablesMap = new Map<string, boolean>();
        this.databaseSynchronizationService.getTableName().subscribe((res: HttpResponse<string[]>) => {
            this.tablesArr = res.body;
            this.loadJob();
        }, (res: HttpErrorResponse) => this.onError(res.message));;
    }

    editScheduler() {
        if (this.p.isOpen()) {
            this.p.close();
        } else {
            this.p.open();
        }
    }

    periodicSyncTimeCheck() {
        setInterval(() => {
            this.getPreviousSyncTime();
        }, 1000 * 60 * 5);
    }

    getPreviousSyncTime() {
        let query = "status: COMPLETED && job.id: " + this.job.id;
        this.jobHistoryService.search({
            query: query,
        }).subscribe((res: HttpResponse<JobHistory[]>) => {
            this.jobHistories = res.body.sort((a,b) => {
                return (a.createdDate < b.createdDate) ? 1 : -1;
            });
            this.jobHistory = this.jobHistories[0];
            console.log("Jobhistory id: " + this.jobHistory.id);
            console.log("Jobhistory createdDate: " + this.jobHistory.createdDate);


        }, (res: HttpErrorResponse) => this.onError(res.message));
    }

    saveSchedulerChanges() {
        this.ngxLoader.start();
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
        this.ngxLoader.stop();
        this.eventManager.broadcast({ name: 'jobListModification', content: 'OK'});
        if (this.p.isOpen()) {
            this.p.close();
        }
    }

    private onSaveError() {
        this.ngxLoader.stop();
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
        this.ngxLoader.start();
        const req = this.databaseSynchronizationService.syncDatabase(this.currentAccount.login);
        this.http.request(req).subscribe((res: HttpResponse<any>) => {
            this.ngxLoader.stop();
            this.getPreviousSyncTime();
        });
    }
}
