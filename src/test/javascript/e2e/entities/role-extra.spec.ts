import { browser, element, by } from 'protractor';
import { NavBarPage } from './../page-objects/jhi-page-objects';

describe('RoleExtra e2e test', () => {

    let navBarPage: NavBarPage;
    let roleExtraDialogPage: RoleExtraDialogPage;
    let roleExtraComponentsPage: RoleExtraComponentsPage;

    beforeAll(() => {
        browser.get('/');
        browser.waitForAngular();
        navBarPage = new NavBarPage();
        navBarPage.getSignInPage().autoSignInUsing('admin', 'admin');
        browser.waitForAngular();
    });

    it('should load RoleExtras', () => {
        navBarPage.goToEntity('role-extra');
        roleExtraComponentsPage = new RoleExtraComponentsPage();
        expect(roleExtraComponentsPage.getTitle())
            .toMatch(/baseApp.roleExtra.home.title/);

    });

    it('should load create RoleExtra dialog', () => {
        roleExtraComponentsPage.clickOnCreateButton();
        roleExtraDialogPage = new RoleExtraDialogPage();
        expect(roleExtraDialogPage.getModalTitle())
            .toMatch(/baseApp.roleExtra.home.createOrEditLabel/);
        roleExtraDialogPage.close();
    });

   /* it('should create and save RoleExtras', () => {
        roleExtraComponentsPage.clickOnCreateButton();
        roleExtraDialogPage.setNameInput('name');
        expect(roleExtraDialogPage.getNameInput()).toMatch('name');
        roleExtraDialogPage.setDescriptionInput('description');
        expect(roleExtraDialogPage.getDescriptionInput()).toMatch('description');
        roleExtraDialogPage.setCreatedByInput('createdBy');
        expect(roleExtraDialogPage.getCreatedByInput()).toMatch('createdBy');
        roleExtraDialogPage.setCreatedDateInput(12310020012301);
        expect(roleExtraDialogPage.getCreatedDateInput()).toMatch('2001-12-31T02:30');
        roleExtraDialogPage.setLastModifiedByInput('lastModifiedBy');
        expect(roleExtraDialogPage.getLastModifiedByInput()).toMatch('lastModifiedBy');
        roleExtraDialogPage.setLastModifiedDateInput(12310020012301);
        expect(roleExtraDialogPage.getLastModifiedDateInput()).toMatch('2001-12-31T02:30');
        // roleExtraDialogPage.permissionsSelectLastOption();
        roleExtraDialogPage.save();
        expect(roleExtraDialogPage.getSaveButton().isPresent()).toBeFalsy();
    });*/

    afterAll(() => {
        navBarPage.autoSignOut();
    });
});

export class RoleExtraComponentsPage {
    createButton = element(by.css('.jh-create-entity'));
    title = element.all(by.css('jhi-role-extra div h2 span')).first();

    clickOnCreateButton() {
        return this.createButton.click();
    }

    getTitle() {
        return this.title.getAttribute('jhiTranslate');
    }
}

export class RoleExtraDialogPage {
    modalTitle = element(by.css('h4#myRoleExtraLabel'));
    saveButton = element(by.css('.modal-footer .btn.btn-primary'));
    closeButton = element(by.css('button.close'));
    nameInput = element(by.css('input#field_name'));
    descriptionInput = element(by.css('input#field_description'));
    createdByInput = element(by.css('input#field_createdBy'));
    createdDateInput = element(by.css('input#field_createdDate'));
    lastModifiedByInput = element(by.css('input#field_lastModifiedBy'));
    lastModifiedDateInput = element(by.css('input#field_lastModifiedDate'));
    permissionsSelect = element(by.css('select#field_permissions'));

    getModalTitle() {
        return this.modalTitle.getAttribute('jhiTranslate');
    }

    setNameInput = function(name) {
        this.nameInput.sendKeys(name);
    };

    getNameInput = function() {
        return this.nameInput.getAttribute('value');
    };

    setDescriptionInput = function(description) {
        this.descriptionInput.sendKeys(description);
    };

    getDescriptionInput = function() {
        return this.descriptionInput.getAttribute('value');
    };

    setCreatedByInput = function(createdBy) {
        this.createdByInput.sendKeys(createdBy);
    };

    getCreatedByInput = function() {
        return this.createdByInput.getAttribute('value');
    };

    setCreatedDateInput = function(createdDate) {
        this.createdDateInput.sendKeys(createdDate);
    };

    getCreatedDateInput = function() {
        return this.createdDateInput.getAttribute('value');
    };

    setLastModifiedByInput = function(lastModifiedBy) {
        this.lastModifiedByInput.sendKeys(lastModifiedBy);
    };

    getLastModifiedByInput = function() {
        return this.lastModifiedByInput.getAttribute('value');
    };

    setLastModifiedDateInput = function(lastModifiedDate) {
        this.lastModifiedDateInput.sendKeys(lastModifiedDate);
    };

    getLastModifiedDateInput = function() {
        return this.lastModifiedDateInput.getAttribute('value');
    };

    permissionsSelectLastOption = function() {
        this.permissionsSelect.all(by.tagName('option')).last().click();
    };

    permissionsSelectOption = function(option) {
        this.permissionsSelect.sendKeys(option);
    };

    getPermissionsSelect = function() {
        return this.permissionsSelect;
    };

    getPermissionsSelectedOption = function() {
        return this.permissionsSelect.element(by.css('option:checked')).getText();
    };

    save() {
        this.saveButton.click();
    }

    close() {
        this.closeButton.click();
    }

    getSaveButton() {
        return this.saveButton;
    }
}
