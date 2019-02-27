/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';

import { BaseTestModule } from '../../../test.module';
import { RoleExtraDetailComponent } from '../../../../../../main/webapp/app/entities/role-extra/role-extra-detail.component';
import { RoleExtraService } from '../../../../../../main/webapp/app/entities/role-extra/role-extra.service';
import { RoleExtra } from '../../../../../../main/webapp/app/entities/role-extra/role-extra.model';

describe('Component Tests', () => {

    describe('RoleExtra Management Detail Component', () => {
        let comp: RoleExtraDetailComponent;
        let fixture: ComponentFixture<RoleExtraDetailComponent>;
        let service: RoleExtraService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [RoleExtraDetailComponent],
                providers: [
                    RoleExtraService
                ]
            })
            .overrideTemplate(RoleExtraDetailComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(RoleExtraDetailComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(RoleExtraService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN

                spyOn(service, 'find').and.returnValue(Observable.of(new HttpResponse({
                    body: new RoleExtra(123)
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.find).toHaveBeenCalledWith(123);
                expect(comp.roleExtra).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
