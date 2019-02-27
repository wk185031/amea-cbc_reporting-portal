import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { Attachment } from '../entities/attachment/attachment.model';
import { createRequestOption } from '../shared';

export type EntityResponseType = HttpResponse<Attachment>;

@Injectable()
export class AppAttachmentService {

    private resourceUrl =  SERVER_API_URL + 'api/attachments';
    private resourceSearchUrl = SERVER_API_URL + 'api/_search/attachments';
    private resourceUrlMultiple = SERVER_API_URL + 'api/attachments-multiple';
    private resourceUrlByAttachmentGroup = SERVER_API_URL + 'api/attachments-by-attachment-group';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(attachment: Attachment): Observable<EntityResponseType> {
        const copy = this.convert(attachment);
        return this.http.post<Attachment>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(attachment: Attachment): Observable<EntityResponseType> {
        const copy = this.convert(attachment);
        return this.http.put<Attachment>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<Attachment>(`${this.resourceUrl}/${id}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<Attachment[]>> {
        const options = createRequestOption(req);
        return this.http.get<Attachment[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<Attachment[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response'});
    }

    search(req?: any): Observable<HttpResponse<Attachment[]>> {
        const options = createRequestOption(req);
        return this.http.get<Attachment[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<Attachment[]>) => this.convertArrayResponse(res));
    }

    findByAttachmentGroupId(attachmentGroupId: number): Observable<any> {
        // return this.http.get(`${this.resourceUrlByAttachmentGroup}/${attachmentGroupId}`);
        return this.http.get<Attachment[]>(`${this.resourceUrlByAttachmentGroup}/${attachmentGroupId}`, { observe: 'response' })
            .map((res: HttpResponse<Attachment[]>) => this.convertArrayResponse(res));
    }

    createMultiple(attachments: Attachment[]): Observable<any> {
        return this.http.post(this.resourceUrlMultiple, attachments)
            .map((res: HttpResponse<Attachment[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: Attachment = this.convertItemFromServer(res.body);
        return res.clone({body});
    }

    private convertArrayResponse(res: HttpResponse<Attachment[]>): HttpResponse<Attachment[]> {
        const jsonResponse: Attachment[] = res.body;
        const body: Attachment[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }

    /**
     * Convert a returned JSON object to Attachment.
     */
    private convertItemFromServer(attachment: Attachment): Attachment {
        const copy: Attachment = Object.assign({}, attachment);
        copy.createdDate = this.dateUtils
            .convertDateTimeFromServer(attachment.createdDate);
        copy.lastModifiedDate = this.dateUtils
            .convertDateTimeFromServer(attachment.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a Attachment to a JSON which can be sent to the server.
     */
    private convert(attachment: Attachment): Attachment {
        const copy: Attachment = Object.assign({}, attachment);

        copy.createdDate = this.dateUtils.toDate(attachment.createdDate);

        copy.lastModifiedDate = this.dateUtils.toDate(attachment.lastModifiedDate);
        return copy;
    }
}
