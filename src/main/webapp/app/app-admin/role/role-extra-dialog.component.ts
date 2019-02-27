import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { RoleExtra } from '../../entities/role-extra/role-extra.model';
import { RoleExtraPopupService } from './role-extra-popup.service';
import { RoleExtraService } from './role-extra.service';
import { AppResource } from '../../entities/app-resource';
import { AppResourceService } from './app-resource/app-resource.service';

import { Principal } from '../../shared/auth/principal.service';
import { TreeModule, TreeComponent, TreeNode } from 'angular-tree-component';

@Component({
    selector: 'jhi-role-extra-dialog',
    templateUrl: './role-extra-dialog.component.html'
})
export class RoleExtraDialogComponent implements OnInit {

    roleExtra: RoleExtra;
    isSaving: boolean;

    appresources: AppResource[];
    
    username: string;
    nodes: TreeModule;
    showCheckedBox = true;

    constructor(
        public activeModal: NgbActiveModal,
        private jhiAlertService: JhiAlertService,
        private roleExtraService: RoleExtraService,
        private appResourceService: AppResourceService,
        private eventManager: JhiEventManager,
        private principal: Principal
    ) {
    }

    ngOnInit() {
        this.isSaving = false;
        this.appResourceService.query()
            .subscribe(
                (res: HttpResponse<AppResource[]>) => { 
                    this.appresources = res.body; 
                    
                    let id = (this.roleExtra.id !== undefined) ? this.roleExtra.id: 0;
                    this.appResourceService.findAppResourceTree(id).subscribe(
                        (res: HttpResponse<any[]>) => {
                            this.nodes = res.body;
                        },
                        (res: HttpErrorResponse) => this.onError(res.message)
                    );
                }, 
                (res: HttpErrorResponse) => this.onError(res.message)
            );
            
        this.principal.identity().then((account) => {
            this.username = account.login;
        });
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        this.isSaving = true;
        this.updateRoleExtra();
        if (this.roleExtra.id !== undefined) {
            this.subscribeToSaveResponse(
                this.roleExtraService.update(this.roleExtra));
        } else {
            this.subscribeToSaveResponse(
                this.roleExtraService.create(this.roleExtra));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<RoleExtra>>) {
        result.subscribe((res: HttpResponse<RoleExtra>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: RoleExtra) {
        this.eventManager.broadcast({ name: 'roleExtraListModification', content: 'OK'});
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    trackAppResourceById(index: number, item: AppResource) {
        return item.id;
    }

    updateRoleExtra() {
        let index = 0;
        let updatedPermissions: number[] = [];
        let newPermissions: AppResource[] = [];
        while (this.nodes[index]) {
            if (this.nodes[index].checked) {
                updatedPermissions.push(this.nodes[index].id);
            }
            if (this.nodes[index].children) {
                this.getChildrenChecked(updatedPermissions, this.nodes[index].children);
            }
            index++;
        }
        for (const appResource of this.appresources) {
            let currentId = updatedPermissions.filter(permission => permission == appResource.id);
            if (currentId.length > 0) {
                newPermissions.push(appResource);
            }
        }
        this.roleExtra.permissions = newPermissions;
    }

    getChildrenChecked(updatedPermissions: number[], nodes) {
        for (let node of nodes) {
            if (node.checked) {
                updatedPermissions.push(node.id);
            }
            if (node.children) {
                this.getChildrenChecked(updatedPermissions, node.children);
            }
        }
        
    }
}

@Component({
    selector: 'jhi-role-extra-popup',
    template: ''
})
export class RoleExtraPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private roleExtraPopupService: RoleExtraPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.roleExtraPopupService
                    .open(RoleExtraDialogComponent as Component, params['id']);
            } else {
                this.roleExtraPopupService
                    .open(RoleExtraDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
