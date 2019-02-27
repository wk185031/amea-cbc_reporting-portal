/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';

import { BaseTestModule } from '../../../test.module';
import { AppResourceDetailComponent } from '../../../../../../main/webapp/app/entities/app-resource/app-resource-detail.component';
import { AppResourceService } from '../../../../../../main/webapp/app/entities/app-resource/app-resource.service';
import { AppResource } from '../../../../../../main/webapp/app/entities/app-resource/app-resource.model';

describe('Component Tests', () => {

    describe('AppResource Management Detail Component', () => {
        let comp: AppResourceDetailComponent;
        let fixture: ComponentFixture<AppResourceDetailComponent>;
        let service: AppResourceService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [AppResourceDetailComponent],
                providers: [
                    AppResourceService
                ]
            })
            .overrideTemplate(AppResourceDetailComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(AppResourceDetailComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(AppResourceService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN

                spyOn(service, 'find').and.returnValue(Observable.of(new HttpResponse({
                    body: new AppResource(123)
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.find).toHaveBeenCalledWith(123);
                expect(comp.appResource).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
