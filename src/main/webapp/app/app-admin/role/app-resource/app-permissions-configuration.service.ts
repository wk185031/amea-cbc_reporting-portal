import { Injectable } from '@angular/core';
import { JhiDateUtils } from 'ng-jhipster';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { createRequestOption } from '../../../shared';
import { AppResource } from '../../../entities/app-resource/app-resource.model';

export type EntityResponseType = HttpResponse<AppResource>;

@Injectable()
export class AppPermissionsConfigurationService {

    static readonly CODE_ADMIN = 'Admin';
    static readonly CODE_INSTITUTION = 'Institution';
    static readonly CODE_USER_ROLE = 'UserRole';
    static readonly CODE_USER = 'User';
    static readonly CODE_SYSTEM_CONFIGURATION = 'SystemConfiguration';
    static readonly CODE_CONFIGURATION = 'Configuration';
    static readonly CODE_CUSTOMER = 'Customer';
    static readonly CODE_WORKFLOW_TEMPLATE = 'WorkflowTemplate';
    static readonly CODE_OPERATION = 'Operation';
    static readonly CODE_DASHBOARD = 'Dashboard';
    static readonly CODE_SHIPMENT = 'Shipment';

    private resourceUrl = 'api/app-permissions-resources';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    query(req?: any): Observable<HttpResponse<AppResource[]>> {
        const options = createRequestOption(req);
        return this.http.get<AppResource[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<AppResource[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: AppResource = this.convertItemFromServer(res.body);
        return res.clone({body});
    }  

    private convertArrayResponse(res: HttpResponse<AppResource[]>): HttpResponse<AppResource[]> {
        const jsonResponse: AppResource[] = res.body;
        const body: AppResource[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }   
    
    /**
     * Convert a returned JSON object to AppResource.
     */
    private convertItemFromServer(appResource: AppResource): AppResource {
        const copy: AppResource = Object.assign({}, appResource);
        copy.createdDate = this.dateUtils
            .convertDateTimeFromServer(appResource.createdDate);
        copy.lastModifiedDate = this.dateUtils
            .convertDateTimeFromServer(appResource.lastModifiedDate);
        return copy;
    }

}
