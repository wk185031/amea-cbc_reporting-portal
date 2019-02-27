import { Route } from '@angular/router';

import { RegisterComponent } from './register.component';

import { AppRouteSelfRegistrationService } from '../../common/app-route-self-registration-service';

export const registerRoute: Route = {
    path: 'register',
    component: RegisterComponent,
    data: {
        authorities: [],
        pageTitle: 'register.title'
    },
    canActivate: [AppRouteSelfRegistrationService]
};
