import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { createRequestOption } from '../../shared';
import { ReportCategory } from './report-config-category.model';

export type EntityResponseType = HttpResponse<ReportCategory>;

@Injectable()
export class ReportConfigCategoryService {

    private resourceUrl = SERVER_API_URL + 'api/reportCategory';
    private resourceSearchUrl = SERVER_API_URL + 'api/_search/reportCategory';
    private resourceUrlNoPaging = SERVER_API_URL + 'api/reportCategory-nopaging';
    private resourcGetParenteUrl = SERVER_API_URL + 'api/reportCategory-parent-for-reportCategory-and-user';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(reportCategory: ReportCategory): Observable<EntityResponseType> {
        const copy = this.convert(reportCategory);
        return this.http.post<ReportCategory>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(reportCategory: ReportCategory): Observable<EntityResponseType> {
        const copy = this.convert(reportCategory);
        return this.http.put<ReportCategory>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<ReportCategory>(`${this.resourceUrl}/${id}`, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<ReportCategory[]>> {
        const options = createRequestOption(req);
        return this.http.get<ReportCategory[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportCategory[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response' });
    }

    search(req?: any): Observable<HttpResponse<ReportCategory[]>> {
        const options = createRequestOption(req);
        return this.http.get<ReportCategory[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportCategory[]>) => this.convertArrayResponse(res));
    }

    findParent(id: number): Observable<HttpResponse<ReportCategory[]>> {
        const options = createRequestOption(id);
        return this.http.get<ReportCategory[]>(`${this.resourcGetParenteUrl}/${id}`, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportCategory[]>) => this.convertArrayResponse(res));
    }

    queryNoPaging(req?: any): Observable<HttpResponse<ReportCategory[]>> {
        const options = createRequestOption(req);
        return this.http.get<ReportCategory[]>(this.resourceUrlNoPaging, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportCategory[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: ReportCategory = this.convertItemFromServer(res.body);
        return res.clone({ body });
    }

    private convertArrayResponse(res: HttpResponse<ReportCategory[]>): HttpResponse<ReportCategory[]> {
        const jsonResponse: ReportCategory[] = res.body;
        const body: ReportCategory[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({ body });
    }

    /**
     * Convert a returned JSON object to ReportCategory.
     */
    private convertItemFromServer(reportCategory: ReportCategory): ReportCategory {
        const copy: ReportCategory = Object.assign({}, reportCategory);
        copy.createdDate = this.dateUtils.convertDateTimeFromServer(reportCategory.createdDate);
        copy.lastModifiedDate = this.dateUtils.convertDateTimeFromServer(reportCategory.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a ReportCategory to a JSON which can be sent to the server.
     */
    private convert(reportCategory: ReportCategory): ReportCategory {
        const copy: ReportCategory = Object.assign({}, reportCategory);
        copy.createdDate = this.dateUtils.toDate(reportCategory.createdDate);
        copy.lastModifiedDate = this.dateUtils.toDate(reportCategory.lastModifiedDate);
        return copy;
    }
}
