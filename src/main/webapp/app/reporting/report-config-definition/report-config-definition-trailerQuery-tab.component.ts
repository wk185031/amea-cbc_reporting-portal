import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';
import { ReportDefinition } from './report-config-definition.model';

@Component({
    selector: 'report-config-definition-trailerQuery-tab',
    templateUrl: './report-config-definition-trailerQuery-tab.component.html'
})
export class ReportConfigDefinitionTrailerQueryTabComponent implements OnInit {

    @Output() onValueChange = new EventEmitter<boolean>();
    @Input() reportDefinition: ReportDefinition;
    @Input() isEdit: boolean;

    view: boolean = false;
    reportDefinitionList: ReportDefinition[];

    constructor(
    ) {
    }

    ngOnInit() {
    }

    valueChange() {
        this.onValueChange.emit(true);
    }

    resize(query, value) {
        let maxRows = query.rows;
        let cols: number = query.cols;
        let arraytxt: any = value.split('\n');
        let rows: number = arraytxt.length;

        for (let i = 0; i < arraytxt.length; i++)
            rows += arraytxt[i].length / cols;

        if (rows > maxRows) {
            query.rows = rows;
        } else {
            query.rows = maxRows;
        }
        this.valueChange();
    }
}