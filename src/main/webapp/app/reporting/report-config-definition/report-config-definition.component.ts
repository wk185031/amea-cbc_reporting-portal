import { Component, OnInit } from '@angular/core';

import { ReportConfigDefinitionService } from './report-config-definition.service';
import { Subscription } from 'rxjs';
import { ReportDefinition } from './report-config-definition.model';
import { JhiAlertService, JhiEventManager } from 'ng-jhipster';
import { Principal } from '../../shared';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

@Component({
    selector: 'report-config-definition',
    templateUrl: './report-config-definition.component.html'
})
export class ReportConfigDefinitionComponent implements OnInit {
    currentAccount: any;
    eventSubscriber: Subscription;
    deleteEventSubscriber: Subscription;
    reportDefinition: ReportDefinition[];
    reportDefinitionId: number;
    mode: string;

    constructor(
        private reportConfigDefinitionService: ReportConfigDefinitionService,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private eventManager: JhiEventManager
    ) {
    }

    loadAll() {
        this.reportConfigDefinitionService.query().subscribe((response: HttpResponse<ReportDefinition[]>) => {
            this.reportDefinition = response.body;
        }, (response: HttpErrorResponse) => this.onError(response.message));
    }

    ngOnInit() {
        this.mode = 'view';
        this.loadAll();
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.registerChangeInReportDefinition();
    }

    ngOnDestroy() {
        if (this.eventManager && this.eventSubscriber) {
            this.eventManager.destroy(this.eventSubscriber);
        }
    }

    trackId(index: number, item: ReportDefinition) {
        return item.id;
    }

    registerChangeInReportDefinition() {
        this.eventSubscriber = this.eventManager.subscribe('reportConfigDefinitionListModification', (response) => this.loadAll());
        this.deleteEventSubscriber = this.eventManager.subscribe('reportConfigDefinitionTreeStructureDelete', (response) => this.loadAll());
    }

    onNotify(id: number): void {
        this.reportDefinitionId = id;
    }

    private onError(error) {
        this.jhiAlertService.error(error.message, null, null);
    }

    onClick(id: number) {
        this.reportDefinitionId = id;
    }
}
