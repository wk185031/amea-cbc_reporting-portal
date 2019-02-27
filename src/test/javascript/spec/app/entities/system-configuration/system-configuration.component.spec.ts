/* tslint:disable max-line-length */
import { ComponentFixture, TestBed, async } from '@angular/core/testing';
import { Observable } from 'rxjs/Observable';
import { HttpHeaders, HttpResponse } from '@angular/common/http';

import { BaseTestModule } from '../../../test.module';
import { SystemConfigurationComponent } from '../../../../../../main/webapp/app/entities/system-configuration/system-configuration.component';
import { SystemConfigurationService } from '../../../../../../main/webapp/app/entities/system-configuration/system-configuration.service';
import { SystemConfiguration } from '../../../../../../main/webapp/app/entities/system-configuration/system-configuration.model';

describe('Component Tests', () => {

    describe('SystemConfiguration Management Component', () => {
        let comp: SystemConfigurationComponent;
        let fixture: ComponentFixture<SystemConfigurationComponent>;
        let service: SystemConfigurationService;

        beforeEach(async(() => {
            TestBed.configureTestingModule({
                imports: [BaseTestModule],
                declarations: [SystemConfigurationComponent],
                providers: [
                    SystemConfigurationService
                ]
            })
            .overrideTemplate(SystemConfigurationComponent, '')
            .compileComponents();
        }));

        beforeEach(() => {
            fixture = TestBed.createComponent(SystemConfigurationComponent);
            comp = fixture.componentInstance;
            service = fixture.debugElement.injector.get(SystemConfigurationService);
        });

        describe('OnInit', () => {
            it('Should call load all on init', () => {
                // GIVEN
                const headers = new HttpHeaders().append('link', 'link;link');
                spyOn(service, 'query').and.returnValue(Observable.of(new HttpResponse({
                    body: [new SystemConfiguration(123)],
                    headers
                })));

                // WHEN
                comp.ngOnInit();

                // THEN
                expect(service.query).toHaveBeenCalled();
                expect(comp.systemConfigurations[0]).toEqual(jasmine.objectContaining({id: 123}));
            });
        });
    });

});
