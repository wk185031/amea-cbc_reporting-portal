/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { Observable } from 'rxjs/Observable';
import { HttpHeaders, HttpResponse } from '@angular/common/http';

import { BaseTestModule } from '../../../test.module';
import { RoleExtraComponent } from '../../../../../../main/webapp/app/entities/role-extra/role-extra.component';
import { RoleExtraService } from '../../../../../../main/webapp/app/entities/role-extra/role-extra.service';
import { RoleExtra } from '../../../../../../main/webapp/app/entities/role-extra/role-extra.model';

describe('Component Tests', () => {

    describe('RoleExtra Management Component', () => {
        let comp: RoleExtraComponent;
        let fixture: ComponentFixture<RoleExtraComponent>;
        let service: RoleExtraService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [RoleExtraComponent],
                providers: [
                    RoleExtraService
                ]
            })
            .overrideTemplate(RoleExtraComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(RoleExtraComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(RoleExtraService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN
                const headers = new HttpHeaders().append('link', 'link;link');
                spyOn(service, 'query').and.returnValue(Observable.of(new HttpResponse({
                    body: [new RoleExtra(123)],
                    headers
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.query).toHaveBeenCalled();
                expect(comp.roleExtras[0]).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
