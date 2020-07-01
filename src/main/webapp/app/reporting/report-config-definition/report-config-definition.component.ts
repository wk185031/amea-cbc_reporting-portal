import { Component, OnInit } from '@angular/core';

import { ReportConfigDefinitionService } from './report-config-definition.service';
import { Subscription } from 'rxjs';
import { ReportDefinition } from './report-config-definition.model';
import { JhiAlertService, JhiEventManager } from 'ng-jhipster';
import { Principal } from '../../shared';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';
import { TreeModule } from 'angular-tree-component';

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
    nodes: TreeModule;
    filterBranch: boolean;
    branchId: number;

    constructor(
        private reportConfigDefinitionService: ReportConfigDefinitionService,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private eventManager: JhiEventManager
    ) {
    }

    loadAll() {
        this.reportConfigDefinitionService.findReportDefinitionStructures(this.branchId).subscribe(
            (response: HttpResponse<any>) => {
                this.nodes = response.body;
            },
            (response: HttpErrorResponse) => this.onError(response.message));
    }

    ngOnInit() {
        this.mode = 'view';
        this.branchId = this.principal.getSelectedBranchId();
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
        let index = 0;
        while (this.nodes[index]) {
            if (this.nodes[index].children) {
                let indexChildren = 0;
                while (this.nodes[index].children[indexChildren]) {
                    if (this.nodes[index].children[indexChildren].id === id) {
                        this.reportDefinitionId = this.nodes[index].children[indexChildren].actualId;
                        return;
                    }
                    indexChildren++;
                }
            }
            index++;
        }
        this.reportDefinitionId = null;
    }

    private onError(error) {
        this.jhiAlertService.error(error.message, null, null);
    }

    filterByBranch(event) {
        this.filterBranch = event.target.checked;
        if (this.filterBranch) {
            console.log("FILTERRRRRRRR");
        } else {
            console.log("NO FILTERRRRRRRRRRR");
        }
    }
}
