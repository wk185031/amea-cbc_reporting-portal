import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager } from 'ng-jhipster';

import { AttachmentGroup } from './attachment-group.model';
import { AttachmentGroupService } from './attachment-group.service';

@Component({
    selector: 'jhi-attachment-group-detail',
    templateUrl: './attachment-group-detail.component.html'
})
export class AttachmentGroupDetailComponent implements OnInit, OnDestroy {

    attachmentGroup: AttachmentGroup;
    private subscription: Subscription;
    private eventSubscriber: Subscription;

    constructor(
        private eventManager: JhiEventManager,
        private attachmentGroupService: AttachmentGroupService,
        private route: ActivatedRoute
    ) {
    }

    ngOnInit() {
        this.subscription = this.route.params.subscribe((params) => {
            this.load(params['id']);
        });
        this.registerChangeInAttachmentGroups();
    }

    load(id) {
        this.attachmentGroupService.find(id)
            .subscribe((attachmentGroupResponse: HttpResponse<AttachmentGroup>) => {
                this.attachmentGroup = attachmentGroupResponse.body;
            });
    }
    previousState() {
        window.history.back();
    }

    ngOnDestroy() {
        this.subscription.unsubscribe();
        this.eventManager.destroy(this.eventSubscriber);
    }

    registerChangeInAttachmentGroups() {
        this.eventSubscriber = this.eventManager.subscribe(
            'attachmentGroupListModification',
            (response) => this.load(this.attachmentGroup.id)
        );
    }
}
