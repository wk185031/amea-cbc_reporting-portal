import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { RoleExtra } from './role-extra.model';
import { createRequestOption } from '../../shared';

export type EntityResponseType = HttpResponse<RoleExtra>;

@Injectable()
export class RoleExtraService {

    private resourceUrl =  SERVER_API_URL + 'api/role-extras';
    private resourceSearchUrl = SERVER_API_URL + 'api/_search/role-extras';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(roleExtra: RoleExtra): Observable<EntityResponseType> {
        const copy = this.convert(roleExtra);
        return this.http.post<RoleExtra>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(roleExtra: RoleExtra): Observable<EntityResponseType> {
        const copy = this.convert(roleExtra);
        return this.http.put<RoleExtra>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<RoleExtra>(`${this.resourceUrl}/${id}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<RoleExtra[]>> {
        const options = createRequestOption(req);
        return this.http.get<RoleExtra[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<RoleExtra[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response'});
    }

    search(req?: any): Observable<HttpResponse<RoleExtra[]>> {
        const options = createRequestOption(req);
        return this.http.get<RoleExtra[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<RoleExtra[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: RoleExtra = this.convertItemFromServer(res.body);
        return res.clone({body});
    }

    private convertArrayResponse(res: HttpResponse<RoleExtra[]>): HttpResponse<RoleExtra[]> {
        const jsonResponse: RoleExtra[] = res.body;
        const body: RoleExtra[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }

    /**
     * Convert a returned JSON object to RoleExtra.
     */
    private convertItemFromServer(roleExtra: RoleExtra): RoleExtra {
        const copy: RoleExtra = Object.assign({}, roleExtra);
        copy.createdDate = this.dateUtils
            .convertDateTimeFromServer(roleExtra.createdDate);
        copy.lastModifiedDate = this.dateUtils
            .convertDateTimeFromServer(roleExtra.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a RoleExtra to a JSON which can be sent to the server.
     */
    private convert(roleExtra: RoleExtra): RoleExtra {
        const copy: RoleExtra = Object.assign({}, roleExtra);

        copy.createdDate = this.dateUtils.toDate(roleExtra.createdDate);

        copy.lastModifiedDate = this.dateUtils.toDate(roleExtra.lastModifiedDate);
        return copy;
    }
}
