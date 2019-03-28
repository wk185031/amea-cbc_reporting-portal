import { BaseEntity } from './../../shared';

export class ReportDefinitionSection implements BaseEntity {
    constructor(
        public id?: number,
        public sequence?: number,
        public name?: string,
        public fieldName?: string,
        public fieldLengthCsvTxt?: number,
        public fieldLengthPdf?: number,
        public fieldType?: string,
        public fieldDelimiter?: string,
        public fieldDefaultValue?: string,
        public fieldfirst?: boolean,
        public fieldBodyHeader?: boolean,
        public fieldEndOfLine?: boolean,
        public fieldEndOfBodyHeader?: boolean,
        public reportDefinition?: BaseEntity,
    ) {
    }
}
