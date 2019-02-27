import { browser, element, by } from 'protractor';
import { NavBarPage } from './../page-objects/jhi-page-objects';

describe('AttachmentGroup e2e test', () => {

    let navBarPage: NavBarPage;
    let attachmentGroupDialogPage: AttachmentGroupDialogPage;
    let attachmentGroupComponentsPage: AttachmentGroupComponentsPage;

    beforeAll(() => {
        browser.get('/');
        browser.waitForAngular();
        navBarPage = new NavBarPage();
        navBarPage.getSignInPage().autoSignInUsing('admin', 'admin');
        browser.waitForAngular();
    });

    it('should load AttachmentGroups', () => {
        navBarPage.goToEntity('attachment-group');
        attachmentGroupComponentsPage = new AttachmentGroupComponentsPage();
        expect(attachmentGroupComponentsPage.getTitle())
            .toMatch(/baseApp.attachmentGroup.home.title/);

    });

    it('should load create AttachmentGroup dialog', () => {
        attachmentGroupComponentsPage.clickOnCreateButton();
        attachmentGroupDialogPage = new AttachmentGroupDialogPage();
        expect(attachmentGroupDialogPage.getModalTitle())
            .toMatch(/baseApp.attachmentGroup.home.createOrEditLabel/);
        attachmentGroupDialogPage.close();
    });

    it('should create and save AttachmentGroups', () => {
        attachmentGroupComponentsPage.clickOnCreateButton();
        attachmentGroupDialogPage.setEntityInput('entity');
        expect(attachmentGroupDialogPage.getEntityInput()).toMatch('entity');
        attachmentGroupDialogPage.setCreatedByInput('createdBy');
        expect(attachmentGroupDialogPage.getCreatedByInput()).toMatch('createdBy');
        attachmentGroupDialogPage.setCreatedDateInput(12310020012301);
        expect(attachmentGroupDialogPage.getCreatedDateInput()).toMatch('2001-12-31T02:30');
        attachmentGroupDialogPage.setLastModifiedByInput('lastModifiedBy');
        expect(attachmentGroupDialogPage.getLastModifiedByInput()).toMatch('lastModifiedBy');
        attachmentGroupDialogPage.setLastModifiedDateInput(12310020012301);
        expect(attachmentGroupDialogPage.getLastModifiedDateInput()).toMatch('2001-12-31T02:30');
        attachmentGroupDialogPage.save();
        expect(attachmentGroupDialogPage.getSaveButton().isPresent()).toBeFalsy();
    });

    afterAll(() => {
        navBarPage.autoSignOut();
    });
});

export class AttachmentGroupComponentsPage {
    createButton = element(by.css('.jh-create-entity'));
    title = element.all(by.css('jhi-attachment-group div h2 span')).first();

    clickOnCreateButton() {
        return this.createButton.click();
    }

    getTitle() {
        return this.title.getAttribute('jhiTranslate');
    }
}

export class AttachmentGroupDialogPage {
    modalTitle = element(by.css('h4#myAttachmentGroupLabel'));
    saveButton = element(by.css('.modal-footer .btn.btn-primary'));
    closeButton = element(by.css('button.close'));
    entityInput = element(by.css('input#field_entity'));
    createdByInput = element(by.css('input#field_createdBy'));
    createdDateInput = element(by.css('input#field_createdDate'));
    lastModifiedByInput = element(by.css('input#field_lastModifiedBy'));
    lastModifiedDateInput = element(by.css('input#field_lastModifiedDate'));

    getModalTitle() {
        return this.modalTitle.getAttribute('jhiTranslate');
    }

    setEntityInput = function(entity) {
        this.entityInput.sendKeys(entity);
    };

    getEntityInput = function() {
        return this.entityInput.getAttribute('value');
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
