/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { HttpResponse } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';

import { BaseTestModule } from '../../../test.module';
import { SystemConfigurationDetailComponent } from '../../../../../../main/webapp/app/entities/system-configuration/system-configuration-detail.component';
import { SystemConfigurationService } from '../../../../../../main/webapp/app/entities/system-configuration/system-configuration.service';
import { SystemConfiguration } from '../../../../../../main/webapp/app/entities/system-configuration/system-configuration.model';

describe('Component Tests', () => {

    describe('SystemConfiguration Management Detail Component', () => {
        let comp: SystemConfigurationDetailComponent;
        let fixture: ComponentFixture<SystemConfigurationDetailComponent>;
        let service: SystemConfigurationService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [SystemConfigurationDetailComponent],
                providers: [
                    SystemConfigurationService
                ]
            })
            .overrideTemplate(SystemConfigurationDetailComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(SystemConfigurationDetailComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(SystemConfigurationService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN

                spyOn(service, 'find').and.returnValue(Observable.of(new HttpResponse({
                    body: new SystemConfiguration(123)
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.find).toHaveBeenCalledWith(123);
                expect(comp.systemConfiguration).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
