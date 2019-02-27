import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { AppResource } from '../../../entities/app-resource/app-resource.model';
import { createRequestOption } from '../../../shared';

export type EntityResponseType = HttpResponse<AppResource>;

@Injectable()
export class AppResourceService {

    private resourceUrl =  'api/app-resources';
    private resourceSearchUrl = 'api/_search/app-resources';
    private resourceMultipleUrl = 'api/app-resources-multiple';
    private resourceByTypeUrl = 'api/app-resources-by-type';
    private reourceTreeUrl = SERVER_API_URL + 'api/app-resources/permission';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    findAppResourceTree(id: number): Observable<HttpResponse<any[]>> {
        return this.http.get<any[]>(`${this.reourceTreeUrl}/${id}`, { observe: 'response' })
            .map((res: HttpResponse<any[]>) =>this.convertArrayResponse(res));
    }

    create(appResource: AppResource): Observable<EntityResponseType> {
        const copy = this.convert(appResource);
        return this.http.post<AppResource>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    createMultiple(appResource: AppResource[]): Observable<HttpResponse<AppResource[]>> {
        return this.http.post<AppResource[]>(this.resourceMultipleUrl, appResource, { observe: 'response' })
            .map((res: HttpResponse<AppResource[]>) => this.convertArrayResponse(res));
    }

    update(appResource: AppResource): Observable<EntityResponseType> {
        const copy = this.convert(appResource);
        return this.http.put<AppResource>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<AppResource>(`${this.resourceUrl}/${id}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    findByType(type: string): Observable<EntityResponseType> {
        return this.http.get<AppResource>(`${this.resourceByTypeUrl}/${type}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<AppResource[]>> {
        const options = createRequestOption(req);
        return this.http.get<AppResource[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<AppResource[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response'});
    }

    search(req?: any): Observable<HttpResponse<AppResource[]>> {
        const options = createRequestOption(req);
        return this.http.get<AppResource[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<AppResource[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: AppResource = this.convertItemFromServer(res.body);
        return res.clone({body});
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

    /**
     * Convert a AppResource to a JSON which can be sent to the server.
     */
    private convert(appResource: AppResource): AppResource {
        const copy: AppResource = Object.assign({}, appResource);

        copy.createdDate = this.dateUtils.toDate(appResource.createdDate);

        copy.lastModifiedDate = this.dateUtils.toDate(appResource.lastModifiedDate);
        return copy;
    }
}
