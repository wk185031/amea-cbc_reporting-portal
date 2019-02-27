/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';

import { BaseTestModule } from '../../../test.module';
import { AttachmentGroupDetailComponent } from '../../../../../../main/webapp/app/entities/attachment-group/attachment-group-detail.component';
import { AttachmentGroupService } from '../../../../../../main/webapp/app/entities/attachment-group/attachment-group.service';
import { AttachmentGroup } from '../../../../../../main/webapp/app/entities/attachment-group/attachment-group.model';

describe('Component Tests', () => {

    describe('AttachmentGroup Management Detail Component', () => {
        let comp: AttachmentGroupDetailComponent;
        let fixture: ComponentFixture<AttachmentGroupDetailComponent>;
        let service: AttachmentGroupService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [AttachmentGroupDetailComponent],
                providers: [
                    AttachmentGroupService
                ]
            })
            .overrideTemplate(AttachmentGroupDetailComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(AttachmentGroupDetailComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(AttachmentGroupService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN

                spyOn(service, 'find').and.returnValue(Observable.of(new HttpResponse({
                    body: new AttachmentGroup(123)
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.find).toHaveBeenCalledWith(123);
                expect(comp.attachmentGroup).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
