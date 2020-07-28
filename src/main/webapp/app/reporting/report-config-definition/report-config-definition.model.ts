import { BaseEntity } from '../../shared';
import { ReportDefinitionSection } from './report-config-definition-section.model';
import { ReportCategory } from '../report-config-category/report-config-category.model';

export class ReportDefinition implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public description?: string,
        public fileNamePrefix?: string,
        public fileFormat?: string,
        public fileLocation?: string,
        public processingClass?: string,
        public frequency?: string,
        public generatedPathCsv?: string,
        public generatedPathTxt?: string,
        public generatedPathPdf?: string,
        public generatedFileNameCsv?: string,
        public generatedFileNameTxt?: string,
        public generatedFileNamePdf?: string,
        public headerFields?: string,
        public bodyFields?: string,
        public trailerFields?: string,
        public bodyQuery?: string,
        public trailerQuery?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public reportCategory?: ReportCategory,
        public headerSection?: ReportDefinitionSection[],
        public bodySection?: ReportDefinitionSection[],
        public trailerSection?: ReportDefinitionSection[],
        public branchFlag?: string,
        public scheduleTime?: any,
        public institutionId?: number
    ) {
    }
}
