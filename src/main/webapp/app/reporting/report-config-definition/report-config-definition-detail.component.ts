import { Component, OnInit, OnDestroy, Input, OnChanges } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';
import { ReportDefinition } from './report-config-definition.model';
import { ReportConfigDefinitionService } from './report-config-definition.service';

@Component({
    selector: 'report-config-definition-detail',
    templateUrl: './report-config-definition-detail.component.html'
})
export class ReportConfigDefinitionDetailComponent implements OnInit, OnDestroy, OnChanges {

    private subscription: Subscription;
    private eventSubscriber: Subscription;
    reportDefinition: ReportDefinition;
    reportDefinitionId: number;
    tabValue: string;

    constructor(
        private eventManager: JhiEventManager,
        private reportConfigDefinitionService: ReportConfigDefinitionService,
        private jhiAlertService: JhiAlertService,
        private route: ActivatedRoute
    ) {
    }

    ngOnInit() {
        this.registerChangeInReportDefinition();
        this.tabValue = 'content1';
        this.subscription = this.route.params.subscribe((params) => {
            this.load(params['id']);
            this.reportDefinitionId = params['id'];
        });
    }

    ngOnChanges() {
        if (this.reportDefinitionId) {
            this.load(this.reportDefinitionId);
        }
    }

    load(id) {
        if (id) {
            this.reportConfigDefinitionService.find(id).subscribe((reportDefinition: HttpResponse<ReportDefinition>) => {
                this.reportDefinition = reportDefinition.body;
                this.reportDefinition.headerSection = JSON.parse(this.reportDefinition.headerFields);
                this.reportDefinition.bodySection = JSON.parse(this.reportDefinition.bodyFields);
                this.reportDefinition.trailerSection = JSON.parse(this.reportDefinition.trailerFields);
            }, (error: HttpErrorResponse) => this.onError(error.message));
        }
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    previousState() {
        window.history.back();
    }

    ngOnDestroy() {
        if (this.subscription) {
            this.subscription.unsubscribe();
        }
        if (this.eventManager && this.eventSubscriber) {
            this.eventManager.destroy(this.eventSubscriber);
        }
    }

    registerChangeInReportDefinition() {
        this.eventSubscriber = this.eventManager.subscribe(
            'reportConfigDefinitionListModification',
            (response) => {
                if (response.content === 'Deleted a report definition') {
                    this.reportDefinitionId = null;
                    this.reportDefinition = null;
                }
                this.load(this.reportDefinitionId);
            });
    }
}
