import { Component, OnInit, OnDestroy } from '@angular/core';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { Principal } from '../../shared';
import { ReportCategory } from './report-config-category.model';
import { ReportConfigCategoryService } from './report-config-category.service';

@Component({
    selector: 'report-config-category',
    templateUrl: './report-config-category.component.html'
})
export class ReportConfigCategoryComponent implements OnInit, OnDestroy {

    currentAccount: any;
    eventSubscriber: Subscription;
    deleteEventSubscriber: Subscription;
    reportCategory: ReportCategory[];
    reportCategoryId: number;
    mode: string;
    showCheckedBox = false;

    constructor(
        private reportConfigCategoryService: ReportConfigCategoryService,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private eventManager: JhiEventManager
    ) {
    }

    loadAll() {
        this.reportConfigCategoryService.queryNoPaging().subscribe((response: HttpResponse<ReportCategory[]>) => {
            this.reportCategory = response.body;
        }, (response: HttpErrorResponse) => this.onError(response.message));
    }

    ngOnInit() {
        this.mode = 'view';
        this.loadAll();
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.registerChangeInReportCategory();
    }

    ngOnDestroy() {
        if (this.eventManager && this.eventSubscriber) {
            this.eventManager.destroy(this.eventSubscriber);
        }
    }

    trackId(index: number, item: ReportCategory) {
        return item.id;
    }

    registerChangeInReportCategory() {
        this.eventSubscriber = this.eventManager.subscribe('reportConfigCategoryListModification', (response) => this.loadAll());
        this.deleteEventSubscriber = this.eventManager.subscribe('reportConfigCategoryTreeStructureDelete', (response) => this.loadAll());
    }

    onNotify(id: number): void {
        this.reportCategoryId = id;
    }

    private onError(error) {
        this.jhiAlertService.error(error.message, null, null);
    }

    onClick(id: number) {
        this.reportCategoryId = id;
    }
}
