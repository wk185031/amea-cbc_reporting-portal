import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService, JhiLanguageService} from 'ng-jhipster';

import { UserExtra } from '../../entities/user-extra/user-extra.model';
import { UserExtraPopupService } from './user-extra-popup.service';
import { UserExtraService } from './user-extra.service';
import { LANGUAGES, User, UserService } from '../../shared';
import { RoleExtra  } from '../../entities/role-extra';
import { RoleExtraService } from '../role/role-extra.service';
import { Institution } from '../../entities/institution';
import { InstitutionService } from '../institution/institution.service';
import { Principal } from '../../shared/auth/principal.service';
import { BranchService, Branch } from '../../entities/branch';

@Component({
    selector: 'jhi-user-extra-dialog',
    templateUrl: 'user-extra-edit-dialog.component.html'
})
export class UserExtraEditDialogComponent implements OnInit {

    userExtra: UserExtra;
    authorities: any[];
    isSaving: boolean;
    languages: string[];
    username: string;
    users: User[];
    roleextras: RoleExtra[];
    activated: boolean;
    institutions: Institution[];
    branches: Branch[];

    constructor(public activeModal: NgbActiveModal,
                private jhiLanguageService: JhiLanguageService,
                private jhiAlertService: JhiAlertService,
                private userExtraService: UserExtraService,
                private institutionService: InstitutionService,
                private branchService: BranchService,
                private roleExtraService: RoleExtraService,
                private eventManager: JhiEventManager,
                private principal: Principal) {
        this.principal.identity().then((account) => {
            this.username = account.login;
        });
        this.languages = LANGUAGES;
    }

    ngOnInit() {
        this.isSaving = false;
        this.authorities = ['ROLE_USER', 'ROLE_ADMIN'];
        this.roleExtraService.query()
            .subscribe((res: HttpResponse<RoleExtra[]>) => { this.roleextras = res.body; }, (res: HttpErrorResponse) => this.onError(res.message));
        this.institutionService.queryNoPaging()
            .subscribe((res: HttpResponse<Institution[]>) => { this.institutions = res.body; }, (res: HttpErrorResponse) => this.onError(res.message));
        this.branchService.query()
            .subscribe((res: HttpResponse<Branch[]>) => { 
            	this.branches = res.body; 
            	const allBranch: Branch = {
  					abr_name: 'ALL',
  					abr_code: '',
				};
				this.branches.unshift(allBranch);
            }, (res: HttpErrorResponse) => this.onError(res.message));
        this.activated = this.userExtra.user.activated.valueOf();
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    update() {
        this.isSaving = true;
        this.userExtra.lastModifiedBy = this.username;
        this.userExtra.user.lastModifiedBy = this.username;
        this.userExtra.user.langKey = this.languages[0];

        if (this.activated) {
        	this.userExtra.user.activated = this.activated;
        } else {
        	this.userExtra.user.activated = false;
        }

        this.subscribeToSaveResponse(
            this.userExtraService.update(this.userExtra));
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<UserExtra>>) {
        result.subscribe((res: HttpResponse<UserExtra>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: UserExtra) {
        this.eventManager.broadcast({name: 'userExtraListModification', content: 'OK'});
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    trackRoleExtraById(index: number, item: RoleExtra) {
        return item.id;
    }

    trackinstitutionById(index: number, item: Institution) {
        return item.id;
    }

    trackBranchById(index: number, item: Branch) {
        return item.id;
    }

    getSelected(selectedVals: Array<any>, option: any) {
        if (selectedVals) {
            for (let i = 0; i < selectedVals.length; i++) {
                if (option.id === selectedVals[i].id) {
                    return selectedVals[i];
                }
            }
        }
        return option;
    }
}

@Component({
    selector: 'jhi-edit-user-extra-popup',
    template: ''
})
export class UserExtraEditPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(private route: ActivatedRoute,
                private userExtraPopupService: UserExtraPopupService) {
    }

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.userExtraPopupService
                    .open(UserExtraEditDialogComponent as Component, params['id']);
            } else {
                this.userExtraPopupService
                    .open(UserExtraEditDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
