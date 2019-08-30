import { BaseEntity } from '../../shared';
import { ReportCategory } from '../report-config-category/report-config-category.model';
import { ReportDefinition } from '../report-config-definition/report-config-definition.model';

export class ReportGeneration implements BaseEntity {
    constructor(
        public id?: number,
        public fileDate?: string,
        public txnStart?: any,
        public txnEnd?: any,
        public generate?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public reportCategory?: ReportCategory,
        public reportDefinition?: ReportDefinition
    ) {
    }
}
