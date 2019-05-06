import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';

import { TaskGroup } from './task-group.model';
import { TaskGroupPopupService } from './task-group-popup.service';
import { TaskGroupService } from './task-group.service';

@Component({
    selector: 'jhi-task-group-delete-dialog',
    templateUrl: './task-group-delete-dialog.component.html'
})
export class TaskGroupDeleteDialogComponent {

    taskGroup: TaskGroup;

    constructor(
        private taskGroupService: TaskGroupService,
        public activeModal: NgbActiveModal,
        private eventManager: JhiEventManager
    ) {
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    confirmDelete(id: number) {
        this.taskGroupService.delete(id).subscribe((response) => {
            this.eventManager.broadcast({
                name: 'taskGroupListModification',
                content: 'Deleted an taskGroup'
            });
            this.activeModal.dismiss(true);
        });
    }
}

@Component({
    selector: 'jhi-task-group-delete-popup',
    template: ''
})
export class TaskGroupDeletePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private taskGroupPopupService: TaskGroupPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            this.taskGroupPopupService
                .open(TaskGroupDeleteDialogComponent as Component, params['id']);
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
