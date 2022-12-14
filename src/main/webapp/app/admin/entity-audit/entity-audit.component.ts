import { Component, OnInit } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { JhiAlertService } from 'ng-jhipster';

import { EntityAuditService } from './entity-audit.service';
import { EntityAuditEvent } from './entity-audit-event.model';
import { EntityAuditModalComponent } from './entity-audit-modal.component';

@Component({
    selector: 'jhi-entity-audit',
    templateUrl: './entity-audit.component.html',
    styles: [`
      .code {
        background: #dcdada;
        padding: 10px;
      }
    `]
})
export class EntityAuditComponent implements OnInit {
    audits: EntityAuditEvent[];
    entities: string[] = [];
    selectedEntity: string;
    limits = [25, 50, 100, 200];
    selectedLimit = this.limits[0];
    loading = false;
    filterEntityId = '';
    orderProp: string;
    reverse = false;

    constructor(
        private modalService: NgbModal,
        private service: EntityAuditService,
        private alertService: JhiAlertService
    ) {}

    ngOnInit() {
        this.service.getAllAudited().subscribe((res) => {
            this.entities = res.body;
        });
    }

    loadChanges() {
        this.loading = true;
        this.service.findByEntity(this.selectedEntity, this.selectedLimit)
            .subscribe((res) => {
                this.audits = res.body.map((it) => {
                    it.entityValue = JSON.parse(it.entityValue);
                    return it;
                });
                this.loading = false;
            }, (err) => this.loading = false);
    }

    trackId(index: number, item: EntityAuditEvent) {
        return item.id;
    }

    openChange(audit: EntityAuditEvent) {
        if (audit.commitVersion < 2) {
            this.alertService.warning('entityAudit.result.firstAuditEntry');

        } else {
            const modalRef = this.modalService.open(EntityAuditModalComponent);
            modalRef.componentInstance.openChange(audit);
        }
    }
}
