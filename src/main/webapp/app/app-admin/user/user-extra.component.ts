import { Component, OnInit, OnDestroy } from '@angular/core';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';
import { ActivatedRoute, Router } from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager, JhiParseLinks, JhiAlertService } from 'ng-jhipster';

import { UserExtra } from '../../entities/user-extra/user-extra.model';
import { UserExtraService } from './user-extra.service';
import { ITEMS_PER_PAGE, Principal } from '../../shared';
import { GenerateReportService } from '../../reporting/generate-report/generate-report.service';

@Component({
    selector: 'jhi-user-extra',
    templateUrl: './user-extra.component.html'
})
export class UserExtraComponent implements OnInit, OnDestroy {

currentAccount: any;
    userExtras: UserExtra[];
    error: any;
    success: any;
    eventSubscriber: Subscription;
    currentSearch: string;
    routeData: any;
    links: any;
    totalItems: any;
    queryCount: any;
    itemsPerPage: any;
    page: any;
    predicate: any;
    previousPage: any;
    reverse: any;

    constructor(
        private userExtraService: UserExtraService,
        private parseLinks: JhiParseLinks,
        private jhiAlertService: JhiAlertService,
        private principal: Principal,
        private activatedRoute: ActivatedRoute,
        private router: Router,
        private eventManager: JhiEventManager,
        private generateReportService: GenerateReportService
    ) {
        this.itemsPerPage = ITEMS_PER_PAGE;
        this.routeData = this.activatedRoute.data.subscribe((data) => {
            this.page = data.pagingParams.page;
            this.previousPage = data.pagingParams.page;
            this.reverse = data.pagingParams.ascending;
            this.predicate = data.pagingParams.predicate;
        });
        this.currentSearch = this.activatedRoute.snapshot && this.activatedRoute.snapshot.params['search'] ?
            this.activatedRoute.snapshot.params['search'] : '';
    }

    loadAll() {
        if (this.currentSearch) {
            this.userExtraService.search({
                page: this.page - 1,
                query: this.currentSearch,
                size: this.itemsPerPage,
                sort: this.sort()}).subscribe(
                    (res: HttpResponse<UserExtra[]>) => this.onSuccess(res.body, res.headers),
                    (res: HttpErrorResponse) => this.onError(res.message)
                );
            return;
        }
        this.userExtraService.fillAllUserExtrasWithPagination({
            page: this.page - 1,
            size: this.itemsPerPage,
            sort: this.sort()}).subscribe(
                (res: HttpResponse<UserExtra[]>) => this.onSuccess(res.body, res.headers),
                (res: HttpErrorResponse) => this.onError(res.message)
        );
    }
    loadPage(page: number) {
        if (page !== this.previousPage) {
            this.previousPage = page;
            this.transition();
        }
    }
    transition() {
        this.router.navigate(['/app-admin-user'], {queryParams:
            {
                page: this.page,
                size: this.itemsPerPage,
                search: this.currentSearch,
                sort: this.predicate + ',' + (this.reverse ? 'asc' : 'desc')
            }
        });
        this.loadAll();
    }

    clear() {
        this.page = 0;
        this.currentSearch = '';
        this.router.navigate(['/app-admin-user', {
            page: this.page,
            sort: this.predicate + ',' + (this.reverse ? 'asc' : 'desc')
        }]);
        this.loadAll();
    }
    search(query) {
        if (!query) {
            return this.clear();
        }
        this.page = 0;
        this.currentSearch = query;
        this.router.navigate(['/app-admin-user', {
            search: this.currentSearch,
            page: this.page,
            sort: this.predicate + ',' + (this.reverse ? 'asc' : 'desc')
        }]);
        this.loadAll();
    }
    ngOnInit() {
        this.loadAll();
        this.principal.identity().then((account) => {
            this.currentAccount = account;
        });
        this.registerChangeInUserExtras();
    }

    ngOnDestroy() {
        this.eventManager.destroy(this.eventSubscriber);
    }

    trackId(index: number, item: UserExtra) {
        return item.id;
    }
    registerChangeInUserExtras() {
        this.eventSubscriber = this.eventManager.subscribe('userExtraListModification', (response) => this.loadAll());
    }

    sort() {
        const result = [this.predicate + ',' + (this.reverse ? 'asc' : 'desc')];
        if (this.predicate !== 'id') {
            result.push('id');
        }
        return result;
    }

    private onSuccess(data, headers) {
        this.links = this.parseLinks.parse(headers.get('link'));
        this.totalItems = headers.get('X-Total-Count');
        this.queryCount = this.totalItems;
        // this.page = pagingParams.page;
        this.userExtras = data;
    }
    private onError(error) {
        this.jhiAlertService.error(error.message, null, null);
    }
    
     export(reportCategory: string, reportName:string) {
    	console.log('Export method in ts');
    	
    	
    	this.generateReportService.exportReport(reportCategory, reportName, "", "").subscribe(resp => {
    		const a: any = document.createElement('a');
    		const contentDisposition = resp.headers.get('content-disposition');
    		const filename = contentDisposition.split(';')[1].split('filename')[1].split('=')[1].trim().replace(/(^"|"$)/g, '');
    		console.log('download file: ' + filename);
    		a.href = window.URL.createObjectURL(resp.body);
    		a.target = '_blank';
    		a.download = filename;
            document.body.appendChild(a);
            
            a.click();
    	}, error => {
    		
    		this.jhiAlertService.error('error.report.exportFailed', null, null);
    	});
    	
    }
}
