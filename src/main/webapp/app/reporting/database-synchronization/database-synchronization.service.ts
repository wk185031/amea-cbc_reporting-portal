import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse, HttpRequest } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { createRequestOption } from '../../shared';
import { DatabaseSynchronization } from './database-synchronization.model';

export type EntityResponseType = HttpResponse<DatabaseSynchronization>;

@Injectable()
export class DatabaseSynchronizationService {

    private resourceUrl = SERVER_API_URL + 'api/databaseSynchronization';
    private resourceSearchUrl = SERVER_API_URL + 'api/_search/databaseSynchronization';
    private resourceUrlNoPaging = SERVER_API_URL + 'api/databaseSynchronization-nopaging';
    private resourcGetParenteUrl = SERVER_API_URL + 'api/databaseSynchronization-parent-for-databaseSynchronization-and-user';
    private resourceDbSyncUrl = SERVER_API_URL + 'api/synchronize-database';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(databaseSynchronization: DatabaseSynchronization): Observable<EntityResponseType> {
        const copy = this.convert(databaseSynchronization);
        return this.http.post<DatabaseSynchronization>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(databaseSynchronization: DatabaseSynchronization): Observable<EntityResponseType> {
        const copy = this.convert(databaseSynchronization);
        return this.http.put<DatabaseSynchronization>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<DatabaseSynchronization>(`${this.resourceUrl}/${id}`, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<DatabaseSynchronization[]>> {
        const options = createRequestOption(req);
        return this.http.get<DatabaseSynchronization[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<DatabaseSynchronization[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response' });
    }

    search(req?: any): Observable<HttpResponse<DatabaseSynchronization[]>> {
        const options = createRequestOption(req);
        return this.http.get<DatabaseSynchronization[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<DatabaseSynchronization[]>) => this.convertArrayResponse(res));
    }

    findParent(id: number): Observable<HttpResponse<DatabaseSynchronization[]>> {
        const options = createRequestOption(id);
        return this.http.get<DatabaseSynchronization[]>(`${this.resourcGetParenteUrl}/${id}`, { params: options, observe: 'response' })
            .map((res: HttpResponse<DatabaseSynchronization[]>) => this.convertArrayResponse(res));
    }

    queryNoPaging(req?: any): Observable<HttpResponse<DatabaseSynchronization[]>> {
        const options = createRequestOption(req);
        return this.http.get<DatabaseSynchronization[]>(this.resourceUrlNoPaging, { params: options, observe: 'response' })
            .map((res: HttpResponse<DatabaseSynchronization[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: DatabaseSynchronization = this.convertItemFromServer(res.body);
        return res.clone({ body });
    }

    private convertArrayResponse(res: HttpResponse<DatabaseSynchronization[]>): HttpResponse<DatabaseSynchronization[]> {
        const jsonResponse: DatabaseSynchronization[] = res.body;
        const body: DatabaseSynchronization[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({ body });
    }

    /**
     * Convert a returned JSON object to DatabaseSynchronization.
     */
    private convertItemFromServer(databaseSynchronization: DatabaseSynchronization): DatabaseSynchronization {
        const copy: DatabaseSynchronization = Object.assign({}, databaseSynchronization);
        copy.createdDate = this.dateUtils.convertDateTimeFromServer(databaseSynchronization.createdDate);
        copy.lastModifiedDate = this.dateUtils.convertDateTimeFromServer(databaseSynchronization.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a DatabaseSynchronization to a JSON which can be sent to the server.
     */
    private convert(databaseSynchronization: DatabaseSynchronization): DatabaseSynchronization {
        const copy: DatabaseSynchronization = Object.assign({}, databaseSynchronization);
        copy.createdDate = this.dateUtils.toDate(databaseSynchronization.createdDate);
        copy.lastModifiedDate = this.dateUtils.toDate(databaseSynchronization.lastModifiedDate);
        return copy;
    }

    syncDatabase(user: string): any {
        const req = new HttpRequest('POST', `${this.resourceDbSyncUrl}/${user}`, { observe: 'response' });
        return req;
    }
}
