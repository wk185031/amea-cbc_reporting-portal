import { Component, OnInit, Input, AfterViewInit, Renderer, ElementRef } from '@angular/core';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { Router } from '@angular/router';
import { JhiEventManager } from 'ng-jhipster';

import { JobHistory } from '../../app-admin/job-history/job-history.model';

import { ProfileService } from '../../layouts/profiles/profile.service';
import { GenerateReportService } from './generate-report.service';

@Component({
    selector: 'jhi-report-status-modal',
     templateUrl: './report-status.component.html'
})

export class ReportStatusComponent implements OnInit {

	reportStatuses = [];
	reportCategories = [];
	totalCount: any;
    
    constructor(
    	private generateReportService: GenerateReportService,
        private eventManager: JhiEventManager,
        private elementRef: ElementRef,
        private renderer: Renderer,
        private router: Router,
        public activeModal: NgbActiveModal,
       
    ) {
       
    }

    ngOnInit() {
        console.log('After init');
       	this.getReportStatus();
    }

    cancel() {
        this.activeModal.dismiss('cancel');
    }
    
    getReportStatus(){
    	 console.log('generateReportService.getJobDetail():' + this.generateReportService.getJobDetail());
    	 
    	 interface ReportStatus {
			[key: string]: any
		}
    	 
    	let jsonDetailObject = this.generateReportService.getJobDetail();
   		 
   		for (var key of Object.keys(jsonDetailObject)) {
   			var result = jsonDetailObject[key].split('|')
    		
    		if(this.reportCategories.indexOf(result[0]) == -1)
    			this.reportCategories.push(result[0]);
    		    		
			let obj: ReportStatus = {};
			obj.reportName = key;
			obj.reportCategory = result[0];
			obj.reportStatus = result[1];
    		
    		this.reportStatuses.push(obj);
		}
		
		this.totalCount = this.reportStatuses.length;
		
		this.reportCategories.sort();
		
		this.reportStatuses.sort((a, b) => a.reportName.localeCompare(b.reportName));
		
		let html = "";
		
		for (var i = 0; i < this.reportCategories.length; i++) {
			html += " </br><h6>" + this.reportCategories[i] + "</h6>";
			for (let j in this.reportStatuses) {
			   if (this.reportStatuses[j].reportCategory === this.reportCategories[i]){
					html += this.reportStatuses[j].reportName + ' - ' + this.reportStatuses[j].reportStatus + "</br>";
			   }
			}
			
			document.getElementById("reportStatus").innerHTML = html;
		}
		
    }
}
