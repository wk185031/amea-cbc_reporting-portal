import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { JhiLanguageService, JhiEventManager } from 'ng-jhipster';

import { ProfileService } from '../profiles/profile.service';
import { JhiLanguageHelper, Principal, LoginModalService, LoginService } from '../../shared';

import { VERSION } from '../../app.constants';

import { AppService } from '../../common/app.service';
import { AppPermissionService } from '../../common/app-permission.service';
import { AppResource } from '../../entities/app-resource/app-resource.model';
import { Branch } from '../../entities/branch/branch.model';
import { Institution } from '../../entities/institution/institution.model';
import { HttpResponse } from '@angular/common/http';

@Component({
    selector: 'jhi-navbar',
    templateUrl: './navbar.component.html',
    styleUrls: [
        'navbar.css'
    ]
})
export class NavbarComponent implements OnInit {
    inProduction: boolean;
    isNavbarCollapsed: boolean;
    languages: any[];
    swaggerEnabled: boolean;
    modalRef: NgbModalRef;
    version: string;

    account: Account;
    selectedBranch: Branch;
    branches: Branch[];
    allBranches: Branch[];
    selectedInstitution: Institution;
    institutions: Institution[];
    allInstitutions: Institution[];
    appResources: AppResource[];
    isSelfRegistration: boolean;
    isLanguageSelection: boolean;

    constructor(
        private loginService: LoginService,
        private languageService: JhiLanguageService,
        private languageHelper: JhiLanguageHelper,
        private principal: Principal,
        private loginModalService: LoginModalService,
        private profileService: ProfileService,
        private router: Router,
        private appService: AppService,
        private appPermissionService: AppPermissionService,
        private eventManager: JhiEventManager
    ) {
        this.version = VERSION ? 'v' + VERSION : '';
        this.isNavbarCollapsed = true;
    }

    ngOnInit() {
        this.languageHelper.getAll().then((languages) => {
            this.languages = languages;
        });

        this.profileService.getProfileInfo().then((profileInfo) => {
            this.isSelfRegistration = profileInfo.selfRegistration;
            this.isLanguageSelection = profileInfo.languageSelection;
            this.inProduction = profileInfo.inProduction;
            this.swaggerEnabled = profileInfo.swaggerEnabled;
        });
        this.refreshNavbar();
        this.registerChangeInLogin();
    }

    refreshNavbar() {
        this.principal.identity().then((account) => {
            this.account = account;
        });

        //retrieve Branch for companies
        this.appService.queryBranchesForUser().subscribe((res: HttpResponse<Branch[]>) => {
            this.branches = res.body;
            this.branches = this.branches;
            this.changeBranch(this.branches[0].id) ;
        });

        // retrieve all the companies accessible by this user
        // TODO
        this.appService.queryInstitutionsForUser().subscribe((res: HttpResponse<Institution[]>) => {
            this.institutions = res.body;
            this.allInstitutions = this.institutions;
            this.changeInstitution(this.institutions[0].id) ;
        });

        // retrieve permissions granted for this user
        this.appService.queryPermissionsForUser().subscribe((res: HttpResponse<AppResource[]>) => {
            this.appResources = res.body;
            // store permissions to global service, kept at the client
            this.appPermissionService.permissions = this.appResources;
            this.appResources.forEach((resource: AppResource) => console.log('Granted permission:' + resource.code));
        });

    }

    changeBranch(id: number) {
        for (const branch of this.branches) {
            if (branch.id === id) {
                this.selectedBranch = branch;
                break;
            }
        }
        this.principal.setSelectedBranchId(this.selectedBranch.id);
        this.router.navigate(['/']);
    }

    changeInstitution(id: number) {
        for (const institution of this.institutions) {
            if (institution.id === id) {
                this.selectedInstitution = institution;
                break;
            }
        }
        this.principal.setSelectedInstitutionId(this.selectedInstitution.id);
        this.router.navigate(['/']);
    }

    registerChangeInLogin() {
        this.eventManager.subscribe('authenticationSuccess', (response) => this.refreshNavbar());
    }

    isMenuEnabled(menu: String) {
        return this.appPermissionService.hasPermission(menu);
    }

    changeLanguage(languageKey: string) {
      this.languageService.changeLanguage(languageKey);
    }

    collapseNavbar() {
        this.isNavbarCollapsed = true;
    }

    isAuthenticated() {
        return this.principal.isAuthenticated();
    }

    login() {
        this.modalRef = this.loginModalService.open();
    }

    logout() {
        this.collapseNavbar();
        this.loginService.logout();
        this.account = null;
        this.selectedInstitution = null;
        this.appPermissionService.permissions = null;
        this.router.navigate(['']);
    }

    toggleNavbar() {
        this.isNavbarCollapsed = !this.isNavbarCollapsed;
    }

    getImageUrl() {
        return this.isAuthenticated() ? this.principal.getImageUrl() : null;
    }

    onKeyup(value) {
        if (value) {
            this.institutions = this.allInstitutions.filter((institution) => {
                return institution.name.toUpperCase().indexOf(value.toUpperCase()) != -1;
            })
        }
        else {
            this.institutions = this.allInstitutions;
        }
    }

    onFilter() {
        event.preventDefault();
        event.stopPropagation();
    }
}
