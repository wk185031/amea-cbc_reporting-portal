import { Component, OnInit, OnDestroy, Input, OnChanges } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpResponse } from '@angular/common/http';
import { Subscription } from 'rxjs/Subscription';
import { JhiEventManager } from 'ng-jhipster';

import { Institution } from '../../entities/institution/institution.model';
import { InstitutionService } from './institution.service';
import { AppPermissionService } from '../../common/app-permission.service';
import { AppPermissionsConfigurationService } from '../role/app-resource/app-permissions-configuration.service';
import { AppAttachmentService } from '../../common/app-attachment.service';
import { Attachment } from '../../entities/attachment';
import { DomSanitizer } from '../../../../../../node_modules/@angular/platform-browser';
import { FormGroup, FormBuilder } from '@angular/forms';

@Component({
    selector: 'jhi-institution-detail',
    templateUrl: './institution-detail.component.html'
})
export class InstitutionDetailComponent implements OnInit, OnDestroy, OnChanges {

    @Input() institutionId: number;
    institution: Institution;
    private subscription: Subscription;
    private eventSubscriber: Subscription;

    constructor(
        private eventManager: JhiEventManager,
        private institutionService: InstitutionService,
        private route: ActivatedRoute,
        private appPermissionService: AppPermissionService,
        private attachmentService: AppAttachmentService,
        private sanitizer: DomSanitizer
    ) {
    }

    ngOnInit() {
        this.subscription = this.route.params.subscribe((params) => {
            this.load(params['id']);
        });
        this.registerChangeInInstitutions();
    }

    ngOnChanges() {
        this.load(this.institutionId);
    }

    load(id) {
        if (!id) {
            id = this.institutionId;
        }
        this.institutionService.find(id)
            .subscribe((institutionResponse: HttpResponse<Institution>) => {
                this.institution = institutionResponse.body;
                const attachment = [];
                if (this.institution.attachmentGroup) {
                    this.attachmentService.findByAttachmentGroupId(this.institution.attachmentGroup.id)
                        .subscribe((attachments: HttpResponse<Attachment[]>) => {
                            this.institution.attachments = attachments.body;
                            this.addImageSource();
                    });
                }
            });
    }
    previousState() {
        window.history.back();
    }

    ngOnDestroy() {
        this.subscription.unsubscribe();
        this.eventManager.destroy(this.eventSubscriber);
    }

    registerChangeInInstitutions() {
        this.eventSubscriber = this.eventManager.subscribe(
            'institutionListModification',
            (response) => this.load(this.institution.id)
        );
    }

    private processInstitutionImageUrl() {
        const sources = [];
        for (const attachment of this.institution.attachmentGroup.attachments) {
            const a: Attachment = attachment;
            a.blobFile = this.b64toBlob(a.blobFile, 'image/jpeg');
            const url = window.URL.createObjectURL(a.blobFile);
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

        const blob = new Blob(byteArrays, {type: contentType});
        return blob;
    }
    private addImageSource() {        
        for (let i = 0; i < this.institution.attachments.length; i++) {
            this.institution.attachments[i].removeFlag = false;
            const url = window.URL.createObjectURL(this.b64toBlob(this.institution.attachments[i].blobFile, 'image/jpeg'));
            this.institution.attachments[i].imageSource = this.sanitizer.bypassSecurityTrustUrl(url);
        }
    }
}
