/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { Observable } from 'rxjs/Observable';
import { HttpHeaders, HttpResponse } from '@angular/common/http';

import { BaseTestModule } from '../../../test.module';
import { AttachmentComponent } from '../../../../../../main/webapp/app/entities/attachment/attachment.component';
import { AttachmentService } from '../../../../../../main/webapp/app/entities/attachment/attachment.service';
import { Attachment } from '../../../../../../main/webapp/app/entities/attachment/attachment.model';

describe('Component Tests', () => {

    describe('Attachment Management Component', () => {
        let comp: AttachmentComponent;
        let fixture: ComponentFixture<AttachmentComponent>;
        let service: AttachmentService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [AttachmentComponent],
                providers: [
                    AttachmentService
                ]
            })
            .overrideTemplate(AttachmentComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(AttachmentComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(AttachmentService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN
                const headers = new HttpHeaders().append('link', 'link;link');
                spyOn(service, 'query').and.returnValue(Observable.of(new HttpResponse({
                    body: [new Attachment(123)],
                    headers
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.query).toHaveBeenCalled();
                expect(comp.attachments[0]).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
