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
        public justifyLeft?: boolean,
        public decrypt?: boolean,
        public decryptionKey?: string,
        public fieldPadding?: string,
        public reportDefinition?: BaseEntity,

        public enablePadFieldLength?: boolean,
        public padFieldLength?: string,
        public padFieldType?: string,
        public padFieldString?: string,

        public enableDecryption?: boolean,
    ) {
    }
}
