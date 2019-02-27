import { Component, OnInit, OnDestroy, Input, OnChanges } from '@angular/core';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';
import { ActivatedRoute } from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { AppResource } from '../../../entities/app-resource/app-resource.model';
import { AppResourceService } from './app-resource.service';
import { Principal } from '../../../shared';
import { RoleExtra } from '../../../entities/role-extra/role-extra.model';
import { AppPermissionsConfiguration } from './app-permissions-configuration.model';
import { AppPermissionsConfigurationService } from './app-permissions-configuration.service';

@Component({
    selector: 'jhi-app-resource',
    templateUrl: './app-resource.component.html'
})
export class AppResourceComponent implements OnInit, OnChanges {

    @Input() roleExtra: RoleExtra;
    menuAppPermissionsConfig: AppPermissionsConfiguration[];
    private menuNames: string[];
    private readAppResources: Map<string, boolean>;
    private addAppResources: Map<string, boolean>;
    private updateAppResources: Map<string, boolean>;
    private deleteAppResources: Map<string, boolean>;
    private selectedAppResources: Map<string, AppResource>;
    checkAllRead: boolean;
    checkAllAdd: boolean;
    checkAllUpdate: boolean;
    checkAllDelete: boolean;
    currentAccount: any;

    constructor(
        private appPermissionsConfigService: AppPermissionsConfigurationService,
        private principal: Principal
    ) {
        this.menuAppPermissionsConfig = [];
        this.menuNames = [];
        this.readAppResources = new Map<string, boolean>();
        this.addAppResources = new Map<string, boolean>();
        this.updateAppResources = new Map<string, boolean>();
        this.deleteAppResources = new Map<string, boolean>();
        this.selectedAppResources = new Map<string, AppResource>();
    }

    ngOnInit(): void {
        this.loadAll();
    }

    ngOnChanges(): void {
        this.loadAll();
    }

    private loadAll(): void {
        this.appPermissionsConfigService.query().subscribe(
            (res: HttpResponse<AppResource[]>) => {
                this.menuAppPermissionsConfig = res.body;
                this.setAppResources();
            }
        );

        this.principal.identity().then(
            (identity) => this.currentAccount = identity
        );
    }

    private setAppResources() {
        for (const menuAppResource of this.menuAppPermissionsConfig) {
            const menuName = menuAppResource.name;
            this.readAppResources.set(menuName, false);
            this.addAppResources.set(menuName, false);
            this.updateAppResources.set(menuName, false);
            this.deleteAppResources.set(menuName, false);
            this.menuNames.push(menuName);
        }

        if (this.roleExtra && this.roleExtra.permissions) {
            for (const appResource of this.roleExtra.permissions) {
                if (appResource.type === 'MAIN_MENU') {
                    this.readAppResources.set(appResource.name.slice('MENU: '.length), true);
                }

                if (appResource.type === 'OPER') {
                    if (appResource.code.endsWith('.READ')) {
                        const appResourceName = appResource.name.slice('Operation: Read '.length);
                        this.readAppResources.set(appResourceName, true);
                    }

                    if (appResource.code.endsWith('.CREATE')) {
                        const appResourceName = appResource.name.slice('Operation: Create '.length);
                        this.addAppResources.set(appResourceName, true);
                    }

                    if (appResource.code.endsWith('.UPDATE')) {
                        const appResourceName = appResource.name.slice('Operation: Update '.length);
                        this.updateAppResources.set(appResourceName, true);
                    }

                    if (appResource.code.endsWith('.DELETE')) {
                        const appResourceName = appResource.name.slice('Operation: Delete '.length);
                        this.deleteAppResources.set(appResourceName, true);
                    }
                }
            }
        }
    }

    selectAll(accessType: string, checked: boolean): void {
        switch (accessType) {
            case 'read':
                for (const menuAppResource of this.menuAppPermissionsConfig) {
                    this.setSelectedAppResources('Read', '.READ', menuAppResource.name, menuAppResource.code, checked);
                }

                this.setCheckedStatusOnSelectAll(checked, this.readAppResources);
                this.checkAllRead = true;
                break;

            case 'add':
                for (const menuAppResource of this.menuAppPermissionsConfig) {
                    this.setSelectedAppResources('Create', '.CREATE', menuAppResource.name, menuAppResource.code, checked);
                }

                this.setCheckedStatusOnSelectAll(checked, this.addAppResources);
                this.checkAllAdd = true;
                break;

            case 'edit':
                for (const menuAppResource of this.menuAppPermissionsConfig) {
                    this.setSelectedAppResources('Update', '.UPDATE', menuAppResource.name, menuAppResource.code, checked);
                }

                this.setCheckedStatusOnSelectAll(checked, this.updateAppResources);
                this.checkAllUpdate = true;
                break;

            case 'delete':
                for (const menuAppResource of this.menuAppPermissionsConfig) {
                    this.setSelectedAppResources('Delete', '.DELETE', menuAppResource.name, menuAppResource.code, checked);
                }

                this.setCheckedStatusOnSelectAll(checked, this.deleteAppResources);
                this.checkAllDelete = true;
                break;
        }

        this.roleExtra.permissions = Array.from(this.selectedAppResources.values());
    }

    private setCheckedStatusOnSelectAll(checked: boolean, map: Map<string, boolean>): void {
        map.clear();
        if (checked) {
            for (const name of this.menuNames) {
                map.set(name, true);
            }
        } else {
            for (const name of this.menuNames) {
                map.set(name, false);
            }
        }
    }

    select(accessType: string, menu: AppPermissionsConfiguration, checked: boolean): void {
        switch (accessType) {
            case 'read':
                this.setCheckedOnSelected(accessType, this.readAppResources, menu, checked);
                break;

            case 'add':
                this.setCheckedOnSelected(accessType, this.addAppResources, menu, checked);
                break;

            case 'edit':
                this.setCheckedOnSelected(accessType, this.updateAppResources, menu, checked);
                break;

            case 'delete':
                this.setCheckedOnSelected(accessType, this.deleteAppResources, menu, checked);
                break;
        }

        this.roleExtra.permissions = Array.from(this.selectedAppResources.values());
    }

    setSelectedAppResources(operationType: string, suffix: string, menuName: string, menuCode: string, checked: boolean): void {
        const operationName = 'Operation: ' + operationType + ' ' + menuName;
        const associatedMenuName = 'Menu: ' + menuName;
        if (this.selectedAppResources.has(operationName)) {
            if (checked) {
                return;
            } else {

            }
        } else {
            if (checked) {

            } else {
                return;
            }
        }
    }

    private setCheckedOnSelected(accessType: string, map: Map<string, boolean>, menu: AppPermissionsConfiguration, checked: boolean): void {
        map.set(menu.name, checked);

        for (const menuName of this.menuNames) {
            if (!map.get(menuName)) {
                switch (accessType) {
                    case 'read':
                        this.checkAllRead = false;
                        return;

                    case 'add':
                        this.checkAllAdd = false;
                        return;

                    case 'edit':
                        this.checkAllUpdate = false;
                        return;

                    case 'delete':
                        this.checkAllDelete = false;
                        return;
                }
            }

            switch (accessType) {
                case 'read':
                    this.checkAllRead = true;
                    return;

                case 'add':
                    this.checkAllAdd = true;
                    return;

                case 'edit':
                    this.checkAllUpdate = true;
                    return;

                case 'delete':
                    this.checkAllDelete = true;
                    return;
            }
        }
    }

    isChecked(accessType: string, menu: string): boolean {
        switch (accessType) {
            case 'read':
                return this.readAppResources.get(menu);

            case 'add':
                return this.addAppResources.get(menu);

            case 'edit':
                return this.updateAppResources.get(menu);

            case 'delete':
                return this.deleteAppResources.get(menu);
        }
    }
}
