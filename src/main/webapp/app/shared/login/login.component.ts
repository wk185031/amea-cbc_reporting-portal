import { Component, AfterViewInit, Renderer, ElementRef } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { Router } from '@angular/router';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';
import * as CryptoJS from 'crypto-js';
import { E2E_KEY } from '..';

import { LoginService } from './login.service';
import { StateStorageService } from '../auth/state-storage.service';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { ProfileService } from '../../layouts/profiles/profile.service';
@Component({
    selector: 'jhi-login-modal',
    templateUrl: './login.component.html'
})
export class JhiLoginModalComponent implements AfterViewInit {
    authenticationError: boolean;
    password: string;
    rememberMe: boolean;
    username: string;
    credentials: any;
    errorMsg: string;

    isSelfRegistration: boolean;

    constructor(
        private eventManager: JhiEventManager,
        private loginService: LoginService,
        private stateStorageService: StateStorageService,
        private elementRef: ElementRef,
        private renderer: Renderer,
        private router: Router,
        public activeModal: NgbActiveModal,
        private profileService: ProfileService,
        private jhiAlertService: JhiAlertService,
    ) {
        this.credentials = {};
        this.profileService.getProfileInfo().then((profileInfo) => {
            this.isSelfRegistration = profileInfo.selfRegistration;
        });
    }

    ngAfterViewInit() {
        this.renderer.invokeElementMethod(this.elementRef.nativeElement.querySelector('#username'), 'focus', []);
    }

    cancel() {
        this.credentials = {
            username: null,
            password: null,
            rememberMe: true
        };
        this.authenticationError = false;
        this.activeModal.dismiss('cancel');
    }

    login() {
        this.loginService.login({
            username: CryptoJS.AES.encrypt(this.username, E2E_KEY).toString(),
            password: CryptoJS.AES.encrypt(this.password, E2E_KEY).toString(),
            rememberMe: this.rememberMe
        }).then(() => {
        	this.errorMsg = '';
            this.authenticationError = false;
            this.activeModal.dismiss('login success');
            if (this.router.url === '/register' || (/^\/activate\//.test(this.router.url)) ||
                (/^\/reset\//.test(this.router.url))) {
                this.router.navigate(['']);
            }

            this.eventManager.broadcast({
                name: 'authenticationSuccess',
                content: 'Sending Authentication Success'
            });

            // // previousState was set in the authExpiredInterceptor before being redirected to login modal.
            // // since login is succesful, go to stored previousState and clear previousState
            const redirect = this.stateStorageService.getUrl();
            if (redirect) {
                this.stateStorageService.storeUrl(null);
                this.router.navigate([redirect]);
            }
        }).catch((res: HttpErrorResponse) => {
        
        	console.log("-----"+res.status);
        	if (res.status == 409) {
        		this.errorMsg = 'You already logged in on another system.';
            	this.onError(this.errorMsg);
        	} else if (res.error.detail && res.error.detail != 'Bad credentials') {
            	this.errorMsg = res.error.detail;
            	this.onError(res.error.detail);
            } else {
            	this.errorMsg = 'Failed to sign in! Please check your credentials and try again.';
            	this.onError(res.error.message);
            }

            this.authenticationError = true;
        });
    }

    register() {
        this.activeModal.dismiss('to state register');
        this.router.navigate(['/register']);
    }

    requestResetPassword() {
        this.activeModal.dismiss('to state requestReset');
        this.router.navigate(['/reset', 'request']);
    }
    
    private onError(msg: any) {
        //this.ngxLoader.stop();
        this.jhiAlertService.error(msg, null, null);
    }
}
