import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { JobHistory } from './job-history.model';
import { createRequestOption } from '../../shared';

export type EntityResponseType = HttpResponse<JobHistory>;

@Injectable()
export class JobHistoryService {

    private resourceUrl =  SERVER_API_URL + 'api/job-history';
    //private resourceSearchUrl = SERVER_API_URL + 'api/_search/job-history';
    private resourceSearchUrl = SERVER_API_URL + 'api/_searchlatest/job-history';
    private resourceDownloadReportByDateUrl = SERVER_API_URL + 'api/job-history-generated';
        
    jobHistory: JobHistory[] = [];

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) { }

    create(jobHistory: JobHistory): Observable<EntityResponseType> {
        const copy = this.convert(jobHistory);
        return this.http.post<JobHistory>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(jobHistory: JobHistory): Observable<EntityResponseType> {
        const copy = this.convert(jobHistory);
        return this.http.put<JobHistory>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<JobHistory>(`${this.resourceUrl}/${id}`, { observe: 'response'})
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<JobHistory[]>> {
        const options = createRequestOption(req);
        return this.http.get<JobHistory[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<JobHistory[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response'});
    }

    //search(req?: any): Observable<HttpResponse<JobHistory[]>> {
    //   const options = createRequestOption(req);
    //  return this.http.get<JobHistory[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
    //     .map((res: HttpResponse<JobHistory[]>) => this.convertArrayResponse(res));
    //}

    search(req?: any): Observable<HttpResponse<JobHistory>> {
            const options = createRequestOption(req);
            return this.http.get<JobHistory>(this.resourceSearchUrl, { params: options, observe: 'response' })
                .map((res: HttpResponse<JobHistory>) => res);
        }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: JobHistory = this.convertItemFromServer(res.body);
        return res.clone({body});
    }

    private convertArrayResponse(res: HttpResponse<JobHistory[]>): HttpResponse<JobHistory[]> {
        const jsonResponse: JobHistory[] = res.body;
        const body: JobHistory[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({body});
    }

    /**
     * Convert a returned JSON object to JobHistory.
     */
    private convertItemFromServer(jobHistory: JobHistory): JobHistory {
        const copy: JobHistory = Object.assign({}, jobHistory);
        //console.log("###" + jobHistory.createdDate);
        copy.createdDate = this.dateUtils.convertDateTimeFromServer(jobHistory.createdDate);
        console.log(jobHistory.createdDate);
        console.log(copy.createdDate);

        return copy;
    }

    /**
     * Convert a JobHistory to a JSON which can be sent to the server.
     */
    private convert(jobHistory: JobHistory): JobHistory {
        const copy: JobHistory = Object.assign({}, jobHistory);
        copy.createdDate = this.dateUtils.toDate(jobHistory.createdDate);

        return copy;
    }
    
    searchJobHistory(req?: any): Observable<HttpResponse<JobHistory[]>> {
        const options = createRequestOption(req);
        return this.http.get<JobHistory[]>(this.resourceDownloadReportByDateUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<JobHistory[]>) => res);
    }
        
    testGetData(){
    	console.log('It works here. size: '+Object.keys(this.jobHistory).length)
    	return this.jobHistory;
    }
}
