import { browser, element, by } from 'protractor';
import { NavBarPage } from './../page-objects/jhi-page-objects';

describe('UserExtra e2e test', () => {

    let navBarPage: NavBarPage;
    let userExtraDialogPage: UserExtraDialogPage;
    let userExtraComponentsPage: UserExtraComponentsPage;

    beforeAll(() => {
        browser.get('/');
        browser.waitForAngular();
        navBarPage = new NavBarPage();
        navBarPage.getSignInPage().autoSignInUsing('admin', 'admin');
        browser.waitForAngular();
    });

    it('should load UserExtras', () => {
        navBarPage.goToEntity('user-extra');
        userExtraComponentsPage = new UserExtraComponentsPage();
        expect(userExtraComponentsPage.getTitle())
            .toMatch(/baseApp.userExtra.home.title/);

    });

    it('should load create UserExtra dialog', () => {
        userExtraComponentsPage.clickOnCreateButton();
        userExtraDialogPage = new UserExtraDialogPage();
        expect(userExtraDialogPage.getModalTitle())
            .toMatch(/baseApp.userExtra.home.createOrEditLabel/);
        userExtraDialogPage.close();
    });

   /* it('should create and save UserExtras', () => {
        userExtraComponentsPage.clickOnCreateButton();
        userExtraDialogPage.setNameInput('name');
        expect(userExtraDialogPage.getNameInput()).toMatch('name');
        userExtraDialogPage.setDesignationInput('designation');
        expect(userExtraDialogPage.getDesignationInput()).toMatch('designation');
        userExtraDialogPage.setContactMobileInput('contactMobile');
        expect(userExtraDialogPage.getContactMobileInput()).toMatch('contactMobile');
        userExtraDialogPage.setContactWorkInput('contactWork');
        expect(userExtraDialogPage.getContactWorkInput()).toMatch('contactWork');
        userExtraDialogPage.setContactOtherInput('contactOther');
        expect(userExtraDialogPage.getContactOtherInput()).toMatch('contactOther');
        userExtraDialogPage.setCreatedByInput('createdBy');
        expect(userExtraDialogPage.getCreatedByInput()).toMatch('createdBy');
        userExtraDialogPage.setCreatedDateInput(12310020012301);
        expect(userExtraDialogPage.getCreatedDateInput()).toMatch('2001-12-31T02:30');
        userExtraDialogPage.setLastModifiedByInput('lastModifiedBy');
        expect(userExtraDialogPage.getLastModifiedByInput()).toMatch('lastModifiedBy');
        userExtraDialogPage.setLastModifiedDateInput(12310020012301);
        expect(userExtraDialogPage.getLastModifiedDateInput()).toMatch('2001-12-31T02:30');
        userExtraDialogPage.userSelectLastOption();
        // userExtraDialogPage.rolesSelectLastOption();
        // userExtraDialogPage.institutionsSelectLastOption();
        userExtraDialogPage.save();
        expect(userExtraDialogPage.getSaveButton().isPresent()).toBeFalsy();
    });*/

    afterAll(() => {
        navBarPage.autoSignOut();
    });
});

export class UserExtraComponentsPage {
    createButton = element(by.css('.jh-create-entity'));
    title = element.all(by.css('jhi-user-extra div h2 span')).first();

    clickOnCreateButton() {
        return this.createButton.click();
    }

    getTitle() {
        return this.title.getAttribute('jhiTranslate');
    }
}

export class UserExtraDialogPage {
    modalTitle = element(by.css('h4#myUserExtraLabel'));
    saveButton = element(by.css('.modal-footer .btn.btn-primary'));
    closeButton = element(by.css('button.close'));
    nameInput = element(by.css('input#field_name'));
    designationInput = element(by.css('input#field_designation'));
    contactMobileInput = element(by.css('input#field_contactMobile'));
    contactWorkInput = element(by.css('input#field_contactWork'));
    contactOtherInput = element(by.css('input#field_contactOther'));
    createdByInput = element(by.css('input#field_createdBy'));
    createdDateInput = element(by.css('input#field_createdDate'));
    lastModifiedByInput = element(by.css('input#field_lastModifiedBy'));
    lastModifiedDateInput = element(by.css('input#field_lastModifiedDate'));
    userSelect = element(by.css('select#field_user'));
    rolesSelect = element(by.css('select#field_roles'));
    institutionsSelect = element(by.css('select#field_institutions'));

    getModalTitle() {
        return this.modalTitle.getAttribute('jhiTranslate');
    }

    setNameInput = function(name) {
        this.nameInput.sendKeys(name);
    };

    getNameInput = function() {
        return this.nameInput.getAttribute('value');
    };

    setDesignationInput = function(designation) {
        this.designationInput.sendKeys(designation);
    };

    getDesignationInput = function() {
        return this.designationInput.getAttribute('value');
    };

    setContactMobileInput = function(contactMobile) {
        this.contactMobileInput.sendKeys(contactMobile);
    };

    getContactMobileInput = function() {
        return this.contactMobileInput.getAttribute('value');
    };

    setContactWorkInput = function(contactWork) {
        this.contactWorkInput.sendKeys(contactWork);
    };

    getContactWorkInput = function() {
        return this.contactWorkInput.getAttribute('value');
    };

    setContactOtherInput = function(contactOther) {
        this.contactOtherInput.sendKeys(contactOther);
    };

    getContactOtherInput = function() {
        return this.contactOtherInput.getAttribute('value');
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

    userSelectLastOption = function() {
        this.userSelect.all(by.tagName('option')).last().click();
    };

    userSelectOption = function(option) {
        this.userSelect.sendKeys(option);
    };

    getUserSelect = function() {
        return this.userSelect;
    };

    getUserSelectedOption = function() {
        return this.userSelect.element(by.css('option:checked')).getText();
    };

    rolesSelectLastOption = function() {
        this.rolesSelect.all(by.tagName('option')).last().click();
    };

    rolesSelectOption = function(option) {
        this.rolesSelect.sendKeys(option);
    };

    getRolesSelect = function() {
        return this.rolesSelect;
    };

    getRolesSelectedOption = function() {
        return this.rolesSelect.element(by.css('option:checked')).getText();
    };

    institutionsSelectLastOption = function() {
        this.institutionsSelect.all(by.tagName('option')).last().click();
    };

    institutionsSelectOption = function(option) {
        this.institutionsSelect.sendKeys(option);
    };

    getInstitutionsSelect = function() {
        return this.institutionsSelect;
    };

    getInstitutionsSelectedOption = function() {
        return this.institutionsSelect.element(by.css('option:checked')).getText();
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
