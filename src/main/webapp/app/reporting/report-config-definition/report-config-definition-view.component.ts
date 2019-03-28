import { Component, OnInit, OnDestroy, Input, OnChanges } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';
import { ReportDefinition } from './report-config-definition.model';
import { ReportConfigDefinitionService } from './report-config-definition.service';

@Component({
    selector: 'report-config-definition-view',
    templateUrl: './report-config-definition-view.component.html'
})
export class ReportConfigDefinitionViewComponent implements OnInit, OnDestroy, OnChanges {

    @Input() reportDefinitionId: number;
    private subscription: Subscription;
    private eventSubscriber: Subscription;

    reportDefinition: ReportDefinition;

    constructor(
        private eventManager: JhiEventManager,
        private reportConfigDefinitionService: ReportConfigDefinitionService,
        private jhiAlertService: JhiAlertService,
        private route: ActivatedRoute
    ) {
        this.registerChangeInReportDefinition();
    }

    ngOnInit() {
        this.subscription = this.route.params.subscribe((params) => {
            this.load(params['id']);
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
            }, (error: HttpErrorResponse) => this.onError(error.message));
        }
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
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
