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

    fieldTypeOptions: string[] = ['String', 'Number', 'Decimal', 'Date'];
    fieldLengthTypeOptions: string[] = ['Leading', 'Trailing'];
    padFieldLength: string;
    fieldLengthType: string;
    padFieldString: string;

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
            reportDefinitionSections.padFieldLength = null;
            reportDefinitionSections.justifyLeft = false;
            reportDefinitionSections.enablePadFieldLength = false;
            reportDefinitionSections.decrypt = false;
            reportDefinitionSections.enableDecryption = false;
            this.reportDefinition.bodySection.push(reportDefinitionSections);
        } else {
            const reportDefinitionSections = new ReportDefinitionSection();
            reportDefinitionSections.sectionName = '' + (this.reportDefinition.bodySection.length + 1);
            reportDefinitionSections.fieldType = 'String';
            reportDefinitionSections.padFieldLength = null;
            reportDefinitionSections.justifyLeft = false;
            reportDefinitionSections.enablePadFieldLength = false;
            reportDefinitionSections.decrypt = false;
            reportDefinitionSections.enableDecryption = false;
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
        if (field == 'length') {
            if (event.target.value == '') {
                section.enablePadFieldLength = false;
                section.padFieldLength = null;
                section.padFieldType = null;
                section.padFieldString = null;
            } else {
                section.enablePadFieldLength = true;
                if (!section.padFieldType) {
                    section.padFieldType = 'Leading';
                }
                if (!section.padFieldString) {
                    section.padFieldString = null;
                }
            }
        } else if (field == 'type') {
            section.padFieldType = event.target.value;
        }
        this.valueChange();
    }

    bodyHeaderValueChange(section: ReportDefinitionSection) {
        if (section.bodyHeader == true) {
            section.justifyLeft = true;
        } else {
            section.justifyLeft = false;
        }
        this.valueChange();
    }

    isDecrypt(section: ReportDefinitionSection) {
        if (section.decrypt == true) {
            section.enableDecryption = true;
            section.decryptionKey = null;
        } else {
            section.enableDecryption = false;
            section.decryptionKey = null;
        }
        this.valueChange();
    }
}
