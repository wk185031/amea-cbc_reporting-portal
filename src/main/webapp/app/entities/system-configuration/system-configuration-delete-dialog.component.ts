import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiEventManager } from 'ng-jhipster';

import { SystemConfiguration } from './system-configuration.model';
import { SystemConfigurationPopupService } from './system-configuration-popup.service';
import { SystemConfigurationService } from './system-configuration.service';

@Component({
    selector: 'jhi-system-configuration-delete-dialog',
    templateUrl: './system-configuration-delete-dialog.component.html'
})
export class SystemConfigurationDeleteDialogComponent {

    systemConfiguration: SystemConfiguration;

    constructor(
        private systemConfigurationService: SystemConfigurationService,
        public activeModal: NgbActiveModal,
        private eventManager: JhiEventManager
    ) {
    }

    clear() {
        this.activeModal.dismiss('cancel');
    }

    confirmDelete(id: number) {
        this.systemConfigurationService.delete(id).subscribe((response) => {
            this.eventManager.broadcast({
                name: 'systemConfigurationListModification',
                content: 'Deleted an systemConfiguration'
            });
            this.activeModal.dismiss(true);
        });
    }
}

@Component({
    selector: 'jhi-system-configuration-delete-popup',
    template: ''
})
export class SystemConfigurationDeletePopupComponent implements OnInit, OnDestroy {

    routeSub: any;

    constructor(
        private route: ActivatedRoute,
        private systemConfigurationPopupService: SystemConfigurationPopupService
    ) {}

    ngOnInit() {
        this.routeSub = this.route.params.subscribe((params) => {
            this.systemConfigurationPopupService
                .open(SystemConfigurationDeleteDialogComponent as Component, params['id']);
        });
    }

    ngOnDestroy() {
        this.routeSub.unsubscribe();
    }
}
