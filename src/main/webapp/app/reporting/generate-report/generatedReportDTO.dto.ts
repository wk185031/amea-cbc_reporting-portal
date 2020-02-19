import { ReportCategory } from '../report-config-category/report-config-category.model';

export class GeneratedReportDTO {
    constructor(
        public reportCategory?: ReportCategory,
        public reportDate?: string,
        public reportList?: string[]
    ) {
    }
}
