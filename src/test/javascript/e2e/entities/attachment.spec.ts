import { browser, element, by } from 'protractor';
import { NavBarPage } from './../page-objects/jhi-page-objects';

describe('Attachment e2e test', () => {

    let navBarPage: NavBarPage;
    let attachmentDialogPage: AttachmentDialogPage;
    let attachmentComponentsPage: AttachmentComponentsPage;

    beforeAll(() => {
        browser.get('/');
        browser.waitForAngular();
        navBarPage = new NavBarPage();
        navBarPage.getSignInPage().autoSignInUsing('admin', 'admin');
        browser.waitForAngular();
    });

    it('should load Attachments', () => {
        navBarPage.goToEntity('attachment');
        attachmentComponentsPage = new AttachmentComponentsPage();
        expect(attachmentComponentsPage.getTitle())
            .toMatch(/baseApp.attachment.home.title/);

    });

    it('should load create Attachment dialog', () => {
        attachmentComponentsPage.clickOnCreateButton();
        attachmentDialogPage = new AttachmentDialogPage();
        expect(attachmentDialogPage.getModalTitle())
            .toMatch(/baseApp.attachment.home.createOrEditLabel/);
        attachmentDialogPage.close();
    });

   /* it('should create and save Attachments', () => {
        attachmentComponentsPage.clickOnCreateButton();
        attachmentDialogPage.setNameInput('name');
        expect(attachmentDialogPage.getNameInput()).toMatch('name');
        attachmentDialogPage.setTypeInput('type');
        expect(attachmentDialogPage.getTypeInput()).toMatch('type');
        attachmentDialogPage.setCreatedByInput('createdBy');
        expect(attachmentDialogPage.getCreatedByInput()).toMatch('createdBy');
        attachmentDialogPage.setCreatedDateInput(12310020012301);
        expect(attachmentDialogPage.getCreatedDateInput()).toMatch('2001-12-31T02:30');
        attachmentDialogPage.setLastModifiedByInput('lastModifiedBy');
        expect(attachmentDialogPage.getLastModifiedByInput()).toMatch('lastModifiedBy');
        attachmentDialogPage.setLastModifiedDateInput(12310020012301);
        expect(attachmentDialogPage.getLastModifiedDateInput()).toMatch('2001-12-31T02:30');
        attachmentDialogPage.attachmentGroupSelectLastOption();
        attachmentDialogPage.save();
        expect(attachmentDialogPage.getSaveButton().isPresent()).toBeFalsy();
    });*/

    afterAll(() => {
        navBarPage.autoSignOut();
    });
});

export class AttachmentComponentsPage {
    createButton = element(by.css('.jh-create-entity'));
    title = element.all(by.css('jhi-attachment div h2 span')).first();

    clickOnCreateButton() {
        return this.createButton.click();
    }

    getTitle() {
        return this.title.getAttribute('jhiTranslate');
    }
}

export class AttachmentDialogPage {
    modalTitle = element(by.css('h4#myAttachmentLabel'));
    saveButton = element(by.css('.modal-footer .btn.btn-primary'));
    closeButton = element(by.css('button.close'));
    nameInput = element(by.css('input#field_name'));
    typeInput = element(by.css('input#field_type'));
    createdByInput = element(by.css('input#field_createdBy'));
    createdDateInput = element(by.css('input#field_createdDate'));
    lastModifiedByInput = element(by.css('input#field_lastModifiedBy'));
    lastModifiedDateInput = element(by.css('input#field_lastModifiedDate'));
    attachmentGroupSelect = element(by.css('select#field_attachmentGroup'));

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
