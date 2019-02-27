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

@Component({
    selector: 'jhi-user-new-extra-dialog',
    templateUrl: 'user-extra-new-dialog.component.html'
})
export class UserExtraNewDialogComponent implements OnInit {

    userExtra: UserExtra;
    isSaving: boolean;
    languages: string[];
    username: string;
    users: User[];
    roleExtras: RoleExtra[];
    activated: boolean;
    institutions: Institution[];

    constructor(public activeModal: NgbActiveModal,
                private jhiLanguageService: JhiLanguageService,
                private jhiAlertService: JhiAlertService,
                private userExtraService: UserExtraService,
                private institutionService: InstitutionService,
                private roleExtraService: RoleExtraService,
                private eventManager: JhiEventManager,
                private principal: Principal) {
        this.principal.identity().then((account) => {
            this.username = account.login;
        });
        this.languages = LANGUAGES;
        this.activated = true;
    }

    ngOnInit() {
        this.userExtra.user = new User();
        this.isSaving = false;
        this.roleExtraService.query()
            .subscribe((res: HttpResponse<RoleExtra[]>) => { this.roleExtras = res.body; }, (res: HttpErrorResponse) => this.onError(res.message));
        this.institutionService.query()
            .subscribe((res: HttpResponse<Institution[]>) => { this.institutions = res.body; }, (res: HttpErrorResponse) => this.onError(res.message));
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        this.isSaving = true;
        this.userExtra.lastModifiedBy = this.username;
        this.userExtra.createdBy = this.username;
        this.userExtra.user.langKey = this.languages[0];
        this.userExtra.name = this.userExtra.user.login;
        this.subscribeToSaveResponse(
            this.userExtraService.create(this.userExtra));
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

    private onError(error) {
        this.jhiAlertService.error(error.message, null, null);
    }

    trackRoleExtraById(index: number, item: RoleExtra) {
        return item.id;
    }

    trackinstitutionById(index: number, item: Institution) {
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
    selector: 'jhi-new-user-extra-popup',
    template: ''
})
export class UserExtraNewPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(private route: ActivatedRoute,
                private userExtraPopupService: UserExtraPopupService) {
    }

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.userExtraPopupService
                    .open(UserExtraNewDialogComponent as Component, params['id']);
            } else {
                this.userExtraPopupService
                    .open(UserExtraNewDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
