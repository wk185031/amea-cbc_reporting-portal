import { Component, OnInit, OnDestroy, Input, OnChanges } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager } from 'ng-jhipster';
import { ReportCategory } from './report-config-category.model';
import { ReportConfigCategoryService } from './report-config-category.service';

@Component({
    selector: 'report-config-category-detail',
    templateUrl: './report-config-category-detail.component.html'
})
export class ReportConfigCategoryDetailComponent implements OnInit, OnDestroy, OnChanges {

    @Input() reportCategoryId: number;
    reportCategory: ReportCategory;
    private subscription: Subscription;
    private eventSubscriber: Subscription;

    constructor(
        private eventManager: JhiEventManager,
        private reportConfigCategoryService: ReportConfigCategoryService,
        private route: ActivatedRoute
    ) {
        this.registerChangeInReportCategory();
    }

    ngOnInit() {
        this.subscription = this.route.params.subscribe((params) => {
            this.load(params['id']);
        });
    }

    ngOnChanges() {
        if (this.reportCategoryId) {
            this.load(this.reportCategoryId);
        }
    }

    load(id) {
        if (id) {
            this.reportConfigCategoryService.find(id).subscribe((reportCategoryResponse: HttpResponse<ReportCategory>) => {
                this.reportCategory = reportCategoryResponse.body;
            });
        }
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

    registerChangeInReportCategory() {
        this.eventSubscriber = this.eventManager.subscribe(
            'reportConfigCategoryListModification',
            (response) => {
                if (response.content === 'Deleted a report category') {
                    this.reportCategoryId = null;
                    this.reportCategory = null;
                }
                this.load(this.reportCategoryId);
            });
    }
}
