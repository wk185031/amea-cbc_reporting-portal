import { Injectable } from '@angular/core';
import { HttpClient, HttpResponse, HttpRequest } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { SERVER_API_URL } from '../../app.constants';

import { JhiDateUtils } from 'ng-jhipster';

import { createRequestOption } from '../../shared';
import { ReportGeneration } from './generate-report.model';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';

export type EntityResponseType = HttpResponse<ReportGeneration>;

@Injectable()
export class GenerateReportService {

    private resourceUrl = SERVER_API_URL + 'api/reportGeneration';
    private resourceSearchUrl = SERVER_API_URL + 'api/_search/reportGeneration';
    private resourceUrlNoPaging = SERVER_API_URL + 'api/reportGeneration-nopaging';
    private resourcGetParenteUrl = SERVER_API_URL + 'api/reportGeneration-parent-for-reportGeneration-and-user';
    private resourceGetGeneratedReport = SERVER_API_URL + 'api/report-get-generated';
    private resourceDownloadReport = SERVER_API_URL + 'api/download-report';
    private resourceDeleteReport = SERVER_API_URL + 'api/delete-report';
    private resourceExportReport = SERVER_API_URL + 'api/export-report';
    private jobDetail = '';
    public reportDefinition: ReportDefinition[];

    constructor(private http: HttpClient, private dateUtils: JhiDateUtils) {
        this.reportDefinition = [];
    }

    create(reportGeneration: ReportGeneration): Observable<EntityResponseType> {
        const copy = this.convert(reportGeneration);
        return this.http.post<ReportGeneration>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    update(reportGeneration: ReportGeneration): Observable<EntityResponseType> {
        const copy = this.convert(reportGeneration);
        return this.http.put<ReportGeneration>(this.resourceUrl, copy, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    find(id: number): Observable<EntityResponseType> {
        return this.http.get<ReportGeneration>(`${this.resourceUrl}/${id}`, { observe: 'response' })
            .map((res: EntityResponseType) => this.convertResponse(res));
    }

    query(req?: any): Observable<HttpResponse<ReportGeneration[]>> {
        const options = createRequestOption(req);
        return this.http.get<ReportGeneration[]>(this.resourceUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportGeneration[]>) => this.convertArrayResponse(res));
    }

    delete(id: number): Observable<HttpResponse<any>> {
        return this.http.delete<any>(`${this.resourceUrl}/${id}`, { observe: 'response' });
    }

    search(req?: any): Observable<HttpResponse<ReportGeneration[]>> {
        const options = createRequestOption(req);
        return this.http.get<ReportGeneration[]>(this.resourceSearchUrl, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportGeneration[]>) => this.convertArrayResponse(res));
    }

    findParent(id: number): Observable<HttpResponse<ReportGeneration[]>> {
        const options = createRequestOption(id);
        return this.http.get<ReportGeneration[]>(`${this.resourcGetParenteUrl}/${id}`, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportGeneration[]>) => this.convertArrayResponse(res));
    }

    queryNoPaging(req?: any): Observable<HttpResponse<ReportGeneration[]>> {
        const options = createRequestOption(req);
        return this.http.get<ReportGeneration[]>(this.resourceUrlNoPaging, { params: options, observe: 'response' })
            .map((res: HttpResponse<ReportGeneration[]>) => this.convertArrayResponse(res));
    }

    private convertResponse(res: EntityResponseType): EntityResponseType {
        const body: ReportGeneration = this.convertItemFromServer(res.body);
        return res.clone({ body });
    }

    private convertArrayResponse(res: HttpResponse<ReportGeneration[]>): HttpResponse<ReportGeneration[]> {
        const jsonResponse: ReportGeneration[] = res.body;
        const body: ReportGeneration[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        return res.clone({ body });
    }

    private convertArrayDefinitionResponse(res: HttpResponse<ReportGeneration[]>): HttpResponse<ReportDefinition[]> {
        const jsonResponse: ReportDefinition[] = res.body;
        const body: ReportDefinition[] = [];
        for (let i = 0; i < jsonResponse.length; i++) {
            body.push(this.convertItemFromServer(jsonResponse[i]));
        }
        this.reportDefinition = body;
        return res.clone({ body });
    }

    /**
     * Convert a returned JSON object to ReportGeneration.
     */
    private convertItemFromServer(reportGeneration: ReportGeneration): ReportGeneration {
        const copy: ReportGeneration = Object.assign({}, reportGeneration);
        copy.createdDate = this.dateUtils.convertDateTimeFromServer(reportGeneration.createdDate);
        copy.lastModifiedDate = this.dateUtils.convertDateTimeFromServer(reportGeneration.lastModifiedDate);
        return copy;
    }

    /**
     * Convert a ReportGeneration to a JSON which can be sent to the server.
     */
    private convert(reportGeneration: ReportGeneration): ReportGeneration {
        const copy: ReportGeneration = Object.assign({}, reportGeneration);
        copy.createdDate = this.dateUtils.toDate(reportGeneration.createdDate);
        copy.lastModifiedDate = this.dateUtils.toDate(reportGeneration.lastModifiedDate);
        return copy;
    }

    generateReport(branchId:number, institutionId: number, reportCategoryId: number, reportId: number, txnStartDate: string): Observable<HttpResponse<ReportDefinition[]>> {
        console.log("generateReport");
        return this.http.get<ReportDefinition[]>(`${this.resourceUrl}/${institutionId}/${reportCategoryId}/${reportId}/${txnStartDate}`, { observe: 'response' })
            .map((res: HttpResponse<ReportDefinition[]>) => this.convertArrayDefinitionResponse(res));
    }

    generateReportWithStartEndDate(branchId:number, institutionId: number, reportCategoryId: number, reportId: number, txnStartDateTime: string, txnEndDateTime: string): Observable<HttpResponse<ReportDefinition[]>> {
        console.log("generateReport with start and end timestamp");
        return this.http.get<ReportDefinition[]>(`${this.resourceUrl}/${institutionId}/${reportCategoryId}/${reportId}?startDateTime=${txnStartDateTime}&endDateTime=${txnEndDateTime}`, { observe: 'response' })
            .map((res: HttpResponse<ReportDefinition[]>) => this.convertArrayDefinitionResponse(res));
    }

    downloadReport(branchId:number, institutionId: number, date: string, reportCategoryId: number, reportName: string, jobId: number, frequency: string): any {
        console.log("downloadReport");
        const rptName = encodeURIComponent('${reportName}');
        const req = new HttpRequest('GET', `${this.resourceDownloadReport}/${institutionId}/${date}/${reportCategoryId}/${rptName}/${jobId}/${frequency}`, {
            requestProgress: true,
            responseType: 'blob'
        });
        return req;
    }
    
    download(jobId: number) {
    	return this.http.get(`${this.resourceDownloadReport}/${jobId}`, {
      		responseType: 'blob',
      		observe: 'response'
    	});
  	}

    deleteReport(jobId: string) {
        console.log("deleteReport");
        return this.http.delete(`${this.resourceDeleteReport}/${jobId}`, { observe: 'response' });
    }

    getReport(institutionId: number, date: string, reportCategoryId: number): Observable<Response> {
        console.log("getReport");
        return this.http.get(`${this.resourceGetGeneratedReport}/${institutionId}/${date}/${reportCategoryId}`)
            .map((res: any) => res);
    }
    
    setJobDetail(parseDetail){
    	this.jobDetail = parseDetail;
    }
    
    getJobDetail(){
    	return this.jobDetail;
    }
    
    exportReport(reportCategory: string, reportName:string, txnStartDate: string, txnEndDate: string) {
    	console.log('Export method in GenerateReportService');
    	return this.http.get(`${this.resourceExportReport}/${reportCategory}/${reportName}?startDate=${txnStartDate}&endDate=${txnEndDate}`, {
    	 responseType: 'blob',
    	 observe: 'response' });
  	}
}
