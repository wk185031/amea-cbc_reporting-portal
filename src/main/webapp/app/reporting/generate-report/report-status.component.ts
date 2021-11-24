import { Component, AfterViewInit, Renderer, ElementRef } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { Router } from '@angular/router';
import { JhiEventManager } from 'ng-jhipster';
import * as CryptoJS from 'crypto-js';
// import { E2E_KEY } from '..';

// import { LoginService } from './login.service';
// import { StateStorageService } from '../auth/state-storage.service';

import { ProfileService } from '../../layouts/profiles/profile.service';
@Component({
    selector: 'jhi-report-status-modal',
     templateUrl: './report-status-component.html'
    //templateUrl: '../../reporting/generate-report/reportStatus.html'
})
export class ReportStatusComponent implements AfterViewInit {
    authenticationError: boolean;
    password: string;
    rememberMe: boolean;
    username: string;
    credentials: any;

    isSelfRegistration: boolean;

    constructor(
        private eventManager: JhiEventManager,
        // private loginService: LoginService,
        // private stateStorageService: StateStorageService,
        private elementRef: ElementRef,
        private renderer: Renderer,
        private router: Router,
        public activeModal: NgbActiveModal,
        private profileService: ProfileService
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
        this.activeModal.dismiss('cancel');
    }
}
