import { Injectable } from '@angular/core';
import { CanActivate } from '@angular/router';

import { ProfileService } from '../layouts/profiles/profile.service';
@Injectable()
export class AppRouteSelfRegistrationService implements CanActivate {

    constructor(private profileService: ProfileService) {
    }

    canActivate(): boolean | Promise<boolean> {
        return this.profileService.getProfileInfo().then((profileInfo) => {
            return profileInfo.selfRegistration;
        });
    }
}
