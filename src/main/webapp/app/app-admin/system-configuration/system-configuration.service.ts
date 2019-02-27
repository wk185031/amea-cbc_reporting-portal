import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { SystemConfiguration } from '../../entities/system-configuration/system-configuration.model';
import { createRequestOption } from '../../shared';

export type EntityResponseType = HttpResponse<SystemConfiguration>;

@Injectable()
export class SystemConfigurationService {

    private resourceUrl =  SERVER_API_URL + 'api/system-configurations';
    private resourceSearchUrl = SERVER_API_URL + 'api/_search/system-configurations';
    private resourceUrlByName = SERVER_API_URL + 'api/system-configurations-by-name';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(systemConfiguration: SystemConfiguration): Observable<EntityResponseType> {
        const copy = this.convert(systemConfiguration);
        return this.http.post<SystemConfiguration>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(systemConfiguration: SystemConfiguration): Observable<EntityResponseType> {
        const copy = this.convert(systemConfiguration);
        return this.http.put<SystemConfiguration>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<SystemConfiguration>(`${this.resourceUrl}/${id}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    findByName(name: string): Observable<HttpResponse<SystemConfiguration>> {
        return this.http.get<SystemConfiguration>(`${this.resourceUrlByName}/${name}`, { observe: 'response'})
            .map((res: HttpResponse<SystemConfiguration>)  => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<SystemConfiguration[]>> {
        const options = createRequestOption(req);
        return this.http.get<SystemConfiguration[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<SystemConfiguration[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response'});
    }

    search(req?: any): Observable<HttpResponse<SystemConfiguration[]>> {
        const options = createRequestOption(req);
        return this.http.get<SystemConfiguration[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<SystemConfiguration[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: SystemConfiguration = this.convertItemFromServer(res.body);
        return res.clone({body});
    }

    private convertArrayResponse(res: HttpResponse<SystemConfiguration[]>): HttpResponse<SystemConfiguration[]> {
        const jsonResponse: SystemConfiguration[] = res.body;
        const body: SystemConfiguration[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }

    /**
     * Convert a returned JSON object to SystemConfiguration.
     */
    private convertItemFromServer(systemConfiguration: SystemConfiguration): SystemConfiguration {
        const copy: SystemConfiguration = Object.assign({}, systemConfiguration);
        copy.createdDate = this.dateUtils
            .convertDateTimeFromServer(systemConfiguration.createdDate);
        copy.lastModifiedDate = this.dateUtils
            .convertDateTimeFromServer(systemConfiguration.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a SystemConfiguration to a JSON which can be sent to the server.
     */
    private convert(systemConfiguration: SystemConfiguration): SystemConfiguration {
        const copy: SystemConfiguration = Object.assign({}, systemConfiguration);

        copy.createdDate = this.dateUtils.toDate(systemConfiguration.createdDate);

        copy.lastModifiedDate = this.dateUtils.toDate(systemConfiguration.lastModifiedDate);
        return copy;
    }
}
