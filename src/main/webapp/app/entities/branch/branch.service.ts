import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { Branch } from './branch.model';
import { createRequestOption } from '../../shared';

export type EntityResponseType = HttpResponse<Branch>;

@Injectable()
export class BranchService {

    private resourceUrl =  SERVER_API_URL + 'api/branches';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }
    
    update(branch: Branch): Observable<EntityResponseType> {
        const copy = this.convert(branch);
        return this.http.put<Branch>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<Branch>(`${this.resourceUrl}/${id}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<Branch[]>> {
        const options = createRequestOption(req);
        return this.http.get<Branch[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<Branch[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: Branch = this.convertItemFromServer(res.body);
        return res.clone({body});
    }

    private convertArrayResponse(res: HttpResponse<Branch[]>): HttpResponse<Branch[]> {
        const jsonResponse: Branch[] = res.body;
        const body: Branch[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }

    /**
     * Convert a returned JSON object to Branch.
     */
    private convertItemFromServer(branch: Branch): Branch {
        const copy: Branch = Object.assign({}, branch);
        copy.abr_last_update_ts = this.dateUtils
            .convertDateTimeFromServer(branch.abr_last_update_ts);
        return copy;
    }

    /**
     * Convert a Branch to a JSON which can be sent to the server.
     */
    private convert(branch: Branch): Branch {
        const copy: Branch = Object.assign({}, branch);

        copy.abr_last_update_ts = this.dateUtils.toDate(branch.abr_last_update_ts);
        return copy;
    }
}
