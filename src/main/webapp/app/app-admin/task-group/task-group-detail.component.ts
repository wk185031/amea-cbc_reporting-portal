import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager } from 'ng-jhipster';

import { TaskGroup } from './task-group.model';
import { TaskGroupService } from './task-group.service';

@Component({
    selector: 'jhi-task-group-detail',
    templateUrl: './task-group-detail.component.html'
})
export class TaskGroupDetailComponent implements OnInit, OnDestroy {

    taskGroup: TaskGroup;
    private subscription: Subscription;
    private eventSubscriber: Subscription;

    constructor(
        private eventManager: JhiEventManager,
        private taskGroupService: TaskGroupService,
        private route: ActivatedRoute
    ) {
    }

    ngOnInit() {
        this.subscription = this.route.params.subscribe((params) => {
            this.load(params['id']);
        });
        this.registerChangeInTaskGroups();
    }

    load(id) {
        this.taskGroupService.find(id)
            .subscribe((taskGroupResponse: HttpResponse<TaskGroup>) => {
                this.taskGroup = taskGroupResponse.body;
            });
    }
    previousState() {
        window.history.back();
    }

    ngOnDestroy() {
        this.subscription.unsubscribe();
        this.eventManager.destroy(this.eventSubscriber);
    }

    registerChangeInTaskGroups() {
        this.eventSubscriber = this.eventManager.subscribe(
            'taskGroupListModification',
            (response) => this.load(this.taskGroup.id)
        );
    }
}
