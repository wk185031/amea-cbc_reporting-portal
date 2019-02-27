import { Directive, Input, TemplateRef, ViewContainerRef } from '@angular/core';
import { Principal } from '../shared/auth/principal.service';
import { AppPermissionService } from '.';
/**
 * @whatItDoes Conditionally includes an HTML element if current user has any
 * of the authorities passed as the `expression`.
 *
 * @howToUse
 * ```
 *     <some-element *appHasAnyPermission="'MENU:User'">...</some-element>
 *
 *     <some-element *appHasAnyPermission="['MENU:User', 'MENU:UserRole']">...</some-element>
 * ```
 */
@Directive({
    selector: '[appHasAnyPermission]'
})
export class AppHasAnyPermissionDirective {

    private authorities: string[];

    constructor(
        private principal: Principal,
        private templateRef: TemplateRef<any>,
        private viewContainerRef: ViewContainerRef,
        private appPermissionService: AppPermissionService) {
    }

    @Input()
    set appHasAnyPermission(value: string|string[]) {
        this.authorities = typeof value === 'string' ? [ <string> value ] : <string[]> value;
        this.updateView();
        // Get notified each time authentication state changes.
        this.principal.getAuthenticationState().subscribe((identity) => this.updateView());
    }

    private updateView(): void {
        this.appPermissionService.hasAnyAuthority(this.authorities).then((result) => {
            this.viewContainerRef.clear();
            if (result) {
                this.viewContainerRef.createEmbeddedView(this.templateRef);
            }
        });
    }
}
