import { browser, element, by } from 'protractor';
import { NavBarPage } from './../page-objects/jhi-page-objects';

describe('AppResource e2e test', () => {

    let navBarPage: NavBarPage;
    let appResourceDialogPage: AppResourceDialogPage;
    let appResourceComponentsPage: AppResourceComponentsPage;

    beforeAll(() => {
        browser.get('/');
        browser.waitForAngular();
        navBarPage = new NavBarPage();
        navBarPage.getSignInPage().autoSignInUsing('admin', 'admin');
        browser.waitForAngular();
    });

    it('should load AppResources', () => {
        navBarPage.goToEntity('app-resource');
        appResourceComponentsPage = new AppResourceComponentsPage();
        expect(appResourceComponentsPage.getTitle())
            .toMatch(/baseApp.appResource.home.title/);

    });

    it('should load create AppResource dialog', () => {
        appResourceComponentsPage.clickOnCreateButton();
        appResourceDialogPage = new AppResourceDialogPage();
        expect(appResourceDialogPage.getModalTitle())
            .toMatch(/baseApp.appResource.home.createOrEditLabel/);
        appResourceDialogPage.close();
    });

    it('should create and save AppResources', () => {
        appResourceComponentsPage.clickOnCreateButton();
        appResourceDialogPage.setCodeInput('code');
        expect(appResourceDialogPage.getCodeInput()).toMatch('code');
        appResourceDialogPage.setNameInput('name');
        expect(appResourceDialogPage.getNameInput()).toMatch('name');
        appResourceDialogPage.setTypeInput('type');
        expect(appResourceDialogPage.getTypeInput()).toMatch('type');
        appResourceDialogPage.setDescriptionInput('description');
        expect(appResourceDialogPage.getDescriptionInput()).toMatch('description');
        appResourceDialogPage.setSeqNoInput('5');
        expect(appResourceDialogPage.getSeqNoInput()).toMatch('5');
        appResourceDialogPage.setDepthInput('5');
        expect(appResourceDialogPage.getDepthInput()).toMatch('5');
        appResourceDialogPage.setCreatedByInput('createdBy');
        expect(appResourceDialogPage.getCreatedByInput()).toMatch('createdBy');
        appResourceDialogPage.setCreatedDateInput(12310020012301);
        expect(appResourceDialogPage.getCreatedDateInput()).toMatch('2001-12-31T02:30');
        appResourceDialogPage.setLastModifiedByInput('lastModifiedBy');
        expect(appResourceDialogPage.getLastModifiedByInput()).toMatch('lastModifiedBy');
        appResourceDialogPage.setLastModifiedDateInput(12310020012301);
        expect(appResourceDialogPage.getLastModifiedDateInput()).toMatch('2001-12-31T02:30');
        appResourceDialogPage.parentSelectLastOption();
        appResourceDialogPage.save();
        expect(appResourceDialogPage.getSaveButton().isPresent()).toBeFalsy();
    });

    afterAll(() => {
        navBarPage.autoSignOut();
    });
});

export class AppResourceComponentsPage {
    createButton = element(by.css('.jh-create-entity'));
    title = element.all(by.css('jhi-app-resource div h2 span')).first();

    clickOnCreateButton() {
        return this.createButton.click();
    }

    getTitle() {
        return this.title.getAttribute('jhiTranslate');
    }
}

export class AppResourceDialogPage {
    modalTitle = element(by.css('h4#myAppResourceLabel'));
    saveButton = element(by.css('.modal-footer .btn.btn-primary'));
    closeButton = element(by.css('button.close'));
    codeInput = element(by.css('input#field_code'));
    nameInput = element(by.css('input#field_name'));
    typeInput = element(by.css('input#field_type'));
    descriptionInput = element(by.css('input#field_description'));
    seqNoInput = element(by.css('input#field_seqNo'));
    depthInput = element(by.css('input#field_depth'));
    createdByInput = element(by.css('input#field_createdBy'));
    createdDateInput = element(by.css('input#field_createdDate'));
    lastModifiedByInput = element(by.css('input#field_lastModifiedBy'));
    lastModifiedDateInput = element(by.css('input#field_lastModifiedDate'));
    parentSelect = element(by.css('select#field_parent'));

    getModalTitle() {
        return this.modalTitle.getAttribute('jhiTranslate');
    }

    setCodeInput = function(code) {
        this.codeInput.sendKeys(code);
    };

    getCodeInput = function() {
        return this.codeInput.getAttribute('value');
    };

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

    setDescriptionInput = function(description) {
        this.descriptionInput.sendKeys(description);
    };

    getDescriptionInput = function() {
        return this.descriptionInput.getAttribute('value');
    };

    setSeqNoInput = function(seqNo) {
        this.seqNoInput.sendKeys(seqNo);
    };

    getSeqNoInput = function() {
        return this.seqNoInput.getAttribute('value');
    };

    setDepthInput = function(depth) {
        this.depthInput.sendKeys(depth);
    };

    getDepthInput = function() {
        return this.depthInput.getAttribute('value');
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
