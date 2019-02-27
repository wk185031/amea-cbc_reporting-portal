import { Component, OnInit, OnDestroy } from '@angular/core';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';
import { ActivatedRoute } from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { AttachmentGroup } from './attachment-group.model';
import { AttachmentGroupService } from './attachment-group.service';
import { Principal } from '../../shared';

@Component({
    selector: 'jhi-attachment-group',
    templateUrl: './attachment-group.component.html'
})
export class AttachmentGroupComponent implements OnInit, OnDestroy {
attachmentGroups: AttachmentGroup[];
    currentAccount: any;
    eventSubscriber: Subscription;
    currentSearch: string;

    constructor(
        private attachmentGroupService: AttachmentGroupService,
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
            this.attachmentGroupService.search({
                query: this.currentSearch,
                }).subscribe(
                    (res: HttpResponse<AttachmentGroup[]>) => this.attachmentGroups = res.body,
                    (res: HttpErrorResponse) => this.onError(res.message)
                );
            return;
       }
        this.attachmentGroupService.query().subscribe(
            (res: HttpResponse<AttachmentGroup[]>) => {
                this.attachmentGroups = res.body;
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
        this.registerChangeInAttachmentGroups();
    }

    ngOnDestroy() {
        this.eventManager.destroy(this.eventSubscriber);
    }

    trackId(index: number, item: AttachmentGroup) {
        return item.id;
    }
    registerChangeInAttachmentGroups() {
        this.eventSubscriber = this.eventManager.subscribe('attachmentGroupListModification', (response) => this.loadAll());
    }

    private onError(error) {
        this.jhiAlertService.error(error.message, null, null);
    }
}
