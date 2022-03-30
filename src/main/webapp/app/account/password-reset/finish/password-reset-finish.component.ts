import { Component, OnInit, AfterViewInit, Renderer, ElementRef } from '@angular/core';
import { NgbModalRef } from '@ng-bootstrap/ng-bootstrap';
import { ActivatedRoute } from '@angular/router';
import * as CryptoJS from 'crypto-js';
import { E2E_KEY } from '../../../shared';
import { PasswordResetFinishService } from './password-reset-finish.service';
import { LoginModalService } from '../../../shared';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

@Component({
    selector: 'jhi-password-reset-finish',
    templateUrl: './password-reset-finish.component.html'
})
export class PasswordResetFinishComponent implements OnInit, AfterViewInit {
    confirmPassword: string;
    E2ENewPassword: string;
    E2ENewKey: string;
    doNotMatch: string;
    error: string;
    errorKey: string;
    errorMsg: string;
    keyMissing: boolean;
    resetAccount: any;
    success: string;
    modalRef: NgbModalRef;
    key: string;

    constructor(
        private passwordResetFinishService: PasswordResetFinishService,
        private loginModalService: LoginModalService,
        private route: ActivatedRoute,
        private elementRef: ElementRef, private renderer: Renderer
    ) {
    }

    ngOnInit() {
        this.route.queryParams.subscribe((params) => {
            this.key = params['key'];
        });
        this.resetAccount = {};
        this.keyMissing = !this.key;
    }

    ngAfterViewInit() {
        if (this.elementRef.nativeElement.querySelector('#password') != null) {
          this.renderer.invokeElementMethod(this.elementRef.nativeElement.querySelector('#password'), 'focus', []);
        }
    }

    finishReset() {
        this.doNotMatch = null;
        this.error = null;
        this.errorKey = null;
        this.errorMsg = null;
        this.E2ENewPassword = CryptoJS.AES.encrypt(this.resetAccount.password, E2E_KEY).toString();
        this.E2ENewKey  = CryptoJS.AES.encrypt(this.key, E2E_KEY).toString();
        this
        if (this.resetAccount.password !== this.confirmPassword) {
            this.doNotMatch = 'ERROR';
        } else {
            this.passwordResetFinishService.save({key: this.E2ENewKey, newPassword: this.E2ENewPassword}).subscribe(() => {
                this.success = 'OK';
            }, (res: HttpErrorResponse) => {
                this.success = null;
                this.error = 'ERROR';
                this.errorKey = res.error.errorKey;
                this.errorMsg = res.error.title;
            });
        }
    }

    login() {
        this.modalRef = this.loginModalService.open();
    }
}
