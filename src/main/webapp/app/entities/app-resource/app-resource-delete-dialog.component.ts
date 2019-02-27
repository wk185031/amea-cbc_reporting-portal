import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';

import { AppResource } from './app-resource.model';
import { AppResourcePopupService } from './app-resource-popup.service';
import { AppResourceService } from './app-resource.service';

@Component({
    selector: 'jhi-app-resource-delete-dialog',
    templateUrl: './app-resource-delete-dialog.component.html'
})
export class AppResourceDeleteDialogComponent {

    appResource: AppResource;

    constructor(
        private appResourceService: AppResourceService,
        public activeModal: NgbActiveModal,
        private eventManager: JhiEventManager
    ) {
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    confirmDelete(id: number) {
        this.appResourceService.delete(id).subscribe((response) => {
            this.eventManager.broadcast({
                name: 'appResourceListModification',
                content: 'Deleted an appResource'
            });
            this.activeModal.dismiss(true);
        });
    }
}

@Component({
    selector: 'jhi-app-resource-delete-popup',
    template: ''
})
export class AppResourceDeletePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private appResourcePopupService: AppResourcePopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            this.appResourcePopupService
                .open(AppResourceDeleteDialogComponent as Component, params['id']);
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
