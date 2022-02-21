import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { UserExtra } from '../../entities/user-extra/user-extra.model';
import { createRequestOption } from '../../shared';

export type EntityResponseType = HttpResponse<UserExtra>;

@Injectable()
export class UserExtraService {

    private reousrceBase = 'api';
    private resourceUrl = 'api/user-extras';
    private resourceByUserExtraIdsUrl = 'api/user-extras-by-ids';
    private resourceSearchUrl = 'api/_search/user-extras';
    private resourceByLoginUrl = 'api/user-extras-by-user-login';
    private resourceByUserIdUrl = 'api/user-extras-by-user-id';
    private resourceLoginUpdateUrl = 'api/user-extras-login-update';
    private resourceByRoles = 'user-extras-by-roles';
    private resourceByUser = 'api/user-extras-by-user';
    private resourceUrlPagination = 'api/user-extras-pagination';

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(userExtra: UserExtra): Observable<EntityResponseType> {
        const copy = this.convert(userExtra);
        return this.http.post<UserExtra>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    fillAllUserExtrasWithPagination(req?: any): Observable<HttpResponse<UserExtra[]>> {
        const options = createRequestOption(req);
        return this.http.get<UserExtra[]>(this.resourceUrlPagination, { params: options, observe: 'response' })
            .map((res: HttpResponse<UserExtra[]>) => this.convertArrayResponse(res))
            ;
    }

    update(userExtra: UserExtra): Observable<EntityResponseType> {
        const copy = this.convert(userExtra);

        return this.http.put<UserExtra>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<UserExtra>(`${this.resourceUrl}/${id}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    // findByUserId(id: number): Observable<EntityResponseType> {
    //     return this.http.get<UserExtra>(`${this.resourceByUserIdUrl}/${id}`, { observe: 'response'})
    //         .map((res: EntityResponseType) => this.convertResponse(res));
    // }

    // findByUserIds(ids: number[]): Observable<HttpResponse<UserExtra[]>> {
    //     return this.http.get<UserExtra[]>(`${this.resourceByUserExtraIdsUrl}/${ids}`, { observe: 'response'})
    //         .map((res: HttpResponse<UserExtra[]>) => this.convertArrayResponse(res));
    // }

    // findByUserLogin(logins: string[], req?: any): Observable<EntityResponseType> {
    //     const options = createRequestOption(req);
    //     return this.http.get<UserExtra>(`${this.resourceByLoginUrl}/${logins}`, { params: options, observe: 'response' }).map(
    //         (res: EntityResponseType) => this.convertResponse(res)
    //     );
    // }

    // findByRoles(rolesName: string,institutionId: number): Observable<HttpResponse<UserExtra[]>> {
    //     return this.http.get<UserExtra[]>(`${this.reousrceBase}/${institutionId}/${this.resourceByRoles}/${rolesName}`, { observe: 'response'})
    //         .map((res: HttpResponse<UserExtra[]>) => this.convertArrayResponse(res));
    // }

    // findByUser(userId: number): Observable<UserExtra> {
    //     return this.http.get(`${this.resourceByUser}/${userId}`).map((res: Response) => {
    //         const jsonResponse = res.json();
    //         return this.convertItemFromServer(jsonResponse);
    //     });
    // }

    query(req?: any): Observable<HttpResponse<UserExtra[]>> {
        const options = createRequestOption(req);
        return this.http.get<UserExtra[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<UserExtra[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response'});
    }

    search(req?: any): Observable<HttpResponse<UserExtra[]>> {
        const options = createRequestOption(req);
        return this.http.get<UserExtra[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<UserExtra[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: UserExtra = this.convertItemFromServer(res.body);
        return res.clone({body});
    }

    private convertArrayResponse(res: HttpResponse<UserExtra[]>): HttpResponse<UserExtra[]> {
        const jsonResponse: UserExtra[] = res.body;
        const body: UserExtra[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }

    /**
     * Convert a returned JSON object to UserExtra.
     */
    private convertItemFromServer(userExtra: UserExtra): UserExtra {
        const copy: UserExtra = Object.assign({}, userExtra);
        copy.createdDate = this.dateUtils
            .convertDateTimeFromServer(userExtra.createdDate);
        copy.lastModifiedDate = this.dateUtils
            .convertDateTimeFromServer(userExtra.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a UserExtra to a JSON which can be sent to the server.
     */
    private convert(userExtra: UserExtra): UserExtra {
        const copy: UserExtra = Object.assign({}, userExtra);
        if (userExtra.user.activated) {
        	copy.user.activated = true;
        } else {
        	copy.user.activated = false;
        }

        copy.createdDate = this.dateUtils.toDate(userExtra.createdDate);

        copy.lastModifiedDate = this.dateUtils.toDate(userExtra.lastModifiedDate);
        return copy;
    }
}
