import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Rx';
import { JhiDateUtils } from 'ng-jhipster';
import { Institution } from '../entities/institution/institution.model';
import { AppResource } from '../entities/app-resource/app-resource.model';
import { HttpClient, HttpResponse } from '@angular/common/http';

@Injectable()
export class AppService {

    private URL_INSTITUTIONS_FOR_USER = 'api/institutions-for-user';
    private URL_APP_RESOURCES_FOR_USER = 'api/app-resources-for-user';
    private URL_SESSION_LOGOUT = 'api/session-logout';

    constructor(private http: HttpClient,
                private dateUtils: JhiDateUtils) {
    }

    queryInstitutionsForUser(req?: any): Observable<HttpResponse<Institution[]>> {
        return this.http.get<Institution[]>(this.URL_INSTITUTIONS_FOR_USER, { observe: 'response'})
            .map((res: HttpResponse<Institution[]>) => this.convertArrayResponse(res));
    }
    queryPermissionsForUser(req?: any): Observable<HttpResponse<AppResource[]>> {
        return this.http.get<AppResource[]>(this.URL_APP_RESOURCES_FOR_USER, { observe: 'response'})
            .map((res: HttpResponse<AppResource[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: any): any {
        const jsonResponse = res.json();
        for (let i = 0; i < jsonResponse.length; i++) {
            jsonResponse[i].createdDate = this.dateUtils
                .convertDateTimeFromServer(jsonResponse[i].createdDate);
            jsonResponse[i].lastModifiedDate = this.dateUtils
                .convertDateTimeFromServer(jsonResponse[i].lastModifiedDate);
        }
        res._body = jsonResponse;
        return res;
    }

    sessionLogout(req?: any): Observable<Response> {
        return this.http.get(`${this.URL_SESSION_LOGOUT}`)
            .map((res: any) => this.convertResponse(res));
    }

    private convertArrayResponse(res: HttpResponse<AppResource[]>): HttpResponse<AppResource[]> {
        const jsonResponse: AppResource[] = res.body;
        const body: AppResource[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }
    /**
     * Convert a returned JSON object to AppResource.
     */
    private convertItemFromServer(appResource: AppResource): AppResource {
        const copy: AppResource = Object.assign({}, appResource);
        copy.createdDate = this.dateUtils
            .convertDateTimeFromServer(appResource.createdDate);
        copy.lastModifiedDate = this.dateUtils
            .convertDateTimeFromServer(appResource.lastModifiedDate);
        return copy;
    }
}
