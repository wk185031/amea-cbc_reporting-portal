import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { Institution } from '../../entities/institution/institution.model';
import { createRequestOption } from '../../shared';

export type EntityResponseType = HttpResponse<Institution>;

@Injectable()
export class InstitutionService {

    private resourceUrl =  SERVER_API_URL + 'api/institutions';
    private resourceSearchUrl = SERVER_API_URL + 'api/_search/institutions';
    private resourceInstitutionStructures = SERVER_API_URL + 'api/institution-structures';
    private resourceUrlNoPaging = SERVER_API_URL + 'api/institutions-nopaging';
    private resourcGetParenteUrl = SERVER_API_URL + 'api/institutions-parent-for-institutions-and-user';
    private resourceWithAttachmentUrl = SERVER_API_URL + 'api/institution-with-attachment';
    private resourceUrlChild =  SERVER_API_URL + 'api/institutions/child';


    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(institution: Institution): Observable<EntityResponseType> {
        const copy = this.convert(institution);
        return this.http.post<Institution>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(institution: Institution): Observable<EntityResponseType> {
        const copy = this.convert(institution);
        return this.http.put<Institution>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<Institution>(`${this.resourceUrl}/${id}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<Institution[]>> {
        const options = createRequestOption(req);
        return this.http.get<Institution[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<Institution[]>) => this.convertArrayResponse(res));
    }
    
    queryChild(req?: any): Observable<HttpResponse<Institution[]>> {
        const options = createRequestOption(req);
        return this.http.get<Institution[]>(this.resourceUrlChild, { params: options, observe: 'response' })
            .map((res: HttpResponse<Institution[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response'});
    }

    search(req?: any): Observable<HttpResponse<Institution[]>> {
        const options = createRequestOption(req);
        return this.http.get<Institution[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<Institution[]>) => this.convertArrayResponse(res));
    }

    findParent(id: number): Observable<HttpResponse<Institution[]>> {
        const options = createRequestOption(id);
        return this.http.get<Institution[]>(`${this.resourcGetParenteUrl}/${id}`, { params: options, observe: 'response' })
            .map((res: HttpResponse<Institution[]>) => this.convertArrayResponse(res));
    }

    // findInstitutionStructures(): Observable<HttpResponse<Institution[]>> {
    //     return this.http.get<Institution[]>(this.resourceInstitutionStructures, {observe: 'response' })
    //         .map((res: HttpResponse<Institution[]>) => this.convertArrayResponse(res));
    // }
    // findInstitutionStructureByInstitutionId(institutionId: number): Observable<EntityResponseType> {
    //     return this.http.get<Institution>(`${this.resourceInstitutionStructures}/${institutionId}`, { observe: 'response'})
    //         .map((res: EntityResponseType) => this.convertResponse(res));
    // }
    
    findInstitutionStructures(): Observable<HttpResponse<any>> {
        return this.http.get<any>(`${this.resourceInstitutionStructures}`, { observe: 'response'})
            .map((res: HttpResponse<any>) => this.convertArrayResponse(res));
    }

    queryNoPaging(req?: any): Observable<HttpResponse<Institution[]>> {
        const options = createRequestOption(req);
        return this.http.get<Institution[]>(this.resourceUrlNoPaging, { params: options, observe: 'response' })
            .map((res: HttpResponse<Institution[]>) => this.convertArrayResponse(res));
    }

    createInstitutionWithAttachment(institution: Institution): Observable<EntityResponseType> {
        const copy = this.convert(institution);
        return this.http.post<Institution>(this.resourceWithAttachmentUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    updateInstitutionWithAttachment(institution: Institution): Observable<EntityResponseType> {
        const copy = this.convert(institution);
        return this.http.put<Institution>(this.resourceWithAttachmentUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: Institution = this.convertItemFromServer(res.body);
        return res.clone({body});
    }

    private convertArrayResponse(res: HttpResponse<Institution[]>): HttpResponse<Institution[]> {
        const jsonResponse: Institution[] = res.body;
        const body: Institution[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }

    /**
     * Convert a returned JSON object to Institution.
     */
    private convertItemFromServer(institution: Institution): Institution {
        const copy: Institution = Object.assign({}, institution);
        copy.createdDate = this.dateUtils
            .convertDateTimeFromServer(institution.createdDate);
        copy.lastModifiedDate = this.dateUtils
            .convertDateTimeFromServer(institution.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a Institution to a JSON which can be sent to the server.
     */
    private convert(institution: Institution): Institution {
        const copy: Institution = Object.assign({}, institution);

        copy.createdDate = this.dateUtils.toDate(institution.createdDate);

        copy.lastModifiedDate = this.dateUtils.toDate(institution.lastModifiedDate);
        return copy;
    }
}
