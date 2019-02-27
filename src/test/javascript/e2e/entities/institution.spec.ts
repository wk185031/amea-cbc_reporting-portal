import { browser, element, by } from 'protractor';
import { NavBarPage } from './../page-objects/jhi-page-objects';

describe('Institution e2e test', () => {

    let navBarPage: NavBarPage;
    let institutionDialogPage: InstitutionDialogPage;
    let institutionComponentsPage: InstitutionComponentsPage;

    beforeAll(() => {
        browser.get('/');
        browser.waitForAngular();
        navBarPage = new NavBarPage();
        navBarPage.getSignInPage().autoSignInUsing('admin', 'admin');
        browser.waitForAngular();
    });

    it('should load Institutions', () => {
        navBarPage.goToEntity('institution');
        institutionComponentsPage = new InstitutionComponentsPage();
        expect(institutionComponentsPage.getTitle())
            .toMatch(/baseApp.institution.home.title/);

    });

    it('should load create Institution dialog', () => {
        institutionComponentsPage.clickOnCreateButton();
        institutionDialogPage = new InstitutionDialogPage();
        expect(institutionDialogPage.getModalTitle())
            .toMatch(/baseApp.institution.home.createOrEditLabel/);
        institutionDialogPage.close();
    });

    it('should create and save Institutions', () => {
        institutionComponentsPage.clickOnCreateButton();
        institutionDialogPage.setNameInput('name');
        expect(institutionDialogPage.getNameInput()).toMatch('name');
        institutionDialogPage.setTypeInput('type');
        expect(institutionDialogPage.getTypeInput()).toMatch('type');
        institutionDialogPage.setBusinessRegNoInput('businessRegNo');
        expect(institutionDialogPage.getBusinessRegNoInput()).toMatch('businessRegNo');
        institutionDialogPage.setIndustryInput('industry');
        expect(institutionDialogPage.getIndustryInput()).toMatch('industry');
        institutionDialogPage.setAddressInput('address');
        expect(institutionDialogPage.getAddressInput()).toMatch('address');
        institutionDialogPage.setPhoneInput('phone');
        expect(institutionDialogPage.getPhoneInput()).toMatch('phone');
        institutionDialogPage.setFaxInput('fax');
        expect(institutionDialogPage.getFaxInput()).toMatch('fax');
        institutionDialogPage.setEmailInput('email');
        expect(institutionDialogPage.getEmailInput()).toMatch('email');
        institutionDialogPage.setWebsiteInput('website');
        expect(institutionDialogPage.getWebsiteInput()).toMatch('website');
        institutionDialogPage.setCreatedByInput('createdBy');
        expect(institutionDialogPage.getCreatedByInput()).toMatch('createdBy');
        institutionDialogPage.setCreatedDateInput(12310020012301);
        expect(institutionDialogPage.getCreatedDateInput()).toMatch('2001-12-31T02:30');
        institutionDialogPage.setLastModifiedByInput('lastModifiedBy');
        expect(institutionDialogPage.getLastModifiedByInput()).toMatch('lastModifiedBy');
        institutionDialogPage.setLastModifiedDateInput(12310020012301);
        expect(institutionDialogPage.getLastModifiedDateInput()).toMatch('2001-12-31T02:30');
        institutionDialogPage.attachmentGroupSelectLastOption();
        institutionDialogPage.parentSelectLastOption();
        institutionDialogPage.save();
        expect(institutionDialogPage.getSaveButton().isPresent()).toBeFalsy();
    });

    afterAll(() => {
        navBarPage.autoSignOut();
    });
});

export class InstitutionComponentsPage {
    createButton = element(by.css('.jh-create-entity'));
    title = element.all(by.css('jhi-institution div h2 span')).first();

    clickOnCreateButton() {
        return this.createButton.click();
    }

    getTitle() {
        return this.title.getAttribute('jhiTranslate');
    }
}

export class InstitutionDialogPage {
    modalTitle = element(by.css('h4#myInstitutionLabel'));
    saveButton = element(by.css('.modal-footer .btn.btn-primary'));
    closeButton = element(by.css('button.close'));
    nameInput = element(by.css('input#field_name'));
    typeInput = element(by.css('input#field_type'));
    businessRegNoInput = element(by.css('input#field_businessRegNo'));
    industryInput = element(by.css('input#field_industry'));
    addressInput = element(by.css('input#field_address'));
    phoneInput = element(by.css('input#field_phone'));
    faxInput = element(by.css('input#field_fax'));
    emailInput = element(by.css('input#field_email'));
    websiteInput = element(by.css('input#field_website'));
    createdByInput = element(by.css('input#field_createdBy'));
    createdDateInput = element(by.css('input#field_createdDate'));
    lastModifiedByInput = element(by.css('input#field_lastModifiedBy'));
    lastModifiedDateInput = element(by.css('input#field_lastModifiedDate'));
    attachmentGroupSelect = element(by.css('select#field_attachmentGroup'));
    parentSelect = element(by.css('select#field_parent'));

    getModalTitle() {
        return this.modalTitle.getAttribute('jhiTranslate');
    }

    setNameInput = function(name) {
        this.nameInput.sendKeys(name);
    };

    getNameInput = function() {
        return this.nameInput.getAttribute('value');
    };

    setTypeInput = function(type) {
        this.typeInput.sendKeys(type);
    };

    getTypeInput = function() {
        return this.typeInput.getAttribute('value');
    };

    setBusinessRegNoInput = function(businessRegNo) {
        this.businessRegNoInput.sendKeys(businessRegNo);
    };

    getBusinessRegNoInput = function() {
        return this.businessRegNoInput.getAttribute('value');
    };

    setIndustryInput = function(industry) {
        this.industryInput.sendKeys(industry);
    };

    getIndustryInput = function() {
        return this.industryInput.getAttribute('value');
    };

    setAddressInput = function(address) {
        this.addressInput.sendKeys(address);
    };

    getAddressInput = function() {
        return this.addressInput.getAttribute('value');
    };

    setPhoneInput = function(phone) {
        this.phoneInput.sendKeys(phone);
    };

    getPhoneInput = function() {
        return this.phoneInput.getAttribute('value');
    };

    setFaxInput = function(fax) {
        this.faxInput.sendKeys(fax);
    };

    getFaxInput = function() {
        return this.faxInput.getAttribute('value');
    };

    setEmailInput = function(email) {
        this.emailInput.sendKeys(email);
    };

    getEmailInput = function() {
        return this.emailInput.getAttribute('value');
    };

    setWebsiteInput = function(website) {
        this.websiteInput.sendKeys(website);
    };

    getWebsiteInput = function() {
        return this.websiteInput.getAttribute('value');
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

    attachmentGroupSelectLastOption = function() {
        this.attachmentGroupSelect.all(by.tagName('option')).last().click();
    };

    attachmentGroupSelectOption = function(option) {
        this.attachmentGroupSelect.sendKeys(option);
    };

    getAttachmentGroupSelect = function() {
        return this.attachmentGroupSelect;
    };

    getAttachmentGroupSelectedOption = function() {
        return this.attachmentGroupSelect.element(by.css('option:checked')).getText();
    };

    parentSelectLastOption = function() {
        this.parentSelect.all(by.tagName('option')).last().click();
    };

    parentSelectOption = function(option) {
        this.parentSelect.sendKeys(option);
    };

    getParentSelect = function() {
        return this.parentSelect;
    };

    getParentSelectedOption = function() {
        return this.parentSelect.element(by.css('option:checked')).getText();
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
