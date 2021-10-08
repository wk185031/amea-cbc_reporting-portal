import { BaseEntity } from '../../shared';
import { Job } from '../job/job.model';

export class JobHistory implements BaseEntity {
    constructor(
        public id?: number,
        public job?: Job,
        public status?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any
    ) {
    }
}
