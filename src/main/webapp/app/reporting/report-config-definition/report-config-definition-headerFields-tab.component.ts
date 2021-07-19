import { Component, Input, Output, EventEmitter, OnChanges } from '@angular/core';

import { ReportDefinition } from './report-config-definition.model';
import { ReportDefinitionSection } from './report-config-definition-section.model';

@Component({
    selector: 'report-config-definition-headerFields-tab',
    templateUrl: './report-config-definition-headerFields-tab.component.html'
})
export class ReportConfigDefinitionHeaderFieldsTabComponent implements OnChanges {

    @Output() onValueChange = new EventEmitter<boolean>();
    @Input() reportDefinition: ReportDefinition;
    @Input() isEdit: boolean

    sectionCollapsed = [0];

    fieldTypeOptions: string[] = ['String', 'Number', 'Decimal', 'Date', 'Date Time'];
    delimiterOptions: string[] = ['', ';'];
    fieldFormatOptions: string[] = ['', ',', '0.00', '#,##0.00', 'yyMMdd', 'MMddyyyy', 'MM/dd/yyyy', 'MM/dd/yy', 'dd/MM/yyyy', 'ddMMyyyy', 'dd/MM/yyyy HH:mm', 'yyyyMMdd', 'HH:mm', 'HH:mm:ss', 'HH:mm:ss a', 'hhmmss', 'HHmmss', 'dd MMM yyyy'];
    padFieldLengthOptions: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25];
    padFieldTypeOptions: string[] = ['Leading', 'Trailing'];
    padFieldValueOptions: string[] = ['Zeros', 'Spaces'];

    ngOnChanges() {
        if (!this.reportDefinition.id) {
            if (!this.reportDefinition.headerSection || this.reportDefinition.headerSection.length === 0) {
                const reportDefinitionSections = new ReportDefinitionSection();
                reportDefinitionSections.sectionName = '1';
                this.reportDefinition.headerSection.push(reportDefinitionSections);
            }
        }
    }

    addSection() {
        if (!this.reportDefinition.headerSection || this.reportDefinition.headerSection.length === 0) {
            this.reportDefinition.headerSection = [];
            const reportDefinitionSections = new ReportDefinitionSection();
            reportDefinitionSections.sectionName = '1';
            reportDefinitionSections.fieldType = 'String';
            reportDefinitionSections.delimiter = '';
            reportDefinitionSections.fieldFormat = '';
            reportDefinitionSections.padFieldLength = 0;
            reportDefinitionSections.leftJustified = true;
            this.reportDefinition.headerSection.push(reportDefinitionSections);
        } else {
            const reportDefinitionSections = new ReportDefinitionSection();
            reportDefinitionSections.sectionName = '' + (this.reportDefinition.headerSection.length + 1);
            reportDefinitionSections.fieldType = 'String';
            reportDefinitionSections.delimiter = '';
            reportDefinitionSections.fieldFormat = '';
            reportDefinitionSections.padFieldLength = 0;
            reportDefinitionSections.leftJustified = true;
            this.reportDefinition.headerSection.push(reportDefinitionSections);
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
}
