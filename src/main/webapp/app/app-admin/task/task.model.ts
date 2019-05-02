import { BaseEntity } from '../../shared';
import { TaskGroup } from '../task-group';

export class Task implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public description?: string,
        public content?: string,
        public sequence?: number,
        public status?: string,
        public type?: string,
        public createdBy?: string,
        public createdDate?: any,
        public taskGroup?: TaskGroup,
    ) {
    }
}
