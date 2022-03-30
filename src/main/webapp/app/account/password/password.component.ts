import { Component, OnInit } from '@angular/core';

import { Principal } from '../../shared';
import { PasswordService } from './password.service';
import * as CryptoJS from 'crypto-js';
import { E2E_KEY } from '../../shared';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

@Component({
    selector: 'jhi-password',
    templateUrl: './password.component.html'
})
export class PasswordComponent implements OnInit {
    doNotMatch: string;
    error: string;
    errorKey: string;
    errorMsg: string;
    success: string;
    account: any;
    password: string;
    confirmPassword: string;
    E2Epassword :string;
    E2EconfirmPassword: string;

    constructor(
        private passwordService: PasswordService,
        private principal: Principal
    ) {
    }

    ngOnInit() {
        this.principal.identity().then((account) => {
            this.account = account;
        });
    }

    changePassword() {

        this.E2Epassword = CryptoJS.AES.encrypt(this.password, E2E_KEY).toString();
        this.E2EconfirmPassword = CryptoJS.AES.encrypt(this.confirmPassword, E2E_KEY).toString();

        if (this.password !== this.confirmPassword) {
            this.error = null;
            this.success = null;
            this.doNotMatch = 'ERROR';
        } else {
            this.doNotMatch = null;
            this.passwordService.save(this.E2Epassword).subscribe(() => {
                this.error = null;
                this.success = 'OK';
            }, (res: HttpErrorResponse) => {
                this.success = null;
                this.error = 'ERROR';
                this.errorKey = res.error.errorKey;
                this.errorMsg = res.error.title;
            });
        }
    }
}
