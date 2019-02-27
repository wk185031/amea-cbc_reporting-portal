import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { AttachmentGroup } from './attachment-group.model';
import { createRequestOption } from '../../shared';

export type EntityResponseType = HttpResponse<AttachmentGroup>;

@Injectable()
export class AttachmentGroupService {

    private resourceUrl =  SERVER_API_URL + 'api/attachment-groups';
    private resourceSearchUrl = SERVER_API_URL + 'api/_search/attachment-groups';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(attachmentGroup: AttachmentGroup): Observable<EntityResponseType> {
        const copy = this.convert(attachmentGroup);
        return this.http.post<AttachmentGroup>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(attachmentGroup: AttachmentGroup): Observable<EntityResponseType> {
        const copy = this.convert(attachmentGroup);
        return this.http.put<AttachmentGroup>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<AttachmentGroup>(`${this.resourceUrl}/${id}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<AttachmentGroup[]>> {
        const options = createRequestOption(req);
        return this.http.get<AttachmentGroup[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<AttachmentGroup[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response'});
    }

    search(req?: any): Observable<HttpResponse<AttachmentGroup[]>> {
        const options = createRequestOption(req);
        return this.http.get<AttachmentGroup[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<AttachmentGroup[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: AttachmentGroup = this.convertItemFromServer(res.body);
        return res.clone({body});
    }

    private convertArrayResponse(res: HttpResponse<AttachmentGroup[]>): HttpResponse<AttachmentGroup[]> {
        const jsonResponse: AttachmentGroup[] = res.body;
        const body: AttachmentGroup[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }

    /**
     * Convert a returned JSON object to AttachmentGroup.
     */
    private convertItemFromServer(attachmentGroup: AttachmentGroup): AttachmentGroup {
        const copy: AttachmentGroup = Object.assign({}, attachmentGroup);
        copy.createdDate = this.dateUtils
            .convertDateTimeFromServer(attachmentGroup.createdDate);
        copy.lastModifiedDate = this.dateUtils
            .convertDateTimeFromServer(attachmentGroup.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a AttachmentGroup to a JSON which can be sent to the server.
     */
    private convert(attachmentGroup: AttachmentGroup): AttachmentGroup {
        const copy: AttachmentGroup = Object.assign({}, attachmentGroup);

        copy.createdDate = this.dateUtils.toDate(attachmentGroup.createdDate);

        copy.lastModifiedDate = this.dateUtils.toDate(attachmentGroup.lastModifiedDate);
        return copy;
    }
}
