import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

import { EntityAuditEvent } from './entity-audit-event.model';

@Injectable()
export class EntityAuditService {

    constructor(private http: HttpClient) { }

    getAllAudited(): Observable<HttpResponse<string[]>> {
        return this.http.get<string[]>('api/audits/entity/all', { observe: 'response'})
            .map((response: HttpResponse<string[]>) => response);
    }

    findByEntity(entity: string, limit: number): Observable<HttpResponse<EntityAuditEvent[]>> {
        let params = new HttpParams();
        params = params.append('entityType', entity);
        params = params.append('limit', limit.toString());

        return this.http.get<EntityAuditEvent[]>('api/audits/entity/changes', { params: params, observe: 'response' })
            .map((response: HttpResponse<EntityAuditEvent[]>) => response);
    }

    getPrevVersion(qualifiedName: string, entityId: string, commitVersion: number) {
        let params = new HttpParams();
        params = params.append('qualifiedName', qualifiedName);
        params = params.append('entityId', entityId);
        params = params.append('commitVersion', commitVersion.toString());

        return this.http
            .get<EntityAuditEvent>('api/audits/entity/changes/version/previous', { params: params, observe: 'response' })
            .map((response: HttpResponse<EntityAuditEvent>) => response);
    }
}
