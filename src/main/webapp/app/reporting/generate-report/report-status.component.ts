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
    	 
    	 let jsonDetailObject = this.generateReportService.getJobDetail();
   		 
   		for (var key of Object.keys(jsonDetailObject)) {
    		console.log(key + " -> " + jsonDetailObject[key])
    		this.reportStatuses.push(key + ' - ' + jsonDetailObject[key]);
		}
    }
}
