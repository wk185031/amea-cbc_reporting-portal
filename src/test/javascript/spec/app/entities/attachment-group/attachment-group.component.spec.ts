/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { Observable } from 'rxjs/Observable';
import { HttpHeaders, HttpResponse } from '@angular/common/http';

import { BaseTestModule } from '../../../test.module';
import { AttachmentGroupComponent } from '../../../../../../main/webapp/app/entities/attachment-group/attachment-group.component';
import { AttachmentGroupService } from '../../../../../../main/webapp/app/entities/attachment-group/attachment-group.service';
import { AttachmentGroup } from '../../../../../../main/webapp/app/entities/attachment-group/attachment-group.model';

describe('Component Tests', () => {

    describe('AttachmentGroup Management Component', () => {
        let comp: AttachmentGroupComponent;
        let fixture: ComponentFixture<AttachmentGroupComponent>;
        let service: AttachmentGroupService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [AttachmentGroupComponent],
                providers: [
                    AttachmentGroupService
                ]
            })
            .overrideTemplate(AttachmentGroupComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(AttachmentGroupComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(AttachmentGroupService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN
                const headers = new HttpHeaders().append('link', 'link;link');
                spyOn(service, 'query').and.returnValue(Observable.of(new HttpResponse({
                    body: [new AttachmentGroup(123)],
                    headers
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.query).toHaveBeenCalled();
                expect(comp.attachmentGroups[0]).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
