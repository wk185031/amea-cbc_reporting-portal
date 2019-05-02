import { BaseEntity } from '../../shared';
import { Job } from '../job';

export class TaskGroup implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public description?: string,
        public status?: string,
        public createdBy?: string,
        public createdDate?: any,
        public job?: Job,
    ) {
    }
}
