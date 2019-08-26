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
        public leftJustified?: boolean,
        public padFieldLength?: number,
        public padFieldType?: string,
        public padFieldValue?: string,
        public decrypt?: boolean,
        public decryptionKey?: string,
        public tagValue?: string,
        public reportDefinition?: BaseEntity
    ) {
    }
}
