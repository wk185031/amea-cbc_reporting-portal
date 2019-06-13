import { BaseEntity } from '../../shared';

export class Job implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public description?: string,
        public scheduleTime?: any,
        public status?: string,
        public createdBy?: string,
        public createdDate?: any,
    ) {
    }
}
