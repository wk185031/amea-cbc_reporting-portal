import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager, JhiAlertService } from 'ng-jhipster';

import { Institution } from '../../entities/institution/institution.model';
import { InstitutionPopupService } from './institution-popup.service';
import { InstitutionService } from './institution.service';

import { Principal } from '../../shared/auth/principal.service';
import { INDUSTRIES } from '../../common/industry';
import { AppAttachmentService } from '../../common/app-attachment.service';
import { Attachment } from '../../entities/attachment';

import { DomSanitizer } from '../../../../../../node_modules/@angular/platform-browser';

@Component({
    selector: 'jhi-institution-dialog',
    templateUrl: './institution-dialog.component.html'
})
export class InstitutionDialogComponent implements OnInit {
    institution: Institution;
    isSaving: boolean;

    username: string;
    industryOptions: string[];
    institutions: Institution[];

    removeAttachmentFlag: boolean;

    constructor(
        public activeModal: NgbActiveModal,
        private jhiAlertService: JhiAlertService,
        private institutionService: InstitutionService,
        private eventManager: JhiEventManager,
        private principal: Principal,
        private attachmentService: AppAttachmentService,
        private sanitizer: DomSanitizer,
    ) {
        this.principal.identity().then((account) => {
            this.username = account.login;
        });
        this.industryOptions = INDUSTRIES;
    }

    ngOnInit() {
        this.institution.attachments = new Array<Attachment>();
        this.isSaving = false;
        this.removeAttachmentFlag = false;
        let institutionId = -1;
        if (this.institution.id !== undefined) {
            institutionId = this.institution.id;
        }
        this.institutionService.findParent(institutionId)
            .subscribe((res: HttpResponse<Institution[]>) => { 
                this.institutions = res.body;
                if(this.institution.id === undefined){
                    this.institution.parent = this.institutions[0];
                }
                if (this.institution.attachmentGroup) {
                    this.attachmentService.findByAttachmentGroupId(this.institution.attachmentGroup.id).subscribe((attachments: HttpResponse<Attachment[]>) => {
                        this.institution.attachments = attachments.body;
                        this.addImageSource();
                    });
                }
            }, (res: HttpErrorResponse) => this.onError(res.message));
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    save() {
        this.isSaving = true;

        if (this.institution.id !== undefined) {
            this.subscribeToSaveResponse(
                this.institutionService.updateInstitutionWithAttachment(this.institution));
        } else {
            this.institution.type = 'Institution';
            this.subscribeToSaveResponse(
                this.institutionService.createInstitutionWithAttachment(this.institution));
        }
    }

    private subscribeToSaveResponse(result: Observable<HttpResponse<Institution>>) {
        result.subscribe((res: HttpResponse<Institution>) =>
            this.onSaveSuccess(res.body), (res: HttpErrorResponse) => this.onSaveError());
    }

    private onSaveSuccess(result: Institution) {
        this.eventManager.broadcast({ name: 'institutionListModification', content: 'OK'});
        this.isSaving = false;
        this.activeModal.dismiss(result);
    }

    private onSaveError() {
        this.isSaving = false;
    }

    private onError(error: any) {
        this.jhiAlertService.error(error.message, null, null);
    }

    trackInstitutionById(index: number, item: Institution) {
        return item.id;
    }
    trackIndustryByValue(index: number, item: string) {
        return item;
    }

    attachDocumentList(event) {
        this.processNewAttachment(event.srcElement.files);
    }

    private processNewAttachment(files) {
        for (const file of files) {
            const attachment = new Attachment();
            const reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onload = (e: any) => {
                attachment.blobFile = e.target.result.toString().split(',')[1];
                attachment.name = file.name;
                attachment.type = 'Image';
                const theBlob = new Blob([file], { type: 'image/jpeg' });
                const url = window.URL.createObjectURL(theBlob);
                attachment.imageSource = this.sanitizer.bypassSecurityTrustUrl(url);
                attachment.removeFlag = false;
                this.institution.attachments.push(attachment);
            };
        }
    }
    private addImageSource() {        
        for (let i = 0; i < this.institution.attachments.length; i++) {
            this.institution.attachments[i].removeFlag = false;
            this.institution.attachments[i].hiddenFlag = false;
            
            console.log("remove flag: " + this.institution.attachments[i].removeFlag);
            const url = window.URL.createObjectURL(this.b64toBlob(this.institution.attachments[i].blobFile, 'image/jpeg'));
            this.institution.attachments[i].imageSource = this.sanitizer.bypassSecurityTrustUrl(url);
        }
    }
    private processInstitutionImageUrl() {
        const sources = [];
        

        for (const attachment of this.institution.attachments) {
            const a: Attachment = attachment;
            const url = window.URL.createObjectURL(this.b64toBlob(a.blobFile, 'image/jpeg'));
            sources.push(this.sanitizer.bypassSecurityTrustUrl(url));
        }
        return sources;
    }

    b64toBlob(b64Data, contentType, sliceSize?) {
        contentType = contentType || '';
        sliceSize = sliceSize || 512;

        const byteCharacters = atob(b64Data);
        const byteArrays = [];

        for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
            const slice = byteCharacters.slice(offset, offset + sliceSize);

            const byteNumbers = new Array(slice.length);
            for (let i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }

            const byteArray = new Uint8Array(byteNumbers);

            byteArrays.push(byteArray);
        }

        const blob = new Blob(byteArrays, { type: contentType });
        return blob;
    }

    removeFlagToggle(index : string){
        this.institution.attachments[index].removeFlag = !this.institution.attachments[index].removeFlag;
        console.log("remove flag: " + this.institution.attachments[index].removeFlag);
        //Disable remove attachment button if no file 
        let removeFlag = false;
        for (const attachment of this.institution.attachments) {
            if (attachment.removeFlag && !attachment.hiddenFlag){
                removeFlag = true;
            }
        }
        this.removeAttachmentFlag = removeFlag;
    }
    removeAttachment(){
        for (const attachment of this.institution.attachments) {
            if (attachment.removeFlag){
                attachment.hiddenFlag = true;
            }
        }
        this.removeAttachmentFlag = false;
    }
    
}

@Component({
    selector: 'jhi-institution-popup',
    template: ''
})
export class InstitutionPopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private institutionPopupService: InstitutionPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            if ( params['id'] ) {
                this.institutionPopupService
                    .open(InstitutionDialogComponent as Component, params['id']);
            } else {
                this.institutionPopupService
                    .open(InstitutionDialogComponent as Component);
            }
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
