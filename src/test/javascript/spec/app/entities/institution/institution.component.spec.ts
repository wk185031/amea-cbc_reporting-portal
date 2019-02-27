/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { Observable } from 'rxjs/Observable';
import { HttpHeaders, HttpResponse } from '@angular/common/http';

import { BaseTestModule } from '../../../test.module';
import { InstitutionComponent } from '../../../../../../main/webapp/app/entities/institution/institution.component';
import { InstitutionService } from '../../../../../../main/webapp/app/entities/institution/institution.service';
import { Institution } from '../../../../../../main/webapp/app/entities/institution/institution.model';

describe('Component Tests', () => {

    describe('Institution Management Component', () => {
        let comp: InstitutionComponent;
        let fixture: ComponentFixture<InstitutionComponent>;
        let service: InstitutionService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [InstitutionComponent],
                providers: [
                    InstitutionService
                ]
            })
            .overrideTemplate(InstitutionComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(InstitutionComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(InstitutionService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN
                const headers = new HttpHeaders().append('link', 'link;link');
                spyOn(service, 'query').and.returnValue(Observable.of(new HttpResponse({
                    body: [new Institution(123)],
                    headers
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.query).toHaveBeenCalled();
                expect(comp.institutions[0]).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
