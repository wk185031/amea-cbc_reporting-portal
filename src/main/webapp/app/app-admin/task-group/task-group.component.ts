import { Component, OnInit, OnDestroy } from '@angular/core';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';
import { ActivatedRoute } from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { TaskGroup } from './task-group.model';
import { TaskGroupService } from './task-group.service';
import { Principal } from '../../shared';

@Component({
    selector: 'jhi-task-group',
    templateUrl: './task-group.component.html'
})
export class TaskGroupComponent implements OnInit, OnDestroy {
    taskGroups: TaskGroup[];
    currentAccount: any;
    eventSubscriber: Subscription;
    currentSearch: string;

    constructor(
        private taskGroupService: TaskGroupService,
        private jhiAlertService: JhiAlertService,
        private eventManager: JhiEventManager,
        private activatedRoute: ActivatedRoute,
        private principal: Principal
    ) {
        this.currentSearch = this.activatedRoute.snapshot && this.activatedRoute.snapshot.params['search'] ?
            this.activatedRoute.snapshot.params['search'] : '';
    }

    loadAll() {
        if (this.currentSearch) {
            this.taskGroupService.search({
                query: this.currentSearch,
                }).subscribe(
                    (res: HttpResponse<TaskGroup[]>) => this.taskGroups = res.body,
                    (res: HttpErrorResponse) => this.onError(res.message)
                );
            return;
       }
        this.taskGroupService.query().subscribe(
            (res: HttpResponse<TaskGroup[]>) => {
                this.taskGroups = res.body;
                this.currentSearch = '';
            },
            (res: HttpErrorResponse) => this.onError(res.message)
        );
    }

    search(query) {
        if (!query) {
            return this.clear();
        }
        this.currentSearch = query;
        this.loadAll();
    }

    clear() {
        this.currentSearch = '';
        this.loadAll();
    }
    ngOnInit() {
        this.loadAll();
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.registerChangeInTaskGroups();
    }

    ngOnDestroy() {
        this.eventManager.destroy(this.eventSubscriber);
    }

    trackId(index: number, item: TaskGroup) {
        return item.id;
    }
    registerChangeInTaskGroups() {
        this.eventSubscriber = this.eventManager.subscribe('taskGroupListModification', (response) => this.loadAll());
    }

    private onError(error) {
        this.jhiAlertService.error(error.message, null, null);
    }
}
