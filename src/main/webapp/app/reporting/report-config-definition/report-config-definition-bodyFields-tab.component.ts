import { Component, Input, Output, EventEmitter, OnChanges } from '@angular/core';

import { ReportDefinition } from './report-config-definition.model';
import { ReportDefinitionSection } from './report-config-definition-section.model';

@Component({
    selector: 'report-config-definition-bodyFields-tab',
    templateUrl: './report-config-definition-bodyFields-tab.component.html'
})
export class ReportConfigDefinitionBodyFieldsTabComponent implements OnChanges {

    @Output() onValueChange = new EventEmitter<boolean>();
    @Input() reportDefinition: ReportDefinition;
    @Input() isEdit: boolean;

    sectionCollapsed = [0];

    fieldTypeOptions: string[] = ['String', 'Number', 'Decimal', 'Date', 'Date Time'];
    delimiterOptions: string[] = ['', ';'];
    fieldFormatOptions: string[] = ['', ',', '0.00', '#,##0.00', 'yyMMdd', 'MMddyyyy', 'MM/dd/yyyy', 'MM/dd/yy', 'dd/MM/yyyy', 'ddMMyyyy', 'yyyyMMdd', 'dd/MM/yyyy HH:mm', 'HH:mm', 'HH:mm:ss', 'HH:mm:ss a', 'hhmmss'];
    padFieldLengthOptions: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25];
    padFieldTypeOptions: string[] = ['Leading', 'Trailing'];
    padFieldValueOptions: string[] = ['Zeros', 'Spaces'];
    decryptionKeyOptions: string[] = ['', 'TRL_PAN_EKY_ID', 'TRL_ACCOUNT_1_ACN_ID_EKY_ID', 'TRL_ACCOUNT_2_ACN_ID_EKY_ID', 'TRL_CUSTOM_DATA_EKY_ID', 'CRD_PAN_EKY_ID', 'ACN_ACCOUNT_NUMBER_EKY_ID', 'DCMS_ENCRYPTION_KEY'];
    tagValueOptions: string[] = ['', 'BILLERSUBN'];

    ngOnChanges() {
        if (!this.reportDefinition.id) {
            if (!this.reportDefinition.bodySection || this.reportDefinition.bodySection.length === 0) {
                const reportDefinitionSections = new ReportDefinitionSection();
                reportDefinitionSections.sectionName = '1';
                this.reportDefinition.bodySection.push(reportDefinitionSections);
            }
        }
    }

    addSection() {
        if (!this.reportDefinition.bodySection || this.reportDefinition.bodySection.length === 0) {
            this.reportDefinition.bodySection = [];
            const reportDefinitionSections = new ReportDefinitionSection();
            reportDefinitionSections.sectionName = '1';
            reportDefinitionSections.fieldType = 'String';
            reportDefinitionSections.delimiter = '';
            reportDefinitionSections.fieldFormat = '';
            reportDefinitionSections.padFieldLength = 0;
            reportDefinitionSections.leftJustified = false;
            reportDefinitionSections.decrypt = false;
            this.reportDefinition.bodySection.push(reportDefinitionSections);
        } else {
            const reportDefinitionSections = new ReportDefinitionSection();
            reportDefinitionSections.sectionName = '' + (this.reportDefinition.bodySection.length + 1);
            reportDefinitionSections.fieldType = 'String';
            reportDefinitionSections.delimiter = '';
            reportDefinitionSections.fieldFormat = '';
            reportDefinitionSections.padFieldLength = 0;
            reportDefinitionSections.leftJustified = false;
            reportDefinitionSections.decrypt = false;
            this.reportDefinition.bodySection.push(reportDefinitionSections);
        }
        this.valueChange();
    }

    removeFromList(index: number, where: any[]) {
        where.splice(index, 1);
        this.valueChange();
    }

    moveTop(index: number, where: any[]) {
        const previousIndex = index - 1;
        if (previousIndex > -1) {
            where.splice(previousIndex, 0, where[index]);
            where.splice(index + 1, 1);
        }
    }

    moveBottom(index: number, where: any) {
        const nextIndex = index + 2;
        if (nextIndex <= where.length) {
            where.splice(nextIndex, 0, where[index]);
            where.splice(index, 1);
        }
    }

    disableRemoveContent(list: any[]) {
        if (list.length > 1) {
            return false;
        }
        return true;
    }

    collapseToggler(index: number) {
        if (this.sectionCollapsed.indexOf(index) > -1) {
            this.sectionCollapsed.splice(this.sectionCollapsed.indexOf(index), 1);
        } else {
            this.sectionCollapsed.push(index);
        }
    }

    isCollapsed(index: number) {
        if (this.sectionCollapsed.indexOf(index) > -1) {
            return 'collapse show fade';
        } else { return 'collapse fade'; }
    }

    isShowed(index: number) {
        if (this.sectionCollapsed.indexOf(index) > -1) {
            return 'btn btn-link-report-config-definition gray-first-shade btn-block text-left';
        } else { return 'btn btn-block collapsed gray-first-shade text-left'; }
    }

    itemAlternatingColour(index: number) {
        if (index % 2 === 0) {
            return ' gray-second-shade';
        } else {
            return ' gray-second-shade';
        }
    }

    stopCollapse() {
        event.stopPropagation();
    }

    valueChange() {
        this.onValueChange.emit(true);
    }

    fieldLengthChange(section: ReportDefinitionSection, field: string, event: any) {
        if (field === 'length') {
            if (event.target.value === 0) {
                section.padFieldLength = 0;
                section.padFieldType = null;
                section.padFieldValue = null;
            } else {
                section.padFieldLength = event.target.value;
                if (!section.padFieldType) {
                    section.padFieldType = 'Leading';
                }
                if (!section.padFieldValue) {
                    section.padFieldValue = 'Zeros';
                }
            }
        } else if (field === 'type') {
            section.padFieldType = event.target.value;
        } else {
            section.padFieldValue = event.target.value;
        }
        this.valueChange();
    }

    bodyHeaderValueChange(section: ReportDefinitionSection) {
        if (section.bodyHeader === true) {
            section.leftJustified = true;
        } else {
            section.leftJustified = false;
        }
        this.valueChange();
    }

    isDecrypt(section: ReportDefinitionSection) {
        if (section.decrypt === true) {
            section.decryptionKey = null;
            section.tagValue = null;
        } else {
            section.decryptionKey = null;
            section.tagValue = null;
        }
        this.valueChange();
    }
}
