import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { LocalStorageService, SessionStorageService } from 'ngx-webstorage';
import { SERVER_API_URL } from '../../app.constants';
import * as CryptoJS from 'crypto-js';
import { E2E_KEY } from '..';

@Injectable()
export class AuthServerProvider {

    private logoutApi = SERVER_API_URL + 'api/logout';

    constructor(
        private http: HttpClient,
        private $localStorage: LocalStorageService,
        private $sessionStorage: SessionStorageService
    ) {}

    getToken() {

        return this.$localStorage.retrieve('authenticationToken') || this.$sessionStorage.retrieve('authenticationToken');
    }

    login(credentials): Observable<any> {

        const data = {
            username: credentials.username,
            password: credentials.password,
            rememberMe: credentials.rememberMe
        };
        return this.http.post(SERVER_API_URL + 'api/authenticate', data, {observe : 'response'}).map(authenticateSuccess.bind(this));

        function authenticateSuccess(resp) {
            const bearerToken = resp.headers.get('Authorization');
            if (bearerToken && bearerToken.slice(0, 7) === 'Bearer ') {
                const jwt = bearerToken.slice(7, bearerToken.length);
                const key = CryptoJS.enc.Utf8.parse(E2E_KEY);
                const decToken = CryptoJS.AES.decrypt(jwt, key, {
        			mode: CryptoJS.mode.ECB,
					padding: CryptoJS.pad.Pkcs7
        		});

                this.storeAuthenticationToken(decToken.toString(CryptoJS.enc.Utf8), credentials.rememberMe);
                return decToken;
            }
        }
    }

    loginWithToken(jwt, rememberMe) {
        if (jwt) {
            this.storeAuthenticationToken(jwt, rememberMe);
            return Promise.resolve(jwt);
        } else {
            return Promise.reject('auth-jwt-service Promise reject'); // Put appropriate error message here
        }
    }

    storeAuthenticationToken(jwt, rememberMe) {
        if (rememberMe) {
            this.$localStorage.store('authenticationToken', jwt);
        } else {
            this.$sessionStorage.store('authenticationToken', jwt);
        }
    }

    logout(): Observable<any> {
        return new Observable((observer) => {
            this.$localStorage.clear('authenticationToken');
            this.$sessionStorage.clear('authenticationToken');
            observer.complete();
        });
    }

    logoutUpdate(): Observable<any> {
    	const key = CryptoJS.enc.Utf8.parse(E2E_KEY);
    	const encToken = CryptoJS.AES.encrypt(this.getToken(), key, {
        	mode: CryptoJS.mode.ECB,
			    padding: CryptoJS.pad.Pkcs7
        });
        const token = {
            id_token: encToken.toString(),
        };
        return this.http.post(SERVER_API_URL + 'api/logout', token, {observe : 'response'}).map(logoutSuccess.bind(this));

        function logoutSuccess(resp) {
            console.log('logout success');
            return null;
        }
    }
}
