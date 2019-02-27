/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';

import { BaseTestModule } from '../../../test.module';
import { InstitutionDetailComponent } from '../../../../../../main/webapp/app/entities/institution/institution-detail.component';
import { InstitutionService } from '../../../../../../main/webapp/app/entities/institution/institution.service';
import { Institution } from '../../../../../../main/webapp/app/entities/institution/institution.model';

describe('Component Tests', () => {

    describe('Institution Management Detail Component', () => {
        let comp: InstitutionDetailComponent;
        let fixture: ComponentFixture<InstitutionDetailComponent>;
        let service: InstitutionService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [InstitutionDetailComponent],
                providers: [
                    InstitutionService
                ]
            })
            .overrideTemplate(InstitutionDetailComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(InstitutionDetailComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(InstitutionService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN

                spyOn(service, 'find').and.returnValue(Observable.of(new HttpResponse({
                    body: new Institution(123)
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.find).toHaveBeenCalledWith(123);
                expect(comp.institution).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
