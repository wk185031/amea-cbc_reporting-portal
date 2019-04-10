import { BaseEntity } from './../../shared';

export class ReportDefinitionSection implements BaseEntity {
    constructor(
        public id?: number,
        public sequence?: number,
        public sectionName?: string,
        public fieldName?: string,
        public csvTxtLength?: number,
        public pdfLength?: number,
        public fieldType?: string,
        public delimiter?: string,
        public fieldFormat?: string,
        public defaultValue?: string,
        public firstField?: boolean,
        public bodyHeader?: boolean,
        public eol?: boolean,
        public reportDefinition?: BaseEntity,
    ) {
    }
}
