import { BaseEntity } from './../../shared';

export class SystemConfiguration implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public description?: string,
        public config?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
    ) {
    }
}
