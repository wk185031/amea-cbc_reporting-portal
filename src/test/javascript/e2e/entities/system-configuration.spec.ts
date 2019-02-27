import { browser, element, by } from 'protractor';
import { NavBarPage } from './../page-objects/jhi-page-objects';

describe('SystemConfiguration e2e test', () => {

    let navBarPage: NavBarPage;
    let systemConfigurationDialogPage: SystemConfigurationDialogPage;
    let systemConfigurationComponentsPage: SystemConfigurationComponentsPage;

    beforeAll(() => {
        browser.get('/');
        browser.waitForAngular();
        navBarPage = new NavBarPage();
        navBarPage.getSignInPage().autoSignInUsing('admin', 'admin');
        browser.waitForAngular();
    });

    it('should load SystemConfigurations', () => {
        navBarPage.goToEntity('system-configuration');
        systemConfigurationComponentsPage = new SystemConfigurationComponentsPage();
        expect(systemConfigurationComponentsPage.getTitle())
            .toMatch(/baseApp.systemConfiguration.home.title/);

    });

    it('should load create SystemConfiguration dialog', () => {
        systemConfigurationComponentsPage.clickOnCreateButton();
        systemConfigurationDialogPage = new SystemConfigurationDialogPage();
        expect(systemConfigurationDialogPage.getModalTitle())
            .toMatch(/baseApp.systemConfiguration.home.createOrEditLabel/);
        systemConfigurationDialogPage.close();
    });

    it('should create and save SystemConfigurations', () => {
        systemConfigurationComponentsPage.clickOnCreateButton();
        systemConfigurationDialogPage.setNameInput('name');
        expect(systemConfigurationDialogPage.getNameInput()).toMatch('name');
        systemConfigurationDialogPage.setDescriptionInput('description');
        expect(systemConfigurationDialogPage.getDescriptionInput()).toMatch('description');
        systemConfigurationDialogPage.setConfigInput('config');
        expect(systemConfigurationDialogPage.getConfigInput()).toMatch('config');
        systemConfigurationDialogPage.setCreatedByInput('createdBy');
        expect(systemConfigurationDialogPage.getCreatedByInput()).toMatch('createdBy');
        systemConfigurationDialogPage.setCreatedDateInput(12310020012301);
        expect(systemConfigurationDialogPage.getCreatedDateInput()).toMatch('2001-12-31T02:30');
        systemConfigurationDialogPage.setLastModifiedByInput('lastModifiedBy');
        expect(systemConfigurationDialogPage.getLastModifiedByInput()).toMatch('lastModifiedBy');
        systemConfigurationDialogPage.setLastModifiedDateInput(12310020012301);
        expect(systemConfigurationDialogPage.getLastModifiedDateInput()).toMatch('2001-12-31T02:30');
        systemConfigurationDialogPage.save();
        expect(systemConfigurationDialogPage.getSaveButton().isPresent()).toBeFalsy();
    });

    afterAll(() => {
        navBarPage.autoSignOut();
    });
});

export class SystemConfigurationComponentsPage {
    createButton = element(by.css('.jh-create-entity'));
    title = element.all(by.css('jhi-system-configuration div h2 span')).first();

    clickOnCreateButton() {
        return this.createButton.click();
    }

    getTitle() {
        return this.title.getAttribute('jhiTranslate');
    }
}

export class SystemConfigurationDialogPage {
    modalTitle = element(by.css('h4#mySystemConfigurationLabel'));
    saveButton = element(by.css('.modal-footer .btn.btn-primary'));
    closeButton = element(by.css('button.close'));
    nameInput = element(by.css('input#field_name'));
    descriptionInput = element(by.css('input#field_description'));
    configInput = element(by.css('input#field_config'));
    createdByInput = element(by.css('input#field_createdBy'));
    createdDateInput = element(by.css('input#field_createdDate'));
    lastModifiedByInput = element(by.css('input#field_lastModifiedBy'));
    lastModifiedDateInput = element(by.css('input#field_lastModifiedDate'));

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

    setConfigInput = function(config) {
        this.configInput.sendKeys(config);
    };

    getConfigInput = function() {
        return this.configInput.getAttribute('value');
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
