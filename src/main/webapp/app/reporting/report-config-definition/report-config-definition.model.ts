import { BaseEntity } from '../../shared';
import { ReportDefinitionSection } from './report-config-definition-section.model';

export class ReportDefinition implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public description?: string,
        public fileNamePrefix?: string,
        public fileFormat?: string,
        public fileLocation?: string,
        public processingClass?: string,
        public headerFields?: string,
        public bodyFields?: string,
        public trailerFields?: string,
        public query?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public reportCategory?: BaseEntity,
        public headerSection?: ReportDefinitionSection[],
        public bodySection?: ReportDefinitionSection[],
        public trailerSection?: ReportDefinitionSection[]
    ) {
    }
}
