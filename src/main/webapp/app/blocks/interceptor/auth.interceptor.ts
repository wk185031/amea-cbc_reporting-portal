import { Observable } from 'rxjs/Observable';
import { LocalStorageService, SessionStorageService } from 'ngx-webstorage';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent } from '@angular/common/http';
import { SERVER_API_URL } from '../../app.constants';
import * as CryptoJS from 'crypto-js';
import { E2E_KEY } from '../../shared';

export class AuthInterceptor implements HttpInterceptor {

    constructor(
        private localStorage: LocalStorageService,
        private sessionStorage: SessionStorageService
    ) {
    }

    intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
        if (!request || !request.url || (/^http/.test(request.url) && !(SERVER_API_URL && request.url.startsWith(SERVER_API_URL)))) {
            return next.handle(request);
        }

        const token = this.localStorage.retrieve('authenticationToken') || this.sessionStorage.retrieve('authenticationToken');
        if (!!token) {
        	const key = CryptoJS.enc.Utf8.parse(E2E_KEY);
        	const encToken = CryptoJS.AES.encrypt(token, key, {
        		mode: CryptoJS.mode.ECB,
				padding: CryptoJS.pad.Pkcs7
        	});
            request = request.clone({
                setHeaders: {
                    Authorization: 'Bearer ' + encToken
                }
            });
        }
        return next.handle(request);
    }

}
