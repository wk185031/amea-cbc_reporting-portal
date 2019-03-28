import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { createRequestOption } from '../../shared';
import { ReportDefinition } from './report-config-definition.model';

export type EntityResponseType = HttpResponse<ReportDefinition>;

@Injectable()
export class ReportConfigDefinitionService {

    private resourceUrl = SERVER_API_URL + 'api/reportDefinition';
    private resourceSearchUrl = SERVER_API_URL + 'api/_search/reportDefinition';
    private resourceUrlNoPaging = SERVER_API_URL + 'api/reportDefinition-nopaging';
    private resourcGetParenteUrl = SERVER_API_URL + 'api/reportDefinition-parent-for-reportDefinition-and-user';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(reportDefinition: ReportDefinition): Observable<EntityResponseType> {
        const copy = this.convert(reportDefinition);
        return this.http.post<ReportDefinition>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(reportDefinition: ReportDefinition): Observable<EntityResponseType> {
        const copy = this.convert(reportDefinition);
        return this.http.put<ReportDefinition>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<ReportDefinition>(`${this.resourceUrl}/${id}`, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<ReportDefinition[]>> {
        const options = createRequestOption(req);
        return this.http.get<ReportDefinition[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportDefinition[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response' });
    }

    search(req?: any): Observable<HttpResponse<ReportDefinition[]>> {
        const options = createRequestOption(req);
        return this.http.get<ReportDefinition[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportDefinition[]>) => this.convertArrayResponse(res));
    }

    findParent(id: number): Observable<HttpResponse<ReportDefinition[]>> {
        const options = createRequestOption(id);
        return this.http.get<ReportDefinition[]>(`${this.resourcGetParenteUrl}/${id}`, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportDefinition[]>) => this.convertArrayResponse(res));
    }

    queryNoPaging(req?: any): Observable<HttpResponse<ReportDefinition[]>> {
        const options = createRequestOption(req);
        return this.http.get<ReportDefinition[]>(this.resourceUrlNoPaging, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportDefinition[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: ReportDefinition = this.convertItemFromServer(res.body);
        return res.clone({ body });
    }

    private convertArrayResponse(res: HttpResponse<ReportDefinition[]>): HttpResponse<ReportDefinition[]> {
        const jsonResponse: ReportDefinition[] = res.body;
        const body: ReportDefinition[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({ body });
    }

    /**
     * Convert a returned JSON object to ReportDefinition.
     */
    private convertItemFromServer(reportDefinition: ReportDefinition): ReportDefinition {
        const copy: ReportDefinition = Object.assign({}, reportDefinition);
        copy.createdDate = this.dateUtils.convertDateTimeFromServer(reportDefinition.createdDate);
        copy.lastModifiedDate = this.dateUtils.convertDateTimeFromServer(reportDefinition.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a ReportDefinition to a JSON which can be sent to the server.
     */
    private convert(reportDefinition: ReportDefinition): ReportDefinition {
        const copy: ReportDefinition = Object.assign({}, reportDefinition);
        copy.createdDate = this.dateUtils.toDate(reportDefinition.createdDate);
        copy.lastModifiedDate = this.dateUtils.toDate(reportDefinition.lastModifiedDate);
        return copy;
    }
}
