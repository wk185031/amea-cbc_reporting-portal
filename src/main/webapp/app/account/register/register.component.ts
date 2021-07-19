import { Component, OnInit, AfterViewInit, Renderer, ElementRef } from '@angular/core';
import { HttpErrorResponse } from '@angular/common/http';
import { NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { JhiLanguageService } from 'ng-jhipster';
import * as CryptoJS from 'crypto-js';
import { E2E_KEY } from '../../shared';

import { Register } from './register.service';
import { LoginModalService, EMAIL_ALREADY_USED_TYPE, LOGIN_ALREADY_USED_TYPE } from '../../shared';

import { ProfileService } from '../../layouts/profiles/profile.service';
import { ProfileInfo } from '../../layouts/profiles/profile-info.model';
@Component({
    selector: 'jhi-register',
    templateUrl: './register.component.html'
})
export class RegisterComponent implements OnInit, AfterViewInit {

    confirmPassword: string;
    doNotMatch: string;
    error: string;
    errorEmailExists: string;
    errorUserExists: string;
    registerAccount: any;
    success: boolean;
    modalRef: NgbModalRef;
   E2EregisterPassword: string;
   E2EregisterUserName: string;
   E2EregisterEmail: string;
    isSelfRegistration: boolean;

    constructor(
        private languageService: JhiLanguageService,
        private loginModalService: LoginModalService,
        private registerService: Register,
        private elementRef: ElementRef,
        private renderer: Renderer,
        private profileService: ProfileService
    ) {
    }

    ngOnInit() {
        this.success = false;
        this.registerAccount = {};
        this.registerAccount.user = {};
        this.profileService.getProfileInfo().then((profileInfo) => {
            this.isSelfRegistration = profileInfo.selfRegistration;
        });
    }

    ngAfterViewInit() {
        this.renderer.invokeElementMethod(this.elementRef.nativeElement.querySelector('#login'), 'focus', []);
    }

    register() {
        this.E2EregisterUserName = CryptoJS.AES.encrypt(this.registerAccount.user.login, E2E_KEY).toString();
        this.E2EregisterPassword = CryptoJS.AES.encrypt(this.registerAccount.password, E2E_KEY).toString();
        this.E2EregisterEmail = CryptoJS.AES.encrypt(this.registerAccount.user.email, E2E_KEY).toString();

        if (this.registerAccount.password !== this.confirmPassword) {
            this.doNotMatch = 'ERROR';
        } else {
            this.doNotMatch = null;
            this.error = null;
            this.errorUserExists = null;
            this.errorEmailExists = null;
            this.registerAccount.encUsername = this.E2EregisterUserName;
            this.registerAccount.user.login = this.E2EregisterUserName;
            this.registerAccount.password = this.E2EregisterPassword;
            this.registerAccount.user.email= this.E2EregisterEmail;
            this.languageService.getCurrent().then((key) => {
                this.registerAccount.user.langKey = key;
                this.registerService.saveExtra(this.registerAccount).subscribe(() => {
                    this.success = true;
                }, (response) => this.processError(response));
            });
        }
    }

    openLogin() {
        this.modalRef = this.loginModalService.open();
    }

    private processError(response: HttpErrorResponse) {
        this.success = null;
        if (response.status === 400 && response.error.type === LOGIN_ALREADY_USED_TYPE) {
            this.errorUserExists = 'ERROR';
        } else if (response.status === 400 && response.error.type === EMAIL_ALREADY_USED_TYPE) {
            this.errorEmailExists = 'ERROR';
        } else {
            this.error = 'ERROR';
        }
    }
}
