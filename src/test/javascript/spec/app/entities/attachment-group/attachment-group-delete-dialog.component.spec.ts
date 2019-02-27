/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async, inject, fakeAsync, tick } from '@angular/core/testing';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { Observable } from 'rxjs/Observable';
import { JhiEventManager } from 'ng-jhipster';

import { BaseTestModule } from '../../../test.module';
import { AttachmentGroupDeleteDialogComponent } from '../../../../../../main/webapp/app/entities/attachment-group/attachment-group-delete-dialog.component';
import { AttachmentGroupService } from '../../../../../../main/webapp/app/entities/attachment-group/attachment-group.service';

describe('Component Tests', () => {

    describe('AttachmentGroup Management Delete Component', () => {
        let comp: AttachmentGroupDeleteDialogComponent;
        let fixture: ComponentFixture<AttachmentGroupDeleteDialogComponent>;
        let service: AttachmentGroupService;
        let mockEventManager: any;
        let mockActiveModal: any;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [AttachmentGroupDeleteDialogComponent],
                providers: [
                    AttachmentGroupService
                ]
            })
            .overrideTemplate(AttachmentGroupDeleteDialogComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(AttachmentGroupDeleteDialogComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(AttachmentGroupService);
            mockEventManager = fixture.debugElement.injector.get(JhiEventManager);
            mockActiveModal = fixture.debugElement.injector.get(NgbActiveModal);
        });

        describe('confirmDelete', () => {
            it('Should call delete service on confirmDelete',
                inject([],
                    fakeAsync(() => {
                        // GIVEN
                        spyOn(service, 'delete').and.returnValue(Observable.of({}));

                        // WHEN
                        comp.confirmDelete(123);
                        tick();

                        // THEN
                        expect(service.delete).toHaveBeenCalledWith(123);
                        expect(mockActiveModal.dismissSpy).toHaveBeenCalled();
                        expect(mockEventManager.broadcastSpy).toHaveBeenCalled();
                    })
                )
            );
        });
    });

});
