import { BaseEntity } from '../../shared';

export class ReportCategory implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public description?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public parent?: BaseEntity
    ) {
    }
}
