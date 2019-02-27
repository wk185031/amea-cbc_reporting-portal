import { Component, OnInit, OnDestroy } from '@angular/core';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';
import { ActivatedRoute, Router } from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager, JhiParseLinks, JhiLanguageService, JhiAlertService } from 'ng-jhipster';

import { Institution } from '../../entities/institution/institution.model';
import { InstitutionService } from './institution.service';
import { ITEMS_PER_PAGE, Principal } from '../../shared';
import { AppPermissionService } from '../../common/app-permission.service';
import { AppPermissionsConfigurationService } from '../role/app-resource/app-permissions-configuration.service';
import { TreeModule, TreeComponent } from 'angular-tree-component';

@Component({
    selector: 'jhi-institution',
    templateUrl: './institution.component.html'
})
export class InstitutionComponent implements OnInit, OnDestroy {

    currentAccount: any;
    eventSubscriber: Subscription;
    deleteEventSubscriber: Subscription;
    nodes: TreeModule;
    institutionId: number;
    mode: string;
    showCheckedBox = false;
    private subscription: any;

    constructor(
        private institutionService: InstitutionService,
        private jhiLanguageService: JhiLanguageService,
        private parseLinks: JhiParseLinks,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private activatedRoute: ActivatedRoute,
        private router: Router,
        private eventManager: JhiEventManager,
        private appPermissionService: AppPermissionService
    ) {
    }

    loadAll() {
        this.institutionService.findInstitutionStructures().subscribe(
            (response: HttpResponse<any>) => {
                this.nodes = response.body;
            },
            (response: HttpErrorResponse) => this.onError(response.message));
    }

    ngOnInit() {
        this.mode = 'view';
        this.loadAll();
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.registerChangeInInstitutions();
    }

    ngOnDestroy() {
        this.eventManager.destroy(this.eventSubscriber);
    }

    trackId(index: number, item: Institution) {
        return item.id;
    }

    registerChangeInInstitutions() {
        this.eventSubscriber = this.eventManager.subscribe('institutionListModification', (response) => this.loadAll());
        this.deleteEventSubscriber = this.eventManager.subscribe('institutionTreeStructureDelete', (response) => this.loadAll());
    }

    onNotify(id:number):void {
        this.institutionId = id;
    }

    private onError(error) {
        this.jhiAlertService.error(error.message, null, null);
    }
}
