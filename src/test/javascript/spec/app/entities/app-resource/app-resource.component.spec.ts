/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { Observable } from 'rxjs/Observable';
import { HttpHeaders, HttpResponse } from '@angular/common/http';

import { BaseTestModule } from '../../../test.module';
import { AppResourceComponent } from '../../../../../../main/webapp/app/entities/app-resource/app-resource.component';
import { AppResourceService } from '../../../../../../main/webapp/app/entities/app-resource/app-resource.service';
import { AppResource } from '../../../../../../main/webapp/app/entities/app-resource/app-resource.model';

describe('Component Tests', () => {

    describe('AppResource Management Component', () => {
        let comp: AppResourceComponent;
        let fixture: ComponentFixture<AppResourceComponent>;
        let service: AppResourceService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [AppResourceComponent],
                providers: [
                    AppResourceService
                ]
            })
            .overrideTemplate(AppResourceComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(AppResourceComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(AppResourceService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN
                const headers = new HttpHeaders().append('link', 'link;link');
                spyOn(service, 'query').and.returnValue(Observable.of(new HttpResponse({
                    body: [new AppResource(123)],
                    headers
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.query).toHaveBeenCalled();
                expect(comp.appResources[0]).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
